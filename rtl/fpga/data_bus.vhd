/*************************************************************************
 * File:			data_bus.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			20 October 2026
 * Provides:
 *		Address decoder and read-data mux
 *		Address map:
 *			0xFF20_0000 - 0xFF20_FFFF	:	MMIO
 *			everythign else				:	dmem (16 KiB, aliased)
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;

-- Function Block Prototype
-- Inputs:
--		CLK		:	clock
--		RST		:	active-high reset
--		ADDR		:	bus byte address from core
--		WE			:	bus write enable from core
--		RE			:	bus read enable from core
--		DMEM_Q	:	registered read data from data memory
--		IO_Q		:	registered read data from MMIO
-- Outputs:
--		DMEM_WE	:	write enable data memory
--		DMEM_RE	:	read enable data memory
--		IO_WE		:	MMIO write enable
--		IO_RE		:	MMIO read enable
--		RDATA		:	read data back to the core
entity DATA_BUS is
port(
	CLK		:	in		std_logic;
	RST		:	in		std_logic;
	ADDR		:	in		std_logic_vector(31 downto 0);
	WE			:	in		std_logic;
	RE			:	in		std_logic;
	DMEM_Q	:	in		std_logic_vector(31 downto 0);
	IO_Q		:	in		std_logic_vector(31 downto 0);
	DMEM_WE	:	out	std_logic;
	DMEM_RE	:	out	std_logic;
	IO_WE		:	out	std_logic;
	IO_RE		:	out	std_logic;
	RDATA		:	out	std_logic_vector(31 downto 0));
end entity DATA_BUS;

-- architectural description
architecture BEHAVIORAL of DATA_BUS is
	-- base of the io region (upper 16 address bits)
	constant IO_BASE	:	std_logic_vector(15 downto 0)	:=	x"FF20";
	
	signal IO_HIT		:	std_logic;
	signal IO_SEL_R	:	std_logic;
begin
	-- address decode (ex stage)
	IO_HIT	<=	'1' when ADDR(31 downto 16) = IO_BASE else '0';
	
	DMEM_WE	<=	WE and not IO_HIT;
	DMEM_RE	<=	RE and not IO_HIT;
	IO_WE		<=	WE and IO_HIT;
	IO_RE		<=	RE and IO_HIT;
	
	-- remember the read target on the same edge slave captures data
	sel_reg:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				IO_SEL_R	<=	'0';
			elsif RE = '1' then
				IO_SEL_R	<=	IO_HIT;
			end if;
		end if;
	end process sel_reg;
	
	-- read data mux (MEM stage)
	with IO_SEL_R select
	RDATA	<=	IO_Q when '1',
				DMEM_Q when others;
end architecture BEHAVIORAL;