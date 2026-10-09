chcp 65001 >nul
@echo off
setlocal
pushd "%~dp0"

curl.exe -k -s -S -L --retry 2 -o "%~dp0AmongusCleanInstall_Epic.ps1" https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1

set "PS_EXE=powershell.exe"
where pwsh.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "PS_EXE=pwsh.exe"
) else (
    if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
        set "PS_EXE=%ProgramFiles%\PowerShell\7\pwsh.exe"
    )
)

"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0AmongusCleanInstall_Epic.ps1"

del /F /Q "%~dp0AmongusCleanInstall_Epic.ps1"
popd
