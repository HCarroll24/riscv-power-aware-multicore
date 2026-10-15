/*************************************************************************
 * File:			fetch.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Structural for fetch block. Changed from bdf to vhdl.
 * 	16-entry BHT with 2-bit saturating counters indexing with pc[5..2]
 *		Branch target calculation in fetch to remove penalty for correctly
 *		predicted branches and JAL.
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function prototype
-- Inputs:
--		CLK				:	clock signal
--		RST				:	reset signal
--		STALL				:	Signal to stall pipelines and registers
--		REDIRECT_EN		:	binary input to tell if redirect the pc
--		REDIRECT_PC		:	pc value to redirect to
--		TRAIN_EN			:	enable the bht training
--		TRAIN_PC			:	PC from execute to train bht
--		TRAIN_TAKEN		:	Branch taken for BHT
--		CORE_EN			:	Enable the core for stepping
-- Outputs:
--		PC					:	PC value that increments
--		INSTR				:	32-bit instruction from irom
--		PC_PLUS4			:	PC value with 4 to increment in fetch
--		BR_TARGET		:	Branch target calculated in fetch to remove penalty
--		PREDICT_TAKEN	:	Predicts that we are taking branch
--		LOAD_IF			:	Load for instruction fetch registers
--		LD_IF				:	Load for fetch

entity FETCH is
port(
	CLK, RST			:	in 	std_logic;
	STALL				:	in 	std_logic;
	REDIRECT_EN		:	in 	std_logic;
	REDIRECT_PC		:	in 	std_logic_vector(31 downto 0);
	TRAIN_EN			:	in 	std_logic;
	TRAIN_PC			:	in 	std_logic_vector(31 downto 0);
	TRAIN_TAKEN		;	in 	std_logic;
	CORE_EN			:	in 	std_logic;
	PC					:	out 	std_logic_vector(31 downto 0);
	INSTR				:	out	std_logic_vector(31 downto 0);
	PC_PLUS4			:	out	std_logic_vector(31 downto 0);
	BR_TARGET		:	out	std_logic_vector(31 downto 0);
	PREDICT_TAKEN	:	out	std_logic;
	LOAD_IF			:	out	std_logic;
	LD_IF				:	out	std_logic
);
end entity FETCH;

-- architectural description
architecture STRUCTURAL of FETCH is
	-- Component Declarations
	-- One_Port_ROM
	-- no q output register
	component single_port_rom is
	port(
		address	:	in std_logic_vector(11 downto 0);
		clock		:	in	std_logic	:=	'1';
		rden		:	in	std_logic	:= '1';
		q			:	out std_logic_vector(31 downto 0));
	end component;
		
	-- internal signals
	-- PC datapath internal signals
	signal NEXT_PC					:	std_logic_vector(31 downto 0);	-- PCMUX output
	signal PC_INT					:	std_logic_vector(31 downto 0);	-- PC_REG output
	signal PC_PLUS4_INT			:	std_logic_vector(31 downto 0);
	signal INSTR_INT				:	std_logic_vector(31 downto 0);
	signal BR_TARGET_INT			:	std_logic_vector(31 downto 0);
	
	-- pc select and prediction signals
	signal PCSEL					:	std_logic_vector(2 downto 0);
	signal PREDICT					:	std_logic;
	signal TARGET_VALID			:	std_logic;
	signal IS_JAL					:	std_logic;
	signal PREDICT_TAKEN_INT	:	std_logic;
	
	-- BHT Training 
	signal PC_EX					:	std_logic_vector(31 downto 0);	-- TRAIN_PC renamed
	signal BR_TAKEN_BHT			:	std_logic;
	signal UPDATE_EN				:	std_logic;
	
	-- load enables
	signal LOAD_IF_INT			:	std_logic;
	signal LD_IF_INT				:	std_logic;
begin
	-- wire renames from fetch.bdf
	PC_EX				<=	TRAIN_PC;
	BR_TAKEN_BHT	<=	TRAIN_TAKEN;
	
	-- LD/EN gating
	-- Load whenever not stalled and always during reset so IROM picks up 0
	LOAD_IF_INT		<=	(not STALL) or RST;
	
	-- core enable gates the pc / irom load
	LD_IF_INT		<=	LOAD_IF_INT and CORE_EN;
	
	-- core enable gates BHT training
	UPDATE_EN		<=	TRAIN_EN and CORE_EN;
	
	-- PC_SEL_Logic Block for next pc selection
	PCSEL_LOGIC_BLOCK	:	entity work.PC_SEL_LOGIC
		port map(
			RST				=>	RST,
			REDIRECT_EN		=>	REDIRECT_EN,
			STALL				=>	STALL,
			TARGET_VALID	=>	TARGET_VALID,
			IS_JAL			=>	IS_JAL,
			PREDICT			=>	PREDICT,
			PREDICT_TAKEN	=>	PREDICT_TAKEN_INT,
			PCSEL				=>	PCSEL);
	
	-- PCSEL:
	-- 100 = hold pc, 011 = zero, 010 = redirect, 001 = BR_TARGET, 000 = PC+4
	PCMUX					:	entity work.BUSMUX5TO1
		port map(
			D4					=>	PC_INT,
			D3					=>	32x"0";
			D2					=>	REDIRECT_PC,
			D1					=>	BR_TARGET_INT,
			D0					=>	PC_PLUS4_INT,
			S					=>	PCSEL
			Y					=>	NEXT_PC);
	
	-- program counter
	PC_REG				:	entity work.REG32
		port map(
			D					=>	NEXT_PC,
			LD					=>	LD_IF_INT,
			RST				=> RST,
			CLK				=>	CLK,
			Q					=>	PC_INT);
	
	-- pc adder
	PC4_ADD				: entity work.ADDER
		port map(
			A					=> 32x"4",
			B					=>	PC_INT,
			S					=>	PC_PLUS4_INT);
			
	-- instruction memory
	-- address from next_pc to keep registers inline
	IROM					:	single_port_rom
		port map(
			address			=>	NEXT_PC(13 downto 2),
			clock				=>	CLK,
			rden				=>	LD_IF_INT,
			q					=>	INSTR_INT);
			
	-- branch history table, trains using pc value
	BHT					:	entity work.BHT
		port map(
			INSTR				=>	INSTR_INT,
			PC					=>	PC_INT,
			FETCH_TARGET	=>	BR_TARGET_INT,
			TARGET_VALID	=>	TARGET_VALID,
			IS_JAL			=>	IS_JAL);
			
	-- branch target calculation, moved to fetch for 0 penalty on correctly
	-- predicted branches
	BTC					:	entity work.BRANCH_TARGET_CALC
		port map(
			INSTR				=>	INSTR_INT,
			PC					=>	PC_INT,
			FETCH_TARGET	=>	BR_TARGET_INT,
			TARGET_VALID	=>	TARGET_VALID,
			IS_JAL			=>	IS_JAL);
	
	-- output assignments
	PC					<=	PC_INT;
	INSTR				<=	INSTR_INT;
	PC_PLUS4			<=	PC_PLUS4_INT;
	BR_TARGET		<=	BR_TARGET_INT;
	PREDICT_TAKEN	<=	PREDICT_TAKEN_INT;
	LOAD_IF			<=	LOAD_IF_INT;
	LD_IF				<=	LD_IF_INT;
	
end architecture STRUCTURAL;