-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	branch_target_calc.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			8 July 2026
-- Provides:
--   - Combinational fetch-stage branch/jump target calculator.
--   - Extracts B-type or J-type immediate directly from the fetched
--		 instruction and adds it to the fetch-stage PC.
--   - TARGET_VALID is high only for B-type (1100011) and JAL (1101111);
--		 JALR (1100111) needs rs1 and must still resolve in EX.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
--		INSTR[31:0]			:	instruction word from IROM (same cycle as fetch)
--		PC[31:0]				:	fetch-stage PC of that instruction (NOT PC+4)
-- outputs:
--		FETCH_TARGET[31:0]:	PC + B/J immediate, the predicted-taken target
--		TARGET_VALID		:	'1' when FETCH_TARGET is meaningful; gates the
--									PC mux so JALR / non-branches never redirect
entity BRANCH_TARGET_CALC is
port(
	INSTR			:	in std_logic_vector(31 downto 0);
	PC				:	in std_logic_vector(31 downto 0);
	FETCH_TARGET:	out std_logic_vector(31 downto 0);
	TARGET_VALID:	out std_logic
);
end entity BRANCH_TARGET_CALC;

architecture BEHAVIORAL of BRANCH_TARGET_CALC is
	-- opcode field alias for readability
	alias OPCODE	:	std_logic_vector(6 downto 0) is INSTR(6 downto 0);

	-- internal immediate signals
	signal B_IMM	:	std_logic_vector(31 downto 0);
	signal J_IMM	:	std_logic_vector(31 downto 0);
	signal IMM		:	std_logic_vector(31 downto 0);

	-- reuse the existing 32-bit adder for schematic consistency
	component ADDER is
	port(A, B	:	in std_logic_vector(31 downto 0);
		  S		:	out std_logic_vector(31 downto 0));
	end component;
begin
	-- B-type immediate (13-bit, sign-extended)
	-- same slicing as imm_gen.vhd IMMSRC = "010"
	B_IMM	<=	(31 downto 13 => INSTR(31)) & INSTR(31) & INSTR(7)
			 & INSTR(30 downto 25) & INSTR(11 downto 8) & '0';

	-- J-type immediate (21-bit, sign-extended)
	-- same slicing as imm_gen.vhd IMMSRC = "100"
	J_IMM	<=	(31 downto 21 => INSTR(31)) & INSTR(31) & INSTR(19 downto 12)
			 & INSTR(20) & INSTR(30 downto 21) & '0';

	-- select immediate by opcode
	-- B-type = conditional branch, JAL = unconditional jump
	IMM	<=	B_IMM when OPCODE = B"1100011" else
				J_IMM when OPCODE = B"1101111" else
				(others => '0');

	-- valid only for the two fetch-computable opcodes
	-- JALR (1100111) requires rs1 and cannot be computed here
	TARGET_VALID	<=	'1' when (OPCODE = B"1100011" or OPCODE = B"1101111") else
							'0';

	-- target = PC of this instruction + immediate
	target_adder:	ADDER
		port map(
			A	=>	PC,
			B	=>	IMM,
			S	=>	FETCH_TARGET
		);
end architecture BEHAVIORAL;