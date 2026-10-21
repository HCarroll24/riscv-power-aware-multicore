@echo on

%QUARTUS_ROOTDIR%\..\niosv\bin\niosv-shell.exe -w --run "niosv-bsp -g -b=./ settings.bsp"

pause


