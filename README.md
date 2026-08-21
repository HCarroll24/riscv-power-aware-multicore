# A Power-Aware and Reconfigurable Multicore RISC-V Processor

Undergraduate research project | Milwaukee School of Engineering | Hunter Carroll

**Stack:** VHDL | Intel Quartus Prime | ModelSim | Cyclone IV E | RV32I

Research project exploreing whether a multicore RISCV CPU can detect workload changes
and reconfigure hardware at runtime for reduction of energy, comparing against an 
identical adaptation disables design.

**Current** Working 5-stage pipeline with stall, forwarding, hazard detection,
and a 17-entry 2-bit saturating BHT.

---

## Skills demonstrated
 - RTL design in **VHDL** for a RV32I 5-stage pipeline
 - Hazard detection with stall and flush control
 - Operand forwarding
 - Dynamic branch prediction: 16-entry BHT, 2-bit saturating counter
 - FPGA toolchain: Quartus Prime Lite, ModelSIM ASE, Cyclone IV E
 - Research framing for power-aware / reconfigurable computer architecture

## Motivation

Modern architectures push IPC via parallelism. After Dennard scaling stalled, MIMD
multicore processors became the dominant design which drove work on interconnects
and power management. Reconfigurable hardware (FPGAs/CPLDs) are also able to reshape
performance and power at runtime (DVFS, clock gating), but voltage/frequency tradeoffs
cut performance when saving power.

Power-aware computing sits in the middle of CPUs and reconfigurable logic: software and
hardware techniques that go beyond simple V/f scaling (static pipeline, activity prediction,
adaptable pipelines, power gating, smarter scheduling).

## Research questions

Can a multicore RISC-V processor dynamically adapt its hardware
configuration based on behavior and use less energy compared to a static design while
keeping acceptable performance?

1. Which runtime metrics best signal power-saving opportunities?
2. Which adaptations are practical on FPGA?
3. What energy savings and performance costs do adaptation introduce to the design?

---

## Current state

| Component | State |
|---|---|
| RV32I 5-stage pipeline (IF/ID/EX/MEM/WB) | Implemented, synthesizes cleanly |
| ALU, register file, control unit, immediate generator | Implemented |
| Hazard detection and operand forwarding | Implemented |
| Branch prediction (BHT, target calculation, comparator) | Implemented |
| Self-checking testbenches | Not started |
| Timing constraints (`.sdc`) | Not written |
| FPGA hardware validation | Not started |
| Benchmark suite | Not started |
| Dual-core extension | Not started |
| Hardware performance counters | Not started |
| Reconfiguration controller | Not started |
| Experimental results | None collected |

Verification so far is waveform inspection in simulation--not a golden model or
directed self-checking suite.

---

## Architecture

Classic five-stage pipeline implementing the RV32I base integer instruction set.

```
    IF              ID                EX              MEM           WB
 ┌────────┐    ┌──────────┐     ┌────────────┐    ┌─────────┐   ┌──────────┐
 │ PC     │───▶│ decode   │────▶│ ALU        │───▶│ data    │──▶│ register │
 │ instr  │    │ regfile  │     │ branch cmp │    │ memory  │   │ writeback│
 │ memory │    │ imm gen  │     │ forwarding │    │ access  │   │          │
 └────────┘    └──────────┘     └────────────┘    └─────────┘   └──────────┘
     ▲              │                  │
     │              ▼                  │
     │      hazard detection ──────────┘
     │      (stall / flush)
     └──── branch prediction (BHT + target calculation)
```
### Implemented mechanisms
 - **Hazards:** detecting load-use and control hazards; stalling and flush enabled
 - **Forwarding:** bypass EX/MEM/WB results into EX for avoiding stall
 - **Branches:** 16-entry BHT with 2-bit saturating counters


## Planned evaluation

Once dual-core and adaptation logic exist, two buidls will run same forzen benchmark
suite:

| Build | Description |
|---|---|
| **Control** | Static dual-core |
| **Experimental** | Same base design plus counters, workload profiler, and reconfiguration |

**Candidate adaptation** (narrowed down by benefit on FPGA)
 - Function-unit gating
 - Clock-gating / core parking
 - Scheduling informed by per-core utilization

**Metrics:** execution time, IPC/CPI, stalls and branch behavior, FPGA resources, Fmax,
power/energy per instruction.

---

## Repository layout

```
quartus/             Quartus project (.qpf/.qsf); build output generated here
rtl/
  *.bdf              stage-level structural hierarchy
  core/              functional units and memory interfaces
  pipeline/          pipeline registers and stage control
  multicore/         dual-core interconnect and shared memory      (empty)
  power_management/  counters, profiler, reconfiguration controller (empty)
  packages/          shared types and constants                     (empty)
papers/              Literature Review and proposals
```

---

## Building

**Toolchain:** Intel Quartus Prime Lite 18.1, ModelSim ASE 18.1, targeting a
Cyclone IV E device.

```
Open quartus/multicorecpu.qpf in Quartus
Processing → Start → Start Analysis & Elaboration
Processing → Start Compilation
```

The `.qsf` uses relative paths so the project builds on any machine with a matching
Quartus.
---

## Current limitations

 - **No '.sdc'**
 - **No systematic verification**
 - **Schematic hierarchy**
 - **Simulation only**

---

## Results

None yet.

---

## Goals

1. FPGA implementation of a power-aware, reconfigurable multicore RISC-V
2. Runtime workload classification suitable for on-chip adaptation
3. Controlled comparison of adaptive vs static builds under a frozen suite

---

## License

MIT — see [`LICENSE`](LICENSE).
