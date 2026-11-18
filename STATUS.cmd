@echo off
"%~dp0Bin\ServerControl.exe" status
if errorlevel 1 pause
