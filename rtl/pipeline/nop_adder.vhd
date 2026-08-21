-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	nop_adder.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			5 May 2026
-- Provides:
--   - Instruction-path sanitizer: substitutes 
--		 RV32I NOP (`addi x0,x0,0`) on flush/reset or all-zero opcode.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;

entity NOP_ADDER is
port(
	INSTR_IN		:	in std_logic_vector(31 downto 0);
	FLUSH			:	in std_logic;
	RST			:	in std_logic;
	INSTR_OUT	:	out std_logic_vector(31 downto 0)
);
end entity NOP_ADDER;

architecture ADDER of NOP_ADDER is
begin
	INSTR_OUT	<=	32X"00000013" when (FLUSH or RST) else
						32X"00000013" when INSTR_IN = 32X"0" else
						INSTR_IN;
end architecture ADDER;