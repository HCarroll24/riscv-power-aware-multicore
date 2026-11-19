"""
**************************************************************************
 File:      make_power_vcds.py
 Project:   RISC-V Power Aware
 Author:    carrollh@msoe.edu <Hunter C>
 Date:      18 November 2026
 Provides:
    Builds the gate-level VCDs for every isolation config and every
    power benchmark, so the Quartus Power Analyzer can be run on them.

    Configs (one Quartus revision each, so each keeps its own fit):
        none   pw_none   SH_ISOLATE=false  BR_COMP_ISOLATE=false  (baseline)
        sh     pw_sh     SH_ISOLATE=true   BR_COMP_ISOLATE=false
        br     pw_br     SH_ISOLATE=false  BR_COMP_ISOLATE=true
        both   pw_both   SH_ISOLATE=true   BR_COMP_ISOLATE=true

    For each config:
      1. compile the revision once (synthesis + fit + EDA netlist)
      2. for each program:
           a. copy programs/power/<prog>.mif to benchmarks/irom.mif
           b. RTL sim (tb_multicorecpu markers) for the window + checksum
           c. update_mif + EDA netlist, so the gate netlist has the
              new ROM contents without changing the fit
           d. gate-level sim of the .vo, dumping every node to a VCD

 Outputs:
    sim/vcd/<config>/<prog>.vcd
    sim/vcd/windows.csv   window start/end per run, for the
                          Power Analyzer's "Limit VCD period"
    sim/vcd/logs/         every Quartus and Questa log

 Usage (from anywhere, Git Bash or cmd):
    python scripts/make_power_vcds.py
    python scripts/make_power_vcds.py --configs sh,both --programs power_alu
    python scripts/make_power_vcds.py --skip-compile
    python scripts/make_power_vcds.py --full-compile-each

 Needs:
    quartus_sh, quartus_cdb, quartus_eda and vsim on PATH, or the
    default install under C:/altera_pro/25.1.
**************************************************************************
"""

import argparse
import csv
import hashlib
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

# ----------------------------------------------------------------------
# Project layout
# ----------------------------------------------------------------------
def find_root():
    """Walk up from this script to the repo root (the folder with quartus/, sim/, rtl/)."""
    here = Path(__file__).resolve().parent
    for folder in [here] + list(here.parents):
        if (folder / "quartus").is_dir() and (folder / "sim").is_dir() and (folder / "rtl").is_dir():
            return folder
    sys.exit("error: cannot find the repo root (quartus/, sim/, rtl/) above " + str(here))


ROOT = find_root()
QUARTUS_DIR = ROOT / "quartus"
SIM_DIR = ROOT / "sim"
NETLIST_DIR = QUARTUS_DIR / "simulation" / "questa"
IROM_MIF = ROOT / "benchmarks" / "irom.mif"
PROG_DIR = ROOT / "programs" / "power"
OUT_DIR = SIM_DIR / "vcd"
LOG_DIR = OUT_DIR / "logs"

PROJECT = "multicorecpu"
MAIN_QSF = QUARTUS_DIR / (PROJECT + ".qsf")
QPF = QUARTUS_DIR / (PROJECT + ".qpf")

# name: (revision, SH_ISOLATE, BR_COMP_ISOLATE)
CONFIGS = {
    "none": ("pw_none", False, False),
    "sh":   ("pw_sh",   True,  False),
    "br":   ("pw_br",   False, True),
    "both": ("pw_both", True,  True),
}

PROGRAMS = ["power_spin", "power_alu", "power_mem", "power_branch", "power_chase"]

# default install, used when a tool is not on PATH
QUARTUS_BIN = Path("C:/altera_pro/25.1/quartus/bin64")
QUESTA_BIN = Path("C:/altera_pro/25.1/questa_fse/win64")
QUESTA_LIB = "C:/altera_pro/25.1/questa_fse/intel/verilog"

RTL_RUN_CAP = "10 ms"     # RTL sim gives up after this
GATE_MARGIN_NS = 1000     # gate sim runs this far past WINDOW END

