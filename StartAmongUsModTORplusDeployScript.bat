chcp 65001 >nul
@echo off
setlocal
pushd "%~dp0"

echo %date% %time% Script Start >> "%~dp0lastruntime.txt"
echo %date% %time%   Loading...

echo %date% %time%   Downloading Latest Powershell Script

curl.exe -k -s -S -L --retry 2 -o "%~dp0AmongUsModTORplusDeployScript.ps1" https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

if not exist "%~dp0AmongUsModTORplusDeployScript.ps1" (
    echo [ERROR] Failed to download AmongUsModTORplusDeployScript.ps1
    pause
    popd
    exit /b 1
)

echo %date% %time%   Detecting PowerShell Version

set "PS_EXE=powershell.exe"
where pwsh.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "PS_EXE=pwsh.exe"
) else (
    if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
        set "PS_EXE=%ProgramFiles%\PowerShell\7\pwsh.exe"
    )
)

echo %date% %time%   Running Script with %PS_EXE%

"%PS_EXE%" -NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File "%~dp0AmongUsModTORplusDeployScript.ps1"

echo %date% %time%   Delete Powershell Script

del /F /Q "%~dp0AmongUsModTORplusDeployScript.ps1"

echo %date% %time% Script End >> "%~dp0lastruntime.txt"
popd