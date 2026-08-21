-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	busmux4to1.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - 32-bit 4:1 bus multiplexer
--	  - S selects among D0..D3 (with-select style).
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

entity busmux4to1 is 
port( D3, D2, D1, D0: in std_logic_vector(31 downto 0);
      S: in std_logic_vector(1 downto 0);
      Y: out std_logic_vector(31 downto 0));
end entity busmux4to1; 

architecture multiplexer of busmux4to1 is 
begin 

 with S select 
 Y <= D3 when B"11",
		D2 when B"10", 
      D1 when B"01", 
      D0 when others;
		
end architecture multiplexer;