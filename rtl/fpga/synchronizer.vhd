/*************************************************************************
 * File:			synhcronizer.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			15 October 2026
 * Provides:
 *		Synchronizer for inputs on clock edges
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Function block prototype
-- Inputs:
--		SYSRST	:	Reset input form user
--		CLK		:	clock to synchronize with
-- Outputs:
--		RST		:	synchronized reset signal after 2 dff
entity SYNCHRONIZER is
port(
	SYSRST	:	in		std_logic;
	CLK		:	in		std_logic;
	RST		:	out	std_logic);
end entity SYNCHRONIZER;

-- architectural description
architecture BEHAVIORAL of SYNCHRONIZER is
	-- two flip flop chain
	signal SYNC_1	:	std_logic	:=	'0';
	signal SYNC_2	:	std_logic	:=	'0';
begin
	-- asynchronous clear, synchronous release
	sync:	process(CLK, SYSRST)
	begin
		if SYSRST = '0' then
			SYNC_1	<=	'0';
			SYNC_2	<=	'0';
		elsif rising_edge(CLK) then
			SYNC_1	<=	'1';
			SYNC_2	<=	SYNC_1;
		end if;
	end process sync;
	
	-- active-high reset for the rest of the system
	RST	<=	not SYNC_2;
end architecture BEHAVIORAL;