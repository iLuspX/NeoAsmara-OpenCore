@echo off
cd /d "%~dp0"
"%~dp0Bin\Initialize.exe"
if errorlevel 1 (
  echo Setup did not complete. Read the error above.
  pause
  exit /b 1
)
echo Initialization complete.
pause
