@echo off
cd /d "%~dp0"
title Among Us Mod Auto Deploy Tool - Modern GUI Mock Preview

where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    start "" pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0ModernGuiMock.ps1"
) else (
    start "" powershell -NoProfile -Sta -ExecutionPolicy Bypass -File "%~dp0ModernGuiMock.ps1"
)
exit
