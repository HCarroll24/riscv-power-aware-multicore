-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	pc_sel_logic.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 September 2026
-- Provides:
--   - Next-pc select for the fetch-stage PCMUX (busmux4to1)
-- **********************************************************************

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;

-- Function block symbol
--	Inputs:
--		- RST				: active-high reset
--		- REDIRECT_EN	: EX resolved a mispredicted branch or a JALR
--		- TARGET_VALID	: From BTC to check if target is valid
--		- IS_JAL			: JAL is always taken
--		- PREDICT		: from bht
--	Outputs:
--		- PCSEL			: PCMUX select, priority top to bottom
--		- PREDICT_TAKEN: to ID/EX
entity PC_SEL_LOGIC is
port(
	RST				:	in		std_logic;
	REDIRECT_EN		:	in		std_logic;
	STALL				:	in		std_logic;	
	TARGET_VALID	:	in		std_logic;
	IS_JAL			:	in		std_logic;
	PREDICT			:	in		std_logic;
	PREDICT_TAKEN	:	out 	std_logic;
	PCSEL				:	out	std_logic_vector(2 downto 0));
end entity PC_SEL_LOGIC;

-- circuit description
architecture BEHAVIORAL of PC_SEL_LOGIC is
	signal TAKE_TARGET	:	std_logic;
begin
	TAKE_TARGET	<=	TARGET_VALID and (IS_JAL or PREDICT);

	PCSEL	<=	B"011" when RST				= '1' else	-- D3 ZERO32
				B"010" when REDIRECT_EN 	= '1' else	--	D2 REDIRECT_PC
				B"100" when STALL 			= '1' else	-- D4 (PC hold)
				B"001" when TAKE_TARGET		= '1' else	-- D1 BR_TARGET
				B"000";											-- D0 PC_PLUS4
				
	PREDICT_TAKEN	<=	'1' when (RST = '0' and REDIRECT_EN = '0' and STALL = '0' and TAKE_TARGET = '1') else
							'0';
end architecture BEHAVIORAL;