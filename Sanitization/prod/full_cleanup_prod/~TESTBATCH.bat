REM This script must be run as Administrator.

@echo off 
cd c:\Users
powershell -command "Set-ExecutionPolicy Bypass -Force"
for /F "delims=" %%L in ('dir /s /B TESTRUN*') do (set "VAR=%%L")
%VAR%


pause