@echo off
setlocal

if "%~1"=="" (
  echo Usage: tools\new-fpga ^<project_name^>
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0new_fpga_project.ps1" -Name "%~1"
exit /b %ERRORLEVEL%
