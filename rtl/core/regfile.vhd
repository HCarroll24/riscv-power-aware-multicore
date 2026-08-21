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
port(
	A1, A2, A3	:	in std_logic_vector(4 downto 0);
	WD3			:	in std_logic_vector(31 downto 0);
	REGWR			: 	in std_logic;
	RST, CLK		: 	in std_logic;
	RD1, RD2		:	out std_logic_vector(31 downto 0)
	);
end entity REGFILE;

-- circuit description
architecture BEHAVIORAL of REGFILE is
	-- declare 32 32-bit registers that will be used as outputs
   signal X0	: std_logic_vector(31 downto 0);
	signal X1	: std_logic_vector(31 downto 0);	
   signal X2	: std_logic_vector(31 downto 0);
	signal X3	: std_logic_vector(31 downto 0);
	signal X4	: std_logic_vector(31 downto 0);
	signal X5	: std_logic_vector(31 downto 0);	
   signal X6	: std_logic_vector(31 downto 0);
	signal X7	: std_logic_vector(31 downto 0);	
	signal X8	: std_logic_vector(31 downto 0);
	signal X9	: std_logic_vector(31 downto 0);	
   signal X10	: std_logic_vector(31 downto 0);
	signal X11	: std_logic_vector(31 downto 0);	
	signal X12	: std_logic_vector(31 downto 0);
	signal X13	: std_logic_vector(31 downto 0);	
   signal X14	: std_logic_vector(31 downto 0);
	signal X15	: std_logic_vector(31 downto 0);
	signal X16	: std_logic_vector(31 downto 0);
	signal X17	: std_logic_vector(31 downto 0);
	signal X18	: std_logic_vector(31 downto 0);
	signal X19	: std_logic_vector(31 downto 0);
	signal X20	: std_logic_vector(31 downto 0);
	signal X21	: std_logic_vector(31 downto 0);
	signal X22	: std_logic_vector(31 downto 0);
	signal X23	: std_logic_vector(31 downto 0);
	signal X24	: std_logic_vector(31 downto 0);
	signal X25	: std_logic_vector(31 downto 0);
	signal X26	: std_logic_vector(31 downto 0);
	signal X27	: std_logic_vector(31 downto 0);
	signal X28	: std_logic_vector(31 downto 0);
	signal X29	: std_logic_vector(31 downto 0);
	signal X30	: std_logic_vector(31 downto 0);
	signal X31	: std_logic_vector(31 downto 0);
	
begin
	-- X0 is hardwired to 0
	X0 <= X"00000000";
	
	-- READ PORT 1
	-- Selects one of the registers based on A1
	with A1 select
	RD1 <= X0  when B"00000",
			 X1  when B"00001",
			 X2  when B"00010",
			 X3  when B"00011",
			 X4  when B"00100",
			 X5  when B"00101",
			 X6  when B"00110",
			 X7  when B"00111",
			 X8  when B"01000",
			 X9  when B"01001",
			 X10 when B"01010",
			 X11 when B"01011",
			 X12 when B"01100",
			 X13 when B"01101",
			 X14 when B"01110",
			 X15 when B"01111",
			 X16 when B"10000",
			 X17 when B"10001",
			 X18 when B"10010",
			 X19 when B"10011",
			 X20 when B"10100",
			 X21 when B"10101",
			 X22 when B"10110",
			 X23 when B"10111",
			 X24 when B"11000",
			 X25 when B"11001",
			 X26 when B"11010",
			 X27 when B"11011",
			 X28 when B"11100",
			 X29 when B"11101",
			 X30 when B"11110",
			 X31 when others;
			 
	-- READ PORT 2 (rs2)
	-- identical to RD1 but with A2 driven
	with A2 select
	RD2 <= X0  when B"00000",
			 X1  when B"00001",
			 X2  when B"00010",
			 X3  when B"00011",
			 X4  when B"00100",
			 X5  when B"00101",
			 X6  when B"00110",
			 X7  when B"00111",
			 X8  when B"01000",
			 X9  when B"01001",
			 X10 when B"01010",
			 X11 when B"01011",
			 X12 when B"01100",
			 X13 when B"01101",
			 X14 when B"01110",
			 X15 when B"01111",
			 X16 when B"10000",
			 X17 when B"10001",
			 X18 when B"10010",
			 X19 when B"10011",
			 X20 when B"10100",
			 X21 when B"10101",
			 X22 when B"10110",
			 X23 when B"10111",
			 X24 when B"11000",
			 X25 when B"11001",
			 X26 when B"11010",
			 X27 when B"11011",
			 X28 when B"11100",
			 X29 when B"11101",
			 X30 when B"11110",
			 X31 when others;
			 
	-- WRITE PORT (individual per register)
	-- RST = '1' clears all writable registers t0 zero
	-- REGWR = '1' for synchronous load for active-low
	reg1:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X1 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00001" then
					X1 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg2:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X2 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00010" then
					X2 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg3:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X3 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00011" then
					X3 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg4:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X4 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00100" then
					X4 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg5:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X5 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00101" then
					X5 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg6:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X6 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00110" then
					X6 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg7:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X7 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"00111" then
					X7 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg8:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X8 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01000" then
					X8 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg9:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X9 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01001" then
					X9 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg10:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X10 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01010" then
					X10 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg11:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X11 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01011" then
					X11 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg12:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X12 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01100" then
					X12 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg13:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X13 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01101" then
					X13 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg14:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X14 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01110" then
					X14 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg15:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X15 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"01111" then
					X15 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg16:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X16 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10000" then
					X16 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg17:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X17 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10001" then
					X17 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg18:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X18 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10010" then
					X18 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg19:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X19 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10011" then
					X19 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg20:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X20 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10100" then
					X20 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg21:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X21 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10101" then
					X21 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg22:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X22 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10110" then
					X22 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg23:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X23 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"10111" then
					X23 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg24:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X24 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11000" then
					X24 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg25:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X25 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11001" then
					X25 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg26:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X26 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11010" then
					X26 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg27:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X27 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11011" then
					X27 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg28:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X28 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11100" then
					X28 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg29:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X29 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11101" then
					X29 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg30:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X30 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11110" then
					X30 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
	reg31:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				X31 <= X"00000000";
			elsif REGWR = '1' then
				if A3 = B"11111" then
					X31 <= WD3;
				end if;
			end if;
		end if;
	end process;
	
end architecture BEHAVIORAL;