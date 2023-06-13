
chcp 65001
@echo off

for /f "usebackq" %%t in (`CD`) do set COUNT=%%t

curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

del /F /Q %COUNT%\AmongUsModTORplusDeployScript.ps1

