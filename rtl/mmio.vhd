/*************************************************************************
 * File:			mmio.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			20 October 2026
 * Provides:
 *		Address		Register		Access	Contents
 *		0xFF200000	LEDR			R/W		bits 9..0, 1 = LED on
 *		0xFF200020	HEX3_HEX0	R/W		byte n bits 6..0 = HEXn segments,
 *		                                    1 = segment on (bit 0 = seg 0)
 *		0xFF200030	HEX5_HEX4	R/W		byte 0 = HEX4, byte 1 = HEX5
 *		0xFF200040	SW				R			bits 9..0, 1 = switch up
 *		0xFF200050	KEY			R			bits 3..0, 1 = button pressed
 *		0xFF20005C	KEY_EDGE		R/W1C		bit n set when KEYn is pressed and
 *		                                    released; write 1 to a bit to clear it
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;

-- Function Block Prototype
-- Inputs:
--		CLK			:	clock
--		RST			:	active-high reset
--		A				:	bus byte address (decoded by DATA_BUS to the I/O region)
--		BE				:	bus byte enables
--		WDATA			:	bus write data in the correct byte lanes
--		WE				:	write enable (I/O region)
--		RE				:	read enable (I/O region)
--		SW				:	slide switches (pins, 1 = up)
--		KEY			:	push-buttons (pins, active-low)
-- Outputs:
--		Q				:	registered read data
--		LEDR			:	red LEDs (pins, active-low)
--		HEX0..HEX5	:	7-segment displays, segments 6..0 (pins, active-low)
entity MMIO is
port(
	CLK	:	in		std_logic;
	RST	:	in		std_logic;
	A		:	in		std_logic_vector(31 downto 0);
	BE		:	in		std_logic_vector(3 downto 0);
	WDATA	:	in		std_logic_vector(31 downto 0);
	WE		:	in		std_logic;
	RE		:	in		std_logic;
	Q		:	out	std_logic_vector(31 downto 0);
	SW		:	in		std_logic_vector(9 downto 0);
	KEY	:	in		std_logic_vector(3 downto 0);
	LEDR	:	out	std_logic_vector(9 downto 0);
	HEX0	:	out	std_logic_vector(6 downto 0);
	HEX1	:	out	std_logic_vector(6 downto 0);
	HEX2	:	out	std_logic_vector(6 downto 0);
	HEX3	:	out	std_logic_vector(6 downto 0);
	HEX4	:	out	std_logic_vector(6 downto 0);
	HEX5	:	out	std_logic_vector(6 downto 0));
end entity MMIO;

-- architecture description
architecture BEHAVIORAL of MMIO is
	-- register offsets inside I/O region
	constant OFF_LEDR			:	std_logic_vector(15 downto 0)	:=	x"0000";
	constant OFF_HEX3_HEX0	:	std_logic_vector(15 downto 0)	:=	x"0020";
	constant OFF_HEX5_HEX4	:	std_logic_vector(15 downto 0)	:=	x"0030";
	constant OFF_SW			:	std_logic_vector(15 downto 0)	:=	x"0040";
	constant OFF_KEY			:	std_logic_vector(15 downto 0)	:=	x"0050";
	constant OFF_KEY_EDGE	:	std_logic_vector(15 downto 0)	:=	x"005C";
	
	-- word-aligned register offset
	signal REG_OFF				:	std_logic_vector(15 downto 0);
	
	-- output registers (1 = on)
	signal LEDR_REG			:	std_logic_vector(9 downto 0);
	signal HEX0_REG			:	std_logic_vector(7 downto 0);
	signal HEX1_REG			:	std_logic_vector(7 downto 0);
	signal HEX2_REG			:	std_logic_vector(7 downto 0);
	signal HEX3_REG			:	std_logic_vector(7 downto 0);
	signal HEX4_REG			:	std_logic_vector(7 downto 0);
	signal HEX5_REG			:	std_logic_vector(7 downto 0);
	
	-- input synchronizers
	signal SW_S1, SW_S2			:	std_logic_vector(9 downto 0);
	signal KEY_S1, KEY_S2	:	std_logic_vector(3 downto 0);
	signal KEY_DOWN			:	std_logic_vector(3 downto 0); -- 1 = pressed
	signal KEY_DOWN_PREV		:	std_logic_vector(3 downto 0);
	signal KEY_RELEASE		:	std_logic_vector(3 downto 0);	-- 1-cycle pulse
	signal KEY_EDGE_REG		:	std_logic_vector(3 downto 0);
	signal KEY_EDGE_CLR		:	std_logic_vector(3 downto 0);
begin
	REG_OFF	<=	A(15 downto 2) & B"00";
	
	-- input synchronizers and button press capture
	sync: process(CLK)
	begin
		if rising_edge(CLK) then
			SW_S1		<=	SW;
			SW_S2		<=	SW_S1;
			KEY_S1	<=	KEY;
			KEY_S2	<=	KEY_S1;
			KEY_DOWN_PREV	<=	KEY_DOWN;
		end if;
	end process sync;
	
	KEY_DOWN	<=	not KEY_S2;
	
	-- a completed press (pressed then released)
	-- bit 0 masked because key0 is the rst button
	KEY_RELEASE	<=	KEY_DOWN_PREV and not KEY_DOWN and B"1110";
	
	-- write 1 to clear mask for edge-capture reg
	KEY_EDGE_CLR	<=	WDATA(3 downto 0) when (WE = '1' and REG_OFF = OFF_KEY_EDGE and BE(0) = '1') else 
							(others => '0');
							
	edge:	process(CLK)
	begin	
		if rising_edge(CLK) then
			if RST = '1' then
				KEY_EDGE_REG	<=	(others => '0');
			else
				-- new release wins over clear in same cycle
				KEY_EDGE_REG	<=	(KEY_EDGE_REG and not KEY_EDGE_CLR) or KEY_RELEASE;
			end if;
		end if;
	end process edge;
	
	-- output registers (bus writes)
	writes:	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				LEDR_REG	<=	(others => '0');
				HEX0_REG	<=	(others => '0');
				HEX1_REG	<=	(others => '0');
				HEX2_REG	<=	(others => '0');
				HEX3_REG	<=	(others => '0');
				HEX4_REG	<=	(others => '0');
				HEX5_REG	<=	(others => '0');
			elsif WE = '1' then
				if REG_OFF = OFF_LEDR then
					if BE(0) = '1' then
						LEDR_REG(7 downto 0)	<=	WDATA(7 DOWNTO 0);
					end if;
					if BE(1) = '1' then
						LEDR_REG(9 downto 8)	<=	WDATA(9 downto 8);
					end if;
				elsif	REG_OFF = OFF_HEX3_HEX0 then
					if BE(0) = '1' then
						HEX0_REG	<=	WDATA(7 downto 0);
					end if;
					if BE(1) = '1' then
						HEX1_REG	<=	WDATA(15 downto 8);
					end if;
					if BE(2) = '1' then
						HEX2_REG	<=	WDATA(23 downto 16);
					end if;
					if BE(3) = '1' then
						HEX3_REG	<=	WDATA(31 downto 24);
					end if;
				elsif REG_OFF = OFF_HEX5_HEX4 then
					if BE(0) = '1' then
						HEX4_REG	<=	WDATA(7 downto 0);
					end if;
					if BE(1) = '1' then
						HEX5_REG	<=	WDATA(15 downto 8);
					end if;
				end if;
			end if;
		end if;
	end process writes;
	
	-- registered read data
	reads: process(CLK)
	begin
		if rising_edge(CLK) then
			if RE = '1' then
				if REG_OFF = OFF_LEDR then
					Q	<=	(31 downto 10 => '0') & LEDR_REG;
				elsif REG_OFF = OFF_HEX3_HEX0 then
					Q	<=	HEX3_REG & HEX2_REG & HEX1_REG & HEX0_REG;
				elsif REG_OFF = OFF_HEX5_HEX4 then
					Q	<=	(31 downto 16 => '0') & HEX5_REG & HEX4_REG;
				elsif	REG_OFF = OFF_SW then
					Q	<= (31 downto 10 => '0') & SW_S2;
				elsif REG_OFF = OFF_KEY then
					Q	<=	(31 downto 4 => '0') & KEY_DOWN;
				elsif REG_OFF = OFF_KEY_EDGE then
					Q	<=	(31 downto 4 => '0') & KEY_EDGE_REG;
				else
					Q	<=	(others => '0');
				end if;
			end if;
		end if;
	end process reads;
	
	-- board outputs (active-low)
	LEDR	<=	not LEDR_REG;
	HEX0	<=	not HEX0_REG(6 downto 0);
	HEX1	<=	not HEX1_REG(6 downto 0);
	HEX2	<=	not HEX2_REG(6 downto 0);
	HEX3	<=	not HEX3_REG(6 downto 0);
	HEX4	<=	not HEX4_REG(6 downto 0);
	HEX5	<=	not HEX5_REG(6 downto 0);
end architecture BEHAVIORAL;