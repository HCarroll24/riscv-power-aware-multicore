-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	regfile.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			12 March 2026
-- Provides:
--   - Three-read, one-write RV32I-style register file 
--     (x0 hard-wired to zero in logic).
--   - RD1/RD2/RD3 addressed by A1/A2/A3;
--   - WD3 written on rising edge when REGWR is high.
-- **********************************************************************

-- use library packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs: 
--    A1		: 5-bit address specifying read register rs1 instr[19:15]
--		A2		: 5-bit address specifying read register rs2 instr[24:20]
--		A3		: 5-bit address specifying write register rd instr[11:7]
--		WD3	: 32-bit data to be stored in register addressed by A3
--		REGWR : active-high control signal, '1' enables write on rising
--		RST	: active-high reset, '1' clears all registers
--		CLK	: clock for synchronized writes
-- outputs:
--		RD1	: 32-bit output from register specified by address A1
--		RD2	: 32-bit output from register specified by address A2
entity REGFILE is 
generic(
	READ_GATE		:	boolean	:=	false
);
port(
	A1, A2, A3		:	in std_logic_vector(4 downto 0);
	WD3				:	in std_logic_vector(31 downto 0);
	REGWR				: 	in std_logic;
	USE_A1, USE_A2	:	in std_logic;
	RST, CLK			: 	in std_logic;
	RD1, RD2			:	out std_logic_vector(31 downto 0)
);
end entity REGFILE;

-- circuit description
architecture BEHAVIORAL of REGFILE is
	-- 32 x 32 storage, one copy per read port
	-- x0 lives at address 0: it is zero at power-up, zeroed by reset signal
	-- clear, and never written by an instruction (A3 = 0 is discarded)
	type RAM_T is array(0 to 31) of std_logic_vector(31 downto 0);
	signal RAM1	:	RAM_T	:=	(others => (others => '0'));
	signal RAM2	:	RAM_T	:=	(others => (others => '0'));
	attribute ramstyle	:	string;
	attribute ramstyle of RAM1	:	signal is "M20K";
	attribute ramstyle of RAM2	:	signal is "M20K";
	
	-- read side
	signal RF_EN1, RF_EN2	:	std_logic;
	signal RAM_RA1, RAM_RA2	:	natural range 0 to 31;
	signal RAM_Q1, RAM_Q2	:	std_logic_vector(31 downto 0)	:=	(others => '0');
	
	-- write port: instruction write or clear
	signal CLR_CNT		:	unsigned(4 downto 0)	:=	(others => '0');
	signal WR_VALID	:	std_logic;
	signal RAM_WE		:	std_logic;
	signal RAM_WA		:	natural range 0 to 31;
	signal RAM_WD		:	std_logic_vector(31 downto 0);
	
	-- write-first bypass: the read muxes drive
	-- output ports choose between them and WD3
	signal BYP1, BYP2			:	std_logic;
	
begin
	-- read enable
	-- ready copy k only if the IF/ID instruction reads rs_k (output is
	-- forced to zero otherwise, so the hold RAM_Qk is never seen)
	RF_EN1	<=	USE_A1 when READ_GATE else '1';
	RF_EN2	<=	USE_A2 when READ_GATE else '1';
	
	RAM_RA1	<=	to_integer(unsigned(A1));
	RAM_RA2	<=	to_integer(unsigned(A2));
	
	-- WRITE PORT
	-- valid instruction write: x0 and writes during reset are discarded
	WR_VALID	<=	'1' when (RST = '0' and REGWR = '1' and A3 /= B"00000") else '0';
	
	-- reset clear walks every address through normal write port
	RAM_WE	<=	RST or WR_VALID;
	
	with RST select
		RAM_WA	<=	to_integer(CLR_CNT) when '1',
						to_integer(unsigned(A3)) when others;
						
	with RST select
		RAM_WD	<=	(others => '0') when '1',
						WD3	when others;
						
	-- reset clear counter
	CLEAR_COUNTER:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				CLR_CNT	<=	CLR_CNT + 1;
			end if;
		end if;
	end process CLEAR_COUNTER;
	
	-- RAM COPY 1 WRITE (rising edge)
	RAM_WRITE1:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RAM_WE = '1' then
				RAM1(RAM_WA)	<=	RAM_WD;
			end if;
		end if;
	end process RAM_WRITE1;
	
	-- RAM COPY 2 WRITE (rising edge)
	RAM_WRITE2:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RAM_WE = '1' then
				RAM2(RAM_WA)	<=	RAM_WD;
			end if;
		end if;
	end process RAM_WRITE2;
	
	-- RAM COPY 1 READ (rs1, falling edge)
	RAM_READ1:	process(CLK)
	begin
		if falling_edge(CLK) then
			if RF_EN1 = '1' then
				RAM_Q1	<=	RAM1(RAM_RA1);
			end if;
		end if;
	end process RAM_READ1;
	
	-- RAM COPY 2 READ (rs2, falling edge)
	RAM_READ2:	process(CLK)
	begin
		if falling_edge(CLK) then
			if RF_EN2 = '1' then
				RAM_Q2	<=	RAM2(RAM_RA2);
			end if;
		end if;
	end process RAM_READ2;
	
	-- WRITE-FIRST BYPASS (read-during write, same as flip-flop version)
	-- write at end of this ID cycle to the IF/ID address
	BYP1	<=	'1' when (RST = '0' and REGWR = '1' and A3 /= B"00000" and A3 = A1) else '0';
	BYP2	<=	'1' when (RST = '0' and REGWR = '1' and A3 /= B"00000" and A3 = A2) else '0';
	
	-- output select
	-- priority select: unused source -> 0, write at end of this cycle (BYP),
	-- then the RAM output
	RD1	<=	(others => '0') when USE_A1 = '0' else
				WD3 when BYP1 = '1' else
				RAM_Q1;
				
	RD2	<=	(others => '0') when USE_A2 = '0' else
				WD3 when BYP2 = '1' else
				RAM_Q2;
end architecture BEHAVIORAL;