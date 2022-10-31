
chcp 65001
@echo off


curl.exe -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

del .\AmongUsModTORplusDeployScript.ps1

