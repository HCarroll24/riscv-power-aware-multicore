-- **********************************************************************
-- Project:		Undergrad Research Multicore Processor
-- Filename:	irom.vhd
-- Author:		carrollh@msoe.edu <Hunter C>
-- Date:			26 March 2026
-- Provides:
--   - Word-wide instruction ROM; combinational read from ADDR 
--		 to Q (with-select ROM table).
--   - No clocked load or reset—behavior is a fixed decode of the 
--		 programmed instruction image.
-- **********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs: 
--    ADDR  : 32-bit address requesting instruction 
-- outputs: 
--    Q     : 32-bit output of machine code instruction 
-- notes    : ROMs do not reset on power-up so no reset signal 
--          : ROMs do not load in user mode so no load signal  
entity IROM is 
port(ADDR  : in std_logic_vector(31 downto 0);
     Q     : out std_logic_vector(31 downto 0));
end entity IROM;

-- circuit description 
architecture MULTIPLEXER of IROM is 
begin

  -- use address to output correct binary machine code number 
  with ADDR select 
  Q <=  32X"00a00093"	when	32X"0",
32X"108133"	when	32X"4",
32X"500193"	when	32X"8",
32X"700213"	when	32X"0000000C",
32X"003182b3"	when	32X"10",
32X"6400313"	when	32X"14",
32X"100393"	when	32X"18",
32X"200413"	when	32X"0000001C",
32X"006304b3"	when	32X"20",
32X"100513"	when	32X"24",
32X"150593"	when	32X"28",
32X"158613"	when	32X"0000002C",
32X"160693"	when	32X"30",
32X"168713"	when	32X"34",
32X"01e00793"	when	32X"38",
32X"00c00813"	when	32X"0000003C",
32X"010788b3"	when	32X"40",
32X"913"	when	32X"44",
32X"692023"	when	32X"48",
32X"92983"	when	32X"0000004C",
32X"01398a33"	when	32X"50",
32X"00400a93"	when	32X"54",
32X"00aaa023"	when	32X"58",
32X"000aab03"	when	32X"0000005C",
32X"032b0b93"	when	32X"60",
32X"00092c03"	when	32X"64",
32X"02a00c93"	when	32X"68",
32X"019c0d33"	when	32X"0000006C",
32X"00700d93"	when	32X"70",
32X"92e03"	when	32X"74",
32X"01cd8eb3"	when	32X"78",
32X"13"	when	32X"0000007C",
32X"13"	when	32X"80",
32X"13"	when	32X"84",
32X"13"	when	32X"88",
32X"500093"	when	32X"0000008C",
32X"500113"	when	32X"90",
32X"193"	when	32X"94",
32X"00a00213"	when	32X"98",
32X"118193"	when	32X"0000009C",
32X"13"	when	32X"000000A0",
32X"13"	when	32X"000000A4",
32X"fe41cae3"	when	32X"000000A8",
32X"100293"	when	32X"000000AC",
32X"200313"	when	32X"000000B0",
32X"13"	when	32X"000000B4",
32X"13"	when	32X"000000B8",
32X"00628c63"	when	32X"000000BC",
32X"6400393"	when	32X"000000C0",
32X"00628a63"	when	32X"000000C4",
32X"0c800413"	when	32X"000000C8",
32X"628863"	when	32X"000000CC",
32X"12c00493"	when	32X"000000D0",
32X"100513"	when	32X"000000D4",
32X"200593"	when	32X"000000D8",
32X"300613"	when	32X"000000DC",
32X"500693"	when	32X"E0",
32X"500713"	when	32X"E4",
32X"700793"	when	32X"E8",
32X"13"	when	32X"000000EC",
32X"13"	when	32X"000000F0",
32X"00e68263"	when	32X"000000F4",
32X"100813"	when	32X"000000F8",
32X"00f68263"	when	32X"000000FC",
32X"200893"	when	32X"100",
32X"00e68263"	when	32X"104",
32X"300913"	when	32X"108",
32X"00f68263"	when	32X"0000010C",
32X"400993"	when	32X"110",
32X"00e68263"	when	32X"114",
32X"00500a13"	when	32X"118",
32X"00800aef"	when	32X"0000011C",
32X"3e700b13"	when	32X"120",
32X"02a00b93"	when	32X"124",
32X"00000c13"	when	32X"128",
32X"00500c93"	when	32X"0000012C",
32X"13"	when	32X"130",
32X"13"	when	32X"134",
32X"001c0c13"	when	32X"138",
32X"13"	when	32X"0000013C",
32X"13"	when	32X"140",
32X"ff9c4ae3"	when	32X"144",
32X"13"	when	32X"148",
32X"13"	when	32X"0000014C",
32X"13"	when	32X"150",
32X"13"	when	others;

 end architecture MULTIPLEXER;