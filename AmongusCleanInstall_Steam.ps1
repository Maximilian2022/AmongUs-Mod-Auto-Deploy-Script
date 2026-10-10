Param(
    $Args1, #skipconfirmation
    [switch]$DebugMode
)
#################################################################################################
#
# Among Us Clean Install Script Steam
#
$version = "1.0.2"
#
#################################################################################################
# Translate Function with Caching
#################################################################################################
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ProgressPreference = 'SilentlyContinue'
$Cult  = Get-Culture
$TranslationCache = @{}
#$Cult  = "en-US"
function Get-Translate($transtext){
    if($Cult -ne "ja-JP"){
        # キャッシュから返す
        if($TranslationCache.ContainsKey($transtext)){
            return $TranslationCache[$transtext]
        }
        try{
            $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($Cult)&dt=t&q=$transtext"
            $Response = (Invoke-WebRequest -Uri $Uri -Method Get -TimeoutSec 5).Content
            $Resulttxt = $Response -split '\\r\\n' -replace '^(","?)|(null.*?\[")|\[{3}"' -split '","'
            $result = $Resulttxt[0]
            # キャッシュに保存
            $TranslationCache[$transtext] = $result
            return $result
        }catch{
            # エラー時はキャッシュに保存して返す
            $TranslationCache[$transtext] = $transtext
            return $transtext
        }
    }else{
        return $transtext
    }
}

#################################################################################################
# Run w/ Powershell v7 if available.
#################################################################################################
$npl = Get-Location
$isDebugger = ($env:TERM_PROGRAM -eq "vscode") -or ($null -ne $psISE) -or $DebugMode

