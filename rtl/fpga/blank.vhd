-- ***********************************************************************
-- Project: RISC-V Multicore Power Aware Computing
--	Filename: blank.vhd
--	Author:	carrollh@msoe.edu <Hunter C>
--	Date:	24 Sep 2026
--	Provides:
--		Blanking for all segments if not writing to registers or mem
-- ***********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		SEG5		:	5th 7 segment display
--		SEG4		:	4th 7 segment display
--		SEG3		:	3rd 7 segment display
--		SEG2		:	2nd 7 segment display
--		SEG1		:	1st 7 segment display
--		SEG0		:	0th 7 segment display
--		SHOW_WB	:	Selectio if we should show values on the 7 segments
-- outputs:
--		HEX5
--		HEX4
--		HEX3
--		HEX2
--		HEX1
--		HEX0
entity BLANK is
port(
	SEG5, SEG4, SEG3, SEG2, SEG1, SEG0	:	in std_logic_vector(7 downto 0);
	SHOW_WB										:	in std_logic;
	HEX5, HEX4, HEX3, HEX2, HEX1, HEX0	:	out std_logic_vector(7 downto 0));
end entity BLANK;

-- architecture description
architecture MULTIPLEXER of BLANK is
begin
	with SHOW_WB select
	HEX5	<=	SEG5 when '1',
				B"11111111" when others;
	
	with SHOW_WB select
	HEX4	<=	SEG4 and B"01111111" when '1',
				B"01111111" when others;

	with SHOW_WB select
	HEX3	<=	SEG3 when '1',
				B"11111111" when others;
				
	with SHOW_WB select
	HEX2	<=	SEG2 when '1',
				B"11111111" when others;
				
	with SHOW_WB select
	HEX1	<=	SEG1 when '1',
				B"11111111" when others;
			
	with SHOW_WB select	
	HEX0	<=	SEG0 when '1',
				B"11111111" when others;
end architecture MULTIPLEXER;