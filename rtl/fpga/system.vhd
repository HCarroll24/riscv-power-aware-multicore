/**********************************************************
 *	Filename:	system.vhd
 * Author:		carrollh@msoe.edu <Hunter C>
 * Project: 	Power-Aware RISC-V Processor
 * Date:			14 October 2026
 * Provides:	High level system explanation in VHDL for
 *					memory-mapped I/O Functionality.
**********************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block diagram
-- inputs:
--		sysrst		:	the system reset button
--		clk			:	System clock
--		sliders		:	slider switches on board
--		btn			:	Buttons 3..1
--		
entity SYSTEM is
port(
	);