-- ***********************************************************************
-- Project: RISC-V Multicore Power-Aware Processor
-- Filename: run_ctrl.vhd
-- Author: carrollh@msoe.edu <Hunter C>
-- Date: 24 Sep 2026
-- Provides:
--		Synchronizer ffs for async inputs
--		Selection for speed
--		Selection for run/step mode
-- ***********************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--		RUN		:	Step button input to step to next instruction
--		STEP_N	:	Switch to decide between regular run and step
--		SPEED		:	Speed of run mode so instructions can be read
-- outputs:
--		CORE_EN	:	Enables the core to control the run speed
--		STEP_MODE:	If we are stepping with button press or not
entity RUN_CTRL is
generic(CLK_HZ	:	natural	:=	50_000_000);
port(
	CLK		:	in std_logic;
	RST		:	in std_logic;
	RUN		:	in	std_logic;
	SPEED		:	in std_logic_vector(1 downto 0);
	STEP_N	:	in std_logic;
	CORE_EN	:	out std_logic;
	STEP_MODE:	out std_logic);
end entity RUN_CTRL;

-- architecture description
architecture BEHAVIORAL of RUN_CTRL is
	-- two flip flop synchronizers for async input
	signal RUN_S1, RUN_S2	:	std_logic;
	signal SPD_S1, SPD_S2	:	std_logic_vector(1 downto 0);
	signal STEP_S1, STEP_S2	:	std_logic;
	signal STEP_PREV			:	std_logic;
	
	signal STEP_PULSE			:	std_logic;
	signal SLOW_TICK			:	std_logic;
	
	-- slow-run period in clock cycles for speed setting
	signal TERMINAL			:	unsigned(26 downto 0);
	signal COUNT				:	unsigned(26 downto 0);
begin
	-- synchronize switches and key into CLK domain
	sync: process(CLK)
	begin
		if rising_edge(CLK) then
			RUN_S1		<=	RUN;
			SPD_S1		<=	SPEED;
			STEP_S1		<=	STEP_N;
			RUN_S2		<=	RUN_S1;
			SPD_S2		<=	SPD_S1;
			STEP_S2		<=	STEP_S1;
			STEP_PREV	<=	STEP_S2;
		end if;
	end process sync;
	
	-- key1 is active-low
	STEP_PULSE	<=	STEP_PREV and not STEP_S2;
	
	-- period for each slow-run speed (term ct = CLK_HZ / rate - 1)
	with SPD_S2 select
	TERMINAL	<=	to_unsigned(CLK_HZ / 10 - 1, 27) when B"01",	--	10 Hz
					to_unsigned(CLK_HZ / 2 - 1, 27) when B"10",	--	2 Hz
					to_unsigned(CLK_HZ * 2 - 1, 27) when others; -- 0.5 Hz
					
	-- counter to produce one_cycle slow tick
	slow: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '1' or COUNT >= TERMINAL then
				COUNT	<=	(others => '0');
			else
				COUNT	<=	COUNT + 1;
			end if;
		end if;
	end process slow;
	
	SLOW_TICK	<=	'1' when COUNT = TERMINAL else '0';
	
	-- select enable
	CORE_EN		<=	STEP_PULSE when RUN_S2 = '0' else
						'1' when SPD_S2 = B"00" else
						SLOW_TICK;
						
	STEP_MODE	<=	not RUN_S2;
end architecture BEHAVIORAL;