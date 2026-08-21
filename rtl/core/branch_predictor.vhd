-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	branch_predictor.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			8 April 2026
-- Provides:
--   - Simple 1-bit dynamic branch direction predictor 
--		 (state held in REG1), updated on flush edges.
--   - Drives PCSEL LSB from the predicted-taken bit for
--		 conditional branches and related opcodes.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- Function Block Symbol
-- Inputs:
--		- FLUSH	:	signal that flushes the signal, if the
--						flush signal is high goes to not taken
--		- RST		:	reset signal active when high
--		- CLK		:	clock signal to allow for state logic
--						to be output
-- Outputs:
--		- PCSEL	:	Determines if PC will get the PC+imm
--						or pc+4
entity BRANCH_PREDICTOR is
port(
	OPCODE:	in std_logic_vector(6 downto 0);
	FLUSH	:	in std_logic;
	RST	:	in std_logic;
	CLK	:	in std_logic;
	PCSEL	:	out std_logic_vector(1 downto 0));
end entity BRANCH_PREDICTOR;

-- Architectural
architecture BEHAVIORAL of BRANCH_PREDICTOR is
	-- internal signals
	signal 	NEXT_STATE		:	std_logic;
	signal	CURRENT_STATE	:	std_logic;
	signal 	IS_BRANCH		:	std_logic;
	signal	FLUSH_PREV		:	std_logic;
	signal	FLUSH_PULSE		:	std_logic;
	signal	UPDATE			:	std_logic;
	
	-- DECLARE REG1 COMPONENT
	component REG1 is
		port(
			RST	:	in std_logic;
			CLK	:	in std_logic;
			LD		:	in std_logic;
			FLUSH	:	in std_logic;
			D		:	in std_logic;
			Q		:	out std_logic
		);
	end component;
begin
	-- is it a branch?
	IS_BRANCH	<=	'1' when (OPCODE = B"1100011" or OPCODE = B"1101111" or OPCODE = B"1100111") else
						'0';

	-- next state logic
	NEXT_STATE	<= CURRENT_STATE xor FLUSH;
	
	-- D-flip flop
	reg:	REG1
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	'1',
			FLUSH	=>	'0',
			D		=>	NEXT_STATE,
			Q		=>	CURRENT_STATE
		);
	
	--	PCSEL output
	PCSEL	<=	'0' & CURRENT_STATE;
end architecture BEHAVIORAL;
	