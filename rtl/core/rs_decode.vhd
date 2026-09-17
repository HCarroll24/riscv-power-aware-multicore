-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	rs_decode.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 Sep 2026
-- Provides:
--   - zeroing out register addresses that aren't really register
--		 addresses
--	  - Source-register address extraction with architectural mask
--   - RS1/RS2 read as x0 for any opcode that does not read that source
--     register
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
--		INSTR	:	full instruction word from IROM
-- outputs:
--		RS1	:	INSTR(19 downto 15), or x0 if opcode has no rs1
--		RS2	:	INSTR(24 downto 20), or x0 if opcode has no rs2
entity RS_DECODE is
port(
	INSTR		:	in	std_logic_vector(31 downto 0);
	RS1		:	out std_logic_vector(4 downto 0);
	RS2		:	out std_logic_vector(4 downto 0);
	USES_RS1	:	out std_logic;
	USES_RS2	:	out std_logic
);
end entity RS_DECODE;

-- circuit description
architecture BEHAVIORAL of RS_DECODE is
	-- RV32I major opcodes
	constant OP_LUI		:	std_logic_vector(6 downto 0) := B"0110111";
	constant OP_AUIPC		:	std_logic_vector(6 downto 0) := B"0010111";
	constant OP_JAL		:	std_logic_vector(6 downto 0) := B"1101111";
	constant OP_JALR		:	std_logic_vector(6 downto 0) := B"1100111";
	constant OP_BRANCH	:	std_logic_vector(6 downto 0) := B"1100011";
	constant OP_LOAD		:	std_logic_vector(6 downto 0) := B"0000011";
	constant OP_STORE		:	std_logic_vector(6 downto 0) := B"0100011";
	constant OP_IARITH	:	std_logic_vector(6 downto 0) := B"0010011";
	constant OP_RTYPE		:	std_logic_vector(6 downto 0) := B"0110011";
	
	signal OPCODE			:	std_logic_vector(6 downto 0);
	signal USE1				:	std_logic;
	signal USE2				:	std_logic;
begin
	OPCODE	<=	INSTR(6 downto 0);
	
	-- USE1: instructionst hat use RS1 get a '1' otherwise '0'
	USE1	<=	'1' when (OPCODE = OP_RTYPE
							 or OPCODE = OP_IARITH
							 or OPCODE = OP_LOAD
							 or OPCODE = OP_STORE
							 or OPCODE = OP_BRANCH
							 or OPCODE = OP_JALR) else
				'0';
					
	-- USe2: instructions that use rs2 get '1' otherwise '0'
	USE2	<=	'1' when (OPCODE = OP_RTYPE
							 or OPCODE = OP_STORE
							 or OPCODE = OP_BRANCH) else
				'0';
					
	USES_RS1	<=	USE1;
	USES_RS2	<=	USE2;
					
	RS1		<=	INSTR(19 downto 15) when USES_RS1 = '1' else B"00000";
	RS2		<=	INSTR(24 downto 20) when USES_RS2 = '1' else B"00000";
end architecture BEHAVIORAL;