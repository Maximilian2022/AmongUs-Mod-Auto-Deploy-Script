chcp 65001
@echo off
curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1
pwsh -NoProfile -ExecutionPolicy Unrestricted .\gmhtechsupport.ps1 "LM" "C:\Program Files (x86)\Steam\steamapps\common\Among Us LM Mod" "steam"

del .\gmhtechsupport.ps1
