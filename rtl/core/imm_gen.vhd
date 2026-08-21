-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	imm_gen.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			20 March 2026
-- Provides:
--   - Combinational RV32I immediate extractor; 
--	  - IMMSRC picks I/S/B/U/J field layout.
--   - IMM_EXT is always 32 bits with proper sign extension 
--		 for each immediate type.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
--		INSTR[31:0]		: full instruction word from IF/ID pipeline register
--		IMMSRC[2:0]		: format select drive by control unit
--						  		"000" = I-type
--						  		"001" = S-type
--						  		"010" = B-type
--						  		"011" = U-type
--						  		"100" = J-type
-- outputs:
--		IMM_EXT[31:0]	: sign-extended immediate value
entity IMM_GEN is
port(
	INSTR		: in std_logic_vector(31 downto 0);
	IMMSRC	: in std_logic_vector(2 downto 0);
	IMM_EXT	: out std_logic_vector(31 downto 0)
);
end entity IMM_GEN;

-- circuit description
architecture BEHAVIORAL of IMM_GEN is
begin
	-- select immediate format based on IMMSRC
	IMM_EXT <= (31 downto 12 => INSTR(31)) & INSTR(31 downto 20) when IMMSRC = B"000" else		-- I-type
				  (31 downto 12 => INSTR(31)) & INSTR(31 downto 25) & INSTR(11 downto 7) when IMMSRC = B"001" else		-- S-type
				  (31 downto 13 => INSTR(31)) & INSTR(31) & INSTR(7) & INSTR(30 downto 25) & INSTR(11 downto 8) & '0' when IMMSRC = B"010" else	-- B-type
				  INSTR(31 downto 12) & (11 downto 0 => '0') when IMMSRC = B"011" else	-- U-type
				  (31 downto 21 => INSTR(31)) & INSTR(31) & INSTR(19 downto 12) & INSTR(20) & INSTR(30 downto 21) & '0' when IMMSRC = B"100" else	-- J-type
				  X"00000000";
	
end architecture BEHAVIORAL;