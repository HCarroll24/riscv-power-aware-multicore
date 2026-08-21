-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	branch_comp.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			24 March 2026
-- Provides:
--   - Combinational branch comparator for 
--		 B-type instructions (FUNCT3 selects condition).
--   - BR_TAKEN is qualified by BRANCH so 
--		 comparisons apply only to branch opcodes.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		- RD1			:	rs1
--		- RD2			:	rs2
--		- FUNCT3		:	funct3 encoding from instr
--		- BRANCH		:	branch signal from control_unit, used to only
--							do comparison if branch instruction
-- outputs:
--		- BR_TAKEN	:	the comparison that tells if branch conditions met
entity BRANCH_COMP is
port(
	RD1		:	in std_logic_vector(31 downto 0);
	RD2		:	in std_logic_vector(31 downto 0);
	FUNCT3	:	in std_logic_vector(2 downto 0);
	BRANCH	:	in std_logic;
	BR_TAKEN	:	out std_logic
);
end entity BRANCH_COMP;

architecture BEHAVIORAL of BRANCH_COMP is
	-- comparison signal to check if 0
	-- '1' = comparison correct
	--	'0' = comparison wrong
	signal COMP	:	std_logic;
begin
	-- comp signal logic
	COMP	<=	'1' when (FUNCT3 = B"000" and RD1 = RD2) else								-- beq
				'1' when (FUNCT3 = B"001" and RD1 /= RD2) else								-- bne
				'1' when (FUNCT3 = B"100" and signed(RD1) < signed(RD2)) else			-- blt
				'1' when (FUNCT3 = B"101" and signed(RD1) >= signed(RD2)) else			-- bge
				'1' when (FUNCT3 = B"110" and unsigned(RD1) < unsigned(RD2)) else		-- bltu
				'1' when (FUNCT3 = B"111" and unsigned(RD1) >= unsigned(RD2)) else	-- bgeu
				'0';
				
	BR_TAKEN	<=	COMP and BRANCH;
end architecture BEHAVIORAL;