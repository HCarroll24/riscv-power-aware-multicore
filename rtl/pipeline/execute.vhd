/*************************************************************************
 * File:			execute.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		ALU calculation from SRC1 and SRC2
 *		BR Target piped from fetch to dtermine branch
 *		Helps check if there is a mispredict
 *		JALR handling
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Function Block Symbol
-- Inputs:
--		ID_EX_SRC1				:	SRC1 from id/ex registers
--		ID_EX_SRC2				:	SRC2 form id/ex registers
--		ID_EX_STORE_DATA		:	Store data is equivaluent to src2
--		ID_EX_PC_PLUS4			:	PC+4 from ID/EX
--		ID_EX_BR_TARGET		:	BR_TARGET piped to EX
--		ID_EX_BRANCH			:	BRANCH signal piped to EX
--		ID_EX_IS_JALR			:	IS_JALR piped to EX
--		ID_EX_ALUSEL			:	ALUSEL FROM DECODE STAGE
--		ID_EX_FUNCT3			:	FUNCT3 bits from decode
--		ID_EX_WD4SEL			:	Selection for wb value from decode
--		ID_EX_PREDICT_TAKEN	:	Branchs is predicted taken
-- 	CORE_EN					:	Control operation speed on FPGA
-- Outputs:
--		ALU_F						:	Calculated value by ALU
--		EX_WB_VALUE				:	WB Value to regfile
--		REDIRECT_PC				:	PC value to redirect to
--		REDIRECT_EN				:	Enable redirection
--		TRAIN_TAKEN				:	Is the branch taken or not
--		IFID_FLUSH				:	Flush the ifid registers
--		MISPREDICT				:	branch is mispredicted
entity EXECUTE is
port(
	ID_EX_SRC1				:	in		std_logic_vector(31 downto 0);
	ID_EX_SRC2				:	in		std_logic_vector(31 downto 0);
	ID_EX_STORE_DATA		:	in		std_logic_vector(31 downto 0);
	ID_EX_PC_PLUS4			:	in		std_logic_vector(31 downto 0);
	ID_EX_BR_TARGET		:	in		std_logic_vector(31 downto 0);
	ID_EX_BRANCH			:	in		std_logic;
	ID_EX_IS_JALR			:	in		std_logic;
	ID_EX_ALUSEL			:	in		std_logic_vector(3 downto 0);
	ID_EX_FUNCT3			:	in		std_logic_vector(2 downto 0);
	ID_EX_WD4SEL			:	in		std_logic_vector(1 downto 0);
	ID_EX_PREDICT_TAKEN	:	in		std_logic;
	CORE_EN					:	in		std_logic;
	ALU_F						:	out	std_logic_vector(31 downto 0);
	EX_WB_VALUE				:	out	std_logic_vector(31 downto 0);
	REDIRECT_PC				:	out	std_logic_vector(31 downto 0);
	REDIRECT_EN				:	out	std_logic;
	TRAIN_TAKEN				:	out	std_logic;
	IFID_FLUSH				:	out	std_logic;
	MISPREDICT				:	out	std_logic);
end entity EXECUTE;

architecture STRUCTURAL of EXECUTE is
	-- internal wiring nets/signals
	signal ALU_F_INT			:	std_logic_vector(31 downto 0);
	signal JALR_TARGET		:	std_logic_vector(31 downto 0);
	signal REDIR_SEL			:	std_logic_vector(1 downto 0);
	signal BR_TAKEN			:	std_logic;
	signal MISP_RAW			:	std_logic;
	signal MISPREDICT_INT	:	std_logic;
	signal REDIRECT_EN_INT	:	std_logic;
begin
	-- ALU
	ALU	:	entity work.ALU
		port map(
			A	=>	ID_EX_SRC1,
			B	=>	ID_EX_SRC2,
			S	=>	ID_EX_ALUSEL,
			F	=>	ALU_F_INT);
	
	-- Branch comparator, final check to see need to branch or not
	BR_COMP	:	entity work.BRANCH_COMP
		port map(
			RD1		=>	ID_EX_SRC1,
			RD2		=>	ID_EX_SRC2,
			FUNCT3	=>	ID_EX_FUNCT3,
			BRANCH	=>	ID_EX_BRANCH,
			BR_TAKEN	=>	BR_TAKEN);
			
	-- mispredict detection, last check to see if flush needed
	MISP_RAW				<=	BR_TAKEN xor ID_EX_PREDICT_TAKEN;
	MISPREDICT_INT		<=	MISP_RAW and ID_EX_BRANCH;
	REDIRECT_EN_INT	<=	MISPREDICT_INT or ID_EX_IS_JALR;
	IFID_FLUSH			<=	CORE_EN and REDIRECT_EN_INT;
	
	-- Redirect PC
	-- S = IS_JALR & BR_TAKEN
	--		00 = PC + 4, 01 = fetch br_target, 1x = JALR target with bit 0=gnd
	JALR_TARGET	<=	ALU_F_INT(31 downto 1) & '0';
	REDIR_SEL	<=	ID_EX_IS_JALR & BR_TAKEN;
	
	REDIRECT_MUX	:	entity work.busmux4to1
		port map(
			D3	=>	JALR_TARGET,
			D2	=>	JALR_TARGET,
			D1	=>	ID_EX_BR_TARGET,
			D0	=>	ID_EX_PC_PLUS4,
			S	=>	REDIR_SEL,
			Y	=>	REDIRECT_PC);
			
	-- WBVAL MUX for execute forwarding value
	-- '0' ALU result, '1' PC + 4
	with ID_EX_WD4SEL(1) select
		EX_WB_VALUE	<=	ID_EX_PC_PLUS4 when '1',
							ALU_F_INT 		when others;
							
	-- output assignments
	ALU_F			<=	ALU_F_INT;
	REDIRECT_EN	<=	REDIRECT_EN_INT;
	TRAIN_TAKEN	<=	BR_TAKEN;
	MISPREDICT	<=	MISPREDICT_INT;
end architecture STRUCTURAL;