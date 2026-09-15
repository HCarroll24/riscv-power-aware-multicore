-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	control_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 Sep 2025
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
--		IS_JALR		:	Conditional if JALR instruction
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
	IS_JALR	:	out std_logic;
	WD4SEL	: 	out std_logic_vector(1 downto 0);
	IMMSRC	:	out std_logic_vector(2 downto 0);
	ALUSEL	:	out std_logic_vector(3 downto 0)
);
end entity CONTROL_UNIT;

-- circuit description
architecture BEHAVIORAL of CONTROL_UNIT is
	--RV32I major opcodes
	constant OP_LUI		:	std_logic_vector(6 downto 0) := B"0110111";
	constant OP_AUIPC		:	std_logic_vector(6 downto 0) := B"0010111";
	constant OP_JAL		:	std_logic_vector(6 downto 0) := B"1101111";
	constant OP_JALR		:	std_logic_vector(6 downto 0) := B"1100111";
	constant OP_BRANCH	:	std_logic_vector(6 downto 0) := B"1100011";
	constant OP_LOAD		:	std_logic_vector(6 downto 0) := B"0000011";
	constant OP_STORE		:	std_logic_vector(6 downto 0) := B"0100011";
	constant OP_IARITH	:	std_logic_vector(6 downto 0) := B"0010011";
	constant OP_RTYPE		:	std_logic_vector(6 downto 0) := B"0110011";
	
	signal	OPCODE		:	std_logic_vector(6 downto 0);
	signal	FUNCT3		:	std_logic_vector(2 downto 0);
begin
	-- Grab opcode and funct 3 from instrunction bus
	OPCODE	<=	INSTR(6 downto 0);
	FUNCT3	<=	INSTR(14 downto 12);
	
	-- SRC1SEL for ALU MUX determines whether PC or rs1
	-- 0 = rs1
	-- 1 = pc (auipc), note: JAL and B-type handled in fetch
	SRC1SEL	<=	'1' when OPCODE = OP_AUIPC else
					'0';
	-- SRC2SEL for ALU MUX determines whether rs2 or imm
	-- R-type and B-type have two register sources
	-- B-type is don't care -- ALU result never written, regwr and memwr are '0'
	-- 0 = rs2
	-- 1 = imm
	SRC2SEL	<= '0' when (OPCODE = OP_RTYPE or OPCODE = OP_BRANCH) else -- r-type and b-type
					'1';
				  
	-- Memory enables, one opcode each
	MEMWR		<=	'1' when OPCODE = OP_STORE else '0';
	MEMRD		<=	'1' when OPCODE = OP_LOAD else '0';
				
	-- REGWR: default to 0 to prevent runaway PC issues
	-- enumerate writers
	REGWR		<=	'1' when (OPCODE = OP_RTYPE
							 or OPCODE = OP_IARITH
							 or OPCODE = OP_LOAD
							 or OPCODE = OP_JAL
							 or OPCODE = OP_JALR
							 or OPCODE = OP_LUI
							 or OPCODE = OP_AUIPC) else
					'0';
					
	-- Branch: EX runs comparator and redicrects only on a mispredict
	BRANCH	<=	'1' when OPCODE = OP_BRANCH else '0';
	
	-- IS_JALR: Ex redirects unconditionally. JALR cannot be predicted, alwayhs costs one cycle
	IS_JALR	<=	'1' when OPCODE = OP_JALR else '0';
	
	-- WD4SEL, writeback source
	-- 00 = ALU result
	-- 01 = memory data (loads)
	-- 10 = PC + 4 for jal and jalr
	WD4SEL 	<= B"01" when OPCODE = OP_LOAD else
					B"10" when (OPCODE = OP_JAL or OPCODE = OP_JALR) else
					B"00";
				 
	-- IMMSRC, immediate format for imm_gen
	-- B and J are generated even though btc extrats own copies in fetch
	IMMSRC 	<= B"000" when (OPCODE = OP_IARITH
								 or OPCODE = OP_LOAD
								 or OPCODE = OP_JALR)	else -- I
					B"001" when OPCODE = OP_STORE		else -- S
					B"010" when OPCODE = OP_BRANCH	else -- B
					B"011" when (OPCODE = OP_LUI
								 or OPCODE = OP_AUIPC)	else -- U
					B"100" when OPCODE = OP_JAL		else -- J
					B"111";										  -- error default
	
	-- ALUSEL in R and I arithmetic cases
	-- 0 add, 1 sll, 2 slt, 3 sltu, 4 xor, 5 srl, 6 or, 7 and, 8 sub, 13 sra
	ALUSEL 	<=	INSTR(30) & FUNCT3 when OPCODE = OP_RTYPE else
					INSTR(30) & FUNCT3 when (OPCODE = OP_IARITH and FUNCT3 = B"101") else
					'0' & FUNCT3 when OPCODE = OP_IARITH else
					B"0000";
end architecture BEHAVIORAL;