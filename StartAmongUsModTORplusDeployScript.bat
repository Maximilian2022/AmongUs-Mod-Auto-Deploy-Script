chcp 65001
@echo off

setlocal

for /f "usebackq delims=" %%A in (`curl.exe -A 'usercommand:bat_ps1' -s -o nul -w "%%{http_code}" "https://blog.kit-a.net/counter/"`) do set hcode=%%A

if %hcode% == 200 (

curl.exe -O https://blog.kit-a.net/wp-content/uploads/2021/12/AmongUsModTORplusDeployScript.ps1

powershell -NoProfile -ExecutionPolicy Unrestricted .\AmongUsModTORplusDeployScript.ps1

del .\AmongUsModTORplusDeployScript.ps1

) else (
	echo %hcode%
	echo 多分今サイトが落ちてます。また後程お試しください。
	pause
)