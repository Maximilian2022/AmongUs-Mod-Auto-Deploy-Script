chcp 65001
@echo off


curl.exe -O -L https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongusCleanInstall_Steam.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\AmongusCleanInstall_Steam.ps1

del .\AmongusCleanInstall_Steam.ps1

