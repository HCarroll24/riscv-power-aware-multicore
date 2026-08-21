-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	busmux6to1.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - 32-bit 6:1 bus multiplexer; S selects 
--		 among D0..D5 (with-select style).
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

entity BUSMUX6TO1 is 
port( D5, D4, D3, D2, D1, D0: in std_logic_vector(31 downto 0);
      S: in std_logic_vector(1 downto 0);
      Y: out std_logic_vector(31 downto 0));
end entity BUSMUX6TO1; 

architecture multiplexer of BUSMUX6TO1 is 
begin 

 with S select 
 Y <= D5 when B"101",
		D4 when B"100",
		D3 when B"011",
		D2 when B"010", 
      D1 when B"001", 
      D0 when others;
		
end architecture multiplexer;