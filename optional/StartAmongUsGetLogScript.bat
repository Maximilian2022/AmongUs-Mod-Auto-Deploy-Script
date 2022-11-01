chcp 65001
@echo off


curl.exe -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\gmhtechsupport.ps1

del .\gmhtechsupport.ps1

