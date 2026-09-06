chcp 65001 >nul
@echo off
setlocal
pushd "%~dp0"

echo %date% %time% Script Start >> "%~dp0lastruntime.txt"
echo %date% %time%   Loading...

echo %date% %time%   Downloading Latest Powershell Script

curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

if not exist "%~dp0AmongUsModTORplusDeployScript.ps1" (
    echo [ERROR] Failed to download AmongUsModTORplusDeployScript.ps1
    pause
    popd
    exit /b 1
)

echo %date% %time%   Running Powershell Script

powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted -File "%~dp0AmongUsModTORplusDeployScript.ps1"

echo %date% %time%   Delete Powershell Script

del /F /Q "%~dp0AmongUsModTORplusDeployScript.ps1"

echo %date% %time% Script End >> "%~dp0lastruntime.txt"
popd