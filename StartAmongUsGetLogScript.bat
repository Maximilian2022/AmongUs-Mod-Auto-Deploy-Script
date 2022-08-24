chcp 65001
@echo off


curl.exe -O -L https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/gmhtechsupport.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\gmhtechsupport.ps1

del .\gmhtechsupport.ps1

