    .section .text.init
    .globl  _start
_start:
    la      sp, __stack_top     # stack starts at top of DMEM
    call    main
1:  j       1b                  # if main returns, spin here
