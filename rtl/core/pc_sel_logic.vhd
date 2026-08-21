-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	pc_sel_logic.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - Small combinational glue between static PCSEL 
--		 intent and dynamic branch outcome.
--   - Merges PCSEL, BR_TAKEN, and opcode context into 
--		 the mux select the PC datapath uses.
-- **********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;

-- Function block symbol
--	Inputs:
--		- PCSEL[1:0]	-	pc select signal
--		- BR_TAKEN		-	branch taken signal
--	Outputs:
--		- SEL				-	Select signal between pcsel and br_taken
entity PC_SEL_LOGIC is
port(
	PREDICT	:	in std_logic;
	TARGET_VALID	:	in std_logic;
	OPCODE	:	in std_logic_vector(6 downto 0);
	FLUSH		:	in std_logic;
	PREDICT_EX	:	in std_logic;
	JUMP_EX	:	in std_logic;
	SEL		:	out std_logic_vector(1 downto 0));
end entity PC_SEL_LOGIC;

architecture BEHAVIORAL of PC_SEL_LOGIC is
	signal IS_B_TYPE	:	std_logic;
begin
	IS_B_TYPE	<=	'1' when OPCODE = B"1100011" else '0';

	SEL	<=	B"01" when JUMP_EX = '1' else
				B"11" when (FLUSH = '1' and PREDICT_EX = '1') else -- recovery address
				B"01" when (FLUSH = '1' and PREDICT_EX = '0') else
				B"10" when (PREDICT = '1' and TARGET_VALID = '1' and IS_B_TYPE = '1') else
				B"00";
end architecture BEHAVIORAL;