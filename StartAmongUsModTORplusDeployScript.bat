
chcp 65001
@echo off

echo %date% %time%   Loading...

for /f "usebackq" %%t in (`CD`) do set COUNT=%%t

echo %date% %time%   Downloading Latest Powershell Script

curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

echo %date% %time%   Running Powershell Script

powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

echo %date% %time%   Delete Powershell Script

del /F /Q %COUNT%\AmongUsModTORplusDeployScript.ps1

