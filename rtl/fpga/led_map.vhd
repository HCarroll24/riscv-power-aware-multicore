-- ***********************************************************************
-- Project: RISC-V Multicore Power-Aware
-- Filename: led_map.vhd
-- Author: carrollh@msoe.edu <Hunter C>
-- Date: 24 Sep 2026
-- Provides:
--		Mapping for values for LEDS on De-10 Lite board
-- ***********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		CLK
--		RST
--		CORE_EN
--		STEP_MODE
--		IF_ID_VALID
--		ID_EX_VALID
--		EX_MEM_VALID
--		MEM_WB_VALID
--		MEM_WB_REGWR
--		STALL
--		REDIRECT_EN
--		PREDICT_TAKEN
--		MISPREDICT
-- OUTPUTS:
--		LEDR
entity LED_MAP is
port(	CLK, RST			:	in std_logic;
		CORE_EN			:	in std_logic;
		STEP_MODE		:	in std_logic;
		IF_ID_VALID		:	in std_logic;
		ID_EX_VALID		:	in std_logic;
		EX_MEM_VALID	:	in std_logic;
		MEM_WB_VALID	:	in std_logic;
		MEM_WB_REGWR	:	in std_logic;
		STALL				:	in std_logic;
		REDIRECT_EN		:	in std_logic;
		PREDICT_TAKEN	:	in std_logic;
		MISPREDICT		:	in std_logic;
		LEDR				:	out std_logic_vector(9 downto 0));
end entity LED_MAP;

-- architecture description
architecture BEHAVIORAL of LED_MAP is
	-- free running heartbeat signals
	-- 50 MHz / 2^25 = 1.5 Hz blink
	signal BEAT_CNT	:	unsigned(24 downto 0);
	signal HEARTBEAT	:	std_logic;
begin
	-- heartbeat counter
	beat: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				BEAT_CNT	<=	(others => '0');
			else
				BEAT_CNT	<=	BEAT_CNT + 1;
			end if;
		end if;
	end process beat;
	
	HEARTBEAT	<=	BEAT_CNT(24);
	
	-- LED assignments
	LEDR(0)	<=	IF_ID_VALID;
	LEDR(1)	<=	ID_EX_VALID;
	LEDR(2)	<=	EX_MEM_VALID;
	LEDR(3)	<=	MEM_WB_VALID;
	LEDR(4)	<=	MEM_WB_REGWR;
	LEDR(5)	<=	STALL;
	LEDR(6)	<=	REDIRECT_EN;
	LEDR(7)	<=	PREDICT_TAKEN;
	LEDR(8)	<=	MISPREDICT;
	LEDR(9)	<=	'1' when STEP_MODE = '1' else HEARTBEAT;
end architecture BEHAVIORAL;