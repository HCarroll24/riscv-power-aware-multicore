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
--		A[31..0]		:	The ALU result from the execute stage
--		WD[31..0]	:	Data in register 2 for store instructions
--		FUNCT3[31..]:	Function bits to determine size of store and load
--		MEMWR			:	Write enable
--		CLK			:	clock signal for synchronous writes
--		RST			:	Reset signal
-- outputs:
--		RD				:	The data from memory for load instructions
entity DMEM is
port(
	A			:	in std_logic_vector(31 downto 0);
	WD		:	in std_logic_vector(31 downto 0);
	FUNCT3	:	in std_logic_vector(2 downto 0);
	MEMWR		:	in std_logic;
	MEMRD		: 	in std_logic;
	CLK		:	in std_logic;
	RST		:	in std_logic;
	RDM		:	out std_logic_vector(31 downto 0)
);
end entity DMEM;

architecture BEHAVIORAL of DMEM is
	-- RISC-V is byte addressible and I want 32,768 bits of memory for words
	type MEMARRAY is array(0 to 1023) of std_logic_vector(31 downto 0);
	signal MEM: MEMARRAY := (others => (others => '0'));
	
	attribute ramstyle : string;
	attribute ramstyle of MEM : signal is "M9K, no_rw_check";
	
	-- word index into the array
	signal WORD_IDX : integer range 0 to 1023;
	
	-- write to memory helpers
	signal BYTE_ENABLES : std_logic_vector(3 downto 0);
	signal WORD_ALIGN : std_logic_vector(31 downto 0);
	
	-- memory stage signals produced by RAM
	signal RDM_WORD : std_logic_vector(31 downto 0);
	signal FUNCT3_MEM : std_logic_vector(2 downto 0);
	signal ADDR_LOW_MEM : std_logic_vector(1 downto 0);
	
	-- load alignment signals
	signal RD_BYTE : std_logic_vector(7 downto 0);
	signal RD_HALF : std_logic_vector(15 downto 0);
	
	-- memrd signal
	signal MEMRD_MEM : std_logic;
begin
	-- word index
	WORD_IDX <= to_integer(unsigned(A(11 downto 2)));
	
	-- Byte enables and lane alignment (combinational, EX stage)
	BYTE_ENABLES <= "1111" when FUNCT3(1 downto 0) = "10" else -- sw
						 "1100" when FUNCT3(1 downto 0) = "01" and A(1) = '1' else -- sh upper
						 "0011" when FUNCT3(1 downto 0) = "01" else -- sh lower
						 "1000" when a(1 downto 0) = "11" else
						 "0100" when A(1 downto 0) = "10" else
						 "0010" when A(1 downto 0) = "01" else
						 "0001";
						 
	WORD_ALIGN <= WD when FUNCT3(1 downto 0) = "10" else
					  WD(15 downto 0) & WD(15 downto 0) when FUNCT3(1 downto 0) = "01" else
					  WD(7 downto 0) & WD(7 downto 0) & WD(7 downto 0) & WD(7 downto 0);
					  
	-- The RAM itself
	MEM_PROCESS : process(CLK)
	begin
		if rising_edge(CLK) then
			-- byte-enabled write
			if MEMWR = '1' then 
				for i in 0 to 3 loop
					if BYTE_ENABLES(i) = '1' then
						MEM(WORD_IDX)(8*i+7 downto 8*i) <= WORD_ALIGN(8*i+7 downto 8*i);
					end if;
				end loop;
			end if;
			
			-- unconditional registered read
			RDM_WORD <= MEM(WORD_IDX);
			
			-- CARRY formatting controls forward into MEM
			FUNCT3_MEM <= FUNCT3;
			ADDR_LOW_MEM <= A(1 downto 0);
			MEMRD_MEM <= MEMRD;
		end if;
	end process MEM_PROCESS;
	
	-- LOAD ALIGNMENT(combinational, mem stage)
	
	RD_BYTE <= RDM_WORD(7 downto 0) when ADDR_LOW_MEM = "00" else
				  RDM_WORD(15 downto 8) when ADDR_LOW_MEM = "01" else
				  RDM_WORD(23 downto 16) when ADDR_LOW_MEM = "10" else
				  RDM_WORD(31 downto 24);
				  
	RD_HALF <= RDM_WORD(15 downto 0) when ADDR_LOW_MEM(1) = '0' ELSE
				  RDM_WORD(31 downto 16);
				  
	RDM <= std_logic_vector(resize(signed(RD_BYTE), 32)) when (MEMRD_MEM = '1' and FUNCT3_MEM = "000") else
	       std_logic_vector(resize(signed(RD_HALF), 32)) when (MEMRD_MEM = '1' and FUNCT3_MEM = "001") else
	       RDM_WORD when (MEMRD_MEM = '1' and FUNCT3_MEM = "010") else
	       std_logic_vector(resize(unsigned(RD_BYTE), 32)) when (MEMRD_MEM = '1' and FUNCT3_MEM = "100") else
	       std_logic_vector(resize(unsigned(RD_HALF), 32)) when (MEMRD_MEM = '1' and FUNCT3_MEM = "101") else
	       (others => '0');
end architecture BEHAVIORAL;