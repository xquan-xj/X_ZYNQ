@echo off
setlocal

if "%~1"=="" (
  echo Usage:
  echo   tools\fpga new ^<project_name^>
  echo   tools\fpga validate ^<project_path^>
  echo   tools\fpga create ^<project_path^>
  echo   tools\fpga sim ^<project_path^>
  echo   tools\fpga synth ^<project_path^>
  echo   tools\fpga bitstream ^<project_path^>
  echo   tools\fpga gui ^<project_path^>
  echo   tools\fpga clean ^<project_path^>
  exit /b 1
)

set "ACTION=%~1"
set "TARGET=%~2"

if /I "%ACTION%"=="new" (
  if "%TARGET%"=="" (
    echo Usage: tools\fpga new ^<project_name^>
    exit /b 1
  )
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0new_fpga_project.ps1" -Name "%TARGET%"
  exit /b %ERRORLEVEL%
)

if "%TARGET%"=="" set "TARGET=."

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fpga.ps1" -Project "%TARGET%" -Action "%ACTION%"
exit /b %ERRORLEVEL%
