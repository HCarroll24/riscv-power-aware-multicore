-- (C) 2001-2025 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License Subscription 
-- Agreement, Altera IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.




LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.all;

ENTITY single_port_rom_rom_1port_2022_3ha7tri IS
    PORT
    (
        address       : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        clock       : IN STD_LOGIC  := '1';
        rden       : IN STD_LOGIC  := '1';
        q       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END single_port_rom_rom_1port_2022_3ha7tri;


ARCHITECTURE SYN OF single_port_rom_rom_1port_2022_3ha7tri IS

    SIGNAL sub_wire0    : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
    q     <= sub_wire0 (31 DOWNTO 0);

    altera_syncram_component : altera_syncram
    GENERIC MAP (
            address_aclr_a  => "NONE",
            clock_enable_input_a  => "BYPASS",
            clock_enable_output_a  => "BYPASS",
            init_file  => "C:/dev/riscv-power-aware/benchmarks/irom.mif",
            intended_device_family  => "Agilex 3",
            lpm_type  => "altera_syncram",
            maximum_depth  => 2048,
            numwords_a  => 4096,
            operation_mode  => "ROM",
            outdata_aclr_a  => "NONE",
            outdata_sclr_a  => "NONE",
            outdata_reg_a  => "UNREGISTERED",
            ram_block_type  => "M20K",
            enable_force_to_zero  => "FALSE",
            optimization_option  => "LOW_POWER",
            widthad_a  => 12,
            width_a  => 32,
            width_byteena_a  => 1
    )
    PORT MAP (
        address_a => address,
        clock0 => clock,
        rden_a => rden,
        q_a => sub_wire0
    );



END SYN;

