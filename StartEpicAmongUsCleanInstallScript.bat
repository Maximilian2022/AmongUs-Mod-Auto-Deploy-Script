chcp 65001
@echo off


curl.exe -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\AmongusCleanInstall_Epic.ps1

del .\AmongusCleanInstall_Epic.ps1

