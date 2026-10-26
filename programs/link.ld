ENTRY(_start)

MEMORY
{
    IROM (rx) : ORIGIN = 0x00000000, LENGTH = 16K
    DMEM (rw) : ORIGIN = 0x00010000, LENGTH = 16K
}

SECTIONS
{
    .text   : { *(.text.init) *(.text .text.*) } > IROM
    .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } > DMEM
    .data   : { *(.data .data.* .sdata .sdata.*) } > DMEM
    .bss    : { *(.bss .bss.* .sbss .sbss.*) } > DMEM

    __stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

    ASSERT(SIZEOF(.rodata) == 0 && SIZEOF(.data) == 0, "no .rodata/.data allowed: DMEM is not initialized")
    ASSERT(SIZEOF(.bss) == 0, "no .bss: crt0 does not zero it")
}
