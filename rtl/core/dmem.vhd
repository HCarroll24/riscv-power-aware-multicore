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
	RD2		:	in std_logic_vector(31 downto 0);
	FUNCT3	:	in std_logic_vector(2 downto 0);
	MEMWR		:	in std_logic;
	MEMRD		: 	in std_logic;
	CLK		:	in std_logic;
	RST		:	in std_logic;
	RDM		:	out std_logic_vector(31 downto 0)
);
end entity DMEM;

architecture INFERRED of DMEM is
	constant ADDR_BITS : natural := 12;
	constant RAM_WORDS : natural := 2**ADDR_BITS;
	
	type WORD_T is array(0 to 3) of std_logic_vector(7 downto 0);
	type MEMARRAY is array(0 to RAM_WORDS-1) of WORD_T;

	-- RISC-V is byte addressible and I want 32,768 bits of memory for words
	signal MEM : MEMARRAY := (others => (others => (others => '0')));
	attribute ramstyle : string;
	attribute ramstyle of MEM : signal is "M9K";
	
	-- EX stage signals feeding into RAM
	signal RAM_ADDR : natural range 0 to RAM_WORDS-1;
	signal RAM_BYTE_ENABLE : std_logic_vector(3 downto 0);
	signal RAM_WDATA : std_logic_vector(31 downto 0);
	signal RAM_WREN : std_logic;
	
	-- MEM-STAGE SIGNALS
	signal RAM_Q_W :  WORD_T;
	signal RAM_Q	:	std_logic_vector(31 downto 0);
	signal RDM_FMT :	std_logic_vector(31 downto 0);
	
	-- pipeline registers for ex_mem
	-- needed to have proper pipeline timing
	signal FUNCT3_R : std_logic_vector(2 downto 0);
	signal OFFSET_R : std_logic_vector(1 downto 0);
	signal MEMRD_R	 : std_logic;
	
	-- simulation only misalingment flag
	signal MISALIGNED	:	std_logic;
