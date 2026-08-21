-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	alu.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			27 February 2026
-- Provides:
--   - 32-bit combinational ALU; opcode on S selects arithmetic, logic, 
--     and shifts.
--   - Uses numeric_std for unsigned arithmetic and std_logic_vector casts.
-- Notes:
--   - S encoding: 0 add, 1 sll, 2 slt, 3 sltu, 4 xor, 5 srl, 6 or, 7 and,
--     8 sub, 13 sra (others reserved / unused in this design).
-- **********************************************************************

-- library packages
--   std_logic_1164: 9-valued logic signal voltages 
--   numeric_std: unsigned, type conversions 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- A, B, and F are 32-bit voltage vectors
-- S is a 4-bit voltage vector selecting a particular function
entity ALU is 
port(A:		in std_logic_vector(31 downto 0);
     B:		in std_logic_vector(31 downto 0);
     S:     in std_logic_vector(3 downto 0);
     F:		out std_logic_vector(31 downto 0)); 
end entity ALU;


-- internal circuit  
architecture DATAFLOW of ALU is 

  -- 32-bit addition results in carry-out as bit 33 
  -- use 33-bit unsigned number to store that extra carry-out bit
  
  -- logic will be typecast to unsigned integers
  -- signed matters if using >, <, =, /= comparisons
  -- the ALU does not use these and thus unsigned is fine
  signal INTA: unsigned(32 downto 0);
  signal INTB: unsigned(32 downto 0);
  signal INTF: unsigned(32 downto 0);
  
  -- overflow occurs when two positives add to a negative 
  -- overflow occurs when two negatives add to a positive 
  -- overflow occurs when negative minus positive gives positive 
  -- overflow occurs when positive minus negative gives negative 
  -- use internal signal and create logic equation  
  
  -- set less than values need to be calculated beforehand
  signal SLT_VAL, SLTU_VAL: unsigned(32 downto 0);
  
  -- signals for shifting to allow cleaner with S select
  signal SRA_VAL: unsigned(32 downto 0);
  signal SLL_VAL, SRL_VAL: unsigned(32 downto 0);
  
begin
  -- connect INTA and INTB to the inputs 
  -- inputs are only 32-bits, from bits 31 downto 0
  -- set bit 32 of 33-bit number to 0
  INTA(32) <= '0';
  INTA(31 downto 0) <= unsigned(A);
  INTB(32) <= '0';
  INTB(31 downto 0) <= unsigned(B);
  
  -- Logic for slt and sltu
  SLT_VAL <= 33x"1" when (signed(A) < signed(B)) else 33x"0";
  SLTU_VAL <= 33x"1" when (INTA < INTB) else 33x"0";
  
  -- Logic for shifts 
  SRA_VAL <= '0' & unsigned(shift_right(signed(A), to_integer(INTB)));
  SLL_VAL <= shift_left(INTA, to_integer(INTB(4 downto 0)));
  SRL_VAL <= shift_right(INTA, to_integer(INTB(4 downto 0)));
  
  -- complete the arithmetic and logic 
  -- numeric_std defines +, -, bitwise logic, etc. on unsigned type
  with S select 
  INTF <= INTA + INTB when B"0000", 	-- add
			 SLL_VAL when B"0001", 			-- sll
			 SLT_VAL when B"0010",			-- slt
			 SLTU_VAL when B"0011",			-- sltu
			 INTA xor INTB when B"0100",	-- xor
			 SRL_VAL when B"0101",			-- srl
			 INTA or INTB when B"0110",	-- or
			 INTA and INTB when B"0111",	-- and
			 INTA - INTB when B"1000",		-- sub
			 SRA_VAL when B"1101",			-- sra
			 33x"ABC" when others;			-- error code for debugging
			 		 
  -- typecast the lower 32-bits of the unsigned to the
  -- output as a std_logic_vector: hint use 31 downto 0
  F <= std_logic_vector(INTF(31 downto 0)); 
end architecture DATAFLOW;
