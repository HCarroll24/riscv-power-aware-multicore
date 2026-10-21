-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	dmem.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			3 September 2026
-- Provides:
--   - Byte-addressable data memory (256 B) backing 
--		 32-bit loads/stores; FUNCT3 sets access width.
--   - Combinational read when MEMRD is high; synchronous 
--		 byte writes when MEMWR is high on CLK.
-- **********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		CLK			:	clock, reads and writes happen on rising edge
--		A[31..0]		:	byte address from data bus
--		BE[3..0]		:	byte enables
--		WD[31..0]	:	write data, already placed in correct byte lanes
--		WE				:	write enable
--		RE				:	read enable
-- outputs:
--		Q				:	registered read data
entity DMEM is
port(
	CLK	:	in		std_logic;
	A		:	in		std_logic_vector(31 downto 0);
	BE		:	in		std_logic_vector(3 downto 0);
	WDATA	:	in		std_logic_vector(31 downto 0);
	WE		:	in		std_logic;
	RE		:	in		std_logic;
	Q		:	out	std_logic_vector(31 downto 0));
end entity DMEM;

architecture INFERRED of DMEM is
	constant ADDR_BITS : natural := 12;
	constant RAM_WORDS : natural := 2**ADDR_BITS;
	
	type WORD_T is array(0 to 3) of std_logic_vector(7 downto 0);
	type MEMARRAY is array(0 to RAM_WORDS-1) of WORD_T;

	-- RISC-V is byte addressible and I want 32,768 bits of memory for words
	signal MEM : MEMARRAY := (others => (others => (others => '0')));
	attribute ramstyle : string;
	attribute ramstyle of MEM : signal is "M20K";

	signal RAM_ADDR	:	natural range 0 to RAM_WORDS-1;
	signal RAM_Q_W		:	WORD_T;
begin
	-- word address
	RAM_ADDR	<=	to_integer(unsigned(A(ADDR_BITS+1 downto 2)));
	
	-- single-port byte-enable RAM, registered read with read enable
	BLOCK_RAM:	process(CLK)
	begin
		if rising_edge(CLK) then
			if WE = '1' then
				if BE(0) = '1' then
					MEM(RAM_ADDR)(0)	<=	WDATA(7 downto 0);
				end if;
				if BE(1) = '1' then
					MEM(RAM_ADDR)(1)	<=	WDATA(15 downto 8);
				end if;
				if BE(2) = '1' then
					MEM(RAM_ADDR)(2)	<=	WDATA(23 downto 16);
				end if;
				if BE(3) = '1' then
					MEM(RAM_ADDR)(3)	<=	WDATA(31 downto 24);
				end if;
			end if;
			
			if RE = '1' then
				RAM_Q_W	<=	MEM(RAM_ADDR);
			end if;
		end if;
	end process BLOCK_RAM;
	
	Q	<=	RAM_Q_W(3) & RAM_Q_W(2) & RAM_Q_W(1) & RAM_Q_W(0);
end architecture INFERRED;