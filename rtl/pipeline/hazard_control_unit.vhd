-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	hazard_control_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 April 2026
-- Provides:
--   - Load-use hazard detector: stalls IF/ID when a 
--		 load in ID/EX targets RS1/RS2 of the instruction in IF/ID.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
entity HAZARD_CONTROL_UNIT is
port(
	MEMRD_ID_EX			:	in std_logic;
	RD_ADDR_ID_EX		:	in std_logic_vector(4 downto 0);
	RS1_ADDR_IF_ID		:	in std_logic_vector(4 downto 0);
	RS2_ADDR_IF_ID		:	in std_logic_vector(4 downto 0);
	STALL					:	out std_logic
);
end entity HAZARD_CONTROL_UNIT;

architecture BEHAVIORAL of HAZARD_CONTROL_UNIT is

begin
	STALL	<= '1' when (MEMRD_ID_EX = '1' and RD_ADDR_ID_EX /= B"00000" and (RD_ADDR_ID_EX = RS1_ADDR_IF_ID or RD_ADDR_ID_EX = RS2_ADDR_IF_ID)) else
				'0';
				
end architecture BEHAVIORAL;