@echo off
set GHDL=..\..\0.36-mingw32-mcode\bin\ghdl.exe
echo [43;30m               [0m
echo [43;30m ...Compile... [0m
echo [43;30m               [0m
echo.

echo [46;30m Building VHDL files... [0m
%GHDL% -a --std=08 --workdir=work *.vhdl
if errorlevel 1 GOTO ERR
%GHDL% -a --std=08 --workdir=work test_bench\*.vhdl
if errorlevel 1 GOTO ERR
echo VHDL compiled.
echo.


echo [46;30m Testing Data Register [0m
%GHDL% --elab-run --std=08 --workdir=work data_register_tb --stop-time=500ns --vcd=data_register.vcd 
if errorlevel 1 GOTO ERR
echo data register OK
echo.

echo [46;30m Testing Instruction Register [0m
%GHDL% --elab-run --std=08 --workdir=work instruction_register_tb --stop-time=500ns --vcd=instruction_register.vcd 
if errorlevel 1 GOTO ERR
echo instruction register OK
echo.


echo [46;30m Testing ALU [0m
%GHDL% --elab-run --std=08 --workdir=work alu_tb --stop-time=500ns --vcd=alu.vcd 
if errorlevel 1 GOTO ERR
echo ALU OK
echo.


echo [46;30m Testing RAM [0m
%GHDL% --elab-run --std=08 --workdir=work local_ram_tb --stop-time=500ns --vcd=ram.vcd 
if errorlevel 1 GOTO ERR
echo RAM OK
echo.


echo [46;30m Testing Memory Address Register [0m
%GHDL% --elab-run --std=08 --workdir=work mar_register_tb --stop-time=500ns --vcd=mar.vcd 
if errorlevel 1 GOTO ERR
echo Memory Address Register OK
echo.


echo [46;30m Program Counter [0m
%GHDL% --elab-run --std=08 --workdir=work program_counter_tb --stop-time=500ns --vcd=pc.vcd 
if errorlevel 1 GOTO ERR
echo Program Counter OK
echo.

echo [42;97m Build Succeeded [0m

GOTO DONE

:ERR
echo [101;93m Build Failed [0m

:DONE

