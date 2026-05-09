@echo off
setlocal

if "%~1"=="" (
  echo Usage:
  echo   fpga new ^<project_name^>
  echo   fpga validate ^<project_name_or_path^>
  echo   fpga create ^<project_name_or_path^>
  echo   fpga sim ^<project_name_or_path^>
  echo   fpga synth ^<project_name_or_path^>
  echo   fpga bitstream ^<project_name_or_path^>
  echo   fpga gui ^<project_name_or_path^>
  echo   fpga wave ^<project_name_or_path^>
  echo   fpga clean ^<project_name_or_path^>
  exit /b 1
)

set "ACTION=%~1"
set "TARGET=%~2"

if /I "%ACTION%"=="new" (
  if "%TARGET%"=="" (
    echo Usage: fpga new ^<project_name^>
    exit /b 1
  )
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\new_fpga_project.ps1" -Name "%TARGET%"
  exit /b %ERRORLEVEL%
)

if "%TARGET%"=="" set "TARGET=."

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\fpga.ps1" -Project "%TARGET%" -Action "%ACTION%"
exit /b %ERRORLEVEL%
