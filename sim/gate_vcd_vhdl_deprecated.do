vlib gate
vmap tennm C:/altera_pro/25.1/questa_fse/intel/vhdl/tennm
vmap altera_lnsim C:/altera_pro/25.1/questa_fse/intel/vhdl/altera_lnsim
vmap altera_ver C:/altera_pro/25.1/questa_fse/intel/vhdl/altera
vcom -work gate ../quartus/simulation/questa/multicorecpu.vho
vsim -t ps -voptargs=+acc -L tennm -L altera_lnsim -L altera_ver gate.MULTICORECPU

force -freeze CLK 0 0, 1 10ns -repeat 20ns
force -freeze KEY 1111
force -freeze SW 0000000000

source ../quartus/simulation/questa/multicorecpu_dump_all_vcd_nodes.tcl
run $1
examine HEX0 LEDR
vcd flush
quit -sim
file rename -force multicorecpu.vcd $2.vcd