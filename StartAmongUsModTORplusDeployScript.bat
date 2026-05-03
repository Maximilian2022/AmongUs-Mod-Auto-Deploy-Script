chcp 65001
@echo off
setlocal

cd /d "%~dp0"
set LOGFILE=lastruntime.txt

echo %date% %time% Script Start >> "%LOGFILE%"
echo %date% %time%   Loading...

set BASE_URL=https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main

echo %date% %time%   Downloading Latest Scripts...
curl.exe -k -O -L "%BASE_URL%/AmongUsModTORplusDeployScript.ps1"
curl.exe -k -O -L "%BASE_URL%/Utils.psm1"
curl.exe -k -O -L "%BASE_URL%/ModConfig.json"
curl.exe -k -O -L "%BASE_URL%/GlobalVersionSettings.json"

echo %date% %time%   Running Powershell Script...
powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted -File .\AmongUsModTORplusDeployScript.ps1

echo %date% %time%   Cleaning up...
del /F /Q .\AmongUsModTORplusDeployScript.ps1
del /F /Q .\Utils.psm1
del /F /Q .\ModConfig.json
del /F /Q .\GlobalVersionSettings.json

echo %date% %time% Script End >> "%LOGFILE%"
endlocal
exit