-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	pipe_control_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			2 April 2026
-- Provides:
--   - Combinational pipeline control: asserts FLUSH on 
--		 mispredict/jump and coordinates LD with stalls.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
--	Inputs:
--		-	BR_TAKEN	:	Is the branch taken and is the instruction wrong
-- Outputs:
--		-	FLUSH		:	Will the instruction be flushed from the system
--		-	LD			:	Load enable register will always be '1' until stall
--							and branch prediction
entity PIPE_CONTROL_UNIT is
port(
	JUMP_EX		:	in std_logic;
	BRANCH_EX	:	in std_logic;
	PREDICT_EX	:	in std_logic;
	BR_TAKEN		:	in std_logic;
	STALL			:	in std_logic;
	FLUSH			:	out std_logic;
	LD				:	out std_logic
);
end entity PIPE_CONTROL_UNIT;

architecture BEHAVIORAL of PIPE_CONTROL_UNIT is
begin

	-- Load enable always '1' until stall and branch prediction implementation
	LD	<=	not STALL;
	
	-- flushes when prediction is wrong or jump instruction
	-- also keeps the flush for the pc 0 and pc 4 instructions
	-- while calculating the branch address
	FLUSH	<=	((PREDICT_EX xor BR_TAKEN) and BRANCH_EX) or JUMP_EX;
end architecture BEHAVIORAL;