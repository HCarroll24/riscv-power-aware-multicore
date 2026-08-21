-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	adder.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - Simple 32-bit unsigned adder on A and B; carry-out discarded,
--		 result width preserved.
--   - Built with numeric_std casts between std_logic_vector 
--		 and unsigned.
-- **********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
--  numeric_std: allows arithmetic on std_logic_vectors using typecasts
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--   A is the first 32-bit number for addition
--   B is the second 32-bit number for addition 
-- outputs
--   S is the 32-bit output result
entity ADDER is 
port(A, B: in std_logic_vector(31 downto 0);
     S: out std_logic_vector(31 downto 0));
end entity ADDER;

-- circuit description 
architecture DATAFLOW of ADDER is 
begin

  -- program counter addition is unsigned 
  -- it is okay to do inline typecasting 
  S <= std_logic_vector(unsigned(A) + unsigned(B));

end architecture DATAFLOW;