-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	forwarding_unit.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - Combinational forwarding/operand bypass control 
--		 for EX-stage RS1/RS2 (and branch paths).
--   - Compares rs1/rs2 against pending destinations in EX/MEM, 
--		 MEM/WB, and WB with REGWR/MEMRD gating.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- Function block
entity FORWARDING_UNIT is
port(
	RS1_ADDR			:	in std_logic_vector(4 downto 0);
	RS2_ADDR			:	in std_logic_vector(4 downto 0);
	RD_ADDR_EX_MEM	:	in std_logic_vector(4 downto 0);
	REGWR_EX_MEM	:	in std_logic;
	RD_ADDR_MEM_WB	:	in std_logic_vector(4 downto 0);
	REGWR_MEM_WB	:	in std_logic;
	MEMRD_MEM_WB	:	in std_logic;
	RD_ADDR_WB		:	in std_logic_vector(4 downto 0);
	REGWR_WB			:	in std_logic;
	OPCODE			:	in std_logic_vector(6 downto 0);
	BSEL				: 	out std_logic_vector(2 downto 0);
	ASEL				:	out std_logic_vector(2 downto 0);
	ASEL_BR			:	out std_logic_vector(2 downto 0);
	BSEL_BR			:	out std_logic_vector(2 downto 0)
);
end entity FORWARDING_UNIT;

-- architecture
-- 000 = Data from write-back stage
-- 001 = Result from the memory unit
-- 010 = ALU_Result in the memory stage
-- 011 = ALU_Result in the Execute stage
-- 100 = no forwarding
architecture BEHAVIORAL of FORWARDING_UNIT is

begin
	ASEL <= 	B"100" when (OPCODE = B"1101111" or OPCODE = B"0010111" or OPCODE = B"1100011") else -- jal, B-type, and auipc
				B"011" when (REGWR_EX_MEM = '1' and RD_ADDR_EX_MEM /= B"00000" and RD_ADDR_EX_MEM = RS1_ADDR) else
				B"001" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS1_ADDR and MEMRD_MEM_WB = '1') else
				B"010" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS1_ADDR and MEMRD_MEM_WB = '0') else
				B"000" when (REGWR_WB = '1' and RD_ADDR_WB /= B"00000" and RD_ADDR_WB = RS1_ADDR) else
				B"100";
				
	BSEL <= 	B"100" when (OPCODE = B"0010011") else
				B"011" when (REGWR_EX_MEM = '1' and RD_ADDR_EX_MEM /= B"00000" and RD_ADDR_EX_MEM = RS2_ADDR) else
				B"001" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS2_ADDR and MEMRD_MEM_WB = '1') else
				B"010" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS2_ADDR and MEMRD_MEM_WB = '0') else
				B"000" when (REGWR_WB = '1' and RD_ADDR_WB /= B"00000" and RD_ADDR_WB = RS2_ADDR) else
				B"100";
				
	ASEL_BR <=  B"011" when (REGWR_EX_MEM = '1' and RD_ADDR_EX_MEM /= B"00000" and RD_ADDR_EX_MEM = RS1_ADDR) else
					B"001" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS1_ADDR and MEMRD_MEM_WB = '1') else
					B"010" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS1_ADDR and MEMRD_MEM_WB = '0') else
					B"000" when (REGWR_WB = '1' and RD_ADDR_WB /= B"00000" and RD_ADDR_WB = RS1_ADDR) else
					B"100";

	BSEL_BR <=  B"011" when (REGWR_EX_MEM = '1' and RD_ADDR_EX_MEM /= B"00000" and RD_ADDR_EX_MEM = RS2_ADDR) else
					B"001" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS2_ADDR and MEMRD_MEM_WB = '1') else
					B"010" when (REGWR_MEM_WB = '1' and RD_ADDR_MEM_WB /= B"00000" and RD_ADDR_MEM_WB = RS2_ADDR and MEMRD_MEM_WB = '0') else
					B"000" when (REGWR_WB = '1' and RD_ADDR_WB /= B"00000" and RD_ADDR_WB = RS2_ADDR) else
					B"100";
end architecture BEHAVIORAL;