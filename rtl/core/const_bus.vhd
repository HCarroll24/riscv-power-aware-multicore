-- ***********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	const_bus.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			15 September 2026
-- Provides:
--		- constant-valued bus for schematic datapath
--		- Replaces lpm_constant for porting to vivado
-- ***********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block sybol
-- generic:
--		WIDTH	:	bus width in bits
--		VALUE	:	constant this block drives
-- outputs:
--		Y		: constant, width bits wide
entity CONST_BUS is
generic(
	WIDTH	:	natural	:=	32;
	VALUE	:	natural	:=	0);
port(
	Y		:	out std_logic_vector(WIDTH-1 downto 0));
end entity CONST_BUS;

-- circuit description
architecture DATAFLOW of CONST_BUS is
begin
	Y	<=	std_logic_vector(to_unsigned(VALUE, WIDTH));
end architecture DATAFLOW;