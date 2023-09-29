
chcp 65001
@echo off
set T1=%time%
call :ConvSec "%T1%"
set R1=%R%
echo %date% %time%   Loading...

for /f "usebackq" %%t in (`CD`) do set COUNT=%%t

echo %date% %time%   Downloading Latest Powershell Script

curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongUsModTORplusDeployScript.ps1

echo %date% %time%   Running Powershell Script

powershell -NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

echo %date% %time%   Delete Powershell Script

del /F /Q %COUNT%\AmongUsModTORplusDeployScript.ps1

set T2=%time%
call :ConvSec "%T2%"
set R2=%R%
call :Calc "%R1%" "%R2%"
echo 所要時間 T2-T1 = %H%:%M%:%S% >> %COUNT%\lastruntime.txt
exit

:ConvSec
for /F "tokens=1-3 delims=:." %%a in ('echo %~1') do (
    set /a R=%%a*3600+1%%b*60+1%%c-6100
)
goto :EOF

:Calc
set /a A=%~2-%~1
set /a H=%A%/3600
set /a M=%A%%%3600/60
set /a S=%A%%%60
goto:EOF