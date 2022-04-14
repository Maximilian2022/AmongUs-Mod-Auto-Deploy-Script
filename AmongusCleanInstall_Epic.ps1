#################################################################################################
#
# Among Us Clean Install Script Epic
#
$version = "1.0.0"
#
#################################################################################################
# Run w/ Powershell v7 if available.
#################################################################################################
$npl = Get-Location
$v5run = $false

if($PSVersionTable.PSVersion.major -eq 5){
    if(test-path "$env:ProgramFiles\PowerShell\7"){
        pwsh.exe -NoProfile -ExecutionPolicy Unrestricted "$npl\AmongusCleanInstall_Epic.ps1"
    }else{
        $v5run = $true
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
            ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongusCleanInstall_Epic.ps1`"" -Verb RunAs -Wait
            exit
        }
        
    }
}elseif($PSVersionTable.PSVersion.major -gt 5){
    $v5run = $true
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")
        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongusCleanInstall_Epic.ps1`"" -Verb RunAs -Wait
        exit
    }
    
}else{
    write-host "ERROR - PowerShell Version : not supported."
}

if(!($v5run)){
    exit
}



#>
#################################################################################################
# Folder用Function
#################################################################################################
#Special Thanks
#https://qiita.com/Kosen-amai/items/7b2339d7de8223ab77c4
Add-Type -AssemblyName System.Windows.Forms
function Get-FolderPathG{
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$Description = "フォルダを選択してください",
        [boolean]$CurrentDefault = $false
    )
    # メインウィンドウ取得
    $process = [Diagnostics.Process]::GetCurrentProcess()
    $window = New-Object Windows.Forms.NativeWindow
    $window.AssignHandle($process.MainWindowHandle)

    $fd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fd.Description = $Description

    if($CurrentDefault -eq $true){
        # カレントディレクトリを初期フォルダとする
        $fd.SelectedPath = (Get-Item $PWD).FullName
    }

    # フォルダ選択ダイアログ表示
    $ret = $fd.ShowDialog($window)

    if($ret -eq [System.Windows.Forms.DialogResult]::OK){
        return $fd.SelectedPath
    }
    else{
        return $null
    }
}

#################################################################################################
# Log用Function
#################################################################################################
# ログの出力先
$LogPath = "C:\Temp"
# ログファイル名
$LogName = "AmongUsClean_InstallLog"
$Now = Get-Date
# ログファイル名(XXXX_YYYY-MM-DD.log)
$LogFile = $LogName + "_" +$Now.ToString("yyyy-MM-dd-HH-mm-ss") + ".log"
# ログフォルダーがなかったら作成
if( -not (Test-Path $LogPath) ) {
    New-Item $LogPath -Type Directory
}
# ログファイル名
$LogFileName = Join-Path $LogPath $LogFile
function Write-Log($logstring){
    $Now = Get-Date
    # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
    $Log += $LogString
        # ログ出力
    Write-Output $Log | Out-File -FilePath $LogFileName -Encoding UTF8 -Append
    # echo させるために出力したログを戻す
    Return $Log
}
#################################################################################################

Write-Log "Running With Powershell Version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Log "                                                                 "
Write-Log "-----------------------------------------------------------------"
Write-Log "                                                                 "
Write-Log "                AmongUs Clean Install Script Epic                 "
Write-Log "                                                   Version: $version"
Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Starts"
Write-Log "-----------------------------------------------------------------"

#Among Us Original Epic Path
$au_path_epic_org = "C:\Program Files\Epic Games\AmongUs"
#Among Us Backup ：Backup用フォルダ
$au_path_epic_back = "C:\Program Files\Epic Games\AmongUsBackup"
$spath = ""

if(Test-path "$au_path_epic_org\Among Us.exe"){
    $spath = $au_path_epic_org
    $sback = $au_path_epic_back
}else{
    $fileName = Join-path $npl "\AmongUsModDeployScript.conf"
    ### Load
    if(test-path "$fileName"){
        $spath = Get-content "$fileName"
    }else{
        #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
        Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"      
        Write-Log "フォルダをユーザーに選択するようダイアログを出します"      
        [System.Windows.Forms.MessageBox]::Show("Modが入っていないAmongUsがインストールされているフォルダを選択してください", "Among Us Clean Install Tool")
        $spath = Get-FolderPathG
    }
    if($null -eq $spath){
        Write-Log "Failed $spath"
        pause
        Exit
    }
    if(test-path "$spath\Among Us.exe"){
        Write-Log "$spath にAmongUsのインストールパスを確認しました"
    }else{
        Write-Log "$spath にAmongUsのインストールが確認できませんでした"
    }
    $curloc = Get-Location
    Set-Location $spath
    Set-Location ../
    $str_path = Get-Location   
    $sback = "$str_path\Among Us Backup"
    Set-Location $curloc
}

Write-Log "Delete AmongUs First"
if([System.Windows.Forms.MessageBox]::Show("クリーンインストールのために選択したFolderは削除されます`n続行しますか？", "Among Us Clean Install Tool",4) -eq "Yes"){
}else{
    Write-Log "処理を中止します"
    exit
}

Start-Transcript -Append -Path "$LogFileName"

if(Test-Path "$sback\legendary.exe"){
    Set-Location $sback
    $legflag = $true
}else{
    Set-Location $npl
    Invoke-WebRequest "https://github.com/derrod/legendary/releases/download/0.20.25/legendary.exe" -OutFile "$npl\legendary.exe" 
    ./legendary.exe auth --import    
}

$currentLoc = Get-Location
Set-Location $spath
Set-Location ../
$spath = Get-Location
Set-Location $currentLoc
Remove-Item -Path $spath -Recurse -Force
Start-Sleep -Seconds 1
./legendary.exe uninstall Among Us --keep-files -y 
Start-Sleep -Seconds 1
./legendary.exe install Among Us -y --base-path "$spath"
Start-Sleep -Seconds 1
./legendary.exe -y egl-sync
Stop-Transcript
if (!($legflag)){
    Remove-item "$npl\legendary.exe" -Force
}

Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Ends"
Write-Log "-----------------------------------------------------------------"


