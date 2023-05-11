
chcp 65001
@echo off


curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

del /F /Q .\AmongUsModTORplusDeployScript.ps1

