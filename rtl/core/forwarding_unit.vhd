-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	forwarding_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 September 2026
-- Provides:
--   - Combinational forwarding/operand bypass control 
--		 for EX-stage RS1/RS2 (and branch paths).
--   - Compares rs1/rs2 against pending destinations in EX/MEM, 
--		 MEM/WB, and WB with REGWR/MEMRD gating.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- Function block
-- inputs:
--		- RS1_ADDR			:	ID/EX rs1, already masked to x0 by rs_decode
--		- RS2_ADDR			:	ID/EX rs2, already masked to x0 by rs_decode
--		- SRC2SEL			:	ID/EX copy of the decode-stage B-operand select.
--									'1' means OP_A/OP_B already hold an immediate
--		- RD_ADDR_EX_MEM	:	destination of instruction in MEM
--		- REGWR_EX_MEM		:	instruction writes a register
--		- RD_ADDR_MEM_WB	:	destination of instruction in WB
--		- REGWR_MEM_WB		:	instruction writes a register
--		- MEMRD_MEM_WB		:	instruction is a load, so its value is memory read data rather than carried result
-- outputs:
--		- ASEL				:	operand A forward select
--		- BSEL_ALU			:	oselect for OP_B forward mux
--		- BSEL_DATA			:	select for RD2 forward mux -> store data and branch comparator B
entity FORWARDING_UNIT is
port(
	RS1_ADDR			:	in std_logic_vector(4 downto 0);
	RS2_ADDR			:	in std_logic_vector(4 downto 0);
	SRC2SEL			:	in std_logic;
	RD_ADDR_ID_EX	:	in std_logic_vector(4 downto 0);
	REGWR_ID_EX		:	in std_logic;
	RD_ADDR_EX_MEM	:	in std_logic_vector(4 downto 0);
	REGWR_EX_MEM	:	in std_logic;
	MEMRD_EX_MEM	:	in std_logic;
	ASEL				:	out std_logic_vector(1 downto 0);
	BSEL_ALU			:	out std_logic_vector(1 downto 0);
	BSEL_DATA		:	out std_logic_vector(1 downto 0)
);
end entity FORWARDING_UNIT;

-- circuit description
-- 00 = no forwarding
-- 01 = from EX/MEM
-- 10 = from MEM/WB, load
-- 11 = from MEM/WB, other
architecture BEHAVIORAL of FORWARDING_UNIT is
	-- Function
	-- every input is parameter rather than enclosing signal
	-- no reliance on impure=function support
	function FWD_SEL(
		RS				:	std_logic_vector(4 downto 0);
		RD_ID_EX		:	std_logic_vector(4 downto 0);
		WR_ID_EX		:	std_logic;
		RD_EX_MEM	:	std_logic_vector(4 downto 0);
		WR_EX_MEM	:	std_logic;
		LOAD_EX_MEM	:	std_logic) return std_logic_vector is
	begin
		-- younger instruction first
		if WR_ID_EX = '1' and RD_ID_EX /= B"00000" and RD_ID_EX = RS then
			return B"01";
		elsif WR_EX_MEM = '1' and RD_EX_MEM /= B"00000" and RD_EX_MEM = RS then
			if LOAD_EX_MEM = '1' then
				return B"10";
			else
				return B"11";
			end if;
		else
			return B"00";
		end if;
	end function FWD_SEL;
	
	signal RS2_FWD	:	std_logic_vector(1 downto 0);
begin
	-- A side: no gate needed
	ASEL			<=	FWD_SEL(RS1_ADDR, RD_ADDR_ID_EX, REGWR_ID_EX, RD_ADDR_EX_MEM, REGWR_EX_MEM, MEMRD_EX_MEM);
	
	-- rs2's forwarded value, used as-is by store-data path and branch comparator
	RS2_FWD		<=	FWD_SEL(RS2_ADDR, RD_ADDR_ID_EX, REGWR_ID_EX, RD_ADDR_EX_MEM, REGWR_EX_MEM, MEMRD_EX_MEM);
	BSEL_DATA	<=	RS2_FWD;
	
	-- B side into the ALU: suppressed when OP_B is an immediate
	-- Two AND gates
	BSEL_ALU		<=	B"00" when SRC2SEL = '1' else RS2_FWD;
end architecture BEHAVIORAL;