/*************************************************************************
 * File:			pipeline.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Pipelined processor
 *		IF/ID/EX/MEM/WB
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Inputs:
--		RST				:	System RST
--		CLK				:	clock signal
--		CORE_EN			:	EN signal to control speed of the core
-- Outputs:
--		WD3				:	Write back data, the final value of the run
--		RD_ADDR			:	Register Address that wd3 is written to
--		IF_ID_VALID		:	VALID bit to see instructions pipe through if/id
--		ID_EX_VALID		:	VALID bit to see instruction pipe through id/ex
--		EX_MEM_VALID	:	VALID bit to see instructions pipe through ex/mem
--		MEM_WB_VALID	:	VALID bit to see instructions pipe through mem/wb
--		MEM_WB_REGWR	:	Writeback register write enable
--		STALL				:	STALL to see when pipeline stalls
--		REDIRECT_EN		:	Are we branching or redirecting?
--		PREDICT_TAKEN	:	Predict that we should take the branch
--		MISPREDICT		:	Mispredict so we need to insert a bubble
entity PIPELINE is
port(
	CLK				:	in		std_logic;
	RST				:	in		std_logic;
	CORE_EN			:	in		std_logic;
	WD3				:	out	std_logic_vector(31 downto 0);
	RD_ADDR			:	out	std_logic_vector(4 downto 0);
	IF_ID_VALID		:	out	std_logic;
	ID_EX_VALID		:	out	std_logic;
	EX_MEM_VALID	:	out	std_logic;
	MEM_WB_VALID	:	out	std_logic;
	MEM_WB_REGWR	:	out	std_logic;
	STALL				:	out	std_logic;
	REDIRECT_EN		:	out	std_logic;
	PREDICT_TAKEN	:	out	std_logic;
	MISPREDICT		:	out	std_logic);
end entity PIPELINE;

-- architectural description
architecture STRUCTURAL of PIPELINE is
	-- internal signals/nets
	
	-- fetch stage outputs
	signal PC						:	std_logic_vector(31 downto 0);
	signal INSTR					:	std_logic_vector(31 downto 0);
	signal PC_PLUS4				:	std_logic_vector(31 downto 0);
	signal BR_TARGET				:	std_logic_vector(31 downto 0);
	signal PREDICT_TAKEN_INT	:	std_logic;
	signal LD_IF					:	std_logic;
	
	-- IF/ID register outputs
	signal IF_ID_INSTR			:	std_logic_vector(31 downto 0);
	signal IF_ID_PC				:	std_logic_vector(31 downto 0);
	signal IF_ID_PC_PLUS4		:	std_logic_vector(31 downto 0);
	signal IF_ID_BR_TARGET		:	std_logic_vector(31 downto 0);
	signal IF_ID_PREDICT_TAKEN	:	std_logic;
	signal IF_ID_VALID_INT		:	std_logic;
	
	-- decode stage outputs
	signal STALL_INT				:	std_logic;
	signal SRC1						:	std_logic_vector(31 downto 0);
	signal SRC2						:	std_logic_vector(31 downto 0);
	signal STORE_DATA				:	std_logic_vector(31 downto 0);
	signal RD						:	std_logic_vector(4 downto 0);
	signal FUNCT3					:	std_logic_vector(2 downto 0);
	signal ALUSEL					:	std_logic_vector(3 downto 0);
	signal WD4SEL					:	std_logic_vector(1 downto 0);
	signal BRANCH					:	std_logic;
	signal IS_JALR					:	std_logic;
	signal MEMRD					:	std_logic;
	signal MEMWR					:	std_logic;
	signal REGWR					:	std_logic;
	signal IDEX_FLUSH				:	std_logic;
	
	-- ID/EX Register outputs
	signal ID_EX_SRC1				:	std_logic_vector(31 downto 0);
	signal ID_EX_SRC2				:	std_logic_vector(31 downto 0);
	signal ID_EX_STORE_DATA		:	std_logic_vector(31 downto 0);
	signal ID_EX_PC				:	std_logic_vector(31 downto 0);
	signal ID_EX_PC_PLUS4		:	std_logic_vector(31 downto 0);
	signal ID_EX_BR_TARGET		:	std_logic_vector(31 downto 0);
	signal ID_EX_RD				:	std_logic_vector(4 downto 0);
	signal ID_EX_FUNCT3			:	std_logic_vector(2 downto 0);
	signal ID_EX_ALUSEL			:	std_logic_vector(3 downto 0);
	signal ID_EX_WD4SEL			:	std_logic_vector(2 downto 0);
	signal ID_EX_BRANCH			:	std_logic;
	signal ID_EX_IS_JALR			:	std_logic;
	signal ID_EX_MEMRD			:	std_logic;
	signal ID_EX_MEMWR			:	std_logic;
	signal ID_EX_REGWR			:	std_logic;
	signal ID_EX_PREDICT_TAKEN	:	std_logic;
	signal ID_EX_VALID_INT		:	std_logic;
	
	-- Execute stage outputs
	signal ALU_F					:	std_logic_vector(31 downto 0);
	signal EX_WB_VALUE			:	std_logic_vector(31 downto 0);
	signal REDIRECT_PC			:	std_logic_vector(31 downto 0);
	signal REDIRECT_EN_INT		:	std_logic;
	signal TRAIN_TAKEN			:	std_logic;
	signal IFID_FLUSH				:	std_logic;
	signal MISPREDICT_INT		:	std_logic;
	
	-- EX/MEM Register Outputs
	signal EX_MEM_WB_VALUE		:	std_logic_vector(31 downto 0);
	signal EX_MEM_RD				:	std_logic_vector(4 downto 0);
	signal EX_MEM_REGWR			:	std_logic;
	signal EX_MEM_MEMRD			:	std_logic;
	signal EX_MEM_VALID_INT		:	std_logic;
	
	-- memory stage output
	signal RDM						:	std_logic_vector(31 downto 0);
	
	-- MEM/WB regiser outputs
	signal MEM_WB_WB_VALUE		:	std_logic_vector(31 downto 0);
	signal MEM_WB_RDM				:	std_logic_vector(31 downto 0);
	signal MEM_WB_RD				:	std_logic_vector(4 downto 0);
	signal MEM_WB_REGWR_INT		:	std_logic;
	signal MEM_WB_MEMRD			:	std_logic;
	signal MEM_WB_VALID_INT		:	std_logic;
	
	-- writeback stage
	signal WB_VALUE				:	std_logic_vector(31 downto 0);
begin
	-- Fetch stage block
	FETCH_BLOCK	:	entity work.FETCH
		port map(
			CLK				=>	CLK,
			RST				=>	RST,
			STALL				=>	STALL_INT,
			REDIRECT_EN		=>	REDIRECT_EN_INT,
			REDIRECT_PC		=>	REDIRECT_PC,
			TRAIN_EN			=>	ID_EX_BRANCH,
			TRAIN_PC			=>	ID_EX_PC,
			TRAIN_TAKEN		=>	TRAIN_TAKEN,
			CORE_EN			=>	CORE_EN,
			PC					=>	PC,
			INSTR				=>	INSTR,
			PC_PLUS4			=>	PC_PLUS4,
			BR_TARGET		=>	BR_TARGET,
			PREDICT_TAKEN	=>	PREDICT_TAKEN_INT,
			LOAD_IF			=>	open,
			LD_IF				=>	LD_IF);
		
	-- IF/ID Pipeline Registers
	IFID_INSTR	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	INSTR,
			Q					=>	IF_ID_INSTR);
		
	IFID_PC	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	PC,
			Q					=>	IF_ID_PC);
		
	IFID_PC_PLUS4	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	PC_PLUS4,
			Q					=>	IF_ID_PC_PLUS4);
		
	IFID_BR_TARGET	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	BR_TARGET,
			Q					=>	IF_ID_BR_TARGET);
		
	IFID_PREDICT_TAKEN	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	PREDICT_TAKEN_INT,
			Q					=>	IF_ID_PREDICT_TAKEN);
		
	IFID_VALID	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	LD_IF,
			FLUSH				=>	IFID_FLUSH,
			D					=>	'1',
			Q					=>	IF_ID_VALID_INT);
		
	-- DECODE stage block
	DECODE_BLOCK	:	entity work.DECODE
		port map(
			CLK				=>	CLK,
			RST				=>	RST,
			INSTR				=>	IF_ID_INSTR,
			PC					=>	IF_ID_PC,
			REDIRECT_EN		=>	REDIRECT_EN_INT,
			WB_VALUE			=>	WB_VALUE,
			RD_ADDR_WB		=>	MEM_WB_RD,
			REGWR_WB			=>	MEM_WB_REGWR_INT,
			MEMRD_ID_EX		=>	ID_EX_MEMRD,
			RD_ADDR_ID_EX	=>	ID_EX_RD,
			REGWR_ID_EX		=>	ID_EX_REGWR,
			RD_ADDR_EX_MEM	=>	EX_MEM_RD,
			REGWR_EX_MEM	=>	EX_MEM_REGWR,
			MEMRD_EX_MEM	=>	EX_MEM_MEMRD,
			EX_WB_VALUE		=>	EX_WB_VALUE,
			DMEM_Q			=>	RDM,
			EX_MEM_WB_VALUE	=>	EX_MEM_WB_VALUE,
			CORE_EN			=>	CORE_EN,
			STALL				=>	STALL_INT,
			BUBBLE			=>	open,
			SRC1				=>	SRC1,
			SRC2				=>	SRC2,
			STORE_DATA		=>	STORE_DATA,
			RD					=>	RD,
			FUNCT3			=>	FUNCT3,
			ALUSEL			=>	ALUSEL,
			WD4SEL			=>	WD4SEL,
			BRANCH			=>	BRANCH,
			IS_JALR			=>	IS_JALR,
			MEMRD				=>	MEMRD,
			MEMWR				=>	MEMWR,
			REGWR				=>	REGWR,
			IDEX_FLUSH		=>	IDEX_FLUSH);
			
	-- ID/EX Pipeline Registers
	IDEX_SRC1	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	SRC1,
			Q					=>	ID_EX_SRC1);
			
	IDEX_SRC2	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	SRC2,
			Q					=>	ID_EX_SRC2);
			
	IDEX_STORE_DATA	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	STORE_DATA,
			Q					=>	ID_EX_STORE_DATA);
			
	IDEX_PC	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IF_ID_PC,
			Q					=>	ID_EX_PC);
			
	IDEX_PC_PLUS4	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IF_ID_PC_PLUS4,
			Q					=>	ID_EX_PC_PLUS4);
			
	IDEX_BR_TARGET	:	entity work.REGN
		generic map(
			WIDTH				=>	32)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IF_ID_BR_TARGET,
			Q					=>	ID_EX_BR_TARGET);
			
	IDEX_RD	:	entity work.REGN
		generic map(
			WIDTH				=>	5)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	RD,
			Q					=>	ID_EX_RD);
			
	IDEX_FUNCT3	:	entity work.REGN
		generic map(
			WIDTH				=>	3)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	FUNCT3,
			Q					=>	ID_EX_FUNCT3);
			
	IDEX_ALUSEL	:	entity work.REGN
		generic map(
			WIDTH				=>	4)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	ALUSEL,
			Q					=>	ID_EX_ALUSEL);
			
	IDEX_WD4SEL	:	entity work.REGN
		generic map(
			WIDTH				=>	2)
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	WD4SEL,
			Q					=>	ID_EX_WD4SEL);
	
	IDEX_BRANCH	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	BRANCH,
			Q					=>	ID_EX_BRANCH);
			
	IDEX_IS_JALR	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IS_JALR,
			Q					=>	ID_EX_IS_JALR);
			
	IDEX_MEMRD	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	MEMRD,
			Q					=>	ID_EX_MEMRD);
			
	IDEX_MEMWR	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	MEMWR,
			Q					=>	ID_EX_MEMWR);
			
	IDEX_REGWR	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	REGWR,
			Q					=>	ID_EX_REGWR);
			
	IDEX_PREDICT_TAKEN	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IF_ID_PREDICT_TAKEN,
			Q					=>	ID_EX_PREDICT_TAKEN);
			
	IDEX_VALID	:	entity work.REG1
		port map(
			RST				=>	RST,
			CLK				=>	CLK,
			LD					=>	CORE_EN,
			FLUSH				=>	IDEX_FLUSH,
			D					=>	IF_ID_VALID_INT,
			Q					=>	ID_EX_VALID_INT);
			
	-- Execute Stage block
	EXECUTE_BLOCK	:	entity work.EXECUTE
		port map(
			ID_EX_SRC1				=>	ID_EX_SRC1,
			ID_EX_SRC2				=>	ID_EX_SRC2,
			ID_EX_STORE_DATA		=>	ID_EX_STORE_DATA,
			ID_EX_PC_PLUS4			=>	ID_EX_PC_PLUS4,
			ID_EX_BR_TARGET		=>	ID_EX_BR_TARGET,
			ID_EX_BRANCH			=>	ID_EX_BRANCH,
			ID_EX_IS_JALR			=>	ID_EX_IS_JALR,
			ID_EX_ALUSEL			=>	ID_EX_ALUSEL,
			ID_EX_FUNCT3			=>	ID_EX_FUNCT3,
			ID_EX_WD4SEL			=>	ID_EX_WD4SEL,
			ID_EX_PREDICT_TAKEN	=>	ID_EX_PREDICT_TAKEN,
			CORE_EN					=>	CORE_EN,
			ALU_F						=>	ALU_F,
			EX_WB_VALUE				=>	EX_WB_VALUE,
			REDIRECT_PC				=>	REDIRECT_PC,
			REDIRECT_EN				=>	REDIRECT_EN_INT,
			TRAIN_TAKEN				=>	TRAIN_TAKEN,
			IFID_FLUSH				=>	IFID_FLUSH,
			MISPREDICT				=>	MISPREDICT_INT);
			
	-- EX/MEM pipeline registers
	EXMEM_WB_VALUE	:	entity work.REGN
		generic map(
			WIDTH	=>	32)
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	CORE_EN,
			FLUSH	=>	'0',
			D		=>	EX_WB_VALUE,
			Q		=>	EX_MEM_WB_VALUE);
			
	EXMEM_RD	:	entity work.REGN
		generic map(
			WIDTH	=>	5)
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	CORE_EN,
			FLUSH	=>	'0',
			D		=>	ID_EX_RD,
			Q		=>	EX_MEM_RD);
			
	EXMEM_REGWR	:	entity work.REG1
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	CORE_EN,
			FLUSH	=>	'0',
			D		=>	ID_EX_REGWR,
			Q		=>	EX_MEM_REGWR);
			
	EXMEM_MEMRD	:	entity work.REG1
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	CORE_EN,
			FLUSH	=>	'0',
			D		=>	ID_EX_MEMRD,
			Q		=>	EX_MEM_MEMRD);
			
	EXMEM_VALID	:	entity work.REG1
		port map(
			RST	=>	RST,
			CLK	=>	CLK,
			LD		=>	CORE_EN,
			FLUSH	=>	'0',
			D		=>	ID_EX_VALID_INT,
			Q		=>	EX_MEM_VALID_INT);
			
	-- Memory stage block
	MEMORY_BLOCK	:	entity work.MEMORY
		port map(
			A_EX				=>	ALU_F,
			STORE_DATA_EX	=>	ID_EX_STORE_DATA,
			FUNCT3_EX		=>	ID_EX_FUNCT3,
			MEMWR_EX			=>	ID_EX_MEMWR,
			MEMRD_EX			=>	ID_EX_MEMRD,
			CLK				=>	CLK,
			RST				=>	RST,
			CORE_ENABLE		=>	CORE_EN,
			RDM_MEM			=>	RDM);
			
	-- MEM/WB Pipeline registers
	MEMWB_WB_VALUE	:	entity work.REGN
		generic map(
			WIDTH		=>	32)
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	EX_MEM_WB_VALUE,
			Q			=>	MEM_WB_WB_VALUE);
			
	MEMWB_RDM	:	entity work.REGN
		generic map(
			WIDTH		=>	32)
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	RDM,
			Q			=>	MEM_WB_RDM);
			
	MEMWB_RD	:	entity work.REGN
		generic map(
			WIDTH		=>	5)
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	EX_MEM_RD,
			Q			=>	MEM_WB_RD);
			
	MEMWB_REGWR	:	entity work.REG1
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	EX_MEM_REGWR,
			Q			=>	MEM_WB_REGWR_INT);
			
	MEMWB_MEMRD	:	entity work.REG1
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	EX_MEM_MEMRD,
			Q			=>	MEM_WB_MEMRD);
			
	MEMWB_VALID	:	entity work.REG1
		port map(
			RST		=>	RST,
			CLK		=>	CLK,
			LD			=>	CORE_EN,
			FLUSH		=>	'0',
			D			=>	EX_MEM_VALID_INT,
			Q			=>	MEM_WB_VALID_INT);
			
	-- Writeback stage in pipeline
	-- busmux2to1
	with MEM_WB_MEMRD select
		WB_VALUE	<=	MEM_WB_RDM			when '1',
						MEM_WB_WB_VALUE 	when others;
						
	-- Output Assignments
	WD3				<=	WB_VALUE;
	RD_ADDR			<=	MEM_WB_RD;
	IF_ID_VALID		<=	IF_ID_VALID_INT;
	ID_EX_VALID		<=	ID_EX_VALID_INT;
	EX_MEM_VALID	<=	EX_MEM_VALID_INT;
	MEM_WB_VALID	<=	MEM_WB_VALID_INT;
	MEM_WB_REGWR	<=	MEM_WB_REGWR_INT;
	STALL				<=	STALL_INT;
	REDIRECT_EN		<=	REDIRECT_EN_INT;
	PREDICT_TAKEN	<=	PREDICT_TAKEN_INT;
	MISPREDICT		<=	MISPREDICT_INT;
end architecture STRUCTURAL;