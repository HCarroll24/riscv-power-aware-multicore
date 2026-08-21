-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	dmem.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
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
--		A[31..0]		:	The ALU result from the execute stage
--		RD2[31..0]	:	Data in register 2 for store instructions
--		FUNCT3[31..]:	Function bits to determine size of store and load
--		MEMWR			:	Write enable
--		MEMRD			:	Read enable
--		CLK			:	clock signal for synchronous writes
--		RST			:	Reset signal
-- outputs:
--		RD				:	The data from memory for load instructions
entity DMEM is
port(
	A			:	in std_logic_vector(31 downto 0);
	RD2		:	in std_logic_vector(31 downto 0);
	FUNCT3	:	in std_logic_vector(2 downto 0);
	MEMWR		:	in std_logic;
	MEMRD		:	in std_logic;
	CLK		:	in std_logic;
	RST		:	in std_logic;
	RDM		:	out std_logic_vector(31 downto 0)
);
end entity DMEM;

architecture BEHAVIORAL of DMEM is
	-- RISC-V is byte addressible and I want 256 bytes of memory for 32 words
	--	indexed high to low
	type MEMARRAY is array(255 downto 0) of std_logic_vector(7 downto 0);
	signal MEM: MEMARRAY;
	
	-- alias to allow cleaner vhdl logic
	alias ADDR	:	std_logic_vector(7 downto 0) is A(7 downto 0);
begin
	-- asynhcronous read
	--	FUNCT3[3] distinguised signed from unsigned
	-- FUNCT3[1:0] selects byte, halfword, or word width
	--	lbu and lhu have zero extended from 31 downto 8/16
	READ_MEM:	process(all)
	begin
		if MEMRD = '1' then
			if FUNCT3 = B"000" then -- lb
				RDM	<=	(31 downto 8 => MEM(to_integer(unsigned(ADDR)))(7))
						& MEM(to_integer(unsigned(ADDR)));
			elsif FUNCT3 = B"001" then	-- lh
				RDM	<=	(31 downto 16 => MEM(to_integer(unsigned(ADDR))+1)(7))
						& MEM(to_integer(unsigned(ADDR))+1)
						& MEM(to_integer(unsigned(ADDR)));
			elsif FUNCT3 = B"010" then	-- lw
				RDM	<=	MEM(to_integer(unsigned(ADDR))+3)
					 & MEM(to_integer(unsigned(ADDR))+2)
					 & MEM(to_integer(unsigned(ADDR))+1)
					 & MEM(to_integer(unsigned(ADDR)));
			elsif FUNCT3 = B"100" then -- lbu
				RDM	<=	(31 downto 8 => '0')
					 & MEM(to_integer(unsigned(ADDR)));
			elsif FUNCT3 = B"101" then	-- lhu
				RDM	<= (31 downto 16 => '0')
					 & MEM(to_integer(unsigned(ADDR))+1)
					 & MEM(to_integer(unsigned(ADDR)));
			else
				RDM	<=	(others => '0');
			end if;
		else
			RDM	<=	(others => '0');
		end if;
	end process READ_MEM;
	
	-- synchronous write update process
	-- large memory that does not have reset
	UPDATE:	process(all)
	begin
		if rising_edge(CLK) then
			if MEMWR = '1' then
				if FUNCT3(1 downto 0) = B"00" then
					MEM(to_integer(unsigned(ADDR)))	<=	RD2(7 downto 0);
				elsif FUNCT3(1 downto 0) = B"01" then
					MEM(to_integer(unsigned(ADDR)))		<=	RD2(7 downto 0);
					MEM(to_integer(unsigned(ADDR))+1)	<=	RD2(15 downto 8);
				elsif FUNCT3(1 downto 0) = B"10" then
					MEM(to_integer(unsigned(ADDR)))		<=	RD2(7 downto 0);
					MEM(to_integer(unsigned(ADDR))+1)	<= RD2(15 downto 8);
					MEM(to_integer(unsigned(ADDR))+2)	<= RD2(23 downto 16);
					MEM(to_integer(unsigned(ADDR))+3)	<= RD2(31 downto 24);
				end if;
			end if;
		end if;
	end process UPDATE;
end architecture BEHAVIORAL;