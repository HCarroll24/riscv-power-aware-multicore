-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
-- CREATED		"Thu Sep 10 01:45:48 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY multicorecpu IS 
	PORT
	(
		RST :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		WD3 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END multicorecpu;

ARCHITECTURE bdf_type OF multicorecpu IS 

COMPONENT pipeline
	PORT(RST : IN STD_LOGIC;
		 CLK : IN STD_LOGIC;
		 WD3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



b2v_single_core : pipeline
PORT MAP(RST => RST,
		 CLK => CLK,
		 WD3 => WD3);


END bdf_type;