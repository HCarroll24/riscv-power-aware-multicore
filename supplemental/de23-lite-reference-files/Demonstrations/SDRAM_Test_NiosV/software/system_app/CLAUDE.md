# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Intel FPGA Nios V embedded system project for SDRAM testing on an Agilex 3 FPGA development board. The system consists of:

- **system_app/**: Main application that runs SDRAM tests
- **system_bsp/**: Board Support Package (BSP) containing HAL drivers and system configuration

## Architecture

### Hardware Platform
- **FPGA**: Agilex 3 (specified in system.h:132)
- **Processor**: Intel Nios V/g RISC-V core running at 80MHz
- **Memory**: 64MB SDRAM (configurable via EXTERNAL_MEMORY_SPAN = 67108864 bytes)
- **On-chip Memory**: 512KB for code storage
- **I/O**: JTAG UART for console, 4 push buttons, 10 LEDs, 10 switches, PIO interfaces

### Memory Map
- SDRAM Base: 0x4000000 (64MB span, configurable via EXTERNAL_MEMORY_BASE)
- On-chip Memory: 0x100000 (512KB span) 
- JTAG UART: 0x80448
- Push Buttons (PIO_KEY): 0x80410
- LEDs (PIO_LED): 0x80420 (10-bit)
- Switches (PIO_SW): 0x80430 (10-bit)

### Software Architecture
The application (`main.c:81-96`) provides a menu-driven interface for memory testing:
- Full memory test with comprehensive verification using rotating data patterns (32 different patterns)
- Quick memory test using pattern-based verification with 32-bit data width and 24-bit address width (word addressing)
- Memory test utilities in `mem_verify.c`

## Build System

### CMake Configuration
- **Toolchain**: RISC-V GCC (`riscv32-unknown-elf-gcc`)
- **Target**: `memory_test.elf` executable
- **Architecture**: RISC-V RV32IM with Zicbom extension
- **Build outputs**: ELF file, objdump, stack report, HEX file for on-chip memory

### Common Build Commands

```bash
# Build the project (run from system_app directory)
cd build/Default
make

# Or using CMake directly
cmake --build build/Default

# Generate BSP (run from system_bsp directory)  
update_bsp.bat
# Or manually:
%QUARTUS_ROOTDIR%\..\niosv\bin\niosv-shell.exe --run "niosv-bsp -g -b=./ settings.bsp"
```

### Build Artifacts
- `memory_test.elf` - Main executable
- `memory_test.elf.objdump` - Disassembly listing  
- `intel_onchip_memory.hex` - HEX file for FPGA programming
- Stack usage reports generated automatically

## Key Components

### Memory Testing (`mem_verify.c`)
- `TMEM_Verify()`: Comprehensive memory test with pattern generation
- `TMEM_QuickVerify()`: Fast pattern-based memory test
- Tests use pseudo-random data patterns and boundary conditions

### System Configuration (`system.h`)
- Auto-generated hardware configuration file
- Defines memory base addresses, IRQ assignments, and peripheral settings
- **Never modify** - regenerated from Quartus Platform Designer

### BSP Structure
- **HAL/**: Hardware Abstraction Layer with Intel FPGA APIs
- **drivers/**: Peripheral drivers (UART, PIO, Timer, etc.)
- **toolchain.cmake**: Cross-compilation setup for RISC-V

## Development Workflow

1. Modify application code in `system_app/`
2. If hardware changes made in Platform Designer, regenerate BSP with `update_bsp.bat`
3. Build using CMake from `build/Default/`
4. Program FPGA and download `memory_test.elf` via JTAG debugging tools

## Hardware Interface

### User Interface
- **Buttons**: 4 push buttons for test control (active low)
  - Button 0: Start continuous testing mode
  - Any button: Start single test or abort continuous test
- **Console**: JTAG UART for menu interface and test results

### Test Operations
- Full test: Comprehensive write/read verification of entire SDRAM space
- Quick test: Pattern-based testing with configurable data width (32-bit) and address width (28-bit)
- Both tests provide timing information and pass/fail results