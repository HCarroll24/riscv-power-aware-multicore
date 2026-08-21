-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	reg1.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			2 April 2026
-- Provides:
--   - Single-bit register with synchronous 
--	    load/reset and a synchronous flush input.
-- **********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs:
--   D is a n-bit input number for storage 
--   LD is an active-high sychronous load control signal 
--   RST is an active-high synchronous reset signal 
--   CLK is a rising-edge triggered clock 
--	  FLUSH is an active-high flush signal
-- outputs
--   Q is a n-bit stored output number
entity REG1 is
port(
	RST, CLK		:	in std_logic;
	LD				:	in std_logic;
	FLUSH			:	in std_logic;
	D				:	in std_logic;
	Q				:	out std_logic);
end entity REG1;

-- Circuit Description
architecture BEHAVIORAL of REG1 is
begin
	-- single process with synchronous reset for pipelining
	reg:	process(LD, RST, CLK, FLUSH)
	begin
		if rising_edge(CLK) then
			if RST = '1' or FLUSH = '1' then
				Q	<=	'0';
			elsif LD = '1' then
				Q	<=	D;
			end if;
		end if;
	end process reg;
end architecture BEHAVIORAL;