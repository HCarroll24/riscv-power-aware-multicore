-- ***********************************************************************
-- Project: RISC-V Multicore Power AWare
-- Filename: address_decoder.vhd
-- Author: carrollh@msoe.edu <Hunter C>
-- Date: 23 Sep 2026
-- Provides:
--		- Selection for upper or lower half of wb_value
-- ***********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block
-- inputs:
--		WD3		:	Write data value to register
--		RD_ADDR	:	Register to write data to
--		UL_SEL	:	Selects upp 16 bits or lower 16 bits of wd3
-- outputs:
--		A			:	Value to write to 7 segment display
entity ADDRESS_DECODER is
port(
	WD3		:	in	std_logic_vector(31 downto 0);
	RD_ADDR	:	in std_logic_vector(4 downto 0);
	UL_SEL	:	in std_logic;
	A			:	out std_logic_vector(31 downto 0)
);
end entity ADDRESS_DECODER;

-- architectural description
architecture BEHAVIORAL of ADDRESS_DECODER is
	signal HALF	:	std_logic_vector(15 downto 0);
begin
	with UL_SEL select
	HALF	<=	WD3(31 downto 16) when '1',
				WD3(15 downto 0) when others;
				
	A		<=	X"00" & B"000" & RD_ADDR & HALF;
end architecture BEHAVIORAL;