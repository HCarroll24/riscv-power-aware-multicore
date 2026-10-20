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