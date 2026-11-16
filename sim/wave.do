onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_multicorecpu/CLK
add wave -noupdate /tb_multicorecpu/SW
add wave -noupdate -radix hexadecimal /tb_multicorecpu/LEDR
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX0
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX1
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX2
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX3
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX4
add wave -noupdate -radix hexadecimal /tb_multicorecpu/HEX5
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/RST
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/CORE_EN
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/DBUS_ADDR
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/DBUS_WDATA
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/DBUS_WE
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/DBUS_RE
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/PC
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/INSTR
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/STALL_INT
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/MISPREDICT_INT
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/MEM_WB_VALID_INT
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/DECODE_BLOCK/REG_FILE/X1
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/DECODE_BLOCK/REG_FILE/X2
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/DECODE_BLOCK/REG_FILE/X10
add wave -noupdate -divider {OPERAND ISOLATION}
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/IF_ID_INSTR
add wave -noupdate -radix binary      /tb_multicorecpu/DUT/SINGLE_CORE/SHIFT_EN_ID
add wave -noupdate                    /tb_multicorecpu/DUT/SINGLE_CORE/IDEX_FLUSH
add wave -noupdate -radix binary      /tb_multicorecpu/DUT/SINGLE_CORE/SH_LD
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SRC1
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SLL_A
add wave -noupdate -radix unsigned    /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SLL_B
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SRL_A
add wave -noupdate -radix unsigned    /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SRL_B
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SRA_A
add wave -noupdate -radix unsigned    /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_SRA_B
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ID_EX_ALUSEL
add wave -noupdate -radix hexadecimal /tb_multicorecpu/DUT/SINGLE_CORE/ALU_F
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {302370000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 322
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {186842 ps} {266567 ps}
