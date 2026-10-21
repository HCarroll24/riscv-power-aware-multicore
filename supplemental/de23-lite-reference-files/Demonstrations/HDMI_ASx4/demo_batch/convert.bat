@echo off
echo FPGA Configure...

REM ########################################################################
REM # Download sof file
REM ########################################################################
@ set QUARTUS_BIN=%QUARTUS_ROOTDIR%\bin
@ if not exist "%QUARTUS_BIN%" set QUARTUS_BIN=%QUARTUS_ROOTDIR%\bin64


 %QUARTUS_BIN%\\quartus_pfg -c golden_top.sof golden_top.jic -o device=MT25QU128 -o flash_loader=A3CZ135BB18AE7S -o mode=ASX4 
pause