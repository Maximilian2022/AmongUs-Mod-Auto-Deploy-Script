#################################################################################################
#
# Among Us Mod Tech Support Script
#
$version = "1.0.0"
#
#################################################################################################

$npl = Get-Location

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
$LogName = "AmongUs_TechSupportLog"
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
#Mod Selecter

$scid = ""
$scid = "TOR GMH"

#################################################################################################
#AutoDetect用Static
#################################################################################################
Write-Log "Running With Powershell Version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Log "                                                                 "
Write-Log "-----------------------------------------------------------------"
Write-Log "                                                                 "
Write-Log "              Among Us Mod Tech Support Script                   "
Write-Log "                                                   Version: $version"
Write-Log "-----------------------------------------------------------------"
Write-Log "Gathering Tech Support Information Starts"
Write-Log "-----------------------------------------------------------------"

#Among Us Modded Path ：Steam Mod用フォルダ
$au_path_steam_mod = "C:\Program Files (x86)\Steam\steamapps\common\Among Us $scid Mod"
#Among Us Modded Path ：Steam Mod用フォルダ
$au_path_epic_mod = "C:\Program Files\Epic Games\AmongUs $scid Mod"

if(Test-path "$au_path_steam_mod\Among Us.exe"){
    $aupathm = $au_path_steam_mod
    $platform = "steam"
}elseif(Test-path "$au_path_epic_mod\Among Us.exe"){
    $aupathm = $au_path_epic_mod
    $platform = "epic"
}else{
    $fileName = Join-path $npl "\AmongUsModDeployScript.conf"
    ### Load
    if(test-path "$fileName"){
        $spath = Get-content "$fileName"
        Remove-Item $fileName
    }else{
        #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
        Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"      
        Write-Log "フォルダをユーザーに選択するようダイアログを出します"      
        [System.Windows.Forms.MessageBox]::Show("Modが入っているAmongUsがインストールされているフォルダを選択してください", "Among Us Mod Auto Deploy Tool")
        $spath = Get-FolderPathG
    }
    if($null -eq $spath){
        Write-Log "Failed $spath"
        pause
        Exit
    }
    if(test-path "$spath\Among Us.exe"){
        Write-Log "$spath にAmongUs Modのインストールパスを確認しました"
        if([System.Windows.Forms.MessageBox]::Show("PlatformはSteamですか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
            $platform = "Steam"
        }else{
            $platform = "Epic"
        }
    }else{
        Write-Log "$spath にAmongUsのインストールが確認できませんでした"
        pause
        Exit
    }
    if(test-path $spath){
        $aupathm = $spath
        Write-Log $aupathm
    }else{
        Write-Log "選択されたフォルダにAmongUsを見つけることに失敗しました"      
        Write-Log "処理を中止します"      
        pause
        exit
    }
}
Write-Log "Platform:$platform"

Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "Check Tree"
Write-Log "-----------------------------------------------------------------"
Write-Log "$aupathm"

#フォルダ/ファイル構成チェック
Set-Location $aupathm
tree /F | Out-File -FilePath $LogFileName -Encoding UTF8 -Append

Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "Bepin Log"
Write-Log "-----------------------------------------------------------------"

#BepinEx稼働/BepinExLogチェック
if(!(Test-Path "$aupathm\BepInEx\LogOutput.log")){
    Write-Log "There is no Logoutput.log"
}else{
    $content = Get-content "$aupathm\BepInEx\LogOutput.log" -Raw
    Write-Log "`r`n $content"
}

Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "AmongUs AppData tree"
Write-Log "-----------------------------------------------------------------"
#\AppData\LocalLow\Innersloth\Among Us log
Set-Location "$env:APPDATA\..\LocalLow\Innersloth\Among Us"
tree /F | Out-File -FilePath $LogFileName -Encoding UTF8 -Append

Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "persLog"
Write-Log "-----------------------------------------------------------------"
$content = Get-content "$env:APPDATA\..\LocalLow\Innersloth\Among Us\persLog.log" -Raw
Write-Log "`r`n $content"
Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "Player"
Write-Log "-----------------------------------------------------------------"
$content = Get-content "$env:APPDATA\..\LocalLow\Innersloth\Among Us\Player.log" -Raw
Write-Log "`r`n $content"
Write-Log "`r`n`r`n "
Write-Log "-----------------------------------------------------------------"
Write-Log "Player-prev"
Write-Log "-----------------------------------------------------------------"
$content = Get-content "$env:APPDATA\..\LocalLow\Innersloth\Among Us\Player-prev.log" -Raw
Write-Log "`r`n $content"
Write-Log "`r`n`r`n "


Write-Log "-----------------------------------------------------------------"
Write-Log "Script Ends"
Write-Log "-----------------------------------------------------------------"

#post API(Discord or Git issue)



