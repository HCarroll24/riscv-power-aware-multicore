-- *************************************************************
-- Project: 	Undergrad Research Multicore Processor
-- Filename: 	bht.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			8 July 2026
-- Provides:	
--		- Branch History Table: PC-indexed array of 2-bit
--		  saturating counters (00/01 = predict not taken,
--		  10/11 = predict taken).
--		- Combinational read port for fetch (PREDICT is
--		  counter MSB).
--		- Synchronous write port trained by resolved branches
--		  in EX; gated by UPDATE_EN so jumps never train
--		  table.
--		- Replaces branch_predictor.vhd (1-bit global scheme).
--	Notes:
--		- INDEX_BITS generic sizes the table (2**INDEX_BITS
--		  entries).
--		- Index taken from PC(INDEX_BITS+1 downto 2); bits
--		  1:0 skipped because word-aligned fetch addresses
--		  always have them zero.
--		- Reset initializes all entries to "01" (weakly not
--		  taken).
-- *************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		CLK				: clock for synchronous training writes
--		RST				: active-high synchronous reset (all 
--							  entries -> "01")
--		FETCH_PC[31:0]	: fetch-stage PC, reads out this cycle's
--							  prediction
--		EX_PC[31..0]	: PC of the branch resolving in EX
--							  (training index)
--		UPDATE_EN		: '1' when a real B-type branch is in EX
--							  (BRANCH_EX)
--		BR_TAKEN			: actual resolved outcome from branch_comp
-- outputs:
--		PREDICT			: '1' = predict taken for instruction

entity BHT is
generic(INDEX_BITS	:	integer := 4);
port(CLK			:	in std_logic;
	  RST			:	in std_logic;
	  FETCH_PC	:	in std_logic_vector(31 downto 0);
	  EX_PC		:	in std_logic_vector(31 downto 0);
	  UPDATE_EN	:	in std_logic;
	  BR_TAKEN	:	in std_logic;
	  PREDICT	:	out std_logic);
end entity BHT;

architecture BEHAVIORAL of BHT is
	-- table of 2-bit saturating counters
	type COUNTER_ARRAY is array(0 to (2**INDEX_BITS)-1) of std_logic_vector(1 downto 0);
	signal TABLE	:	COUNTER_ARRAY;
	
	-- index signals kept separate so the hasing scheme can be
	-- swapped later (e.g. gshare: index xor global history)
	signal RD_INDEX	:	std_logic_vector(INDEX_BITS-1 downto 0);
	signal WR_INDEX	:	std_logic_vector(INDEX_BITS-1 downto 0);
begin
	-- word-aligned instructions
	RD_INDEX		<=	FETCH_PC(INDEX_BITS+1 downto 2);
	WR_INDEX		<=	EX_PC(INDEX_BITS+1 downto 2);
	
	-- combinational read port for fetch
	-- prediction is the counter MSB: 1x = taken, 0x = not taken
	PREDICT		<=	TABLE(to_integer(unsigned(RD_INDEX)))(1);
	
	-- synchronous training port
	-- saturating increment on taken, saturating decrement on not taken
	TRAIN: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				-- initialize all entries to weakly not taken
				TABLE	<=	(others => B"01");
			elsif UPDATE_EN = '1' then
				if BR_TAKEN = '1' then
					-- increment, saturate at "11"
					if TABLE(to_integer(unsigned(WR_INDEX))) /= B"11" then
						TABLE(to_integer(unsigned(WR_INDEX)))	<=	std_logic_vector(unsigned(TABLE(to_integer(unsigned(WR_INDEX)))) + 1);
					end if;
				else
					-- decrement, saturate at "00"
					if TABLE(to_integer(unsigned(WR_INDEX))) /= B"00" then
						TABLE(to_integer(unsigned(WR_INDEX)))	<=	std_logic_vector(unsigned(TABLE(to_integer(unsigned(WR_INDEX)))) - 1);
					end if;
				end if;
			end if;
		end if;
	end process TRAIN;
end architecture BEHAVIORAL;