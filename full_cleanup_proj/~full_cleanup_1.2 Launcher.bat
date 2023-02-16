REM This script must be run as Administrator.

@echo off 

start powershell.exe "%~dp0full_cleanup_1.2.ps1" runas

pause