# per-revision power assignments are dropped from the copied qsf, so a
# revision never points the Power Analyzer at another config's VCD
STRIP_FROM_REVISION = re.compile(
    r"POWER_INPUT_FILE_NAME|POWER_VCD_FILE_START_TIME|"
    r"POWER_VCD_FILE_END_TIME|POWER_READ_INPUT_FILE")


# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------
def find_tool(name, fallback_dir):
    """Return the full path of a tool: PATH first, then the install dir."""
    found = shutil.which(name)
    if found:
        return found
    for candidate in (fallback_dir / (name + ".exe"), fallback_dir / name):
        if candidate.exists():
            return str(candidate)
    sys.exit("error: cannot find " + name + " (add it to PATH)")


def run(cmd, cwd, log_name):
    """Run a command, save its output to a log, stop the script on failure."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_path = LOG_DIR / log_name
    print("    $ " + " ".join(str(c) for c in cmd))
    start = time.time()
    result = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True,
                            errors="replace")
    log_path.write_text(result.stdout)
    print("      done in %.0f s, log: %s" % (time.time() - start, log_path.name))
    if result.returncode != 0:
        sys.exit("error: command failed, see " + str(log_path))
    return result.stdout


def to_ns(value, unit):
    """Convert a VHDL time'image value to nanoseconds."""
    scale = {"fs": 1e-6, "ps": 1e-3, "ns": 1.0, "us": 1e3, "ms": 1e6}
    return float(value) * scale[unit]


def parse_window(transcript):
    """Pull WINDOW START, CHECKSUM and WINDOW END out of a Questa transcript."""
    time_re = r"\s+([\d.]+)\s*(fs|ps|ns|us|ms)"
    start = re.search(r"WINDOW START" + time_re, transcript)
    end = re.search(r"WINDOW END" + time_re, transcript)
    checksum = re.search(r"CHECKSUM\s+([0-9A-Fa-f]{8})", transcript)
    if start is None or end is None or checksum is None:
        return None
    return {
        "start_ns": to_ns(start.group(1), start.group(2)),
        "end_ns": to_ns(end.group(1), end.group(2)),
        "checksum": checksum.group(1).upper(),
    }


def rom_hash(vo_path):
    """Hash every mem_init string in the netlist (changes when the ROM does)."""
    text = vo_path.read_text(errors="replace")
    inits = re.findall(r'\.mem_init\d+\s*\(\s*"([^"]*)"', text)
    return hashlib.sha1("".join(inits).encode()).hexdigest()


# ----------------------------------------------------------------------
# Quartus revisions
# ----------------------------------------------------------------------
def make_revisions(configs):
    """Create pw_<config>.qsf from the main qsf and list them in the qpf."""
    main_lines = MAIN_QSF.read_text().splitlines()
    for name in configs:
        rev, sh, br = CONFIGS[name]
        qsf = QUARTUS_DIR / (rev + ".qsf")
        lines = []
        for line in main_lines:
            if not STRIP_FROM_REVISION.search(line):
                lines.append(line)
        lines.append("")
        lines.append("# isolation config for this revision (make_power_vcds.py)")
        lines.append("set_parameter -name SH_ISOLATE " + str(sh).lower())
        lines.append("set_parameter -name BR_COMP_ISOLATE " + str(br).lower())
        qsf.write_text("\n".join(lines) + "\n")

    # list every revision, keep the main one last so it stays the default
    qpf_lines = []
    for line in QPF.read_text().splitlines():
        if not line.startswith("PROJECT_REVISION"):
            qpf_lines.append(line)
    for name in configs:
        qpf_lines.append('PROJECT_REVISION = "' + CONFIGS[name][0] + '"')
    qpf_lines.append('PROJECT_REVISION = "' + PROJECT + '"')
    QPF.write_text("\n".join(qpf_lines) + "\n")


def find_netlist(rev):
    """The EDA netlist and VCD node script Quartus wrote for a revision."""
    vo = NETLIST_DIR / (rev + ".vo")
    tcl = NETLIST_DIR / (rev + "_dump_all_vcd_nodes.tcl")
    if not vo.exists() or not tcl.exists():
        sys.exit("error: no gate netlist for " + rev + " in " + str(NETLIST_DIR) +
                 " (check the EDA Netlist Writer settings)")
    return vo, tcl


