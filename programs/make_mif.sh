#!/usr/bin/env bash
# ======================================================================
# programs/make_mif.sh
#
# One step from a C file to the IROM .mif.
#
#   ./make_mif.sh test_prog.c
#   ./make_mif.sh power/power_spin.c
#
# Run it from anywhere; paths are relative to where you are.
#
# Writes, next to the .c file:
#   <name>.elf   linked program
#   <name>.lst   disassembly (check _start is at address 0)
#   <name>.bin   raw machine code
#   <name>.mif   ROM image
# and copies <name>.mif to benchmarks/irom.mif, the file the ROM IP
# loads in Quartus and in simulation.
#
# Uses programs/crt0.S, programs/link.ld and programs/bin2mif.py.
# The compiler flags are fixed: every program, every build, the same.
# ======================================================================
set -e

if [ -z "$1" ]; then
    echo "usage: ./make_mif.sh <file.c>"
    exit 1
fi

SRC="$1"
if [ ! -f "$SRC" ]; then
    echo "error: $SRC not found"
    exit 1
fi

# folder this script lives in (programs/) and the repo root above it
PROGRAMS="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$PROGRAMS/.." && pwd)"

DIR="$(dirname "$SRC")"
NAME="$(basename "$SRC" .c)"
OUT="$DIR/$NAME"

# Windows usually has "python", Linux/macOS "python3"
if command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    PYTHON=python3
fi

CFLAGS="-march=rv32i -mabi=ilp32 -O2 -std=c11 -Wall -Wextra \
        -ffreestanding -fno-builtin -nostdlib -nostartfiles \
        -fno-jump-tables -fno-tree-switch-conversion \
        -fno-tree-loop-distribute-patterns"

echo "creating assembly for $SRC"
riscv-none-elf-gcc $CFLAGS $EXTRA -I "$PROGRAMS" -I "$DIR" \
    -T "$PROGRAMS/link.ld" "$PROGRAMS/crt0.S" "$SRC" -lgcc -S "$OUT.s"

echo "compiling $SRC"
riscv-none-elf-gcc $CFLAGS $EXTRA -I "$PROGRAMS" -I "$DIR" \
    -T "$PROGRAMS/link.ld" "$PROGRAMS/crt0.S" "$SRC" -lgcc -o "$OUT.elf"

riscv-none-elf-objdump -d "$OUT.elf" > "$OUT.lst"
riscv-none-elf-objcopy -O binary -j .text "$OUT.elf" "$OUT.bin"
"$PYTHON" "$PROGRAMS/bin2mif.py" "$OUT.bin" "$OUT.mif"

mkdir -p "$ROOT/benchmarks"
cp "$OUT.mif" "$ROOT/benchmarks/irom.mif"
echo "copied $OUT.mif to benchmarks/irom.mif"
