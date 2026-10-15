/*************************************************************************
 * File:			memory.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Memory stage that goes has dmem
 *		Has correct registering
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Inputs:
--		A_EX				:	ALU calculation from Execute
--		STORE_DATA_EX	:	Store_data piped from decode to avoid calculation
--		FUNCT3_EX		:	Funct3 bits
--		MEMWR_EX			:	Write to memory?
--		MEMRD_EX			:	Read from memory?
--		CLK				:	Clock for synchronous read/write
--		RST				:	Reset the memory
--		CORE_ENABLE		:	CORE_EN signal to control speed
-- Outputs:
--		RDM_MEM			:	Register data memory
entity MEMORY is
port(
	A_EX				:	in		std_logic_vector(31 downto 0);
	STORE_DATA_EX	:	in		std_logic_vector(31 downto 0);
	FUNCT3_EX		:	in		std_logic_vector(2 downto 0);
	MEMWR_EX			:	in		std_logic;
	MEMRD_EX			:	in		std_logic;
	CLK				:	in		std_logic;
	RST				:	in		std_logic;
	CORE_ENABLE		:	in		std_logic;
	RDM_MEM			:	out	std_logic_vector(31 downto 0):
end entity MEMORY;

-- architectural stucture of memory
architecture STRUCTURAL of MEMORY is
begin
	-- data memory block
	DMEM_RAM	:	entity work.DMEM
		port map(
			A			=>	A_EX,
			RD2		=>	STORE_DATA_EX,
			FUNCT3	=>	FUNCT3_EX,
			MEMWR		=>	MEMWR_EX,
			MEMRD		=>	MEMRD_EX,
			CLK		=>	CLK,
			RST		=>	RST,
			CE			=>	CORE_ENABLE,
			RDM		=>	RDM_MEM);
			
end architecture STRUCTURAL;