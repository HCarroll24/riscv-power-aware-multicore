vlib work
vmap altera_lnsim C:/altera_pro/25.1/questa_fse/intel/vhdl/altera_lnsim

vlib rom_1port_2022
vcom -2008 -work rom_1port_2022 ../quartus/single_port_rom/rom_1port_2022/sim/single_port_rom_rom_1port_2022_erqluhq.vhd
vlib single_port_rom
vcom -2008 -work single_port_rom ../quartus/single_port_rom/sim/single_port_rom.vhd
vlib intel_user_rst_clkgate_101
vlog -sv -work intel_user_rst_clkgate_101 ../quartus/reset_release/intel_user_rst_clkgate_101/sim/intel_user_rst_clkgate.sv
vlib reset_release
vcom -2008 -work reset_release ../quartus/reset_release/sim/reset_release.vhd

# your three RTL vcom lines, then the testbench
vcom -2008 tb_multicorecpu.vhd

vsim -t ps -voptargs=+acc -L single_port_rom -L rom_1port_2022 -L reset_release -L intel_user_rst_clkgate_101 -L altera_lnsim work.tb_multicorecpu
log -r /tb_multicorecpu/*
do wave.do
run 2 ms