/*************************************************************************
 * File:			decode.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Structural for decode block.
 *		Hazard control unit
 *		Forwarding Units
 *		Operand Selection
 *		Register File
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block prototype
-- Inputs:
--		CLK				:	clock input
--		RST				:	reset signal
--		INSTR				:	instruction bus from if/id
--		PC					:	PC value from if/id
--		REDIRECT_EN		:	Redirect enable signal from fetch
--		WB_VALUE			:	Value written back for regfile
--		RD_ADDR_WB		:	Address of register to write to in regfile
--		REGWR_WB			:	Register write piped through to writeback
--		MEMRD_ID_EX		:	Read memory signal piped through id/ex reg
--		RD_ADDR_ID_EX	:	Register write address from id/ex
--		REGWR_ID_EX		:	Regwr signal piped through to EX
--		RD_ADDR_EX_MEM	:	Register write address from ex/mem
--		REGWR_EX_MEM	:	REGWR signal piped to EX/MEM
--		MEMRD_EX_MEM	:	Is memory reading ex/mem
--		EX_WB_VALUE		:	WB Value piped through to EX stage
--		DMEM_Q			:	Memory output
--		EX_MEM_WB_VALUE:	WB Value after EX/MEM
--		CORE_EN			:	core_en to control speed of processor for demos
-- Outputs:
--		STALL				:	Stall signal generated if need to stall
--		BUBBLE			:	Generate bubble for flushes
--		SRC1				:	Value from regfile for rs1
--		SRC2				:	Value for rs2
--		STORE_DATA		: 	Data stored to prevent calculation in ex
--		RD					:	Register address to write data to
--		FUNCT3			:	FUNCT3 Bits from INSTR[14..2]
--		ALUSEL			:	Selection produced for which calculation for ALU
--		WD4SEL			:	Which value to wb used in execute
--		BRANCH			:	Is instruction a branch instruction
--		IS_JALR			:	'1' if jalr, '0' if not
--		MEMRD				:	Read from dmem?
--		MEMWR				:	Write to dmem?
--		REGWR				:	WB to regfile?
--		IDEX_FLUSH		: 	Flush fo rbubbles for id_ex stage
entity DECODE is
port(
	CLK, RST				:	in		std_logic;
	INSTR					:	in		std_logic_vector(31 downto 0);
	PC						:	in 	std_logic_vector(31 downto 0);
	REDIRECT_EN			:	in		std_logic;
	WB_VALUE				:	in		std_logic_vector(31 downto 0);
	RD_ADDR_WB			:	in		std_logic_vector(4 downto 0);
	REGWR_WB				:	in		std_logic;
	MEMRD_ID_EX			:	in		std_logic;
	RD_ADDR_ID_EX		:	in		std_logic_vector(4 downto 0);
	REGWR_ID_EX			:	in		std_logic;
	RD_ADDR_EX_MEM		:	in		std_logic_vector(4 downto 0);
	REGWR_EX_MEM		:	in		std_logic;
	MEMRD_EX_MEM		:	in		std_logic;
	EX_WB_VALUE			:	in		std_logic_vector(31 downto 0);
	DMEM_Q				:	in		std_logic_vector(31 downto 0);
	EX_MEM_WB_VALUE	:	in 	std_logic_vector(31 downto 0);
	CORE_EN				:	in		std_logic;
	STALL					:	out	std_logic;
	BUBBLE				:	out	std_logic;
	SRC1					:	out	std_logic_vector(31 downto 0);
	SRC2					:	out	std_logic_vector(31 downto 0);
	STORE_DATA			:	out	std_logic_vector(31 downto 0);
	RD						:	out	std_logic_vector(4 downto 0);
	FUNCT3				:	out	std_logic_vector(2 downto 0);
	ALUSEL				:	out	std_logic_vector(3 downto 0);
	WD4SEL				:	out	std_logic_vector(1 downto 0);
	BRANCH				:	out	std_logic;
	IS_JALR				:	out	std_logic;
	MEMRD					:	out	std_logic;
	MEMWR					:	out	std_logic;
	REGWR					:	out	std_logic;
	IDEX_FLUSH			:	out	std_logic);
end entity DECODE;

-- structural description
architecture STRUCTURAL of DECODE is
	--	Internal signal nets
	-- control signals
	signal SRC1SEL			:	std_logic;
	signal SRC2SEL			:	std_logic;
	signal IMMSRC			:	std_logic_vector(2 downto 0);
	signal IMM_EXT			:	std_logic_vector(31 downto 0);
	
	-- register file
	signal RS1				:	std_logic_vector(4 downto 0);
	signal RS2				:	std_logic_vector(4 downto 0);
	signal USE_A1			:	std_logic;
	signal USE_A2			:	std_logic;
	signal REGFILE_REGWR	:	std_logic;
	signal RD_1				:	std_logic_vector(31 downto 0);
	signal RD_2				:	std_logic_vector(31 downto 0);
	
	-- op muxes and forwarding
	signal OP_A				:	std_logic_vector(31 downto 0);
	signal OP_B				:	std_logic_vector(31 downto 0);
	signal ASEL				:	std_logic_vector(1 downto 0);
	signal BSEL_ALU		:	std_logic_vector(1 downto 0);
	signal BSEL_DATA		:	std_logic_vector(1 downto 0);
	
	-- hazard/flush unit
	signal STALL_INT		:	std_logic;
	signal BUBBLE_INT		:	std_logic;
begin
	-- Instruction field signal taps
	RD			<= INSTR(11 downto 7);
	FUNCT3	<=	INSTR(14 downto 12);
	
	-- control unit
	CONTROL_BLOCK	:	entity work.CONTROL_UNIT
		port map(
			INSTR		=>	INSTR,
			SRC1SEL	=>	SRC1SEL,
			SRC2SEL	=>	SRC2SEL,
			MEMWR		=>	MEMWR,
			MEMRD		=>	MEMRD,
			REGWR		=>	REGWR,
			BRANCH	=>	BRANCH,
			IS_JALR	=>	IS_JALR,
			WD4SEL	=>	WD4SEL,
			IMMSRC	=>	IMMSRC,
			ALUSEL	=>	ALUSEL);
			
	-- immediate generation and signals
	IMMEDIATE_GEN	:	entity work.IMM_GEN
		port map(
			INSTR		=>	INSTR,
			IMMSRC	=>	IMMSRC,
			IMM_EXT	=>	IMM_EXT);
			
	-- register source decode to determine if need that source
	RS_DECODE		:	entity work.RS_DECODE
		port map(
			INSTR		=>	INSTR,
			RS1		=>	RS1,
			RS2		=>	RS2,
			USES_RS1	=>	USE_A1,
			USES_RS2	=>	USE_A2);
			
	-- core enable gating with register file write to control speed
	REGFILE_REGWR	<=	REGWR_WB	and CORE_EN;
	
	-- regfile read and write
	REG_FILE			:	entity work.REGFILE
		port map(
			A1			=>	INSTR(19 downto 15),
			A2			=>	INSTR(24 downto 20),
			A3			=>	RD_ADDR_WB,
			WD3		=>	WB_VALUE,
			REGWR		=>	REGFILE_REGWR,
			USE_A1	=>	USE_A1,
			USE_A2	=>	USE_A2,
			RST		=>	RST,
			CLK		=>	CLK,
			RD1		=>	RD_1,
			RD2		=>	RD_2);
			
	-- hazard detection unit
	HAZARD_CONTROL	:	entity work.HAZARD_CONTROL_UNIT
		port map(
			MEMRD_ID_EX		=>	MEMRD_ID_EX,
			RD_ADDR_ID_EX	=>	RD_ADDR_ID_EX,
			RS1_ADDR_IF_ID	=>	RS1,
			RS2_ADDR_IF_ID	=>	RS2,
			STALL				=>	STALL_INT);
			
	-- bubble id/ex on redirect or load-use stall
	BUBBLE_INT		<=	REDIRECT_EN or STALL_INT;
	
	-- core enable gates ID/EX Flush
	IDEX_FLUSH		<=	BUBBLE_INT and CORE_EN;
	
	-- ALU operand select A and B mux
	-- OPAMUX: '0' = rs1 data, '1' = PC
	with SRC1SEL select
		OP_A			<=	PC 	when '1',
							RD_1 	when others;
							
	-- OPBMUX: '0' = rs2 data, '1' = imm
	with SRC2SEL select
		OP_B			<=	IMM_EXT	wheN '1',
							RD_2		when others;
							
	-- Data forwarding
	-- Basic MUX inputs: D0 = decode val, D1 = EX_WB_VALUE, D2 = MEM_Q,
	-- D3 = EX_MEM_WB_VALUE
	FORWARD_UNIT	:	entity work.FORWARDING_UNIT
		port map(
			RS1_ADDR			=>	RS1,
			RS2_ADDR			=>	RS2,
			SRC2SEL			=>	SRC2SEL,
			RD_ADDR_ID_EX	=>	RD_ADDR_ID_EX,
			REGWR_ID_EX		=>	REGWR_ID_EX,
			RD_ADDR_EX_MEM	=>	RD_ADDR_EX_MEM,
			REGWR_EX_MEM	=>	REGWR_EX_MEM,
			MEMRD_EX_MEM	=>	MEMRD_EX_MEM,
			ASEL				=>	ASEL,
			BSEL_ALU			=>	BSEL_ALU,
			BSEL_DATA		=>	BSEL_DATA);
			
	-- Forwarding for rs1
	FWD_A				:	entity work.busmux4to1
		port map(
			D3	=>	EX_MEM_WB_VALUE,
			D2	=>	DMEM_Q,
			D1	=>	EX_WB_VALUE,
			D0	=>	OP_A,
			S	=>	ASEL,
			Y	=>	SRC1);
			
	-- Forwarding for rs2
	FWD_B				:	entity work.busmux4to1
		port map(
			D3	=>	EX_MEM_WB_VALUE,
			D2	=>	DMEM_Q,
			D1	=>	EX_WB_VALUE,
			D0	=>	OP_B,
			S	=>	BSEL_ALU,
			Y	=>	SRC2);
			
	-- Forwarding for rs2 for data
	FWD_D				:	entity work.busmux4to1
		port map(
			D3	=>	EX_MEM_WB_VALUE,
			D2	=>	DMEM_Q,
			D1	=>	EX_WB_VALUE,
			D0	=>	RD_2,
			S	=>	BSEL_DATA,
			Y	=>	STORE_DATA);
			
	-- output assignments for stall and bubble
	STALL		<=	STALL_INT;
	BUBBLE	<=	BUBBLE_INT;
end architecture STRUCTURAL;