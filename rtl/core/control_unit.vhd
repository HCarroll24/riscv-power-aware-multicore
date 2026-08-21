-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	control_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			20 March 2026
-- Provides:
--   - Combinational main decoder for the RV32I pipeline: 
--				maps INSTR to datapath controls.
--   - Drives ALU select, immediate format, memory/reg write enables, 
--		 and PC/writeback muxes.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
--		INSTR[31:0]	:	full instruction word form IF/ID
-- outputs:
--		SRC1SEL		:	ALU A input mux select
--		SRC2SEL		: 	ALU B input mux select
--		MEMWR			:	1 = write data memory
--		MEMRD			:	1 = read data memory, also drives WB MUX
--		REGWR			:	Determines if write register file in wb
--		BRANCH		:	Conditional branch signal
--		WD4SEL		:	2-bit select signal to choose bewteen writeback sources
--		IMMSRC[2:0]	:	immediate format select for imm_gen
--		ALUSEL[3:0]	:	ALU operation select
entity CONTROL_UNIT is
port(
	INSTR		:	in std_logic_vector(31 downto 0);
	SRC1SEL	:	out std_logic;
	SRC2SEL	:	out std_logic;
	MEMWR		:	out std_logic;
	MEMRD		:	out std_logic;
	REGWR		:	out std_logic;
	BRANCH	:	out std_logic;
	WD4SEL	: 	out std_logic_vector(1 downto 0);
	IMMSRC	:	out std_logic_vector(2 downto 0);
	ALUSEL	:	out std_logic_vector(3 downto 0);
	JUMP		:	out std_logic
);
end entity CONTROL_UNIT;

-- circuit description
architecture BEHAVIORAL of CONTROL_UNIT is
begin
	-- SRC1SEL for ALU MUX determines whether PC or rs1
	-- 0 = rs1
	-- 1 = pc (jal, and auipc, B-type)
	SRC1SEL <= '1' when INSTR(6 downto 0) = B"1101111" else
				  '1' when INSTR(6 downto 0) = B"0010111" else
				  '1' when INSTR(6 downto 0) = B"1100011" else
				  '0';
				  
	-- SRC2SEL for ALU MUX determines whether rs2 or imm
	-- 0 = rs2
	-- 1 = imm
	SRC2SEL <= '0' when INSTR(6 downto 0) = B"0110011" else -- r-type only
				  '1';
				  
	-- MEMWR
	-- S-TYPE is only that write to memory
	MEMWR <= '1' when INSTR(6 downto 0) = B"0100011" else
				'0';
				
	-- MEMRD: I-Load is only that reads from memory
	MEMRD <= '1' when INSTR(6 downto 0) = B"0000011" else
				'0';
				
	-- REGWR: 0 for S and B
	REGWR <= '0' when INSTR(6 downto 0) = B"0100011" else
				'0' when INSTR(6 downto 0) = B"1100011" else
				'1';
				
	-- BRANCH signal
	BRANCH <= '1' when INSTR(6 downto 0) = B"1100011" else
				 '0';
	
	-- WD3SEL
	-- 00 = ALU result
	-- 01 = memory data (loads)
	-- 10 = PC + 4 for jal and jalr
	WD4SEL <= B"01" when INSTR(6 downto 0) = B"0000011" else -- load
				 B"10" when INSTR(6 downto 0) = B"1101111" else -- JAL
				 B"10" when INSTR(6 downto 0) = B"1100111" else -- JALR
				 B"00";														-- everything else
				 
	-- IMMSRC
	IMMSRC <= B"000" when INSTR(6 downto 0) = B"0010011" else	-- I-arith
				 B"000" when INSTR(6 downto 0) = B"0000011" else	-- I-load
				 B"000" when INSTR(6 downto 0) = B"1100111" else	-- JALR
				 B"001" when INSTR(6 downto 0) = B"0100011" else	-- S-type
				 B"010" when INSTR(6 downto 0) = B"1100011" else	-- B-type
				 B"011" when INSTR(6 downto 0) = B"0110111" else	-- LUI
				 B"011" when INSTR(6 downto 0) = B"0010111" else	-- AUIPC
				 B"100" when INSTR(6 downto 0) = B"1101111" else	-- JAL
				 B"111";	-- error/default
	
	-- ALUSEL in R and I arithmetic cases
	ALUSEL <= INSTR(30) & INSTR(14 downto 12) when (INSTR(6 downto 0) = B"0110011" or INSTR(6 downto 0) = B"0010011") else -- normal case
				 B"0000"; -- add when nothing else specified
	
	-- jump to flush whenever i have jal or jalr
	JUMP	<=	'1' when INSTR(6 downto 0) = B"1101111" else -- jal
				'1' when INSTR(6 downto 0) = B"1100111" else -- jalr
				'0';
end architecture BEHAVIORAL;