# ----------------------------------------------------------------------
# Questa
# ----------------------------------------------------------------------
def rtl_window(vsim, config, prog):
    """RTL sim with the testbench markers, at this config's generics."""
    rev, sh, br = CONFIGS[config]
    compile_do = (SIM_DIR / "compile.do").read_text()

    # reuse compile.do, but give vsim this config's generics
    generics = " -gSH_ISOLATE=" + str(sh).lower() + \
               " -gBR_COMP_ISOLATE=" + str(br).lower()
    lines = []
    for line in compile_do.splitlines():
        if line.strip().startswith("vsim "):
            line = line.replace("vsim ", "vsim" + generics + " ", 1)
        lines.append(line)
    lines.append("run " + RTL_RUN_CAP)
    lines.append("quit -f")

    do_file = SIM_DIR / "_rtl_window.do"
    do_file.write_text("\n".join(lines) + "\n")
    out = run([vsim, "-c", "-do", do_file.name], SIM_DIR,
              "rtl_" + config + "_" + prog + ".log")

    window = parse_window(out)
    if window is None:
        sys.exit("error: no WINDOW START / CHECKSUM / WINDOW END for " + prog +
                 ". The testbench needs the checksum (0xFF2000F4) written"
                 " BEFORE the done marker (0xFF2000F0 = 2). Check bench_done()"
                 " in programs/power/bench.h.")
    return window


