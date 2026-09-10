-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	and2_32.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			10 September 2026
-- Provides:
--   - 32-bit and selection
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

entity AND2_32 is
port(	D0	:	in std_logic_vector(31 downto 0);
		D1	:	in std_logic;
		Y	:	out std_logic_vector(31 downto 0));
end entity AND2_32;

architecture behavioral of AND2_32 is
begin
	Y	<= (others => '0') when D1 = '1' else D0;
end architecture behavioral;