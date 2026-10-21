cmake_minimum_required(VERSION 3.14)

add_subdirectory(../system_bsp system_bsp)

include(../system_bsp/toolchain.cmake)

project(memory_test)

enable_language(ASM)
enable_language(C)
enable_language(CXX)

add_executable(memory_test.elf)

target_sources(memory_test.elf
    PRIVATE
        main.c
        mem_verify.c
)

target_include_directories(memory_test.elf
    PRIVATE
    PUBLIC
)

target_link_libraries(memory_test.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump memory_test.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS memory_test.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" memory_test.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file memory_test.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS memory_test.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" memory_test.elf
    COMMENT "Reporting memory available for stack + heap in memory_test.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")

# Generate HEX file(s) from memory_test.elf using elf2hex tool.
# Note : If ECC Full is enabled, width of 39 is set for NiosV TCM. Otherwise, 32.
add_custom_command(
    OUTPUT "intel_onchip_memory.hex"
    DEPENDS memory_test.elf
    COMMAND elf2hex memory_test.elf -o intel_onchip_memory.hex -b 0x00800000 -w 32 -e 0x0087FFFF -r 4
    COMMENT "Creating intel_onchip_memory.hex."
    VERBATIM
)
add_custom_target(create-hex ALL DEPENDS "intel_onchip_memory.hex")