def gate_vcd(vsim, config, prog, vo, tcl, run_ns):
    """Gate-level sim of the netlist, every node dumped to a VCD."""
    rev = CONFIGS[config][0]
    lib = "gate_" + rev
    lines = [
        "vlib " + lib,
        "vmap tennm " + QUESTA_LIB + "/tennm",
        "vmap altera_lnsim " + QUESTA_LIB + "/altera_lnsim",
        "vmap altera_ver " + QUESTA_LIB + "/altera",
        "vlog -work " + lib + " " + vo.as_posix(),
        "vsim -t ps -voptargs=+acc -L tennm -L altera_lnsim -L altera_ver " +
        lib + ".MULTICORECPU",
        "force -freeze CLK 0 0, 1 10ns -repeat 20ns",
        "force -freeze KEY 1111",
        "force -freeze SW 0000000000",
        "source " + tcl.as_posix(),
        "run %d ns" % run_ns,
        "vcd flush",
        "quit -sim",
        "quit -f",
    ]
    do_file = SIM_DIR / "_gate_vcd.do"
    do_file.write_text("\n".join(lines) + "\n")

    started = time.time()
    run([vsim, "-c", "-do", do_file.name], SIM_DIR,
        "gate_" + config + "_" + prog + ".log")

    # the node script names the VCD after the revision; take the one just written
    written = []
    for vcd in SIM_DIR.glob("*.vcd"):
        if vcd.stat().st_mtime >= started:
            written.append(vcd)
    if len(written) != 1:
        sys.exit("error: expected one new VCD in sim/, found " + str(len(written)))

    dest = OUT_DIR / config / (prog + ".vcd")
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(written[0]), str(dest))
    return dest


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Build power VCDs per isolation config.")
    parser.add_argument("--configs", default="none,sh,br,both",
                        help="comma list from: none, sh, br, both")
    parser.add_argument("--programs", default=",".join(PROGRAMS),
                        help="comma list of programs in programs/power/")
    parser.add_argument("--skip-compile", action="store_true",
                        help="reuse each revision's existing fit")
    parser.add_argument("--full-compile-each", action="store_true",
                        help="full compile per program instead of update_mif")
    args = parser.parse_args()

    configs = [c.strip() for c in args.configs.split(",") if c.strip()]
    programs = [p.strip() for p in args.programs.split(",") if p.strip()]
    for c in configs:
        if c not in CONFIGS:
            sys.exit("error: unknown config " + c)
    for p in programs:
        if not (PROG_DIR / (p + ".mif")).exists():
            sys.exit("error: missing " + str(PROG_DIR / (p + ".mif")))

    quartus_sh = find_tool("quartus_sh", QUARTUS_BIN)
    quartus_cdb = find_tool("quartus_cdb", QUARTUS_BIN)
    quartus_eda = find_tool("quartus_eda", QUARTUS_BIN)
    vsim = find_tool("vsim", QUESTA_BIN)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    make_revisions(configs)
    original_irom = IROM_MIF.read_bytes()
    rows = []

    try:
        for config in configs:
            rev = CONFIGS[config][0]
            print("\n=== config " + config + " (revision " + rev + ")")

            # one fit per config, built with the first program in the ROM
            shutil.copyfile(PROG_DIR / (programs[0] + ".mif"), IROM_MIF)
            if not args.skip_compile:
                run([quartus_sh, "--flow", "compile", PROJECT, "-c", rev],
                    QUARTUS_DIR, "compile_" + config + ".log")

            last_hash = None
            for index, prog in enumerate(programs):
                print("  -- " + prog)
                shutil.copyfile(PROG_DIR / (prog + ".mif"), IROM_MIF)

                window = rtl_window(vsim, config, prog)
                print("      window %.0f - %.0f ns, checksum %s"
                      % (window["start_ns"], window["end_ns"], window["checksum"]))

                # put this program's ROM contents into the gate netlist
                if args.full_compile_each and index > 0:
                    run([quartus_sh, "--flow", "compile", PROJECT, "-c", rev],
                        QUARTUS_DIR, "compile_" + config + "_" + prog + ".log")
                elif index > 0:
                    run([quartus_cdb, PROJECT, "-c", rev, "--update_mif"],
                        QUARTUS_DIR, "update_mif_" + config + "_" + prog + ".log")
                run([quartus_eda, PROJECT, "-c", rev],
                    QUARTUS_DIR, "eda_" + config + "_" + prog + ".log")

                vo, tcl = find_netlist(rev)
                this_hash = rom_hash(vo)
                if this_hash == last_hash:
                    sys.exit("error: the gate netlist ROM did not change for " + prog +
                             ". update_mif did not take; rerun with --full-compile-each.")
                last_hash = this_hash

                run_ns = int(window["end_ns"]) + GATE_MARGIN_NS
                vcd = gate_vcd(vsim, config, prog, vo, tcl, run_ns)
                size_mb = vcd.stat().st_size / 1e6
                print("      wrote %s (%.0f MB)" % (vcd.relative_to(ROOT), size_mb))

                rows.append({
                    "config": config,
                    "revision": rev,
                    "program": prog,
                    "vcd": vcd.relative_to(ROOT).as_posix(),
                    "start_ns": "%.0f" % window["start_ns"],
                    "end_ns": "%.0f" % window["end_ns"],
                    "cycles": "%.0f" % ((window["end_ns"] - window["start_ns"]) / 20.0),
                    "checksum": window["checksum"],
                })
    finally:
        IROM_MIF.write_bytes(original_irom)
        if rows:
            with open(OUT_DIR / "windows.csv", "w", newline="") as f:
                writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
                writer.writeheader()
                writer.writerows(rows)

    # isolation must not change timing or results: same cycles and
    # checksum for a program in every config
    print("\n=== cross-config check")
    ok = True
    for prog in programs:
        runs = [r for r in rows if r["program"] == prog]
        cycles = set(r["cycles"] for r in runs)
        sums = set(r["checksum"] for r in runs)
        if len(cycles) == 1 and len(sums) == 1:
            print("  %-13s OK  %s cycles, checksum %s"
                  % (prog, cycles.pop(), sums.pop()))
        else:
            ok = False
            print("  %-13s MISMATCH  cycles %s  checksums %s"
                  % (prog, sorted(cycles), sorted(sums)))
    print("\nwindows: " + str((OUT_DIR / "windows.csv").relative_to(ROOT)))
    if not ok:
        sys.exit("error: configs disagree; isolation changed behavior")


if __name__ == "__main__":
    main()
