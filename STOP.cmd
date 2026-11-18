@echo off
"%~dp0Bin\ServerControl.exe" stop
if errorlevel 1 pause
