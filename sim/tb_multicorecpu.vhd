/*************************************************************************
 * File:			tb_multicorecpu.vhd
 * Project:		RISC-V Power Aware
 * Author:		carrollh@msoe.edu <Hunter C>
 * Date:			20 October 2026
 * Provides:
 *		Testbench for multicorecpu so I can use questasim
*************************************************************************/
library ieee;
use ieee.std_logic_1164.all;

entity TB_MULTICORECPU is
generic(
	USE_MARKERS	:	boolean	:=	true);
end entity TB_MULTICORECPU;

-- architectural description
architecture SIM of TB_MULTICORECPU is
	signal CLK	:	std_logic							:=	'0';
	signal KEY	:	std_logic_vector(3 downto 0)	:=	"1111";	-- no button pressed
	signal SW	:	std_logic_vector(9 downto 0)	:=	(others => '0');
	signal LEDR	:	std_logic_vector(9 downto 0);
	signal HEX0, HEX1, HEX2, HEX3, HEX4, HEX5	:	std_logic_vector(6 downto 0);
begin
	CLK	<=	not CLK after 10 ns;	-- 50 MHz
	
	DUT	:	entity work.MULTICORECPU
		port map(
			CLK	=>	CLK,
			KEY	=>	KEY,
			SW		=>	SW,
			LEDR	=>	LEDR,
			HEX0	=>	HEX0,
			HEX1	=>	HEX1,
			HEX2	=>	HEX2,
			HEX3	=>	HEX3,
			HEX4	=>	HEX4,
			HEX5	=>	HEX5);
			
		MARKERS	:	if USE_MARKERS generate	
			WINDOW	:	process
				alias ADDR	is <<signal .TB_MULTICORECPU.DUT.DBUS_ADDR	:	std_logic_vector(31 downto 0)>>;
				alias WDATA	is <<signal .TB_MULTICORECPU.DUT.DBUS_WDATA	:	std_logic_vector(31 downto 0)>>;
				alias WE		is <<signal .TB_MULTICORECPU.DUT.DBUS_WE		:	std_logic>>;
			begin
				wait until rising_edge(CLK) and WE = '1' and ADDR = x"FF2000F0" and WDATA = x"00000001";
				report "WINDOW START " & time'image(now);
				wait until rising_edge(CLK) and WE = '1' and ADDR = x"FF2000F4";
				report "CHECKSUM " & to_hstring(WDATA);
				wait until rising_edge(CLK) and WE = '1' and ADDR = x"FF2000F0" and WDATA = x"00000002";
				report "WINDOW END " & time'image(now);
				wait for 100 ns;
				std.env.stop;
			end process WINDOW;
		end generate MARKERS;
end architecture SIM;