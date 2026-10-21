/*************************************************************************
 * File:			multicorecpu.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			20 October 2026
 * Provides:
 *		Top level for the Terasic DE23-Lite (Agilex 3 A3CZ135BB18AE7S).
 *		Replaces multicorecpu.bdf. Full memory-mapped I/O
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;

-- Function block prototype
-- Inputs:
--		CLK			:	50 MHz board clock
--		KEY			:	push-buttons, active-low, KEY0 = sysrst
--		SW				:	slide switches
-- Outputs:
--		LEDR			:	red LEDs, active-low
--		HEX0..HEX5	:	7-segment displays
entity MULTICORECPU is
port(
	CLK	:	in		std_logic;
	KEY	:	in		std_logic_vector(3 downto 0);
	SW		:	in		std_logic_vector(9 downto 0);
	LEDR	:	out	std_logic_vector(9 downto 0);
	HEX0	:	out	std_logic_vector(6 downto 0);
	HEX1	:	out	std_logic_vector(6 downto 0);
	HEX2	:	out	std_logic_vector(6 downto 0);
	HEX3	:	out	std_logic_vector(6 downto 0);
	HEX4	:	out	std_logic_vector(6 downto 0);
	HEX5	:	out	std_logic_vector(6 downto 0));
end entity MULTICORECPU;

-- architectural description
architecture STRUCTURAL of MULTICORECPU is
	-- Reset Release IP
	component reset_release is
	port(
		ninit_done	:	out	std_logic);
	end component;
	
	-- system reset
	signal NINIT_DONE	:	std_logic;
	signal SYSRST_N	:	std_logic;
	signal RST			:	std_logic;
	signal CORE_EN		:	std_logic;
	
	-- core data bus (master side)
	signal DBUS_ADDR	:	std_logic_vector(31 downto 0);	--	address
	signal DBUS_BE		:	std_logic_vector(3 downto 0);		--	byte enable
	signal DBUS_WDATA	:	std_logic_vector(31 downto 0);	--	wb data
	signal DBUS_WE		:	std_logic;	--	write enable
	signal DBUS_RE		:	std_logic;	--	read enable
	signal DBUS_RDATA	:	std_logic_vector(31 downto 0);	-- read data
	
	-- slave enables and read data
	signal DMEM_WE		:	std_logic;
	signal DMEM_RE		:	std_logic;
	signal DMEM_Q		:	std_logic_vector(31 downto 0);
	signal IO_WE		:	std_logic;
	signal IO_RE		:	std_logic;
	signal IO_Q			:	std_logic_vector(31 downto 0);
begin
	-- device-ready signal from config manager
	RESET_RELEASE_IP	:	reset_release
		port map(
			ninit_done	=>	NINIT_DONE);
	
	-- reset while KEY0 is pressed or device is not configured
	SYSRST_N	<=	KEY(0) and not NINIT_DONE;
	
	-- reset synchronizer
	SYNCHRONIZE	:	entity work.SYNCHRONIZER
		port map(
			SYSRST	=>	SYSRST_N,
			CLK		=>	CLK,
			RST		=>	RST);
			
	-- core enable, '0' in reset, '1' after
	core_enable:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				CORE_EN	<=	'0';
			else
				CORE_EN	<=	'1';
			end if;
		end if;
	end process core_enable;
	
	-- single RV32I core, data bus master
	SINGLE_CORE	:	entity work.PIPELINE
		port map(
			CLK				=>	CLK,
			RST				=>	RST,
			CORE_EN			=> CORE_EN,
			WD3				=>	open,
			RD_ADDR			=>	open,
			IF_ID_VALID		=>	open,
			ID_EX_VALID		=>	open,
			EX_MEM_VALID	=> open,
			MEM_WB_VALID	=>	open,
			MEM_WB_REGWR	=>	open,
			STALL				=>	open,
			REDIRECT_EN		=>	open,
			PREDICT_TAKEN	=>	open,
			MISPREDICT		=>	open,
			DBUS_ADDR		=>	DBUS_ADDR,
			DBUS_BE			=>	DBUS_BE,
			DBUS_WDATA		=>	DBUS_WDATA,
			DBUS_WE			=>	DBUS_WE,
			DBUS_RE			=>	DBUS_RE,
			DBUS_RDATA		=>	DBUS_RDATA);
			
	-- address decode and read data mux
	SYSTEM_BUS	:	entity work.DATA_BUS
		port map(
			CLK		=>	CLK,
			RST		=>	RST,
			ADDR		=>	DBUS_ADDR,
			WE			=>	DBUS_WE,
			RE			=>	DBUS_RE,
			DMEM_Q	=> DMEM_Q,
			IO_Q		=>	IO_Q,
			DMEM_WE	=>	DMEM_WE,
			DMEM_RE	=>	DMEM_RE,
			IO_WE		=>	IO_WE,
			IO_RE		=>	IO_RE,
			RDATA		=>	DBUS_RDATA);
			
	-- data memory (16 KiB)
	DMEM_RAM	:	entity work.DMEM
		port map(
			CLK	=>	CLK,
			A		=>	DBUS_ADDR,
			BE		=>	DBUS_BE,
			WDATA	=>	DBUS_WDATA,
			WE		=>	DMEM_WE,
			RE		=>	DMEM_RE,
			Q		=>	DMEM_Q);
			
	-- memory-mapped I/O
	BOARD_IO	:	entity work.MMIO
		port map(
			CLK	=>	CLK,
			RST	=>	RST,
			A		=>	DBUS_ADDR,
			BE		=>	DBUS_BE,
			WDATA	=>	DBUS_WDATA,
			WE		=>	IO_WE,
			RE		=>	IO_RE,
			Q		=>	IO_Q,
			SW		=>	SW,
			KEY	=>	KEY,
			LEDR	=>	LEDR,
			HEX0	=>	HEX0,
			HEX1	=>	HEX1,
			HEX2	=>	HEX2,
			HEX3	=>	HEX3,
			HEX4	=>	HEX4,
			HEX5	=>	HEX5);
end architecture STRUCTURAL;