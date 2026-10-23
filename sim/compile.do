# library mapping (precompiled Intel library)
vlib work
vmap altera_lnsim C:/altera_pro/25.1/questa_fse/intel/vhdl/altera_lnsim

# ROM IP
vlib rom_1port_2022
set f [open ../quartus/single_port_rom/sim/common/modelsim_files.tcl]
set t [read $f]
close $f
regexp {single_port_rom_rom_1port_2022_[a-z0-9]+\.vhd} $t ROMFILE
vcom -2008 -work rom_1port_2022 ../quartus/single_port_rom/rom_1port_2022/sim/$ROMFILE
vlib single_port_rom
vcom -2008 -work single_port_rom ../quartus/single_port_rom/sim/single_port_rom.vhd

# Reset Release IP
vlib intel_user_rst_clkgate_101
vlog -sv -work intel_user_rst_clkgate_101 ../quartus/reset_release/intel_user_rst_clkgate_101/sim/intel_user_rst_clkgate.sv
vlib reset_release
vcom -2008 -work reset_release ../quartus/reset_release/sim/reset_release.vhd

# your RTL, then the testbench
vcom -2008 ../rtl/core/alu.vhd ../rtl/core/regfile.vhd ../rtl/core/imm_gen.vhd ../rtl/core/control_unit.vhd ../rtl/core/branch_comp.vhd ../rtl/core/dmem.vhd ../rtl/core/busmux4to1.vhd ../rtl/pipeline/reg32.vhd ../rtl/core/adder.vhd ../rtl/pipeline/regn.vhd ../rtl/pipeline/reg1.vhd ../rtl/core/pc_sel_logic.vhd ../rtl/core/busmux5to1.vhd ../rtl/core/forwarding_unit.vhd ../rtl/pipeline/hazard_control_unit.vhd ../rtl/core/bht.vhd ../rtl/core/branch_target_calc.vhd ../rtl/core/rs_decode.vhd
vcom -2008 ../rtl/pipeline/fetch.vhd ../rtl/pipeline/decode.vhd ../rtl/pipeline/execute.vhd ../rtl/pipeline/memory.vhd ../rtl/pipeline/pipeline.vhd
vcom -2008 ../rtl/fpga/synchronizer.vhd ../rtl/fpga/data_bus.vhd ../rtl/mmio.vhd ../rtl/fpga/multicorecpu.vhd
vcom -2008 tb_multicorecpu.vhd

# load
vsim -t ps -voptargs=+acc -L single_port_rom -L rom_1port_2022 -L reset_release -L intel_user_rst_clkgate_101 -L altera_lnsim work.tb_multicorecpu