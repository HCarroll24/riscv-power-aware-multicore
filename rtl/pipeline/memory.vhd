/*************************************************************************
 * File:			memory.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			14 October 2026
 * Provides:
 *		Memory stage that goes has dmem
 *		Has correct registering
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Inputs:
--		A_EX				:	ALU calculation from Execute
--		STORE_DATA_EX	:	Store_data piped from decode to avoid calculation
--		FUNCT3_EX		:	Funct3 bits
--		MEMWR_EX			:	Write to memory?
--		MEMRD_EX			:	Read from memory?
--		CLK				:	Clock for synchronous read/write
--		RST				:	Reset the memory
--		CORE_ENABLE		:	CORE_EN signal to control speed
--		DBUS_RDATA		:	whole word read data from BUS
-- Outputs:
--		RDM_MEM			:	Register data memory
--		DBUS_ADDR		:	data bus address
--		DBUS_BE			:	byte enable bus
--		DBUS_WDATA		:	bus write data
--		DBUS_WE			:	bus write enable
--		DBUS_RE			:	bus read enable
entity MEMORY is
port(
	A_EX				:	in		std_logic_vector(31 downto 0);
	STORE_DATA_EX	:	in		std_logic_vector(31 downto 0);
	FUNCT3_EX		:	in		std_logic_vector(2 downto 0);
	MEMWR_EX			:	in		std_logic;
	MEMRD_EX			:	in		std_logic;
	CLK				:	in		std_logic;
	RST				:	in		std_logic;
	CORE_ENABLE		:	in		std_logic;
	RDM_MEM			:	out	std_logic_vector(31 downto 0);
	DBUS_ADDR		:	out	std_logic_vector(31 downto 0);
	DBUS_BE			:	out	std_logic_vector(3 downto 0);
	DBUS_WDATA		:	out	std_logic_vector(31 downto 0);
	DBUS_WE			:	out	std_logic;
	DBUS_RE			:	out	std_logic;
	DBUS_RDATA		:	in		std_logic_vector(31 downto 0));
end entity MEMORY;

-- architectural stucture of memory
architecture BEHAVIORAL of MEMORY is
	-- EX-stage signals
	signal BYTE_EN_INT	:	std_logic_vector(3 downto 0);
	
	-- EX -> MEM shadow registers for load formatter
	signal FUNCT3_R		:	std_logic_vector(2 downto 0);
	signal OFFSET_R		:	std_logic_vector(1 downto 0);
	signal MEMRD_R			:	std_logic;
	
	-- mem stage signals
	signal RDM_FMT			:	std_logic_vector(31 downto 0);
begin
	-- EX stage : drive data bus
	DBUS_ADDR	<=	A_EX;
	
	-- store byte enables from width and address offset
	STORE_BYTE_EN:	process(FUNCT3_EX, A_EX)
	begin
		case FUNCT3_EX(1 downto 0) is
			when B"00" =>	-- sb
				case A_EX(1 downto 0) is
					when B"00" => BYTE_EN_INT <= B"0001";
					when B"01" => BYTE_EN_INT <= B"0010";
					when B"10" => BYTE_EN_INT <= B"0100";
					when B"11" => BYTE_EN_INT <= B"1000";
				end case;
			when B"01" =>	-- sh
				if A_EX(1) = '0' then
					BYTE_EN_INT	<=	B"0011";
				else
					BYTE_EN_INT	<=	B"1100";
				end if;
			when B"10" =>	-- sw
				BYTE_EN_INT	<=	B"1111";
			when others => -- undefined store width
				BYTE_EN_INT	<=	B"0000";
		end case;
	end process STORE_BYTE_EN;
	
	DBUS_BE	<=	BYTE_EN_INT;
	
	-- store data lane replication for byte enables looking at right byte
	with FUNCT3_EX(1 downto 0) select
	DBUS_WDATA	<=	STORE_DATA_EX(7 downto 0) & STORE_DATA_EX(7 downto 0) & STORE_DATA_EX(7 downto 0) & STORE_DATA_EX(7 downto 0) when B"00",
						STORE_DATA_EX(15 downto 0) & STORE_DATA_EX(15 downto 0) when B"01",
						STORE_DATA_EX when others;
						
	-- bus enables
	DBUS_WE	<=	MEMWR_EX and CORE_ENABLE and not RST;
	DBUS_RE	<=	MEMRD_EX and CORE_ENABLE;
	
	-- ex->mem shadow registers
	SHADOW_PIPE: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				FUNCT3_R	<=	(others => '0');
				OFFSET_R	<=	(others => '0');
				MEMRD_R	<=	'0';
			elsif CORE_ENABLE = '1' then
				FUNCT3_R	<=	FUNCT3_EX;
				OFFSET_R	<=	A_EX(1 downto 0);
				MEMRD_R	<=	MEMRD_EX;
			end if;
		end if;
	end process SHADOW_PIPE;
	
	-- MEM stage
	LOAD_FORMAT: process(FUNCT3_R, OFFSET_R, DBUS_RDATA)
	begin
		case FUNCT3_R is
			when B"000" =>												-- lb, sign extended
				case OFFSET_R is
					when B"00" =>
						RDM_FMT	<=	(31 downto 8 => DBUS_RDATA(7)) & DBUS_RDATA(7 downto 0);
					when B"01" =>
						RDM_FMT	<=	(31 downto 8 => DBUS_RDATA(15)) & DBUS_RDATA(15 downto 8);
					when B"10" =>
						RDM_FMT	<=	(31 downto 8 => DBUS_RDATA(23)) & DBUS_RDATA(23 downto 16);
					when others =>
						RDM_FMT	<=	(31 downto 8 => DBUS_RDATA(31)) & DBUS_RDATA(31 downto 24);
				end case;

			when B"001" =>												-- lh, sign extended
				if OFFSET_R(1) = '0' then
					RDM_FMT	<=	(31 downto 16 => DBUS_RDATA(15)) & DBUS_RDATA(15 downto 0);
				else
					RDM_FMT	<=	(31 downto 16 => DBUS_RDATA(31)) & DBUS_RDATA(31 downto 16);
				end if;

			when B"010" =>												-- lw
				RDM_FMT	<=	DBUS_RDATA;

			when B"100" =>												-- lbu, zero extended
				case OFFSET_R is
					when B"00" =>
						RDM_FMT	<=	(31 downto 8 => '0') & DBUS_RDATA(7 downto 0);
					when B"01" =>
						RDM_FMT	<=	(31 downto 8 => '0') & DBUS_RDATA(15 downto 8);
					when B"10" =>
						RDM_FMT	<=	(31 downto 8 => '0') & DBUS_RDATA(23 downto 16);
					when others =>
						RDM_FMT	<=	(31 downto 8 => '0') & DBUS_RDATA(31 downto 24);
				end case;

			when B"101" =>												-- lhu, zero extended
				if OFFSET_R(1) = '0' then
					RDM_FMT	<=	(31 downto 16 => '0') & DBUS_RDATA(15 downto 0);
				else
					RDM_FMT	<=	(31 downto 16 => '0') & DBUS_RDATA(31 downto 16);
				end if;

			when others =>												-- undefined load width
				RDM_FMT	<=	(others => '0');
		end case;
	end process LOAD_FORMAT;
	
	-- only a load produces data in MEM
	RDM_MEM	<=	RDM_FMT when MEM_RD = '1' else (others => '0');
	
	-- simulation only checks
	-- synthesis translate-off
	CHECKS:	process(CLK)
		variable ACTIVE		:	boolean;
		variable MISALIGNED	:	boolean;
	begin
		if rising_edge(CLK) then
			ACTIVE		:=	(RST = '0') and (CORE_ENABLE = '1') and (MEMWR_EX = '1' OR MEMRD_EX = '1');
			MISALIGNED	:= (FUNCT3_EX(1 downto 0) = B"10" and A_EX(1 downto 0) /= B"00")
									or (FUNCT3_EX(1 downto 0) = B"01" and A_EX(0) /= '0');
									
			assert not (ACTIVE and MISALIGNED);
				report "MEMORY: misaligned access at 0x" & to_hstring(A_EX) & " -- folded into the containing word"
				severity error;
				
			assert not (MEMWR_EX = '1' and MEMRD_EX = '1')
				report "MEMORY: MEMWR and MEMRD asserted together"
				severity failure;
		end if;
	end process CHECKS;
	-- synthesis translate-on
end architecture STRUCTURAL;