REM This script must be run as Administrator.

@echo off 

start powershell.exe "%~dp0TESTRUN.ps1" runas

pause