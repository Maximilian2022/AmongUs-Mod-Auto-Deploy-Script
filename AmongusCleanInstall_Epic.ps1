Param($Args1) #modnum
#################################################################################################
#
# Among Us Clean Install Script Epic
#
$version = "1.0.1"
#
#################################################################################################
# Translate Function
#################################################################################################
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$Cult  = Get-Culture
#$Cult  = "en-US"
function Get-Translate($transtext){
    if($Cult -ne "ja-JP"){
        $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($Cult)&dt=t&q=$transtext"
        $Response = (Invoke-WebRequest -Uri $Uri -Method Get).Content
        $Resulttxt = $Response -split '\\r\\n' -replace '^(","?)|(null.*?\[")|\[{3}"' -split '","'
        return $Resulttxt[0]
    }else{
        return $transtext
    }
}
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
        [string]$Description = $(Get-Translate("フォルダを選択してください")),
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
$LogPath = "C:\Temp\AUM_Clean"
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
    Write-Output $(Get-Translate($Log)) | Out-File -FilePath $LogFileName -Encoding UTF8 -Append
    # echo させるために出力したログを戻す
    Return $(Get-Translate($Log))
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
        [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っていないAmongUsがインストールされているフォルダを選択してください")), "Among Us Clean Install Tool")
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
if($null -eq $Args1){
    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("クリーンインストールのために選択したFolderは削除されます`n続行しますか？")), "Among Us Clean Install Tool",4) -eq "Yes"){
    }else{
        Write-Log "処理を中止します"
        exit
    }        
}

Start-Transcript -Append -Path "$LogFileName"

try{
    legendary -V
}
catch{
    try{
        choco -v
    }catch{
        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
    }
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco install legendary -y" -Verb RunAs -Wait   
}


Set-Location $spath
Set-Location ../
$instpath = Get-Location
write-log $spath
Write-Log $instpath
Remove-Item -Path $spath -Recurse -Force
Start-Sleep -Seconds 1
legendary uninstall Among Us --keep-files -y 
Start-Sleep -Seconds 1
legendary install Among Us -y --base-path "$instpath"
Start-Sleep -Seconds 1
legendary -y egl-sync
Stop-Transcript

Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Ends"
Write-Log "-----------------------------------------------------------------"


