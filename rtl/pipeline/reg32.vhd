-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	reg32.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - 32-bit pipeline register with synchronous load 
--		 and asynchronous reset (RST).
-- **********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs:
--   D is a 32-bit input number for storage 
--   LD is an active-high sychronous load control signal 
--   RST is an active-high asynchronous reset signal 
--   CLK is a rising-edge triggered clock 
-- outputs
--   Q is a 32-bit stored output number

-- HINT: This is just a register. 
-- HINT: The design is a single process.

entity REG32 is 
port(D: in std_logic_vector(31 downto 0);
     LD: in std_logic; 
     RST: in std_logic;
     CLK: in std_logic;
     Q: out std_logic_vector(31 downto 0));
end entity REG32;

-- circuit description 
architecture BEHAVIORAL of REG32 is 
begin

  reg: process(LD, RST, CLK)
  begin
   if RST = '1' then Q <= X"00000000"; 
   elsif rising_edge(CLK) then 
	  if LD = '1' then Q <= D; 
	  end if; 
	end if;

  end process reg;
  
end architecture BEHAVIORAL;