begin
	-- EX stage: word address
	RAM_ADDR	<=	to_integer(unsigned(A(ADDR_BITS+1 downto 2)));
	
	-- EX stage: store byte-enable generation
	STORE_BYTE_EN_A: process(all)
	begin
		case FUNCT3(1 downto 0) is
			when B"00" => 												-- sb
				case A(1 downto 0) is
					when B"00" => RAM_BYTE_ENABLE <= B"0001";
					when B"01" => RAM_BYTE_ENABLE <= B"0010";
					when B"10" => RAM_BYTE_ENABLE <= B"0100";
					when others => RAM_BYTE_ENABLE <= B"1000";
				end case;
			when B"01" => 												-- sh
				if A(1) = '0' then
					RAM_BYTE_ENABLE <= B"0011";
				else
					RAM_BYTE_ENABLE <= B"1100";
				end if;
			when B"10" =>												-- sw
				RAM_BYTE_ENABLE <= B"1111";
			when others =>												-- undefined store, should never reach
				RAM_BYTE_ENABLE <= B"0000";
		end case;
	end process STORE_BYTE_EN_A;
	
	-- EX stage: store data lane replication
	with FUNCT3(1 downto 0) select
	RAM_WDATA	<=	RD2(7 downto 0) & RD2(7 downto 0) & RD2(7 downto 0) & RD2(7 downto 0) when B"00",
						RD2(15 downto 0) & RD2(15 downto 0) when B"01",
						RD2 when others;
						
	-- EX stage: 	write enable 	-- the one irrevocable signal
	RAM_WREN	<=	MEMWR and not RST;
	
	-- Inferred byte-enable single port block ram
	BLOCK_RAM: process(all)
	begin
		if rising_edge(CLK) then
			if RAM_WREN = '1' then 
				if RAM_BYTE_ENABLE(0) = '1' then
					MEM(RAM_ADDR)(0)	<=	RAM_WDATA(7 downto 0);
				end if;
				if RAM_BYTE_ENABLE(1) = '1' then
					MEM(RAM_ADDR)(1)	<=	RAM_WDATA(15 downto 8);
				end if;
				if RAM_BYTE_ENABLE(2) = '1' then
					MEM(RAM_ADDR)(2)	<=	RAM_WDATA(23 downto 16);
				end if;
				if RAM_BYTE_ENABLE(3) = '1' then
					MEM(RAM_ADDR)(3)	<=	RAM_WDATA(31 downto 24);
				end if;
			end if;
			
			RAM_Q_W	<=	MEM(RAM_ADDR);
		end if;
	end process BLOCK_RAM;
	
	RAM_Q	<=	RAM_Q_W(3) & RAM_Q_W(2) & RAM_Q_W(1) & RAM_Q_W(0);
	
	-- EX -> MEM Shadow Pipeline Registers
	SHADOW_PIPE: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				FUNCT3_R	<=	(others => '0');
				OFFSET_R <= (others => '0');
				MEMRD_R <= '0';
			else
				FUNCT3_R <= FUNCT3;
				OFFSET_R <= A(1 downto 0);
				MEMRD_R <= MEMRD;
			end if;
		end if;
	end process SHADOW_PIPE;
	
	-- MEM stage: load formatting
	LOAD_FORMAT: process(all)
	begin
		case FUNCT3_R is
			when B"000" =>							-- lb, sign extended
				case OFFSET_R is
					when B"00" =>
						RDM_FMT	<=	(31 downto 8 => RAM_Q(7)) & RAM_Q(7 downto 0);
					when B"01" =>
						RDM_FMT	<= (31 downto 8 => RAM_Q(15)) & RAM_Q(15 downto 8);
					when B"10" =>
						RDM_FMT	<= (31 downto 8 => RAM_Q(23)) & RAM_Q(23 downto 16);
					when others =>
						RDM_FMT	<= (31 downto 8 => RAM_Q(31)) & RAM_Q(31 downto 24);
				end case;
			
			when B"001" =>							-- lh, sign extended
				if OFFSET_R(1) = '0' then
					RDM_FMT	<=	(31 downto 16 => RAM_Q(15)) & RAM_Q(15 downto 0);
				else
					RDM_FMT	<= (31 downto 16 => RAM_Q(31)) & RAM_Q(31 downto 16);
				end if;
			
			when B"010"	=>							--lw, full word
				RDM_FMT	<=	RDM;
			
			when B"100"	=>							-- lbu, zero extended
				case OFFSET_R is
					when B"00" =>
						RDM_FMT	<=	(31 downto 8 => '0') & RAM_Q(7 downto 0);
					when B"01" =>
						RDM_FMT	<=	(31 downto 8 => '0') & RAM_Q(15 downto 8);
					when B"10" =>
						RDM_FMT	<=	(31 downto 8 => '0') & RAM_Q(23 downto 16);
					when others =>
						RDM_FMT	<=	(31 downto 8 => '0') & RAM_Q(31 downto 24);
				end case;
			
			when B"101"	=>							-- lhu, zero extended
				if OFFSET_R(1) = '0' then
					RDM_FMT	<=	(31 downto 16 => '0') & RAM_Q(15 downto 0);
				else
					RDM_FMT	<= (31 downto 16 => '0') & RAM_Q(31 downto 16);
				end if;
				
			when others	=>							-- not defined load width
				RDM_FMT	<= (others => '0');
		end case;
	end process LOAD_FORMAT;
	
	-- MEM STAGE: OUTPUT GATE
	RDM	<=	RDM_FMT when MEMRD_R = '1' else (others => '0');
	
	-- Simulation only checks
	MISALIGNED	<=	'1' when (MEMWR = '1' or MEMRD = '1') and
											((FUNCT3(1 downto 0) = B"10" and A(1 downto 0) /= B"00") or
											 (FUNCT3(1 downto 0) = B"01" and A(0) /= '0')) else 
						'0';
						 
	-- pragma translate_off
	CHECKS: process(CLK)
	begin
		if rising_edge(CLK) then
			assert MISALIGNED = '0'
				report "DMEM: misaligned access -- unsupported, folded into containing word"
				severity error;
			assert not ((MEMWR = '1' or MEMRD = '1') and unsigned(A(31 downto ADDR_BITS+2)) /= 0)
				report "DMEM: address above memory size -- silently aliasing"
				severity error;
			assert not (MEMWR = '1' and MEMRD = '1')
				report "DMEM: MEMWR and MEMRD asserted together"
				severity failure;
		end if;
	end process CHECKS;
	-- pragma translate_on
	
end architecture INFERRED;