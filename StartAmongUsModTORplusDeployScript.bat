chcp 65001
@echo off

curl.exe -O -L "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongUsModTORplusDeployScript.ps1"

powershell -NoProfile -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

del .\AmongUsModTORplusDeployScript.ps1