$v5run = $false
if ($PSVersionTable.PSVersion.major -eq 5) {
    if (test-path "$env:ProgramFiles\PowerShell\7") {
        if (!$isDebugger) {
            Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongusCleanInstall_Steam.ps1`"" -Verb RunAs -Wait
            exit
        }
    } else {
        $v5run = $true
    }
} elseif ($PSVersionTable.PSVersion.major -gt 5) {
    $v5run = $true
} else {
    write-host "ERROR - PowerShell Version : not supported."
}

if ($v5run -and !$isDebugger -and !([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongusCleanInstall_Steam.ps1`""
    if ($Args1) { $argList += " -Args1 `"$Args1`"" }
    Start-Process (if ($PSVersionTable.PSVersion.major -gt 5) { "pwsh.exe" } else { "powershell.exe" }) -ArgumentList $argList -Verb RunAs -Wait
    exit
}
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
Write-Log "               AmongUs Clean Install Script Steam                "
Write-Log "                                                   Version: $version"
Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Starts"
Write-Log "-----------------------------------------------------------------"

#Steam起動チェック
$steampth = "C:\Program Files (x86)\Steam\Steam.exe"
$steamReg = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamExe" -ErrorAction SilentlyContinue).SteamExe
if (![string]::IsNullOrEmpty($steamReg) -and (Test-Path $steamReg)) {
    $steampth = $steamReg.Replace('/', '\')
}
$steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue | Select-Object -First 1
$procPath = $null
if ($null -ne $steamProc) {
    try {
        $procPath = $steamProc.Path
        if ([string]::IsNullOrEmpty($procPath)) {
            $procPath = $steamProc.MainModule.FileName
        }
    } catch {
        Write-Log "Warning: Steam process path access failed: $_"
    }
}

if (Test-Path $steampth) {
    Write-Log "Steam アプリは以下で見つかりました。 $steampth"
} elseif ($null -ne $procPath -and (Test-Path $procPath)) {
    $steampth = $procPath
    Write-Log "Steam アプリは以下で見つかりました。 $steampth"
} else {
    Write-Log "Steam アプリがデフォルトの場所に見つかりませんでした。"
    # $FilePath が設定されていない、又はファイルが存在しない
    if ([string]::IsNullOrEmpty($steampth) -Or (Test-Path -LiteralPath $steampth -PathType Leaf) -eq $false) {
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")    
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = $(Get-Translate("EXE ファイル(*.EXE)|*.EXE"))
        $dialog.InitialDirectory = "C:\"
        $dialog.Title = $(Get-Translate("Steam.exe ファイルを選択してください"))
    
        # キャンセルを押された時は処理を止める
        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            exit 1
        }
    
        # 選択したファイルパスを $FilePath に設定
        $steampth = $dialog.FileName
    }
}

#操作したいウィンドウのタイトル
$MAIN_WINDOW_TITLE="Steam"
$steamruncheck = $true
$steamrunner = $true
$steamWaitCount = 0

while($steamruncheck){
    $steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue
    if ($steamProc) {
        # Steam プロセス自体は既に起動している
        try {
            $matchingProcs = Get-Process | Where-Object { $_.MainWindowTitle -like "*$MAIN_WINDOW_TITLE*" }
            if ($matchingProcs -and $matchingProcs[0].MainWindowHandle -ne 0) {
                $hwnd = $matchingProcs[0].MainWindowHandle
            }
        } catch {}
        
        # ウィンドウがなくてもプロセスが動いていれば最大30秒(6回)で進行許可
        if ($hwnd -or ($steamWaitCount -ge 6)) {
            $steamruncheck = $false
            break
        }
    } else {
        if($steamrunner){
            Start-Process $steampth 
            $steamrunner = $false
        }
    }

    $steamWaitCount++
    if ($steamWaitCount -ge 24) { # 最大120秒でタイムアウトして進行
        Write-Log "Steam.exe 起動待機がタイムアウトしました。処理を継続します。"
        break
    }

    Write-Log "Steam.exe 起動チェック中 (${steamWaitCount}/24)..."
    Start-Sleep -Seconds 5
}
Start-Sleep -Seconds 3

#################################################################################################
#AutoDetect
#################################################################################################

#Among Us Original Steam Path
$au_path_steam_org = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"

if(Test-path "$au_path_steam_org\Among Us.exe"){
    $spath = $au_path_steam_org
}else{
    $fileName = Join-path $npl "\AmongUsModDeployScript.conf"
    ### Load
    if(test-path "$fileName"){
        $spath = Get-content "$fileName"
    }elseif($Args1){
        # 非対話モード時はダイアログを出さずに既定のSteamパスを採用
        Write-Log "非対話モード (-Args1): 既定のSteamパス $au_path_steam_org を使用します"
        $spath = $au_path_steam_org
    }else{
        #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
        Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"      
        Write-Log "フォルダをユーザーに選択するようダイアログを出します"      
        [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っていないAmongUsがインストールされているフォルダを選択してください")), "Among Us Clean Install Tool")
        $spath = Get-FolderPathG
    }
    if($null -eq $spath){
        Write-Log "Failed $spath"
        if (-not $Args1) { pause }
        Exit
    }
    if(test-path "$spath\Among Us.exe"){
        Write-Log "$spath にAmongUsのインストールパスを確認しました"
    }else{
        Write-Log "$spath にAmongUsのインストールが確認できませんでした"
    }
}

Write-Log "Delete AmongUs First"
if($null -eq $Args1){
    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("クリーンインストールのために選択したFolderは削除されます`n続行しますか？")), "Among Us Clean Install Tool",4) -eq "Yes"){
    }else{
        Write-Log "処理を中止します"
        exit
    }    
}

if (Test-Path $spath) {
    Remove-Item -Path $spath -Recurse -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 1

Write-Log "Validate AmongUs"
Start-Transcript -Append -Path "$LogFileName"
Start-Process $steampth -argument "+app_start_validation 945360" 
Stop-Transcript

Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Ends"
Write-Log "-----------------------------------------------------------------"
Start-Sleep -Seconds 5
exit 0
