Param(
    $Args1, #skipconfirmation
    [switch]$DebugMode,
    [string]$DeployPlatform
)
$ScriptStartTime = Get-Date
$Log = $ScriptStartTime.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
################################################################################################
#
# Among Us Mod Auto Deploy Script
#
$version = "3.0.0"
$build = "2026101004"
#
#################################################################################################
Write-Output "$Log PS1 Loading Start $version -$build"

### 未確認Modについては　"NONE"で統一する

### Minimum versions (currently active)　v19
$ermin = "v2026.9.30.0"
$esmin = "v2026.9.30.0"
$tormin = "NONE"
$tourmin = "NONE"
$tohmin = "NONE"
$snrmin = "3.3.0.0"
$lmmin = "4.0.1"
$nosmin = "110"
$toymin = "NONE"
$sramin = "v2026.10.8"

### minimum version for 2026.8.18 v18
$ermin1 = "v2026.8.19.0"
$esmin1 = "v2026.8.19.0"
$tormin1 = "NONE"
$tourmin1 = "NONE"
$tohmin1 = "NONE"
$snrmin1 = "3.2.0.0"
$lmmin1 = "3.9.3"
$nosmin1 = "109"
$toymin1 = "NONE"
$sramin1 = "v2025.6.11"

### minimum version for 2026.6.5 v17
$ermin2 = "v2025.9.10.0"
$esmin2 = "v2025.9.10.0"
$tormin2 = "NONE"
$tourmin2 = "NONE"
$tohmin2 = "v5.1.13"
$snrmin2 = "3.1.0.0"
$lmmin2 = "3.9.0"
$nosmin2 = "107"
$toymin2 = "NONE"
$sramin2 = "v2025.6.8"

#Frequent changing parameter https://steamdb.info/depot/945361/manifests/
# Current versions:
#$prever1 = "2025.6.10"
#$prevtargetid1 = "1298083356997541927"
#$prever1 = "2025.9.9"
#$prevtargetid1 = "4146372421172743268"
#$prever1 = "2026.2.17"
#$prevtargetid1 = "8416065559776121687"
$prever1 = "2026.6.5"
$prevtargetid1 = "7623608153396667062"
$prever0 = "2026.8.18"
$prevtargetid0 = "1397756378225229500"
#2026.9.29 990035194164819049 v19
$gmhbool = $false #flag for Test
#Testdll: Snapshot 22.11.21c
#$torgmdll = "https://github.com/Dolly1016/Nebula/releases/download/snapshot/Nebula.dll"
$debugform = $false
$icorenew = $false

#TOR plus, TOR GM, TOR GMH, AUM ,TOR, TOU-R, TOYis depricated.
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$ProgressPreference = 'SilentlyContinue'

#################################################################################################
# Translate Function with Caching
#################################################################################################
$Cult = Get-Culture
$TranslationCache = @{}
$gmhweb = $null
$mrweb = $null
$torweb = $null
$tourweb = $null
$sraweb = $null
$erweb = $null
$nosweb = $null
$lmweb = $null
$snrweb = $null
$tohweb = $null
$toyweb = $null
$rhrweb = $null
$amsweb = $null
$transenabled = $true
#$Cult  = "en-US"
function Get-Translate($transtext) {
    if ($Cult -ne "ja-JP") {
        if ($transenabled) {
            # キャッシュから返す
            if ($TranslationCache.ContainsKey($transtext)) {
                return $TranslationCache[$transtext]
            }
            try {
                $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($Cult)&dt=t&q=$transtext"
                $Response = (Invoke-WebRequest -Uri $Uri -Method Get -TimeoutSec 5).Content
                $Resulttxt = $Response -split '\\r\\n' -replace '^(","?)|(null.*?\[")|\[{3}"' -split '","'
                $result = $Resulttxt[0]
                # キャッシュに保存
                $TranslationCache[$transtext] = $result
                return $result    
            }
            catch {
                # エラー時はキャッシュに保存して返す
                $TranslationCache[$transtext] = $transtext
                return $transtext
            }
        }
        else {
            return $transtext
        }
    }
    else {
        return $transtext
    }
}
$Now = Get-Date
$Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
Write-Output "$Log Loading Done."

if ($Cult -ne "ja-JP") {
    if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("出力されるログもOS言語に翻訳しますか？`r`n有効にすると動作がとても遅くなります。")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
        $transenabled = $true
    }
    else {
        $transenabled = $false
    }
}

#################################################################################################
# 権限チェック
#################################################################################################
$Now = Get-Date
$Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
Write-Output $(Get-Translate("$Log 実行前権限チェック開始"))
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$isAdmin) {
    $TempMyOutputEncode = [System.Console]::OutputEncoding
    [System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('shift_jis')
    if (!(((net localgroup Administrators) -contains $env:username ) -or ((net localgroup Administrators) -contains "$env:userdomain\$env:username"))) {
        $Now = Get-Date
        $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
        Write-Host $(Get-Translate("$Log このWindowsユーザーアカウントでは本Scriptは動作しません。管理者権限が必要です。"))
        Write-Host $(Get-Translate("$Log あなたのユーザー名($env:username)は管理者権限グループに属していません"))
        Write-Host $(Get-Translate("$Log 管理者権限グループに属しているユーザーは以下の通りです"))
        $nn = net localgroup Administrators
        Write-Host $nn
        pause
        Exit
    }
    [System.Console]::OutputEncoding = $TempMyOutputEncode
}
$Now = Get-Date
$Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
Write-Output $(Get-Translate("$Log 実行前権限チェック終了"))

#################################################################################################
# Run w/ Powershell v7 if available.
#################################################################################################
$npl = Get-Location
$npl2 = Get-Location
$Now = Get-Date
$Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
Write-Output $(Get-Translate("$Log 実行前チェック開始"))
$hasPwsh = $null -ne (Get-Command pwsh -ErrorAction SilentlyContinue) -or (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe")
if (!$hasPwsh) {
    $Now = Get-Date
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
    Write-Output $(Get-Translate("$Log 初起動時のみ: Powershell 7を導入中・・・。"))
    Start-Process powershell.exe -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
    Write-Output "`r`n"
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade pwsh powershell-core aria2 legendary -y" -Verb RunAs -Wait   
    Write-Output "`r`n"
    # PATHを再読み込み
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $pwshExe = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") { "$env:ProgramFiles\PowerShell\7\pwsh.exe" } else { "pwsh.exe" }
    $pwshArgs = "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`""
    if ($null -ne $Args1) { $pwshArgs += " $Args1" }
    Start-Process $pwshExe -ArgumentList $pwshArgs -Verb RunAs -Wait
    Write-Output "`r`n"
    Exit
}

Unblock-File "$npl\AmongUsModTORplusDeployScript.ps1"
$a = [Net.Dns]::GetHostName()
$achk = ($a -match '[^\x00-\x7F]')
if ($achk) {
    $Now = Get-Date
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
    Write-Output $(Get-Translate("$Log PCの名前に全角が含まれています。Modがうまく起動しない場合があります。英数字への名前変更を推奨します。"))
    Start-Process "https://support.lenovo.com/jp/ja/solutions/ht105079"
}

$Now = Get-Date
$Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "    
Write-Output $(Get-Translate("$Log 実行前チェック完了"))

$isDebugger = ($env:TERM_PROGRAM -eq "vscode") -or ($null -ne $psISE) -or $DebugMode

if (!$isDebugger -and ((!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) -or ($PSVersionTable.PSVersion.Major -lt 7))) {
    $pwshExe = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") { "$env:ProgramFiles\PowerShell\7\pwsh.exe" } else { "pwsh.exe" }
    $pwshArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`""
    if ($null -ne $Args1) { $pwshArgs += " $Args1" }
    Start-Process $pwshExe -ArgumentList $pwshArgs -Verb RunAs -Wait
    exit
}

#################################################################################################
# Log用Function
#################################################################################################
# ログの出力先
$LogPath = "C:\Temp\AUM_Deploy"
# ログファイル名
$LogName = "AmongUsMod_DeployLog"
$Now = Get-Date
# ログファイル名(XXXX_YYYY-MM-DD.log)
$LogFile = $LogName + "_" + $Now.ToString("yyyy-MM-dd-HH-mm-ss") + ".log"
# ログフォルダーがなかったら作成
if ( -not (Test-Path $LogPath) ) {
    New-Item $LogPath -Type Directory
}
# ログファイル名
$LogFileName = Join-Path $LogPath $LogFile

$scpath = [System.Environment]::GetFolderPath("Desktop")
$WsShell = New-Object -ComObject WScript.Shell
$dsk = "$scpath\AUMADS"

if (!(Test-Path $dsk)) {
    New-Item $dsk -Type Directory
}

function Write-Log($logstring) {
    $Now = Get-Date
    # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + "  " + $LogString
    # ログ出力
    Write-Output $(Get-Translate($Log)) | Out-File -FilePath $LogFileName -Encoding utf8 -Append

    # モダン GUI がアクティブな場合、リアルタイムログ画面に追記 & 描画更新
    if ($null -ne $script:guiTxtLog) {
        try {
            $formatted = $(Get-Translate($Log))
            $script:guiTxtLog.Text += "`r`n$formatted"
            if ($null -ne $script:guiScrollLog) {
                $script:guiScrollLog.ScrollToEnd()
            }
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        } catch {}
    }

    # echo させるために出力したログを戻す
    Return $(Get-Translate($Log))
}

trap [Exception] {
    # イベント・ログに書き込む
    Write-Log $error[0].exception
    break
}

Write-Log "Running With Powershell Version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Log "                                                                 "
Write-Log "-----------------------------------------------------------------"
Write-Log "                                                                 "
Write-Log "                    AmongUs Mod Deploy Script                    "
Write-Log "                                                   Version: $version"
Write-Log "                                                   Build  : $build"
Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Starts"
Write-Log "-----------------------------------------------------------------"
if (!(Get-Module -Name 7Zip4Powershell -ListAvailable)) {
    Install-Module -Name 7Zip4Powershell -Force -Scope CurrentUser
}
#################################################################################################
# Icon and AUMADS Folder on Desktop
#################################################################################################
if (!(Test-Path "$dsk\AUMADS.ico")) {
    aria2c -x16 -s16 -j16 -V --dir "$dsk" -o "AUMADS.ico" "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/AUMADS.ico" --disable-ipv6
}
if ($icorenew) {
    Remove-Item "$dsk\AUMADS.ico" -Force 
    aria2c -x16 -s16 -j16 -V --dir "$dsk" -o "AUMADS.ico" "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/AUMADS.ico" --disable-ipv6
}
if (!(Test-Path "$dsk\AUMADS.ico")) {
    try {
        magick.exe -help | Out-Null
    }
    catch {
        Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco install -y imagemagick.app -PackageParameters "InstallDevelopmentHeaders=true LegacySupport=true"' -Verb RunAs -Wait
    }
    aria2c -x16 -s16 -j16 -V --dir "$dsk" -o "icon.png" "https://3dicons.sgp1.cdn.digitaloceanspaces.com/v1/dynamic/premium/rocket-dynamic-premium.png" --disable-ipv6
    magick.exe convert "$dsk\icon.png" -define icon:auto-resize=16, 48, 256 -compress zip "$dsk\AUMADS.ico"    
    Remove-Item "$dsk\icon.png" -Force 
}

#################################################################################################
# Folder用Function
#################################################################################################
#Special Thanks
#https://qiita.com/Kosen-amai/items/7b2339d7de8223ab77c4
Add-Type -AssemblyName System.Windows.Forms
function Get-FolderPathG {
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$Description = $(Get-Translate("フォルダを選択してください")),
        [boolean]$CurrentDefault = $false
    )
    # メインウィンドウ取得
    $process = [Diagnostics.Process]::GetCurrentProcess()
    $window = New-Object Windows.Forms.NativeWindow
    $window.AssignHandle($process.MainWindowHandle)

    $fd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fd.Description = $Description

    if ($CurrentDefault -eq $true) {
        # カレントディレクトリを初期フォルダとする
        $fd.SelectedPath = (Get-Item $PWD).FullName
    }

    # フォルダ選択ダイアログ表示
    $ret = $fd.ShowDialog($window)

    if ($ret -eq [System.Windows.Forms.DialogResult]::OK) {
        return $fd.SelectedPath
    }
    else {
        return $null
    }
}
#################################################################################################
# バイト配列を16進数文字列に変換する. 
#################################################################################################
function ToHex([byte[]] $hashBytes) {
    $builder = New-Object System.Text.StringBuilder
    $hashBytes | ForEach-Object { [void] $builder.Append($_.ToString("x2")) }
    $builder.ToString()
}


#func backup
Add-Type -AssemblyName UIAutomationClient
$oldtype = $true

if ((Test-Path "C:\Program Files\Epic Games\AmongUs") -or (Test-Path "C:\Program Files\Epic Games\Among Us")) {
    $legver = legendary.exe -V            
    if ($legver -ge 'legendary version "0.20.29", codename "Dark Energy (hotfix #3)"') {
    }
    else {
        Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade legendary -y" -Verb RunAs -Wait   
        #legendaryが最新じゃないので手動でDL
    
        $rel2 = "https://api.github.com/repos/derrod/legendary/releases/latest"
        $webs = Invoke-WebRequest $rel2 -UseBasicParsing
        $webs2 = ConvertFrom-Json $webs.Content
        $aus = $webs2.assets.browser_download_url
        Write-Log $(Get-Translate("Legendary Latest DLL download start"))
        if (!(Test-Path "$aupathm\BepInEx\plugins\")) {
            New-Item "$aupathm\BepInEx\plugins\" -Type Directory
        }
        for ($aaai = 0; $aaai -lt $aus.Length; $aaai++) {
            if ($($aus[$aaai]).IndexOf(".exe") -gt 0) {
                aria2c -x16 -s16 -j16 -V --allow-overwrite=true --dir "$Env:ALLUSERSPROFILE\chocolatey\bin" -o "legendary.exe" $($aus[$aaai])
                Write-Log "$($aus[$aaai])"
                Write-Log "Legendaryのバージョンが古いため、最新に更新しました。"
            }
        }
        Write-Log "重要ファイルの更新がありました。"
        Write-Log "再度Batファイルを実行してください。"
        Pause
        Exit
    }
}

function BackupMod {
    #Backup Mod
    if (!(Test-Path $aupathb)) {
        New-Item $aupathb -ItemType Directory
    }
    if (!(Test-Path $aupathb\$scid)) {
        New-Item $aupathb\$scid -ItemType Directory
    }
    Write-Log $(Get-Translate("Mod Backup Feature Start"))
    if ($scid -ne "AMS") {
        if (Test-Path "$aupathb\$scid\$scid-$torv.zip") {
            $orgsize = (Get-Item "$aupathb\$scid\$scid-$torv.zip").Length
            $dlfsize = (Get-Item "$aupathm\TheOtherRoles.zip").Length
    
            if ($orgsize -lt $dlfsize) {
                Copy-Item "$aupathm\TheOtherRoles.zip" "$aupathb\$scid\$scid-$torv.zip" -Force
            }
        }
        else {
            Copy-Item "$aupathm\TheOtherRoles.zip" "$aupathb\$scid\$scid-$torv.zip"
        }    
    }
    else {
        if (Test-Path "$aupathb\$scid\$scid-$torv.dll") {
            $orgsize = (Get-Item "$aupathb\$scid\$scid-$torv.dll").Length
            $dlfsize = (Get-Item "$aupathm\BepInEx\plugins\AUModS.dll").Length
    
            if ($orgsize -lt $dlfsize) {
                Copy-Item "$aupathm\BepInEx\plugins\AUModS.dll" "$aupathb\$scid\$scid-$torv.dll" -Force
            }
        }
        else {
            Copy-Item "$aupathm\BepInEx\plugins\AUModS.dll" "$aupathb\$scid\$scid-$torv.dll" -Force
        }    
    }
    Write-Log "Mod Backup Feature End"
}

function BackUpAU {
    #Backup System
    if (Test-Path $aupathb) {
    }
    else {
        New-Item $aupathb -ItemType Directory
    }
    Write-Log "Backup Feature Start"

    #Current Ver check
    $datest = Get-Date -Format "yyyyMMdd-hhmmss"
    $backhashtxt = "$aupathb\backuphash.txt"
    $backtracktxt = "$aupathb\backuptrack.txt"
    $backuptxt = "$aupathb\backupfn.txt"
    
    # 既存ユーザーの互換性処理: 古いハッシュファイルがあれば削除し、新しいトラック処理に移行
    if (Test-Path $backhashtxt) {
        Remove-Item $backhashtxt -Force
        # backupfn.txt が存在する場合、バックアップZIPが存在しているはずなので、
        # トラックファイルだけを現状のAmongUsフォルダから作成して次回以降のチェックに備える
        if (Test-Path $backuptxt) {
            $files = Get-ChildItem $aupatho -Recurse | Where-Object { !$_.PSIsContainer }
            $trackData = ""
            foreach ($file in $files) {
                $trackData += "$($file.Name):$($file.Length):$($file.LastWriteTime.Ticks)|"
            }
            $trackData | Out-File $backtracktxt -Encoding utf8
        }
    }

    # トラック情報の構築関数（高速）
    function Get-FolderTrackInfo($folderPath) {
        if (!(Test-Path $folderPath)) { return "" }
        $trackBuilder = New-Object System.Text.StringBuilder
        try {
            $dirInfo = New-Object System.IO.DirectoryInfo($folderPath)
            $files = $dirInfo.EnumerateFiles("*", [System.IO.SearchOption]::AllDirectories)
            foreach ($file in $files) {
                [void]$trackBuilder.Append("$($file.Name):$($file.Length):$($file.LastWriteTime.Ticks)|")
            }
        }
        catch {
            Write-Log "Warning: Folder track info extraction failed: $_"
        }
        return $trackBuilder.ToString()
    }

    if (test-path "$backuptxt") {
        $f = (Get-Content $backuptxt) -as [string[]]
        $filen = $f[0]
        Write-Log $filen
        
        $r = Get-FolderTrackInfo $aupatho
        $e = ""
        if (Test-Path $backtracktxt) {
            $e = Get-Content $backtracktxt -Raw
        }
        
        if ($null -ne $filen -and $filen.Trim().IndexOf($amver) -lt 0) {
            $e = "retake"
        }

        if ($r.Trim() -eq $e.Trim()) {
            Write-Log "古い同一Backupが見つかったのでSkipします"
        }
        else {
            Write-Log "新しいBackupが見つかったので生成します"
            # 差分ファイルの特定とログ出力
            if ($e -ne "" -and $e -ne "retake") {
                $eFiles = @{}
                foreach ($item in $e.Split('|')) {
                    if ($item -match '^(.+?):(\d+?):(\d+)$') {
                        $eFiles[$Matches[1]] = @{ Length = $Matches[2]; Ticks = $Matches[3] }
                    }
                }
                $rFiles = @{}
                foreach ($item in $r.Split('|')) {
                    if ($item -match '^(.+?):(\d+?):(\d+)$') {
                        $rFiles[$Matches[1]] = @{ Length = $Matches[2]; Ticks = $Matches[3] }
                    }
                }
                
                # 差分チェック
                foreach ($name in $rFiles.Keys) {
                    if (!$eFiles.ContainsKey($name)) {
                        Write-Log "差分検出: 新規ファイル -> $name"
                    }
                    else {
                        $eLen = [long]$eFiles[$name].Length
                        $rLen = [long]$rFiles[$name].Length
                        $eTicks = [long]$eFiles[$name].Ticks
                        $rTicks = [long]$rFiles[$name].Ticks
                        if ($eLen -ne $rLen -or $eTicks -ne $rTicks) {
                            Write-Log "差分検出: 変更あり -> $name (サイズ: $eLen -> $rLen, 更新日時Ticks: $eTicks -> $rTicks)"
                        }
                    }
                }
                foreach ($name in $eFiles.Keys) {
                    if (!$rFiles.ContainsKey($name)) {
                        Write-Log "差分検出: 削除されたファイル -> $name"
                    }
                }
            }
            Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
            Compress-7Zip -Path $aupatho -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$amver.zip")
            if (Test-Path $backtracktxt) { Remove-Item -Path $backtracktxt -Force }
            if (Test-Path $backuptxt) { Remove-Item -Path $backuptxt -Force }
            $r | Out-File $backtracktxt -Encoding utf8
            Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
        }
    }
    else {
        Write-Log "Backupが見つかりません。生成します。"
        $r = Get-FolderTrackInfo $aupatho
        $r | Out-File $backtracktxt -Encoding utf8
        Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
        Compress-7Zip -Path $aupatho -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$amver.zip")
    }

    #Manifest Backup
    if ($platform -eq "epic") {
        if (!(Test-Path "$aupathb\epic_manifest")) {
            New-Item "$aupathb\epic_manifest" -Type Directory
        }
        if (Test-Path "$aupatho\.egstore") {
            if (!(Test-Path "$aupathb\$amver.manifest")) {
                $egmani = Get-ChildItem -path "$aupatho\.egstore\*.manifest"
                Copy-Item "$aupatho\.egstore\$($egmani[0].Name)" "$aupathb\epic_manifest\v$amver.manifest"
            }
        }
    }

    #Previous ver check
    $items = Get-ChildItem $aupathb -File
    $prevchk = $true
    foreach ($item in $items) {        
        if (($item.Name).IndexOf("$prever") -gt 0 ) {
            $prevchk = $false
        }
    }
    if ($prevchk) {
        if ($platform -eq "steam") {
            $steampth = "C:\Program Files (x86)\Steam\Steam.exe"
            $steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue | Select-Object -First 1
            if (Test-Path $steampth) {
                Write-Log "Steam アプリは以下で見つかりました。 $steampth"
            }
            elseif ($null -ne $steamProc -and (Test-Path $($steamProc.Path))) {
                $steampth = $($steamProc.Path)
                Write-Log "Steam アプリは以下で見つかりました。 $steampth"
            }
            else {
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
            $MAIN_WINDOW_TITLE = "Steam"
            #Get-Processで取得できた1つ目のハンドルを対象とする。
            $steamruncheck = $true
            $steamrunner = $true

            while ($steamruncheck) {
                try {
                    $hwnd = (Get-Process | Where-Object { $_.MainWindowTitle -like $MAIN_WINDOW_TITLE })[0].MainWindowHandle
                }
                catch {
                    Write-Log "Steam.exe 起動チェック。ログインできていない場合はログインしてください。"       
                }
                if ($null -eq $hwnd) {
                    if ($steamrunner) {
                        Start-Process $steampth 
                        $steamrunner = $false
                    }
                }
                else {
                    $steamruncheck = $false
                }
                Start-Sleep -Seconds 5
            }
            Start-Sleep -Seconds 2

            #Among Us app id 945360
            #main depot id 945361
            Start-Process $steampth -argument "+download_depot 945360 945361 $prevtargetid" 

            Start-Sleep -Seconds 2
            #ハンドルからウィンドウを取得する
            $window = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
            $windowPattern = $window.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)
            #ウィンドウサイズを最小化する
            $windowPattern.SetWindowVisualState([System.Windows.Automation.WindowVisualState]::Minimized)    

            Start-Sleep -Seconds 2

            $stfolder = Split-Path $steampth -Parent
            $bupfolder = Join-Path $stfolder "steamapps\content\app_945360\depot_945361"
            $delfoldser = Join-Path $stfolder "steamapps\content\app_945360"
            $counter = 0;
            while (!(Test-Path $bupfolder)) {
                Start-Sleep -Seconds 2
            }
            Write-Log "Steam.exe は前バージョン($prever)をダウンロード中です。しばらくお待ちください。(Max20分でタイムアウトします)#0"
            $presu = $false
            while (((Get-ChildItem $bupfolder | Measure-Object).Count) -ne 8) {
                Start-sleep -Seconds 15
                #timeout 10min.
                if ($counter -lt 80) {
                    $counter++
                    Write-Log "Steam.exe は前バージョン($prever)をダウンロード中です。しばらくお待ちください。#$counter $((Get-ChildItem $bupfolder | Measure-Object).Count)/8"
                    $presu = $true
                }
                else {
                    break
                    Write-Log "Steam.exe の前バージョン($prever)をダウンロードがタイムアウトしました。再度お試しください。$((Get-ChildItem $bupfolder | Measure-Object).Count)/8"
                }
            }
            if ($presu) {
                Compress-7Zip -Path $bupfolder -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$prever.zip")
                Start-Sleep -Seconds 2
                Remove-Item -Path $delfoldser -Recurse -Force    
            }
            else {
                Write-Log "前バージョン($prever)のロードに失敗しました。再度お試しください。"
            }
        }
        elseif ($platform -eq "epic") {
            if ($oldtype) {
                $epicmanifestchk = $true
                if (Test-Path "$aupathb\epic_manifest") {
                    $eitems = Get-ChildItem "$aupathb\epic_manifest" -File
                    foreach ($item in $eitems) {        
                        if (($item.Name).IndexOf("$prever") -gt 0 ) {
                            $epicmanifestchk = $false
                            $epicmanifestfile = "$aupathb\epic_manifest\$prever.manifest"
                        }
                    }
                }
                if ($epicmanifestchk) {
                    #manifestがないから指定してもらう
                    Write-Log "Epic Game の過去のManifestファイルが見つかりません。Manifestファイルを指定してください。"     
                
                    Add-Type -assemblyName System.Windows.Forms
                    $dialog = New-Object System.Windows.Forms.OpenFileDialog
                    $dialog.Filter = $(Get-Translate("manifest ファイル(*.manifest)|*.manifest"))
                    $dialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
                    $dialog.Title = $(Get-Translate("Manifestファイルを選択してください"))
                    if ($dialog.ShowDialog() -eq "OK") {
                        $epicmanifestfile = $dialog.FileName
                    }
                    else {
                        Write-Log "ファイルを選択しませんでした"
                    }
                }

                Write-Log "選択: $epicmanifestfile"
                if (!(Test-Path "$aupathb\epic_manifest")) {
                    New-Item "$aupathb\epic_manifest" -Type Directory
                }
                $mfileName = Split-Path $epicmanifestfile -Leaf
                Copy-Item $epicmanifestfile "$aupathb\epic_manifest\$mfilename"
                $epicmanifestfile = "$aupathb\epic_manifest\$mfilename"
                Write-Log "コピー: $epicmanifestfile"

                #legendary でAmongusを落とす
                legendary.exe auth --delete
                Start-Sleep -Seconds 3
                legendary.exe auth --import
                legendary.exe -y import 'Among Us' "$aupatho"
                legendary.exe uninstall "Among Us" --keep-files -y
                Copy-Item $aupatho "$aupathb\AmongUs" -Recurse
                legendary.exe -y import 'Among Us' "$aupathb\AmongUs"
                Start-Sleep -Seconds 1
                if (Test-Path "$aupathb\AmongUs") {
                    Remove-item "$aupathb\AmongUs" -Recurse -Force
                    legendary.exe install "Among Us" --old-manifest "$epicmanifestfile" --disable-patching --enable-reordering --repair -y
                }
                else {
                    Write-Log "何かがおかしい・・・"
                }

                $ptt = [System.IO.File]::ReadAllBytes("$aupathb\AmongUs\Among Us_Data\globalgamemanagers")
                $ptt2 = [System.Text.Encoding]::UTF8.GetString($ptt)
                $ptt3 = [regex]::Matches($ptt2, "(19|20)[0-9]{2}[- /.]([1-9]|0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])")
                if ($null -eq $ptt3[1]) {
                    $pmver = $ptt3[0].Value
                }
                else {
                    $pmver = $ptt3[1].Value
                }
                
                if ($pmver -eq $prever) {
                    #success
                    Write-Log $(Get-Translate("Download 成功"))
                    Compress-7Zip -Path "$aupathb\AmongUs" -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$prever.zip")

                    if (!(Test-Path "$aupathb\epic_manifest")) {
                        New-Item "$aupathb\epic_manifest" -Type Directory
                    }
                    if (($epicmanifestchk) -and ($epicmanifestfile -eq "$aupathb\epic_manifest\v$prever.manifest")) {
                    }
                    else {
                        Copy-Item $epicmanifestfile "$aupathb\epic_manifest\v$prever.manifest"        
                        Remove-Item $epicmanifestfile -Force
                    }
                }
                else {
                    Write-Log "Download 失敗か、指定されたManifestが選択されたバージョンではありませんでした"
                    Write-Log "指定したManifestを確認するか、再度やり直してください"
                    Remove-Item $epicmanifestfile -Force
                    Pause
                    Exit
                }

                if (Test-Path "$aupathb\AmongUs") {
                    Remove-item "$aupathb\AmongUs" -Recurse -Force
                } 
            }
        }
    }
    Write-Log "Backup Feature Ends"
}


#################################################################################################
### Convertfrom-vdf
### Ref. from https://github.com/ChiefIntegrator/Steam-GetOnTop
#################################################################################################
Function ConvertFrom-VDF {
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$InputObject
    )
    process {
        $root = New-Object -TypeName PSObject
        $chain = [ordered]@{}
        $depth = 0
        $parent = $root
        $element = $null
        ForEach ($line in $InputObject) {
            $quotedElements = (Select-String -Pattern '(?<=")([^\"\t\s]+\s?)+(?=")' -InputObject $line -AllMatches).Matches
            if ($quotedElements.Count -eq 1) {
                # Create a new (sub) object
                $element = New-Object -TypeName PSObject
                Add-Member -InputObject $parent -MemberType NoteProperty -Name $quotedElements[0].Value -Value $element
            }
            elseif ($quotedElements.Count -eq 2) {
                # Create a new String hash
                Add-Member -InputObject $element -MemberType NoteProperty -Name $quotedElements[0].Value -Value $quotedElements[1].Value
            }
            elseif ($line -match "{") {
                $chain.Add($depth, $element)
                $depth++
                $parent = $chain.($depth - 1) # AKA $element
            }
            elseif ($line -match "}") {
                $depth--
                $parent = $chain.($depth - 1)
                $element = $parent
                $chain.Remove($depth)
            }
            else {
                # Comments etc
            }
        }
        return $root
    }  
}
#################################################################################################
### 高速Download
#################################################################################################

if (!(Test-Path "C:\Temp")) {
    New-Item "C:\Temp" -Type Directory
}

try {
    aria2c -v | Out-Null
}
catch {
    try {
        choco -v
    }
    catch {
        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
    }
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 legendary microsoft-windows-terminal -y" -Verb RunAs -Wait   
}
#################################################################################################
# Clock Sync (Async)
#################################################################################################

$w32tmJob = [powershell]::Create().AddScript({
        try {
            $l = w32tm /query /status
            if ($l.contains("0x80070426")) {
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -Command 'net start `"windows time`" ;start-sleep -Seconds 5; w32tm /monitor /computers:time.google.com;w32tm /config /syncfromflags:manual /manualpeerlist:`"time.google.com,0x8 time.aws.com,0x8 time.cloudflare.com,0x8`" /reliable:yes /update;w32tm /resync;w32tm /query /status'" -Verb RunAs
            }
            else {
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -Command 'w32tm /monitor /computers:time.google.com;w32tm /config /syncfromflags:manual /manualpeerlist:`"time.google.com,0x8 time.aws.com,0x8 time.cloudflare.com,0x8`" /reliable:yes /update;w32tm /resync;w32tm /query /status'" -Verb RunAs      
            }
        }
        catch {
            # Ignore errors quietly in the background
        }
    })
[void]$w32tmJob.BeginInvoke()

$platform = ""
$scid = "TOR GMH"
$tio = $true
$aumin = ""
$aumax = "NONE"
$aupatho = ""
$aupathm = ""
$aupathb = ""
$releasepage = ""
$ovwrite = $false
$amver = ""
$prebool = $false
$latestflag = 0
$isall = $false
$opflag = $false
$ym = Get-Date -Format yyyyMM

#################################################################################################
# ゲーム環境・バージョンの初期検出（起動時1回のみ実行）
#################################################################################################
function Initialize-GameEnvironment {
    # 既存のオートセーブ設定ファイルを読み込むためのローカル変数定義
    $npl = $script:npl
    $dsk = $script:dsk
    $fileName2 = Join-path $npl "\AmongUsModDeployScript.conf"
    $fileName = Join-path $dsk "\AmongUsModDeployScript.conf"

    $au_path_steam_org = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
    # Steamのレジストリからの検出（別ドライブインストール対応）
    $steamRegPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
    if ([string]::IsNullOrEmpty($steamRegPath)) {
        $steamRegPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
    }
    if (![string]::IsNullOrEmpty($steamRegPath)) {
        $steamRegNormalized = $steamRegPath.Replace('/', '\')
        $steamRegAmongUs = Join-Path $steamRegNormalized "steamapps\common\Among Us"
        if (Test-Path "$steamRegAmongUs\Among Us.exe") {
            $au_path_steam_org = $steamRegAmongUs
        }
    }
    $au_path_epic_org = "C:\Program Files\Epic Games\AmongUs"
    if (!(Test-Path "$au_path_epic_org\Among Us.exe") -and (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe")) {
        $au_path_epic_org = "C:\Program Files\Epic Games\Among Us"
    }

    # プロセスからの検出
    $steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue | Select-Object -First 1
    $epicProc = Get-Process -Name "EpicGamesLauncher" -ErrorAction SilentlyContinue | Select-Object -First 1
    $targetProc = if ($null -ne $epicProc) { $epicProc } else { $steamProc }
    $epicbool = ($null -ne $epicProc)
    
    $detected_path = $null
    $procpath = $null
    if ($null -ne $targetProc) {
        try {
            $pPath = $null
            # pathプロパティへのアクセスはアクセス権がないと例外になるため保護
            $pPath = $targetProc.Path
            if ($null -eq $pPath -or $pPath -eq "") {
                $pPath = $targetProc.MainModule.FileName
            }
            if ($null -ne $pPath -and $pPath -ne "") {
                $procpath = Split-Path $pPath -Parent
                $detected_path = Join-Path $procpath "steamapps\common\Among Us"
            }
        }
        catch {
            Write-Log "Warning: Process path access failed: $_"
        }
        
        if ($null -ne $detected_path -and $detected_path -ne "") {
            if (!(Test-Path $detected_path)) {
                foreach ($num in 65..90) {                                     
                    if (Test-Path "$([char]$num):\SteamLibrary\steamapps\common\Among Us") {
                        $detected_path = "$([char]$num):\SteamLibrary\steamapps\common\Among Us"
                        break
                    }     
                }
            }
        } 
    }

    $spath = $null
    $hasSteam = (Test-Path "$au_path_steam_org\Among Us.exe")
    $hasEpic = (Test-Path "$au_path_epic_org\Among Us.exe")
    if (!$hasEpic -and (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe")) {
        $au_path_epic_org = "C:\Program Files\Epic Games\Among Us"
        $hasEpic = $true
    }
    elseif (!$hasEpic -and (Test-Path "C:\Program Files\Epic Games\AmongUs\Among Us.exe")) {
        $au_path_epic_org = "C:\Program Files\Epic Games\AmongUs"
        $hasEpic = $true
    }
    $script:hasSteam = $hasSteam
    $script:hasEpic = $hasEpic
    $script:bothPlatformsDetected = ($hasSteam -and $hasEpic)

    $targetPlatform = if (![string]::IsNullOrEmpty($DeployPlatform)) { $DeployPlatform } elseif (![string]::IsNullOrEmpty($env:TARGET_PLATFORM)) { $env:TARGET_PLATFORM } else { $null }
    if (![string]::IsNullOrEmpty($targetPlatform)) {
        if ($targetPlatform -ieq "Epic") {
            Write-Log "Target platform explicitly set to Epic via argument/environment variable."
            $spath = $au_path_epic_org
            $script:platform = "epic"
        }
        elseif ($targetPlatform -ieq "Steam") {
            Write-Log "Target platform explicitly set to Steam via argument/environment variable."
            $spath = $au_path_steam_org
            $script:platform = "steam"
        }
    }
    elseif ($hasSteam -and $hasEpic) {
        Write-Log "Both Steam and Epic installations of Among Us were detected."
        $selectedIsSteam = $true
        if ($null -ne $Args1 -and $env:TARGET_PLATFORM -eq "Epic") {
            $selectedIsSteam = $false
        }
        # 対話モード時はGUI上で切り替え可能にするため、初期選択としてSteamを設定

        if ($selectedIsSteam) {
            Write-Log "User/Config initially selected Steam (Can be switched via Modern GUI)"
            $spath = $au_path_steam_org
            $script:platform = "steam"
        }
        else {
            Write-Log "User/Config initially selected Epic (Can be switched via Modern GUI)"
            $spath = $au_path_epic_org
            $script:platform = "epic"
        }
    }
    elseif ($hasSteam) {
        Write-Log "Steam Original Detected"
        $spath = $au_path_steam_org
        $script:platform = "steam"
    }
    elseif ($hasEpic) {
        Write-Log "Epic Original Detected"
        $spath = $au_path_epic_org
        $script:platform = "epic"
    }
    elseif ($null -ne $detected_path -and (Test-Path "$detected_path\Among Us.exe")) {
        Write-Log "Detected via Process Path"
        $spath = $detected_path
        $script:platform = "steam"
    }
    elseif ($epicbool) {
        Write-Log "Epic Detected via Legendary"
        legendary.exe auth --import
        $epicinfo = legendary.exe info AmongUs
        $epicpath = $epicinfo | Select-String "Install path"
        $epicrow = $($epicpath.ToString()).Split(": ")
        $epicreal = Split-Path -Path "$epicrow[1]"
        if (Test-Path "$epicreal/Among Us/Among Us.exe") {
            $spath = "$epicreal/Among Us"
            $script:platform = "epic"
        }
        elseif (Test-Path "$epicreal/AmongUs/Among Us.exe") {
            $spath = "$epicreal/AmongUs"
            $script:platform = "epic"
        }
        elseif (Test-Path "$epicreal/Among Us") {
            $spath = "$epicreal/Among Us"
            $script:platform = "epic"
        }
        elseif (Test-Path "$epicreal/AmongUs") {
            $spath = "$epicreal/AmongUs"
            $script:platform = "epic"
        }
    }
    else {
        Write-Log "Failed to Detect automatically. Trying to load config or ask user."
        if (test-path "$fileName2") {
            Move-Item -Path $fileName2 -Destination $fileName
        }
        $chkvdf = $false
        if ($null -ne $procpath -and (Test-Path "$procpath\steamapps\libraryfolders.vdf")) {
            $stvdf = Get-Content "$procpath\steamapps\libraryfolders.vdf"
            $chkvdf = $true
        }
        
        if (test-path "$fileName") {
            $spath2 = Get-content "$fileName"
            $spath3 = $spath2.split("_:_")
            $spath = $spath3[0] 
            $script:platform = $spath3[1]
        }
        else {
            $loadfail = $false
            if ($chkvdf) {
                $cfvdf = ConvertFrom-VDF $stvdf
                foreach ( $property in $cfvdf.libraryfolders.psobject.properties.name ) {
                    if (([string]$($cfvdf.libraryfolders."$property".apps)).contains("945360")) {
                        $cfpth = Join-Path $cfvdf.libraryfolders."$property".path "\steamapps\common\Among Us"
                    }
                }
                if (Test-Path $cfpth) {
                    Write-Log "detected from VDF."
                    $spath = $cfpth
                    $script:platform = "steam"
                    $loadfail = $false
                }
                else {
                    Write-Log "Among Us may not installed with Steam."
                    $loadfail = $true
                }
            }
            else {
                $loadfail = $true
            }

            if ($loadfail) {
                Write-Log "AmongUs detection failed. Showing folder browser dialog."
                [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っていないAmongUsがインストールされているフォルダを選択してください")), "Among Us Mod Auto Deploy Tool")
                $spath = Get-FolderPathG
            }
        }
        
        if ($null -eq $spath) {
            Write-Log "Scriptを再実行してAmong Usが含まれるフォルダを指定してください。$spath"
            pause
            Exit
        }
        if (test-path "$spath\Among Us.exe") {
            Write-Log "$spath にAmongUsのインストールパスを確認しました Platform:$script:platform"
            if (($script:platform -ne "Steam") -and ($script:platform -ne "Epic")) {
                if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("PlatformはSteamですか？")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                    $script:platform = "Steam"
                }
                else {
                    $script:platform = "Epic"
                }
            }
        }
        else {
            Write-Log "$spath にAmongUsのインストールが確認できませんでした"
            pause
            Exit
        }
    }

    # クリーンインストール判定用の重複コードを避けるため、オリジナルフォルダ内のBepInEx存在チェック
    if (test-path $spath) {
        if (Test-path "$spath\BepInEx") {
            Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
            if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("指定されたパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                $cleanScript = if ($script:platform -eq "Epic") { "AmongusCleanInstall_Epic.ps1" } else { "AmongusCleanInstall_Steam.ps1" }
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/$cleanScript" -OutFile "$npl\$cleanScript" -UseBasicParsing
                $fpth2 = "$npl\$cleanScript"
                if (test-path "$env:ProgramFiles\PowerShell\7") {
                    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$fpth2`"" -Verb RunAs -Wait
                }
                else {
                    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$fpth2`"" -Verb RunAs -Wait
                }
                Remove-Item $fpth2 -Force
                Write-Log "クリーンインストールが行われたため、処理を中止します。再度起動してください。"
                pause
                exit
            }
            else {
                Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください。処理を中止します。"
                pause
                exit
            }
        }

        $script:aupatho = $spath
        
        # オートセーブ
        $confcont = $spath + "_:_" + $script:platform
        Write-Output "$confcont" > $fileName
    }
    $script:aupatho = $spath
    $aupatho = $spath

    # バージョン検出 (globalgamemanagers)
    if (Test-Path "$script:aupatho\Among Us_Data\globalgamemanagers") {
        $tt = [System.IO.File]::ReadAllBytes("$script:aupatho\Among Us_Data\globalgamemanagers")
        $tt2 = [System.Text.Encoding]::UTF8.GetString($tt)
        $tt3 = [regex]::Matches($tt2, "(19|20)[0-9][2-9][- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|1[0-9]|2[0-9]|3[01]|[1-9])")
        if ($null -eq $tt3[1]) {
            $script:amver = $tt3[0].Value
        }
        else {
            $script:amver = $tt3[1].Value
        }
        Write-Log "$script:amver が検出されました（キャッシュ保存）"
    }

    # VOICEVOX のインストール有無を非同期でスキャン開始
    Write-Log "VOICEVOX installation check started asynchronously..."
    $script:hasVoicevox = $null
    $script:vvJob = [powershell]::Create().AddScript({
            try {
                $vv = Get-ChildItem -Path('HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') -ErrorAction SilentlyContinue | ForEach-Object { Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue | Select-Object DisplayName } | select-string "VOICEVOX"
                return ($null -ne $vv)
            }
            catch {
                return $false
            }
        })
    $script:vvAsync = $script:vvJob.BeginInvoke()
}

# 起動時の初期検出を実行
Initialize-GameEnvironment

# GitHub API の非同期プレフェッチ (NOS, SNR, ER用)
Write-Log "GitHub API Async Prefetching started..."
$script:prefetchJobs = @{}
$prefetchUrls = @{
    "NOS" = "https://api.github.com/repos/Dolly1016/Nebula/releases"
    "SNR" = "https://api.github.com/repos/ykundesu/SuperNewRoles/releases"
    "ER"  = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
}

foreach ($key in $prefetchUrls.Keys) {
    $url = $prefetchUrls[$key]
    $ps = [powershell]::Create().AddScript({
            param($targetUrl)
            try {
                $response = Invoke-WebRequest $targetUrl -UseBasicParsing -TimeoutSec 10
                return $response
            }
            catch {
                return $null
            }
        }).AddArgument($url)
    
    $asyncResult = $ps.BeginInvoke()
    $script:prefetchJobs[$key] = @{
        PowerShell  = $ps
        AsyncResult = $asyncResult
    }
}

#################################################################################################
### Mod 選択メニュー表示 (Modern GUI - Airship Edition / WPF XAML)
#################################################################################################
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Windows システムテーマ（ライト/ダーク）の自動検出
$regPersonalize = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$systemIsLight = $false
try {
    if (Test-Path $regPersonalize) {
        $themeVal = (Get-ItemProperty -Path $regPersonalize -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue).AppsUseLightTheme
        if ($themeVal -eq 1) { $systemIsLight = $true }
    }
} catch {
    $systemIsLight = $false
}

# XAML 定義
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Among Us Mod Auto Deploy Tool"
        Height="650" Width="900"
        WindowStartupLocation="CenterScreen"
        Background="{DynamicResource BgWindow}" Foreground="{DynamicResource TextPrimary}"
        FontFamily="Segoe UI, Meiryo UI, Yu Gothic UI"
        ResizeMode="CanResizeWithGrip" MinWidth="840" MinHeight="600">

    <Window.Resources>
        <!-- Theme Dynamic Brushes (Initialized via PowerShell) -->
        <SolidColorBrush x:Key="BgWindow" Color="#180D11"/>
        <SolidColorBrush x:Key="BgHeader" Color="#221217"/>
        <SolidColorBrush x:Key="BgCard" Color="#29151C"/>
        <SolidColorBrush x:Key="BorderCard" Color="#4A222C"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#F9FAFB"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#D1BFC4"/>
        <SolidColorBrush x:Key="TextAccentRed" Color="#EF4444"/>
        <SolidColorBrush x:Key="TextAccentGold" Color="#F59E0B"/>
        <SolidColorBrush x:Key="BtnPrimaryBg" Color="#DC2626"/>
        <SolidColorBrush x:Key="BtnPrimaryHover" Color="#EF4444"/>
        <SolidColorBrush x:Key="BtnPrimaryPressed" Color="#B91C1C"/>
        <SolidColorBrush x:Key="BtnSecondaryBg" Color="#381D26"/>
        <SolidColorBrush x:Key="BtnSecondaryBorder" Color="#5C2D3A"/>
        <SolidColorBrush x:Key="BtnSecondaryText" Color="#F3F4F6"/>
        <SolidColorBrush x:Key="InputBg" Color="#210F15"/>
        <SolidColorBrush x:Key="InputBorder" Color="#522532"/>
        <SolidColorBrush x:Key="SeparatorBg" Color="#4A222C"/>
        <SolidColorBrush x:Key="TerminalBg" Color="#12070A"/>
        <SolidColorBrush x:Key="BadgeBg" Color="#381921"/>
        <SolidColorBrush x:Key="BadgeBorder" Color="#6E2C3D"/>

        <!-- Modern Airship Card Style -->
        <Style x:Key="CardBorder" TargetType="Border">
            <Setter Property="Background" Value="{DynamicResource BgCard}"/>
            <Setter Property="CornerRadius" Value="10"/>
            <Setter Property="Padding" Value="16"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderCard}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Margin" Value="6"/>
        </Style>

        <!-- Primary Airship Button (Toppat Crimson Red) -->
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource BtnPrimaryBg}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Padding" Value="20,10"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="btnBorder" Background="{TemplateBinding Background}" 
                                CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="btnBorder" Property="Background" Value="{DynamicResource BtnPrimaryHover}"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="btnBorder" Property="Background" Value="{DynamicResource BtnPrimaryPressed}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Secondary Button (Airship Cabin Slate) -->
        <Style x:Key="SecondaryButton" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource BtnSecondaryBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource BtnSecondaryText}"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BtnSecondaryBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="secBorder" Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="secBorder" Property="Opacity" Value="0.85"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

                <!-- ComboBox Style -->
        <Style TargetType="ComboBox">
            <Setter Property="Foreground" Value="#111827"/>
            <Setter Property="BorderBrush" Value="{DynamicResource InputBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>

        <!-- ComboBoxItem Style (リスト内の文字色を黒に指定) -->
        <Style TargetType="ComboBoxItem">
            <Setter Property="Foreground" Value="#111827"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="6,4"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="0,3"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style TargetType="RadioButton">
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Margin" Value="0,3"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <!-- Header -->
            <RowDefinition Height="*"/>    <!-- Main Content Body -->
            <RowDefinition Height="Auto"/> <!-- Global Footer Status -->
        </Grid.RowDefinitions>

        <!-- HEADER -->
        <Border Grid.Row="0" Background="{DynamicResource BgHeader}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="0,0,0,1" Padding="20,12">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <!-- AUMADS Badge -->
                    <Border Background="{DynamicResource BtnPrimaryBg}" CornerRadius="6" Padding="8,4" Margin="0,0,12,0">
                        <TextBlock Text="🚀 AUMADS" FontWeight="Bold" Foreground="White" FontSize="13"/>
                    </Border>
                    <StackPanel>
                        <TextBlock Text="Among Us Mod Auto Deploy Tool" FontSize="16" FontWeight="Bold" Foreground="{DynamicResource TextPrimary}"/>
                        <TextBlock Text="Single-Window Modern Interface" FontSize="11" Foreground="{DynamicResource TextSecondary}"/>
                    </StackPanel>
                </StackPanel>

                <!-- Header Right: Platform & Theme Toggle -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <!-- Theme Toggle Button -->
                    <Button x:Name="BtnToggleTheme" Content="🌙 ダーク" Style="{StaticResource SecondaryButton}" Margin="0,0,10,0" Padding="10,4"/>
                    
                    <Border Background="#064E3B" BorderBrush="#059669" BorderThickness="1" CornerRadius="12" Padding="10,3" Margin="0,0,8,0">
                        <TextBlock x:Name="TxtPlatformBadge" Text="🟢 Steam 選択中 (v2026.9.29)" FontSize="11" Foreground="#6EE7B7" FontWeight="SemiBold"/>
                    </Border>
                    <Border Background="{DynamicResource BadgeBg}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="1" CornerRadius="12" Padding="8,3">
                        <TextBlock Text="v2.2.0" FontSize="11" Foreground="{DynamicResource TextSecondary}"/>
                    </Border>
                </StackPanel>
            </Grid>
        </Border>

        <!-- VIEW 1: CONFIGURATION (メイン設定画面) -->
        <Grid x:Name="ViewConfig" Grid.Row="1" Margin="14" Visibility="Visible">
            <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- 2-Column Cards -->
            <Grid Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="1.05*"/>
                    <ColumnDefinition Width="0.95*"/>
                </Grid.ColumnDefinitions>

                <!-- LEFT CARD: MOD & Version Selection -->
                <Border Grid.Column="0" Style="{StaticResource CardBorder}">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="📦 MOD の選択" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource TextAccentRed}" Margin="0,0,0,12"/>
                            
                            <TextBlock Text="インストールする MOD" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <ComboBox x:Name="CmbMod" Margin="0,0,0,12">
                                <ComboBoxItem Content="NOS : Nebula on the Ship (Dolly1016)" IsSelected="True"/>
                                <ComboBoxItem Content="SNR : SuperNewRoles (ykundesu)"/>
                                <ComboBoxItem Content="ER : ExtremeRoles (yukieiji)"/>
                                <ComboBoxItem Content="ER+ES : ExtremeRoles + Submerged"/>
                                <ComboBoxItem Content="SRA : StellarRolesAU (Mr-Fluuff)"/>
                                <ComboBoxItem Content="LM : LasMonjas (KiraYamato94)"/>
                                <ComboBoxItem Content="TOH : TownOfHost (tukasa0001)"/>
                                <ComboBoxItem Content="Install/Update Selected (一括インストール)"/>
                                <ComboBoxItem Content="Tool Install Only (ツールのみ)"/>
                            </ComboBox>

                            <TextBlock Text="MOD のバージョン" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <ComboBox x:Name="CmbVersion" Margin="0,0,0,14">
                                <ComboBoxItem Content="最新版: v110 (本体 2026.9.29 対応)" IsSelected="True"/>
                                <ComboBoxItem Content="v109 (本体 2026.8.18 対応)"/>
                                <ComboBoxItem Content="v107 (本体 2026.6.5 対応)"/>
                            </ComboBox>

                            <Separator Background="{DynamicResource SeparatorBg}" Margin="0,4,0,12"/>

                            <TextBlock Text="📂 プラットフォーム &amp; インストール先" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource TextAccentGold}" Margin="0,0,0,8"/>
                            
                            <TextBlock Text="対象プラットフォーム (両方検出時に選択可能):" FontSize="11" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,2"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                                <RadioButton x:Name="RbPlatformSteam" GroupName="GrpPlatform" Content="Steam 版" IsChecked="True" Margin="0,0,16,0"/>
                                <RadioButton x:Name="RbPlatformEpic" GroupName="GrpPlatform" Content="Epic Games 版" Margin="0,0,16,0"/>
                            </StackPanel>

                            <TextBlock Text="バニラ (オリジナル) パス:" FontSize="11" Foreground="{DynamicResource TextSecondary}"/>
                            <TextBlock x:Name="TxtVanillaPath" Text="C:\Program Files (x86)\Steam\steamapps\common\Among Us" 
                                       FontSize="11" Foreground="{DynamicResource TextPrimary}" TextTrimming="CharacterEllipsis" Margin="0,2,0,8"/>

                            <TextBlock Text="MOD 展開先フォルダ (自動決定):" FontSize="11" Foreground="{DynamicResource TextSecondary}"/>
                            <Border Background="{DynamicResource InputBg}" BorderBrush="{DynamicResource InputBorder}" BorderThickness="1" CornerRadius="4" Padding="8,6" Margin="0,2,0,10">
                                <TextBlock x:Name="TxtModPath" Text="C:\Program Files (x86)\Steam\steamapps\common\Among Us NOS Mod" 
                                           FontSize="11" Foreground="{DynamicResource TextPrimary}" TextTrimming="CharacterEllipsis"/>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <!-- RIGHT CARD: Options & Tools -->
                <Border Grid.Column="1" Style="{StaticResource CardBorder}">
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            <TextBlock Text="⚙️ オプション設定" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource TextAccentRed}" Margin="0,0,0,12"/>

                            <!-- 既存フォルダ処理 / デプロイモード (RadioButton5, 6, 7, 17) -->
                            <TextBlock Text="既存フォルダの処理 (デプロイモード)" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <WrapPanel Margin="0,0,0,10">
                                <RadioButton x:Name="RbRecreate" GroupName="GrpDeployMode" Content="再作成する" IsChecked="True" Width="100"/>
                                <RadioButton x:Name="RbOverwrite" GroupName="GrpDeployMode" Content="上書きする" Width="100"/>
                                <RadioButton x:Name="RbNoRecreate" GroupName="GrpDeployMode" Content="再作成しない" Width="105"/>
                                <RadioButton x:Name="RbCleanInstall" GroupName="GrpDeployMode" Content="クリーンインストール" Width="145" Foreground="{DynamicResource TextAccentGold}"/>
                            </WrapPanel>

                            <!-- 起動 & ショートカット -->
                            <TextBlock Text="デスクトップショートカット" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                <RadioButton x:Name="RbShortcutYes" GroupName="GrpShortcut" Content="作成する" IsChecked="True" Margin="0,0,14,0"/>
                                <RadioButton x:Name="RbShortcutNo" GroupName="GrpShortcut" Content="作成しない"/>
                            </StackPanel>

                            <TextBlock Text="完了後の動作" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                <RadioButton x:Name="RbLaunchYes" GroupName="GrpLaunch" Content="自動で起動する" Margin="0,0,14,0"/>
                                <RadioButton x:Name="RbLaunchNo" GroupName="GrpLaunch" Content="起動しない" IsChecked="True"/>
                            </StackPanel>

                            <TextBlock Text="CPU Affinity (NOS向け最適化)" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                                <RadioButton x:Name="RbCpu0" GroupName="GrpCpu" Content="CPU 0のみ" IsChecked="True" Margin="0,0,10,0"/>
                                <RadioButton x:Name="RbCpu01" GroupName="GrpCpu" Content="2コア" Margin="0,0,10,0"/>
                                <RadioButton x:Name="RbCpuNone" GroupName="GrpCpu" Content="設定なし"/>
                            </StackPanel>

                            <Separator Background="{DynamicResource SeparatorBg}" Margin="0,0,0,10"/>

                            <!-- 追加ツール -->
                            <TextBlock Text="🔧 同時インストール Tool" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource TextAccentGold}" Margin="0,0,8,0"/>
                            <WrapPanel>
                                <CheckBox x:Name="Chk_VcRedist" Content="VC Redist" IsChecked="True" Width="135"/>
                                <CheckBox x:Name="Chk_BetterCrewLink" Content="BetterCrewLink" Width="135"/>
                                <CheckBox x:Name="Chk_DotNet" Content=".NET Framework" IsChecked="True" Width="135"/>
                                <CheckBox x:Name="Chk_AmongUsCapture" Content="AmongUsCapture" Width="135"/>
                                <CheckBox x:Name="Chk_Submerged" Content="Submerged" Width="135"/>
                                <CheckBox x:Name="Chk_CustomServer" Content="カスタムサーバー情報追加" Width="160"/>
                            </WrapPanel>
                        </StackPanel>
                    </ScrollViewer>
                </Border>
            </Grid>

            <!-- Bottom Action Bar -->
            <Border Grid.Row="1" Background="{DynamicResource BgHeader}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="1" CornerRadius="8" Padding="14,10" Margin="6,8,6,0">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="💡 準備完了:" FontWeight="Bold" Foreground="{DynamicResource TextAccentGold}" FontSize="12" Margin="0,0,6,0"/>
                        <TextBlock Text="最新バージョンの NOS をバニラバックアップとともにデプロイします" Foreground="{DynamicResource TextSecondary}" FontSize="12"/>
                    </StackPanel>
                    <Button x:Name="BtnStartDeploy" Grid.Column="1" Content="🚀 デプロイを開始する" Style="{StaticResource PrimaryButton}"/>
                </Grid>
            </Border>
        </Grid>

        <!-- VIEW 2: PROGRESS (進行中画面 - 同一ウィンドウ内で遷移！) -->
        <Grid x:Name="ViewProgress" Grid.Row="1" Margin="20" Visibility="Collapsed">
            <Border Style="{StaticResource CardBorder}" Padding="24">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/> <!-- Title & Subtitle -->
                        <RowDefinition Height="Auto"/> <!-- Progress Bar -->
                        <RowDefinition Height="*"/>    <!-- Terminal Log -->
                        <RowDefinition Height="Auto"/> <!-- Action -->
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0" Margin="0,0,0,16">
                        <TextBlock Text="⚡ MOD デプロイ処理を実行中..." FontSize="18" FontWeight="Bold" Foreground="{DynamicResource TextAccentRed}"/>
                        <TextBlock x:Name="TxtProgressStatus" Text="[1/4] Among Us バニラファイルのバックアップを作成しています..." 
                                   FontSize="13" Foreground="{DynamicResource TextPrimary}" Margin="0,4,0,0"/>
                    </StackPanel>

                    <!-- Progress Bar & Percentage -->
                    <Grid Grid.Row="1" Margin="0,0,0,14">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <ProgressBar x:Name="ProgBar" Height="14" Value="25" Maximum="100" 
                                     Background="{DynamicResource InputBg}" Foreground="{DynamicResource BtnPrimaryBg}" BorderThickness="0">
                        </ProgressBar>
                        <TextBlock x:Name="TxtPercent" Grid.Row="1" Text="25%" HorizontalAlignment="Right" 
                                   FontSize="12" FontWeight="SemiBold" Foreground="{DynamicResource TextAccentGold}" Margin="0,4,0,0"/>
                    </Grid>

                    <!-- Terminal Console Log -->
                    <Border Grid.Row="2" Background="{DynamicResource TerminalBg}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,0,14">
                        <ScrollViewer x:Name="ScrollLog" VerticalScrollBarVisibility="Auto">
                            <TextBlock x:Name="TxtLog" FontFamily="Consolas, Cascadia Code, Courier New" FontSize="11" Foreground="#34D399" TextWrapping="Wrap">
[2026/10/10 14:00:01] Among Us Mod Auto Deploy Script v2.2.0 開始
[2026/10/10 14:00:02] Steam版 Among Us を検出: C:\Program Files (x86)\Steam\steamapps\common\Among Us
[2026/10/10 14:00:03] バックアップディレクトリを作成中...
[2026/10/10 14:00:05] バニラファイルを整合性チェック中...
                            </TextBlock>
                        </ScrollViewer>
                    </Border>

                    <Button x:Name="BtnCancel" Grid.Row="3" Content="キャンセル" Style="{StaticResource SecondaryButton}" HorizontalAlignment="Right"/>
                </Grid>
            </Border>
        </Grid>

        <!-- VIEW 3: COMPLETE (完了画面 - 同一ウィンドウ内で遷移！) -->
        <Grid x:Name="ViewComplete" Grid.Row="1" Margin="20" Visibility="Collapsed">
            <Border Style="{StaticResource CardBorder}" Padding="30" VerticalAlignment="Center" HorizontalAlignment="Center" MaxWidth="600">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="🎉" FontSize="48" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                    <TextBlock Text="デプロイが正常に完了しました！" FontSize="20" FontWeight="Bold" Foreground="#34D399" HorizontalAlignment="Center" Margin="0,0,0,8"/>
                    <TextBlock x:Name="TxtCompleteModDesc" Text="Nebula on the Ship (NOS) の導入とショートカット作成が完了しました。" 
                               FontSize="13" Foreground="{DynamicResource TextSecondary}" HorizontalAlignment="Center" TextAlignment="Center" Margin="0,0,0,20"/>

                    <Border Background="{DynamicResource InputBg}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="1" CornerRadius="8" Padding="16" Margin="0,0,0,24">
                        <StackPanel>
                            <TextBlock Text="📍 インストール場所:" FontSize="12" Foreground="{DynamicResource TextSecondary}"/>
                            <TextBlock x:Name="TxtCompletePath" Text="C:\Games\Among Us_NOS" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimary}" Margin="0,2,0,10"/>
                            
                            <TextBlock Text="🔗 デスクトップショートカット:" FontSize="12" Foreground="{DynamicResource TextSecondary}"/>
                            <TextBlock x:Name="TxtCompleteShortcut" Text="Among Us - NOS (CPU Affinity: 0)" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimary}" Margin="0,2,0,0"/>
                        </StackPanel>
                    </Border>

                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                        <Button x:Name="BtnBackToConfig" Content="⚙️ 設定に戻る" Style="{StaticResource SecondaryButton}" Margin="0,0,12,0" Padding="16,10"/>
                        <Button x:Name="BtnLaunchGame" Content="🎮 今すぐゲームを起動" Style="{StaticResource PrimaryButton}" Margin="0,0,12,0"/>
                        <Button x:Name="BtnClose" Content="完了して閉じる" Style="{StaticResource SecondaryButton}" Padding="16,10"/>
                    </StackPanel>
                </StackPanel>
            </Border>
        </Grid>

        <!-- FOOTER BAR -->
        <Border Grid.Row="2" Background="{DynamicResource BgHeader}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="0,1,0,0" Padding="14,6">
            <Grid>
                <TextBlock Text="状態: 待機中" FontSize="11" Foreground="{DynamicResource TextSecondary}" VerticalAlignment="Center"/>
                <TextBlock Text="Among Us Mod Auto Deploy Project" FontSize="11" Foreground="{DynamicResource TextSecondary}" HorizontalAlignment="Right" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$script:mainWindow = $window

if (Test-Path "$dsk\AUMADS.ico") {
    try {
        $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create("$dsk\AUMADS.ico")
    } catch {}
}

# WPF コントロール参照
$ViewConfig = $window.FindName("ViewConfig")
$ViewProgress = $window.FindName("ViewProgress")
$ViewComplete = $window.FindName("ViewComplete")
$script:ViewConfig = $ViewConfig
$script:ViewProgress = $ViewProgress
$script:ViewComplete = $ViewComplete

$BtnStartDeploy = $window.FindName("BtnStartDeploy")
$BtnCancel = $window.FindName("BtnCancel")
$BtnBackToConfig = $window.FindName("BtnBackToConfig")
$BtnLaunchGame = $window.FindName("BtnLaunchGame")
$BtnClose = $window.FindName("BtnClose")
$BtnToggleTheme = $window.FindName("BtnToggleTheme")

$RbRecreate = $window.FindName("RbRecreate")
$RbOverwrite = $window.FindName("RbOverwrite")
$RbNoRecreate = $window.FindName("RbNoRecreate")
$RbCleanInstall = $window.FindName("RbCleanInstall")

$RbPlatformSteam = $window.FindName("RbPlatformSteam")
$RbPlatformEpic = $window.FindName("RbPlatformEpic")
$TxtVanillaPath = $window.FindName("TxtVanillaPath")
$TxtModPath = $window.FindName("TxtModPath")
$TxtPlatformBadge = $window.FindName("TxtPlatformBadge")
$script:TxtVanillaPath = $TxtVanillaPath
$script:TxtModPath = $TxtModPath
$script:TxtPlatformBadge = $TxtPlatformBadge

$CmbMod = $window.FindName("CmbMod")
$CmbVersion = $window.FindName("CmbVersion")
$script:CmbMod = $CmbMod
$script:CmbVersion = $CmbVersion

$RbShortcutYes = $window.FindName("RbShortcutYes")
$RbShortcutNo = $window.FindName("RbShortcutNo")
$RbLaunchYes = $window.FindName("RbLaunchYes")
$RbLaunchNo = $window.FindName("RbLaunchNo")
$RbCpu0 = $window.FindName("RbCpu0")
$RbCpu01 = $window.FindName("RbCpu01")
$RbCpuNone = $window.FindName("RbCpuNone")

$Chk_VcRedist = $window.FindName("Chk_VcRedist")
$Chk_BetterCrewLink = $window.FindName("Chk_BetterCrewLink")
$Chk_DotNet = $window.FindName("Chk_DotNet")
$Chk_AmongUsCapture = $window.FindName("Chk_AmongUsCapture")
$Chk_Submerged = $window.FindName("Chk_Submerged")
$Chk_CustomServer = $window.FindName("Chk_CustomServer")
$script:chk_VcRedist = $Chk_VcRedist
$script:chk_DotNet = $Chk_DotNet

$ProgBar = $window.FindName("ProgBar")
$TxtProgressStatus = $window.FindName("TxtProgressStatus")
$TxtPercent = $window.FindName("TxtPercent")
$TxtLog = $window.FindName("TxtLog")
$ScrollLog = $window.FindName("ScrollLog")
$script:ProgBar = $ProgBar
$script:TxtProgressStatus = $TxtProgressStatus
$script:TxtPercent = $TxtPercent
$script:guiTxtLog = $TxtLog
$script:guiScrollLog = $ScrollLog

$TxtCompleteModDesc = $window.FindName("TxtCompleteModDesc")
$TxtCompletePath = $window.FindName("TxtCompletePath")
$TxtCompleteShortcut = $window.FindName("TxtCompleteShortcut")
$script:TxtCompleteModDesc = $TxtCompleteModDesc
$script:TxtCompletePath = $TxtCompletePath
$script:TxtCompleteShortcut = $TxtCompleteShortcut

# テーマ切替関数
$script:isLightMode = $systemIsLight
function Set-AppTheme([bool]$isLight) {
    $conv = [System.Windows.Media.BrushConverter]::new()
    if ($isLight) {
        $window.Resources["BgWindow"]          = $conv.ConvertFromString("#F8F5F6")
        $window.Resources["BgHeader"]          = $conv.ConvertFromString("#ECE4E7")
        $window.Resources["BgCard"]            = $conv.ConvertFromString("#FFFFFF")
        $window.Resources["BorderCard"]        = $conv.ConvertFromString("#E2CFD5")
        $window.Resources["TextPrimary"]       = $conv.ConvertFromString("#1F1317")
        $window.Resources["TextSecondary"]     = $conv.ConvertFromString("#6B545C")
        $window.Resources["TextAccentRed"]     = $conv.ConvertFromString("#B91C1C")
        $window.Resources["TextAccentGold"]    = $conv.ConvertFromString("#B45309")
        $window.Resources["BtnPrimaryBg"]      = $conv.ConvertFromString("#C81D25")
        $window.Resources["BtnPrimaryHover"]   = $conv.ConvertFromString("#DC2626")
        $window.Resources["BtnPrimaryPressed"] = $conv.ConvertFromString("#991B1B")
        $window.Resources["BtnSecondaryBg"]    = $conv.ConvertFromString("#F1E4E8")
        $window.Resources["BtnSecondaryBorder"]= $conv.ConvertFromString("#D9C2C9")
        $window.Resources["BtnSecondaryText"]  = $conv.ConvertFromString("#2D161E")
        $window.Resources["InputBg"]           = $conv.ConvertFromString("#FAF7F8")
        $window.Resources["InputBorder"]       = $conv.ConvertFromString("#D9C2C9")
        $window.Resources["SeparatorBg"]       = $conv.ConvertFromString("#EADCE1")
        $window.Resources["TerminalBg"]        = $conv.ConvertFromString("#180D11")
        $window.Resources["BadgeBg"]           = $conv.ConvertFromString("#F5E6EB")
        $window.Resources["BadgeBorder"]       = $conv.ConvertFromString("#D9B8C3")
        if ($BtnToggleTheme) { $BtnToggleTheme.Content = "☀️ ライト" }
    } else {
        $window.Resources["BgWindow"]          = $conv.ConvertFromString("#180D11")
        $window.Resources["BgHeader"]          = $conv.ConvertFromString("#221217")
        $window.Resources["BgCard"]            = $conv.ConvertFromString("#29151C")
        $window.Resources["BorderCard"]        = $conv.ConvertFromString("#4A222C")
        $window.Resources["TextPrimary"]       = $conv.ConvertFromString("#F9FAFB")
        $window.Resources["TextSecondary"]     = $conv.ConvertFromString("#D1BFC4")
        $window.Resources["TextAccentRed"]     = $conv.ConvertFromString("#EF4444")
        $window.Resources["TextAccentGold"]    = $conv.ConvertFromString("#F59E0B")
        $window.Resources["BtnPrimaryBg"]      = $conv.ConvertFromString("#DC2626")
        $window.Resources["BtnPrimaryHover"]   = $conv.ConvertFromString("#EF4444")
        $window.Resources["BtnPrimaryPressed"] = $conv.ConvertFromString("#B91C1C")
        $window.Resources["BtnSecondaryBg"]    = $conv.ConvertFromString("#381D26")
        $window.Resources["BtnSecondaryBorder"]= $conv.ConvertFromString("#5C2D3A")
        $window.Resources["BtnSecondaryText"]  = $conv.ConvertFromString("#F3F4F6")
        $window.Resources["InputBg"]           = $conv.ConvertFromString("#210F15")
        $window.Resources["InputBorder"]       = $conv.ConvertFromString("#522532")
        $window.Resources["SeparatorBg"]       = $conv.ConvertFromString("#4A222C")
        $window.Resources["TerminalBg"]        = $conv.ConvertFromString("#12070A")
        $window.Resources["BadgeBg"]           = $conv.ConvertFromString("#381921")
        $window.Resources["BadgeBorder"]       = $conv.ConvertFromString("#6E2C3D")
        if ($BtnToggleTheme) { $BtnToggleTheme.Content = "🌙 ダーク" }
    }
}
Set-AppTheme $script:isLightMode

if ($BtnToggleTheme) {
    $BtnToggleTheme.Add_Click({
        $script:isLightMode = !$script:isLightMode
        Set-AppTheme $script:isLightMode
    })
}

# -------------------------------------------------------------
# 後方互換用 WinForms コントロールオブジェクト (デプロイエンジン用)
# -------------------------------------------------------------
$Font = New-Object System.Drawing.Font("メイリオ", 12)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Among Us Mod Auto Deploy Tool"

$RadioButton5 = New-Object System.Windows.Forms.RadioButton
$RadioButton5.Checked = $True
$RadioButton6 = New-Object System.Windows.Forms.RadioButton
$RadioButton7 = New-Object System.Windows.Forms.RadioButton
$RadioButton17 = New-Object System.Windows.Forms.RadioButton

$RadioButton114 = New-Object System.Windows.Forms.RadioButton
$RadioButton114.Checked = $True
$RadioButton115 = New-Object System.Windows.Forms.RadioButton
$RadioButton116 = New-Object System.Windows.Forms.RadioButton

$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Checked = $True
$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton42 = New-Object System.Windows.Forms.RadioButton

$RadioButton3 = New-Object System.Windows.Forms.RadioButton
$RadioButton4 = New-Object System.Windows.Forms.RadioButton
$RadioButton4.Checked = $True

$RadioButton28 = New-Object System.Windows.Forms.RadioButton
$RadioButton29 = New-Object System.Windows.Forms.RadioButton
$RadioButton29.Checked = $True
$RadioButton27 = New-Object System.Windows.Forms.RadioButton

$CheckedBox = New-Object System.Windows.Forms.CheckedListBox
$RETU = ("AmongUsCapture", "VC Redist", "BetterCrewLink", "PowerShell 7", "dotNetFramework", "LevelImposter", "Submerged", "VOICEVOX", "カスタムサーバー情報追加", "サーバー情報初期化", "配信ソフト", "健康ランド")
$CheckedBox.Items.AddRange($RETU)
$CheckedBox.ClearSelected()

$Combo = New-Object System.Windows.Forms.ComboBox; $Combo.BindingContext = New-Object System.Windows.Forms.BindingContext
if ($gmhbool) { [void] $Combo.Items.Add("NOT :Dolly1016/Nebula on the Test") }
[void] $Combo.Items.Add("NOS :Dolly1016/Nebula on the Ship")
[void] $Combo.Items.Add("SNR :ykundesu/SuperNewRoles")
[void] $Combo.Items.Add("ER :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("ER+ES :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("SRA :Mr-Fluuff/StellarRolesAU")
[void] $Combo.Items.Add("LM :KiraYamato94/LasMonjas")
[void] $Combo.Items.Add("TOH :tukasa0001/TownOfHost")
[void] $Combo.Items.Add("Install/Update Selected")
[void] $Combo.Items.Add("Tool Install Only")
$Combo.SelectedIndex = 0

$Combo2 = New-Object System.Windows.Forms.ComboBox; $Combo2.BindingContext = New-Object System.Windows.Forms.BindingContext
$label4 = New-Object System.Windows.Forms.Label
$label6 = New-Object System.Windows.Forms.Label

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Enabled = $true
$script:OKButton = $OKButton
$script:Combo = $Combo
$script:Combo2 = $Combo2
$script:combo = $Combo
$script:combo2 = $Combo2
$script:CheckedBox = $CheckedBox
$script:label4 = $label4
$script:label6 = $label6

function VerMinMax($ver0, $ver1, $ver2) {
    if ($RadioButton114.Checked) {
        if ($ver0 -eq "NONE") {
            $script:aumin = "NONE"
            $script:aumax = "NONE"
        }
        else {
            $script:aumax = "NONE"
            $script:aumin = $ver0
        }
        $script:latestflag = 1
    }
    elseif ($RadioButton115.Checked) {
        if ($ver1 -eq "NONE") {
            $script:aumax = "NONE"
            $script:aumin = "NONE"
        }
        else {
            if ($ver0 -eq "NONE") {
                $script:aumax = "NONE"
                $script:aumin = $ver1
            }
            elseif ($ver0 -eq $ver1) {
                $script:aumax = "NONE"
                $script:aumin = $ver1
            }
            else {
                $script:aumax = $ver0
                $script:aumin = $ver1    
            }
        }
        $script:latestflag = 2
    }
    elseif ($RadioButton116.Checked) {
        if ($ver2 -eq "NONE") {
            $script:aumax = "NONE"
            $script:aumin = "NONE"
        }
        else {
            if ($ver1 -eq "NONE") {
                if ($ver0 -eq "NONE") {
                    $script:aumax = "NONE"
                    $script:aumin = $ver2
                }
                else {
                    $script:aumax = $ver0
                    $script:aumin = $ver2    
                }
            }
            elseif ($ver1 -eq $ver2) {
                $script:aumax = $ver0
                $script:aumin = $ver2    
            }
            else {
                $script:aumax = $ver1
                $script:aumin = $ver2
            }
        }
        $script:latestflag = 3
    }
}

function Reload() {
    if ($null -eq $script:hasVoicevox) {
        if ($null -ne $script:vvJob -and $null -ne $script:vvAsync) {
            $script:hasVoicevox = $script:vvJob.EndInvoke($script:vvAsync)
            $script:vvJob.Dispose()
            $script:vvJob = $null
            $script:vvAsync = $null
            Write-Log "VOICEVOX check resolved. Installed: $script:hasVoicevox"
        }
        else {
            $script:hasVoicevox = $false
        }
    }
    $CheckedBox.ClearSelected()
    $combo2.Text = ""
    $combo2.DataSource = @()
    if ($null -ne $combo2) { $combo2.Enabled = $true }; if ($null -ne $script:combo2) { $script:combo2.Enabled = $true }
    $tio = $true
    Switch ($combo.text) {
        default {
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            VerMinMax $nosmin $nosmin1 $nosmin2
            Write-Log "NOS Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"AMS :AUModS/AUModS" {
            $releasepage2 = "https://api.github.com/repos/AUModS/AUModS/releases"
            $scid = "AMS"
            VerMinMax $amsmin $amsmin1 $amsmin2
            Write-Log "AMS Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"TOR MR :miru-y/TheOtherRoles-MR" {
            $releasepage2 = "https://api.github.com/repos/miru-y/TheOtherRoles-MR/releases"
            $scid = "TOR MR"
            VerMinMax $tormmin $tormmin1 $tormmin2
            Write-Log "TOR MR Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"NOT :Dolly1016/Nebula on the Test" {
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOT"
            VerMinMax $notmin $notmin1 $notmin2
            Write-Log "NOT Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"TOR GMH :haoming37/TheOtherRoles-GM-Haoming" {
            $releasepage2 = "https://api.github.com/repos/haoming37/TheOtherRoles-GM-Haoming/releases"
            $scid = "TOR GMH"
            VerMinMax $torhmin $torhmin1 $torhmin2
            Write-Log "TOR GMH Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"TOR :TheOtherRolesAU/TheOtherRoles" {
            $releasepage2 = "https://api.github.com/repos/TheOtherRolesAU/TheOtherRoles/releases"
            $scid = "TOR"
            VerMinMax $tormin $tormin1 $tormin2
            Write-Log "TOR Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"TOU-R :eDonnes124/Town-Of-Us-R" {
            $releasepage2 = "https://api.github.com/repos/eDonnes124/Town-Of-Us-R/releases"
            $scid = "TOU-R"
            VerMinMax $tourmin $tourmin1 $tourmin2
            Write-Log "TOU-R Selected"
            $script:isall = $false
            $RadioButton28.Checked = $True
        }"SRA :Mr-Fluuff/StellarRolesAU" {
            $releasepage2 = "https://api.github.com/repos/Mr-Fluuff/StellarRolesAU/releases"
            $scid = "SRA"
            VerMinMax $sramin $sramin1 $sramin2
            Write-Log "SRA Selected"
            $script:isall = $false
            $RadioButton28.Checked = $true
        }"ER :yukieiji/ExtremeRoles" {
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER"
            VerMinMax $ermin $ermin1 $ermin2
            Write-Log "ER Selected"
            $script:isall = $false
            $RadioButton28.Checked = $True
            if (!$script:hasVoicevox) {
                $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("VOICEVOX"), $true)
            }
        }"ER+ES :yukieiji/ExtremeRoles" {
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER+ES"
            VerMinMax $esmin $esmin1 $esmin2
            $aumin = $esmin
            Write-Log "ER+ES Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"NOS :Dolly1016/Nebula" {
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            VerMinMax $nosmin $nosmin1 $nosmin2
            Write-Log "NOS Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"LM :KiraYamato94/LasMonjas" {
            $releasepage2 = "https://api.github.com/repos/KiraYamato94/LasMonjas/releases"
            $scid = "LM"
            VerMinMax $lmmin $lmmin1 $lmmin2
            Write-Log "LM Selected"
            $script:isall = $false
            $RadioButton28.Checked = $True
        }"SNR :ykundesu/SuperNewRoles" {
            $releasepage2 = "https://api.github.com/repos/ykundesu/SuperNewRoles/releases"
            $scid = "SNR"
            VerMinMax $snrmin $snrmin1 $snrmin2
            Write-Log "SNR Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"TOH :tukasa0001/TownOfHost" {
            $releasepage2 = "https://api.github.com/repos/tukasa0001/TownOfHost/releases"
            $scid = "TOH"
            VerMinMax $tohmin $tohmin1 $tohmin2
            Write-Log "TOH Selected"
            $script:isall = $false
            $RadioButton28.Checked = $True
        }"TOY :Yumenopai/TownOfHost_Y" {
            $releasepage2 = "https://api.github.com/repos/Yumenopai/TownOfHost_Y/releases"
            $scid = "TOY"
            VerMinMax $toymin $toymin1 $toymin2
            Write-Log "TOY Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"RHR :sansaaaaai/RevolutionaryHostRoles" {
            $releasepage2 = "https://api.github.com/repos/sansaaaaai/Revolutionary-host-roles/releases"
            $scid = "RHR"
            VerMinMax $rhrmin $rhrmin1 $rhrmin2
            Write-Log "RHR Selected"
            $RadioButton28.Checked = $True
            $script:isall = $false
        }"Install/Update Selected" {
            $script:scid = "IUS"
            $script:tio = $false
            $tio = $false
            Write-Log "SAL Selected"
            if ($null -ne $script:combo2) { $script:combo2.Enabled = $false }; if ($null -ne $combo2) { $combo2.Enabled = $false }
            $script:isall = $true
        }"Tool Install Only" {
            $script:scid = "TIO"
            $script:tio = $false
            $tio = $false
            Write-Log "TIO Selected"
            if ($null -ne $script:combo2) { $script:combo2.Enabled = $false }; if ($null -ne $combo2) { $combo2.Enabled = $false }
            $script:isall = $false
        }
    }

    if ($tio) {
        #GithubのRelease一覧からぶっこぬく
        if (($scid -eq "TOR GMH") -or ($scid -eq "TOR GMT")) {
            if ($null -eq $script:gmhweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:gmhweb = $web 
            }
            else {
                $web = $script:gmhweb 
            }
        }
        elseif ($scid -eq "TOR MR") {
            if ($null -eq $script:mrweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:mrweb = $web 
            }
            else {
                $web = $script:mrweb 
            }
        }
        elseif ($scid -eq "TOR") {
            if ($null -eq $script:torweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:torweb = $web 
            }
            else {
                $web = $script:torweb 
            }
        }
        elseif ($scid -eq "TOU-R") {
            if ($null -eq $script:tourweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:tourweb = $web 
            }
            else {
                $web = $script:tourweb 
            }
        }
        elseif ($scid -eq "SRA") {
            if ($null -eq $script:sraweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:sraweb = $web 
            }
            else {
                $web = $script:sraweb 
            }
        }
        elseif (($scid -eq "ER") -or ($scid -eq "ER+ES")) {
            if ($null -eq $script:erweb) {
                if ($null -ne $script:prefetchJobs["ER"]) {
                    $job = $script:prefetchJobs["ER"]
                    $webResult = $job.PowerShell.EndInvoke($job.AsyncResult)
                    $job.PowerShell.Dispose()
                    $script:prefetchJobs.Remove("ER")
                    $actualWeb = $webResult | Select-Object -First 1
                    if ($null -ne $actualWeb -and (-not [string]::IsNullOrWhiteSpace($actualWeb.Content))) {
                        $script:erweb = $actualWeb
                    }
                }
                if ($null -eq $script:erweb) {
                    $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                    $script:erweb = $web 
                }
            }
            else {
                $web = $script:erweb 
            }
        }
        elseif (($scid -eq "NOS") -or ($scid -eq "NOT")) {
            if ($null -eq $script:nosweb) {
                if ($null -ne $script:prefetchJobs["NOS"]) {
                    $job = $script:prefetchJobs["NOS"]
                    $webResult = $job.PowerShell.EndInvoke($job.AsyncResult)
                    $job.PowerShell.Dispose()
                    $script:prefetchJobs.Remove("NOS")
                    $actualWeb = $webResult | Select-Object -First 1
                    if ($null -ne $actualWeb -and (-not [string]::IsNullOrWhiteSpace($actualWeb.Content))) {
                        $script:nosweb = $actualWeb
                    }
                }
                if ($null -eq $script:nosweb) {
                    $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                    $script:nosweb = $web 
                }
            }
            else {
                $web = $script:nosweb 
            }
        }
        elseif ($scid -eq "LM") {
            if ($null -eq $script:lmweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:lmweb = $web 
            }
            else {
                $web = $script:lmweb 
            }
        }
        elseif ($scid -eq "SNR") {
            if ($null -eq $script:snrweb) {
                if ($null -ne $script:prefetchJobs["SNR"]) {
                    $job = $script:prefetchJobs["SNR"]
                    $webResult = $job.PowerShell.EndInvoke($job.AsyncResult)
                    $job.PowerShell.Dispose()
                    $script:prefetchJobs.Remove("SNR")
                    $actualWeb = $webResult | Select-Object -First 1
                    if ($null -ne $actualWeb -and (-not [string]::IsNullOrWhiteSpace($actualWeb.Content))) {
                        $script:snrweb = $actualWeb
                    }
                }
                if ($null -eq $script:snrweb) {
                    $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                    $script:snrweb = $web 
                }
            }
            else {
                $web = $script:snrweb 
            }
        }
        elseif ($scid -eq "TOH") {
            if ($null -eq $script:tohweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:tohweb = $web 
            }
            else {
                $web = $script:tohweb 
            }
        }
        elseif ($scid -eq "TOY") {
            if ($null -eq $script:toyweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:toyweb = $web 
            }
            else {
                $web = $script:toyweb 
            }
        }
        elseif ($scid -eq "RHR") {
            if ($null -eq $script:rhrweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:rhrweb = $web 
            }
            else {
                $web = $script:rhrweb 
            }
        }
        elseif ($scid -eq "AMS") {
            if ($null -eq $script:amsweb) {
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:amsweb = $web 
            }
            else {
                $web = $script:amsweb 
            }
        }
        else {
            $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
        }

        if ($null -eq $web -or [string]::IsNullOrWhiteSpace($web.Content)) {
            $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
        }
        $web2 = ConvertFrom-Json $web.Content
    
        $list2 = @()
        $tmparr = @()
        # コンボボックスに項目を追加
        if ($null -ne $OKButton) { $OKButton.Enabled = $True }; if ($null -ne $script:OKButton) { $script:OKButton.Enabled = $True }
        if ($script:aumin -ne "NONE") {
            if ($script:aumax -ne "NONE") {
                if ($scid -eq "NOS") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $tmparr = $($web2.tag_name[$ai]).split(",")
                        #Write-Log $tmparr
                        #Write-Log $script:aumin
                        #Write-Log ($tmparr[2] -eq $script:aumin)
                        if ($tmparr[2] -eq $script:aumin) { 
                            if ($tmparr[0] -eq "v") {
                                $list2 += $tmparr[1]
                            }
                        }
                    }
                }
                elseif ($scid -eq "NOT") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $tmparr = $($web2.tag_name[$ai]).split(",")
                        if ($tmparr[2] -eq $script:aumin) {
                            if ($tmparr[0] -ne "v") {
                                $list2 += $tmparr[1]
                            }
                        }
                    }            
                }
                elseif ($scid -eq "ER") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $temptag = $($web2.tag_name[$ai])
                        $tempmin = $script:aumin
                        $tempmax = $script:aumax
                        if ($temptag.IndexOf("v1") -lt 0) {
                            $temptag = $temptag.Replace("v", "v0")
                        }
                        if ($tempmin.IndexOf("v1") -lt 0) {
                            $tempmin = $tempmin.Replace("v", "v0")
                        }
                        if ($tempmax.IndexOf("v1") -lt 0) {
                            $tempmax = $tempmax.Replace("v", "v0")
                        }
                        if (($temptag -ge $tempmin) -and ($temptag -lt $tempmax)) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }
                elseif ($scid -eq "ER+ES") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $temptag = $($web2.tag_name[$ai])
                        $tempmin = $script:aumin
                        $tempmax = $script:aumax
                        if ($temptag.IndexOf("v1") -lt 0) {
                            $temptag = $temptag.Replace("v", "v0")
                        }
                        if ($tempmin.IndexOf("v1") -lt 0) {
                            $tempmin = $tempmin.Replace("v", "v0")
                        }
                        if ($tempmax.IndexOf("v1") -lt 0) {
                            $tempmax = $tempmax.Replace("v", "v0")
                        }
                        if (($temptag -ge $tempmin) -and ($temptag -lt $tempmax)) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }
                else {            
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        if (($web2.tag_name[$ai] -ge $script:aumin) -and ($web2.tag_name[$ai] -lt $script:aumax)) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }    
            }
            else {
                if ($scid -eq "NOS") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $tmparr = $($web2.tag_name[$ai]).split(",")
                        if ($tmparr[2] -eq $script:aumin) {
                            if ($tmparr[0] -eq "v") {
                                $list2 += $tmparr[1]
                            }
                        }
                    }            
                }
                elseif ($scid -eq "NOT") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $tmparr = $($web2.tag_name[$ai]).split(",")
                        if ($tmparr[2] -eq $script:aumin) {
                            if ($tmparr[0] -ne "v") {
                                $list2 += $tmparr[1]
                            }
                        }
                    }            
                }
                elseif ($scid -eq "ER") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $temptag = $($web2.tag_name[$ai])
                        $tempmin = $script:aumin
                        if ($temptag.IndexOf("v1") -lt 0) {
                            $temptag = $temptag.Replace("v", "v0")
                        }
                        if ($tempmin.IndexOf("v1") -lt 0) {
                            $tempmin = $tempmin.Replace("v", "v0")
                        }
                        if ($temptag -ge $tempmin) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }
                elseif ($scid -eq "ER+ES") {
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        $temptag = $($web2.tag_name[$ai])
                        $tempmin = $script:aumin
                        if ($temptag.IndexOf("v1") -lt 0) {
                            $temptag = $temptag.Replace("v", "v0")
                        }
                        if ($tempmin.IndexOf("v1") -lt 0) {
                            $tempmin = $tempmin.Replace("v", "v0")
                        }
                        if ($temptag -ge $tempmin) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }
                else {            
                    for ($ai = 0; $ai -lt $web2.tag_name.Length; $ai++) {
                        if (($web2.tag_name[$ai] -ge $script:aumin)) {
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }    
                #Write-Log "Version List"
                #Write-Log $list2
                $templist2 = @()
                $templist3 = @()
                $venable = $false
                if (($scid -eq "NOS") -or ($scid -eq "NOT") -or ($scid -eq "ER") -or ($scid -eq "ER+ES") -or ($scid -eq "SRA") -or ($scid -eq "TOH") -or ($scid -eq "TOY")) {
                    $venable = $true
                    for ($aa = 0; $aa -lt $list2.length; $aa++) {
                        #Write-Log $list2[$aa] 
                        #Write-Log $list2[$aa].TrimStart("v") 
                        $templist2 += $($list2[$aa]).TrimStart("v") 
                    }
                    $list2 = $templist2 | Sort-Object { $_ -as [version] } -Descending
                    #Write-Log $list2
                }
                if ($venable) {
                    for ($aa = 0; $aa -lt $list2.length; $aa++) {
                        $templist3 += "v$($list2[$aa])" 
                    }
                    $list2 = $templist3
                }
                else {
                    if ($list2.Length -gt 1) {
                        $list2 = $list2 | Sort-Object { $_ -as [version] } -Descending
                    }
                }
                #Write-Log $list2
            }
        }
        else {
            if ($null -ne $OKButton) { $OKButton.Enabled = $false }; if ($null -ne $script:OKButton) { $script:OKButton.Enabled = $false }
        }
        if ($list2.length -eq 0) {
            if ($null -ne $OKButton) { $OKButton.Enabled = $false }; if ($null -ne $script:OKButton) { $script:OKButton.Enabled = $false }
        }
        <#sort version $list2 = $list2 | Sort-Object -Property {$([INT]$_.split('.')[2])} -Descending
        if(($scid -eq "NOS") -or ($scid -eq "NOT") -or ($scid -eq "ER") -or ($scid -eq "ER+ES")){
            $list2 = $list2 | Sort-Object -Property {$([INT]$_.split('.')[3])} -Descending
        }elseif($scid -eq "SNR"){
            $list2 = $list2 | Sort-Object -Property {$($_.split('.')[3])} -Descending
        }elseif(($scid -eq "TOR") -or ($scid -eq "TOU-R") -or ($scid -eq "SRA") -or ($scid -eq "LM") -or ($scid -eq "TOH")){
            $list2 = $list2 | Sort-Object -Property {$([INT]$_.split('.')[2])} -Descending            
        }else{}
        if(($scid -eq "NOS") -or ($scid -eq "NOT")){
            $list2 = $list2 | Sort-Object { $_ -as [version]  } -Descending
        }else{}
        #>
        $combo2.DataSource = $list2
        if ($list2.Length -gt 0) {
            $Combo2.SelectedIndex = 0            
        }

        #################################################################################################
        # 起動時に Initialize-GameEnvironment でスキャンした結果をキャッシュから取得
        #################################################################################################
        $aupatho = $script:aupatho
        $platform = $script:platform
        
        if ([string]::IsNullOrEmpty($aupatho)) {
            $aupatho = if ($script:aupatho) { $script:aupatho } elseif ($script:platform -eq "epic") { "C:\Program Files\Epic Games\Among Us" } else { "C:\Program Files (x86)\Steam\steamapps\common\Among Us" }
            $script:aupatho = $aupatho
        }
        
        # 選択された Mod ($scid) に応じて、パスを自動構成する（I/Oアクセスを伴わず一瞬で完了）
        $parentPath = Split-Path $aupatho -Parent
        $aupathm = Join-Path $parentPath "Among Us $scid Mod"
        if ($platform -eq "epic") {
            $aupathb = Join-Path $parentPath "AmongUsBackup"
        }
        else {
            $aupathb = Join-Path $parentPath "Among Us Backup"
        }
        
        $label4.Text = $aupatho
        $label6.Text = $aupathm
        $script:aupatho = $aupatho
        $script:aupathm = $aupathm
        $script:aupathb = $aupathb
        $script:releasepage = $releasepage2
        $script:scid = $scid
        $script:aumin = $aumin
        $script:tio = $script:tio
        if ($null -ne $script:CheckedBox) { $script:CheckedBox.ClearSelected() }
        for ($cbc = 0; $cbc -lt $script:CheckedBox.Items.Count; $cbc++) {
            $script:CheckedBox.SetItemChecked($cbc, $false)
        }
        if (($script:scid -eq "ER") -or ($script:scid -eq "ER+ES")) {
            if (!$script:hasVoicevox) {
                $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("VOICEVOX"), $true)
            }
        }
        else {
            $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("VOICEVOX"), $false)
        }
        <#
        if(($script:scid -eq "SNR") -or ($script:scid -eq "SRA")){
            $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("LevelImposter"), $true)
        }else{
            $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("LevelImposter"), $false)
        }
        #>
        $ym = $script:ym
        if (!(Test-Path "$aupathb\chk$ym.txt")) {
            $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("VC Redist"), $true)
            $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("dotNetFramework"), $true)                         
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                $script:CheckedBox.SetItemChecked($script:CheckedBox.items.IndexOf("PowerShell 7"), $true)
            }
            $script:opflag = $true
        }
    }
    $script:tio = $tio
    # version detect (using cached value)


    Write-Log "$script:amver が検出されました"
    $RadioButton114.Text = $(Get-Translate("$script:amver"))
    $RadioButton115.Text = $(Get-Translate("$script:prever0"))        
    $RadioButton116.Text = $(Get-Translate("$script:prever1"))        
    if ($RadioButton114.Checked) {
        Write-Log "本体バージョン v$script:amver が選択されています"
    }
    elseif ($RadioButton115.Checked) {
        Write-Log "本体バージョン v$($RadioButton115.Text) が選択されています"
    }
    elseif ($RadioButton116.Checked) {
        Write-Log "本体バージョン v$($RadioButton116.Text) が選択されています"
    }
    else {
        Write-Log "Unknown ERROR:本体バージョン"
    }
    # 本体バージョンの旧世代判定と自動クリーンインストール
    $needCleanInstall = $false
    try {
        if (!(Test-Path "$script:aupatho\Among Us.exe")) {
            Write-Log "Among Us 本体が存在しないため、新規クリーンインストールを実行します。"
            $needCleanInstall = $true
        }
        elseif ($script:amver -and $script:prever0) {
            $verCurrent = $script:amver -as [version]
            $verTarget = $script:prever0 -as [version]
            if ($null -ne $verCurrent -and $null -ne $verTarget) {
                if ($verCurrent -lt $verTarget) {
                    $needCleanInstall = $true
                }
            }
            elseif ($script:amver -lt $script:prever0) {
                $needCleanInstall = $true
            }
        }

    # Modern GUI がアクティブな場合、WPF 画面へ同期反映
    if ($null -ne $script:mainWindow) {
        if ($script:CmbVersion -and $combo2.DataSource) {
            $script:CmbVersion.Items.Clear()
            foreach ($item in $combo2.DataSource) {
                [void]$script:CmbVersion.Items.Add($item)
            }
            if ($script:CmbVersion.Items.Count -gt 0) {
                $script:CmbVersion.SelectedIndex = 0
            }
        }
        if ($script:TxtVanillaPath) { $script:TxtVanillaPath.Text = $script:aupatho }
        if ($script:TxtModPath) { $script:TxtModPath.Text = $script:aupathm }
        if ($script:TxtPlatformBadge) {
            $badgePlat = if ($script:platform -eq "epic") { "Epic" } else { "Steam" }
            $script:TxtPlatformBadge.Text = "🟢 $badgePlat 選択中 (v$script:amver)"
        }
        if ($script:chk_VcRedist) { $script:chk_VcRedist.IsChecked = $CheckedBox.CheckedItems.Contains("VC Redist") }
        if ($script:chk_DotNet) { $script:chk_DotNet.IsChecked = $CheckedBox.CheckedItems.Contains("dotNetFramework") }
    }
    }
    catch {
        Write-Log "Version compare warning: $_"
    }

    if ($needCleanInstall) {
        Write-Log "本体バージョン ($script:amver) が最新 ($script:prever0) より古いため、クリーンインストールの実行対象です。"
        
        $doClean = $false
        if ($null -ne $Args1) {
            # 自動テスト / 非対話実行時は自動で実行
            Write-Log "非対話モード (-Args1) のため、自動でクリーンインストールを実行します。"
            $doClean = $true
        }
        else {
            # 対話実行時はユーザーに確認
            $msg = $(Get-Translate("本体バージョン ($script:amver) が最新 ($script:prever0) より古いです。`n最新の Among Us にクリーンインストールしますか？"))
            if ([System.Windows.Forms.MessageBox]::Show($msg, "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                $doClean = $true
            }
            else {
                Write-Log "ユーザーによってクリーンインストールがキャンセルされました。"
            }
        }

        if ($doClean) {
            $rn = if ($script:platform -eq "epic") { "epic" } else { "steam" }
            Write-Log "クリーンインストールプロセス開始 (プラットフォーム: $rn)"

            $cleanScriptName = if ($rn -eq "epic") { "AmongusCleanInstall_Epic.ps1" } else { "AmongusCleanInstall_Steam.ps1" }
            $cleanScriptLocal = Join-Path $npl $cleanScriptName
            if (!(Test-Path $cleanScriptLocal)) {
                $cleanScriptLocal = Join-Path $dsk $cleanScriptName
            }

            if (!(Test-Path $cleanScriptLocal)) {
                $cleanScriptLocal = "$npl\$cleanScriptName"
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/$cleanScriptName" -OutFile $cleanScriptLocal -UseBasicParsing
            }

            if (Test-Path $cleanScriptLocal) {
                Unblock-File $cleanScriptLocal -ErrorAction SilentlyContinue
                $psCleanExe = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") { "$env:ProgramFiles\PowerShell\7\pwsh.exe" } else { "powershell.exe" }
                $cleanProc = Start-Process -FilePath $psCleanExe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$cleanScriptLocal`" -Args1 `"Yes`"" -PassThru
                $cleanProc.WaitForExit()
                Write-Log "クリーンインストールプロセス終了 (ExitCode: $($cleanProc.ExitCode))"
                
                # インストール完了の待機 (最大600秒ポーリング)
                $waitSec = 0
                while (!(Test-Path "$script:aupatho\Among Us.exe") -and ($waitSec -lt 600)) {
                    if ($script:platform -eq "epic") {
                        if (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe") {
                            $script:aupatho = "C:\Program Files\Epic Games\Among Us"
                            $aupatho = $script:aupatho
                            $au_path_epic_org = $script:aupatho
                            break
                        }
                        elseif (Test-Path "C:\Program Files\Epic Games\AmongUs\Among Us.exe") {
                            $script:aupatho = "C:\Program Files\Epic Games\AmongUs"
                            $aupatho = $script:aupatho
                            $au_path_epic_org = $script:aupatho
                            break
                        }
                    }
                    Start-Sleep -Seconds 5
                    $waitSec += 5
                    Write-Log "本体の配置待機中... (${waitSec}s/600s)"
                }

                $aupatho = $script:aupatho
                if ($script:platform -eq "epic") {
                    $au_path_epic_org = $script:aupatho
                }
                $parentPath = Split-Path $script:aupatho -Parent
                $aupathm = Join-Path $parentPath "Among Us $script:scid Mod"
                $script:aupathm = $aupathm
                if ($script:platform -eq "epic") {
                    $aupathb = Join-Path $parentPath "AmongUsBackup"
                } else {
                    $aupathb = Join-Path $parentPath "Among Us Backup"
                }
                $script:aupathb = $aupathb

                # バージョン再検出
                if (Test-Path "$script:aupatho\Among Us_Data\globalgamemanagers") {
                    $tt = [System.IO.File]::ReadAllBytes("$script:aupatho\Among Us_Data\globalgamemanagers")
                    $tt2 = [System.Text.Encoding]::UTF8.GetString($tt)
                    $tt3 = [regex]::Matches($tt2, "(19|20)[0-9][2-9][- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|1[0-9]|2[0-9]|3[01]|[1-9])")
                    if ($null -eq $tt3[1]) {
                        $script:amver = $tt3[0].Value
                    }
                    else {
                        $script:amver = $tt3[1].Value
                    }
                    $RadioButton114.Text = $(Get-Translate("$script:amver"))
                    Write-Log "本体が $script:amver にアップデートされました。"
                }
            }
            else {
                Write-Log "Error: クリーンインストールスクリプトが見つかりませんでした。"
            }
        }
    }
}

$sttime = Get-Date

if ($null -eq $Args1) {
    # -------------------------------------------------------------
    # 対話モード: Modern GUI (WPF/Airship) を起動
    # -------------------------------------------------------------
    $window.Show()
    $script:guiTxtLog = $TxtLog
    $script:guiScrollLog = $ScrollLog

    # プラットフォーム初期状態の設定
    if ($script:bothPlatformsDetected) {
        $RbPlatformSteam.IsEnabled = $true
        $RbPlatformEpic.IsEnabled = $true
        if ($script:platform -eq "epic") {
            $RbPlatformEpic.IsChecked = $true
        } else {
            $RbPlatformSteam.IsChecked = $true
        }
    } else {
        if ($script:hasEpic) {
            $RbPlatformEpic.IsChecked = $true
        } else {
            $RbPlatformSteam.IsChecked = $true
        }
        $RbPlatformSteam.IsEnabled = $false
        $RbPlatformEpic.IsEnabled = $false
    }

    # プラットフォーム切替ハンドラ
    $RbPlatformSteam.Add_Checked({
        $script:platform = "steam"
        $script:aupatho = $au_path_steam_org
        if (Test-Path "$script:aupatho\Among Us_Data\globalgamemanagers") {
            $tt = [System.IO.File]::ReadAllBytes("$script:aupatho\Among Us_Data\globalgamemanagers")
            $tt2 = [System.Text.Encoding]::UTF8.GetString($tt)
            $tt3 = [regex]::Matches($tt2, "(19|20)[0-9][2-9][- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|1[0-9]|2[0-9]|3[01]|[1-9])")
            if ($null -eq $tt3[1]) { $script:amver = $tt3[0].Value } else { $script:amver = $tt3[1].Value }
        }
        Reload
    })
    $RbPlatformEpic.Add_Checked({
        $script:platform = "epic"
        if (!(Test-Path "$au_path_epic_org\Among Us.exe") -and (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe")) {
            $au_path_epic_org = "C:\Program Files\Epic Games\Among Us"
        }
        $script:aupatho = $au_path_epic_org
        if (Test-Path "$script:aupatho\Among Us_Data\globalgamemanagers") {
            $tt = [System.IO.File]::ReadAllBytes("$script:aupatho\Among Us_Data\globalgamemanagers")
            $tt2 = [System.Text.Encoding]::UTF8.GetString($tt)
            $tt3 = [regex]::Matches($tt2, "(19|20)[0-9][2-9][- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|1[0-9]|2[0-9]|3[01]|[1-9])")
            if ($null -eq $tt3[1]) { $script:amver = $tt3[0].Value } else { $script:amver = $tt3[1].Value }
        }
        Reload
    })

    # MOD 変更ハンドラ
    $CmbMod.Add_SelectionChanged({
        if ($CmbMod.SelectedIndex -ge 0) {
            $Combo.SelectedIndex = $CmbMod.SelectedIndex
            Reload
        }
    })

    # 初期ロード
    $CmbMod.SelectedIndex = 0
    Reload

    # ボタンイベントハンドラ & ウィンドウ閉じる制御 (案A: デプロイ進行中の誤終了防止)
    $script:isDeploying = $false
    $window.Add_Closing({
        param($s, $e)
        if ($script:isDeploying) {
            $e.Cancel = $true
            [System.Windows.MessageBox]::Show("MOD デプロイ処理を実行中です。完了するまでウィンドウを閉じることはできません。", "Among Us Mod Auto Deploy Tool", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
        }
    })

    $script:actionToTake = $null
    $BtnStartDeploy.Add_Click({
        $script:actionToTake = "Deploy"
    })
    $BtnCancel.Add_Click({
        $script:actionToTake = "Cancel"
    })
    $BtnClose.Add_Click({
        $script:actionToTake = "Cancel"
    })
    $BtnBackToConfig.Add_Click({
        $ViewComplete.Visibility = [System.Windows.Visibility]::Collapsed
        $ViewConfig.Visibility = [System.Windows.Visibility]::Visible
    })
    $BtnLaunchGame.Add_Click({
        $script:completeAction = "Launch"
    })

    # ユーザー操作待機ループ
    while ($null -eq $script:actionToTake -and $window.IsVisible) {
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        Start-Sleep -Milliseconds 50
    }

    if ($script:actionToTake -ne "Deploy") {
        $window.Close()
        exit
    }

    # クリーンインストールが選択されている場合の処理
    if ($RbCleanInstall.IsChecked) {
        $cleanScript = if ($script:platform -eq "epic") { "AmongusCleanInstall_Epic.ps1" } else { "AmongusCleanInstall_Steam.ps1" }
        Write-Log "クリーンインストールが選択されました: $cleanScript を実行します..."
        Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/$cleanScript" -OutFile "$npl\$cleanScript" -UseBasicParsing
        $fpth2 = "$npl\$cleanScript"
        $psExe = if (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe") { "$env:ProgramFiles\PowerShell\7\pwsh.exe" } else { "powershell.exe" }
        Start-Process $psExe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$fpth2`"" -Verb RunAs -Wait
        Remove-Item $fpth2 -Force -ErrorAction SilentlyContinue
        Write-Log "クリーンインストールが完了しました。スクリプトを再起動してください。"
        $window.Close()
        exit
    }

    # 選択内容を WinForms 互換オブジェクトへ完全同期
    $RadioButton5.Checked = $RbRecreate.IsChecked
    $RadioButton7.Checked = $RbOverwrite.IsChecked
    $RadioButton6.Checked = $RbNoRecreate.IsChecked
    $RadioButton17.Checked = $RbCleanInstall.IsChecked

    $RadioButton1.Checked = $RbShortcutYes.IsChecked
    $RadioButton2.Checked = $RbShortcutNo.IsChecked

    $RadioButton3.Checked = $RbLaunchYes.IsChecked
    $RadioButton4.Checked = $RbLaunchNo.IsChecked

    $RadioButton29.Checked = $RbCpu0.IsChecked
    $RadioButton28.Checked = $RbCpu01.IsChecked
    $RadioButton27.Checked = $RbCpuNone.IsChecked

    $CheckedBox.ClearSelected()
    if ($Chk_VcRedist.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("VC Redist"), $true) }
    if ($Chk_BetterCrewLink.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("BetterCrewLink"), $true) }
    if ($Chk_DotNet.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("dotNetFramework"), $true) }
    if ($Chk_AmongUsCapture.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("AmongUsCapture"), $true) }
    if ($Chk_Submerged.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("Submerged"), $true) }
    if ($Chk_CustomServer.IsChecked) { $CheckedBox.SetItemChecked($CheckedBox.Items.IndexOf("カスタムサーバー情報追加"), $true) }

    $mod = $Combo.Text
    $torpv = if ($CmbVersion.SelectedItem) { $CmbVersion.SelectedItem.ToString() } else { $Combo2.Text }

    # ViewConfig -> ViewProgress へ遷移 (案A: 進行中はキャンセル無効化)
    $script:isDeploying = $true
    if ($BtnCancel) {
        $BtnCancel.IsEnabled = $false
        $BtnCancel.Content = "処理中..."
        $BtnCancel.ToolTip = "デプロイ処理中はキャンセルできません"
    }
    $ViewConfig.Visibility = [System.Windows.Visibility]::Collapsed
    $ViewProgress.Visibility = [System.Windows.Visibility]::Visible
    $TxtProgressStatus.Text = "Among Us Mod $scid のデプロイを準備中..."
    $ProgBar.Value = 5
    $TxtPercent.Text = "5%"
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)
}
else {
    # -------------------------------------------------------------
    # 非対話モード: 従来通りのバックグラウンド処理
    # -------------------------------------------------------------
    if ($latestflag -eq 1) {
        $RadioButton114.Checked = $True
    }
    elseif ($latestflag -eq 2) {
        $RadioButton115.Checked = $True
    }
    elseif ($latestflag -eq 3) {
        $RadioButton116.Checked = $True
    }
    else {
        $RadioButton114.Checked = $True
    }
    $combo.SelectedIndex = $Args1
    Reload
    $mod = $combo.Text
    $torpv = $combo2.Text
}
$screensize = [System.Windows.Forms.Screen]::AllScreens
$screens = [System.Windows.Forms.Screen]::AllScreens.Count
for ($scs = 0 ; $scs -lt $screens; $scs++) {
    if ($($screensize[$scs]).Primary -eq $True) {
        $prime = $scs
    }
}
$wdh = $($screensize[$prime]).Bounds.Width
$hgt = $($screensize[$prime]).Bounds.Height

if ($isall) {
    # フォームの作成
    $form0 = New-Object System.Windows.Forms.Form
    $form0.Size = "400,450"
    $form0.Startposition = "CenterScreen"
    $form0.Text = "Among Us Mod Auto Deploy Tool"
    $form0.FormBorderStyle = "Fixed3D"
    $form0.Icon = "$dsk\AUMADS.ico"
    $form0.font = $Font
    $form0.TopLevel = $true

    # ラベルを作成
    $label0 = New-Object System.Windows.Forms.Label
    $label0.Location = "5,5"
    $label0.Size = "340,20"
    $label0.Text = "InstallするModを選択してください"

    # チェックボックスを作成
    $CheckedBox0 = New-Object System.Windows.Forms.CheckedListBox
    $CheckedBox0.Location = "5,30"
    $CheckedBox0.Size = "370,350"
    #Modの数-2(ALL)
    $modnum = $($combo.items.count) - 2

    $RETU2 = @("ALL")
    # 配列を作成
    for ($ial = 0; $ial -lt $modnum; $ial++) {
        $RETU2 += $($combo.items[$ial])
    }

    # チェックボックスに10項目を追加
    $CheckedBox0.Items.AddRange($RETU2)

    # すべての既存の選択をクリア
    $CheckedBox0.ClearSelected()

    # OKボタンの設定
    $OKButton0 = New-Object System.Windows.Forms.Button
    $OKButton0.Location = "170,375"
    $OKButton0.Size = "75,30"
    $OKButton0.Text = "OK"
    $OKButton0.DialogResult = [System.Windows.Forms.DialogResult]::OK

    # キャンセルボタンの設定
    $CancelButton0 = New-Object System.Windows.Forms.Button
    $CancelButton0.Location = "270,375"
    $CancelButton0.Size = "75,30"
    $CancelButton0.Text = "Cancel"
    $CancelButton0.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    # フォームにアイテムを追加
    $form0.Controls.Add($label0)
    $form0.Controls.Add($OKButton0)
    $form0.Controls.Add($CancelButton0)
    $form0.Controls.Add($CheckedBox0)

    # キーとボタンの関係
    $form0.AcceptButton = $OKButton0
    $form0.CancelButton = $CancelButton0

    # 最前面に表示：する
    $form0.Topmost = $false

    # フォームを表示
    $result0 = $form0.ShowDialog()

    # 処理分岐
    if ( $result0 -eq "OK" ) {
        $AAA2 = @($CheckedBox0.CheckedItems)
    }
    else {
        exit
    }

    # プログレスバー
    $Form22 = New-Object System.Windows.Forms.Form
    $Form22.Size = "520,270"
    $Form22.Text = "Among Us Mod Auto Deploy Tool"
    $form22.Icon = "$dsk\AUMADS.ico"
    $form22.FormBorderStyle = "Fixed3D"
    $Form22.font = $Font

    $form22.StartPosition = "Manual"
    $form22.Left = ($wdh / 2) - ($form22.Width / 2)
    $form22.Top = ($hgt / 2) - 3 * ($form22.Height / 2)

    $label2222 = New-Object System.Windows.Forms.Label
    $label2222.Location = New-Object System.Drawing.Point(10, 10)
    $label2222.Size = New-Object System.Drawing.Size(500, 120)
    $label2222.Text = $(Get-Translate("Among Us Mod のInstall/Update Selected`r`n Deploy中です。`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
    $form22.Controls.Add($label2222)

    # プログレスバー
    $Bar2 = New-Object System.Windows.Forms.ProgressBar
    $Bar2.Location = "10,190"
    $Bar2.Size = "480,30"
    $Bar2.Maximum = "$($modnum + 1)"
    $Bar2.Minimum = "0"
    $Bar2.Style = "Continuous"
    $Form22.Controls.Add($Bar2)
    $Bar2.Value = "0"
    $Form22.Show()

    #選択されたModの数
    if ($AAA2.contains("ALL")) {
        $modsel = $modnum
    }
    else {
        $modsel = $AAA2.Count
    }
    $currentphase = 0
    Write-Log "SAL: $modnum $modsel"
    Write-Log "SAL: $AAA2"
    for ($iall = 0; $iall -lt $modnum; $iall++) {
        $Bar2.Value = "$($iall + 1)"
        if ($AAA2.contains("$($combo.items[$iall])") -OR $AAA2.contains("ALL")) {
            $currentphase++
            Write-Log "$($combo.items[$iall]) のインストールを開始しました。$currentphase/$modsel"
            $label2222.Text = $(Get-Translate("Among Us Mod $($combo.items[$iall])`r`nDeploy中です。 $currentphase/$modsel`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
            if (Test-Path "$npl\AmongUsModTORplusDeployScript.ps1") {
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`" -Args1 `"$iall`" " -Verb RunAs -Wait
            }
            elseif (Test-Path "$dsk\AmongUsModTORplusDeployScript.ps1") {
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$dsk\AmongUsModTORplusDeployScript.ps1`" -Args1 `"$iall`" " -Verb RunAs -Wait
            }
            else {
                Write-Log "何かがおかしい。"
            }
            Write-Log "$($combo.items[$iall]) のインストールが完了しました。 $currentphase/$modsel"    
            $label2222.Text = $(Get-Translate("Among Us Mod のInstall/Update Selected が進行中です。`r`n$currentphase/$modsel`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
        }
    }

    $Form22.Close()
}

$prefpth = ""
if ($RadioButton114.Checked) {
    $prebool = $false
    Write-Log "本体バージョン v$amver が選択されています"
    $oldtype = $false
    $prevtargetid = $prevtargetid0
    $prever = $prever0
}
elseif ($RadioButton115.Checked) {
    $prevtargetid = $prevtargetid0
    $prever = $prever0
    #ファイル一覧
    BackUpAU
    $items = Get-ChildItem $aupathb -File
    $nbool = $false
    foreach ($item in $items) {
        if (($item.Name).IndexOf("$prever") -gt 0) {
            if (($item.Name).IndexOf(".zip") -gt 0) {
                $prefpth = $item.Name 
                Write-Log $prefpth
                $nbool = $true
            }
        }
    }
    #chk pth
    if ($nbool) {
        if (Test-Path "$aupathb\$prefpth") {
            $prebool = $true
            Write-Log "本体バージョン v$prever が選択されています"
        }
        else {
            $prebool = $false    
            Write-Log "本体バージョン v$amver に選択が変更されました"
        }    
    }
    else {
        $prebool = $false    
        Write-Log "本体バージョン v$amver に選択が変更されました"
    }
}
elseif ($RadioButton116.Checked) {
    $prevtargetid = $prevtargetid1
    $prever = $prever1
    #ファイル一覧
    BackUpAU
    $items = Get-ChildItem $aupathb -File
    $nbool = $false
    foreach ($item in $items) {
        if (($item.Name).IndexOf("$prever1") -gt 0) {
            if (($item.Name).IndexOf(".zip") -gt 0) {
                $prefpth = $item.Name 
                Write-Log $prefpth
                $nbool = $true
            }
        }
    }
    #chk pth
    if ($nbool) {
        if (Test-Path "$aupathb\$prefpth") {
            $prebool = $true
            Write-Log "本体バージョン v$prever が選択されています"
        }
        else {
            $prebool = $false    
            Write-Log "本体バージョン v$amver に選択が変更されました"
        }    
    }
    else {
        $prebool = $false    
        Write-Log "本体バージョン v$amver に選択が変更されました"
    }
}
else {
    Write-Log "Critical:AU ver chk"
    exit
}

Write-Log "$mod が選択されました"
if ($torpv.Length -le 0) {
    if ($scid -eq "TIO") {
    }
    elseif ($scid -eq "IUS") {
    }
    else {
        Write-Log "この本体バージョンでインストール可能なModバージョンが存在しません。"
        Write-Log "処理を中止します。"
        exit    
    }
}
Write-Log "Version $torpv が選択されました"
Write-Log $releasepage
#統計情報（非同期送信）
$jsondata = "{`"date`":`"$Log`", `"mod`":`"$scid`", `"version`":`"$torpv`", `"main`":`"$amver`"}"
try {
    [powershell]::Create().AddScript({
            param($payload)
            try {
                curl.exe -s --max-time 3 -X POST -H "Content-Type: application/json" -d $payload -L "https://script.google.com/macros/s/AKfycbyr8P-sfWEgG9IdYNeillASu7dtnnnhV607XimGh3NXJY8OiWm51_LvP6VPU79zfvx0/exec" | Out-Null
            }
            catch {}
        }).AddArgument($jsondata).BeginInvoke() | Out-Null
}
catch {
    # 統計送信エラーは無視
}

if ($RadioButton29.Checked) {
    $cpun = 1
}
elseif ($RadioButton28.Checked) {
    $cpun = 3
}
else {
    $cpun = 0
}

#################################################################################################>
#Webhook
#################################################################################################>
if ($CheckedBox.CheckedItems -contains "GMH Webhook") {
    if ($scid -eq "TOR GMH") {
        $form1113 = New-Object System.Windows.Forms.Form
        $form1113.Text = "GMH Webhook URL"
        $form1113.Size = New-Object System.Drawing.Size(500, 140)
        $form1113.StartPosition = 'CenterScreen'
        $form1113.Icon = "$dsk\AUMADS.ico"
        $form1113.font = $Font

        $okButton11111 = New-Object System.Windows.Forms.Button
        $okButton11111.Location = New-Object System.Drawing.Point(380, 70)
        $okButton11111.Size = New-Object System.Drawing.Size(75, 23)
        $okButton11111.Text = 'OK'
        $okButton11111.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form1113.AcceptButton = $okButton11111
        $form1113.Controls.Add($okButton11111)
        
        $label11111 = New-Object System.Windows.Forms.Label
        $label11111.Location = New-Object System.Drawing.Point(10, 10)
        $label11111.Size = New-Object System.Drawing.Size(280, 20)
        $label11111.Text = "Discord のWebhook URLを入力してください。"
        $form1113.Controls.Add($label11111)
        
        $textBox11111 = New-Object System.Windows.Forms.TextBox
        $textBox11111.Location = New-Object System.Drawing.Point(10, 30)
        $textBox11111.Size = New-Object System.Drawing.Size(460, 20)
        $form1113.Controls.Add($textBox11111)
        
        $form1113.Topmost = $true
        
        $form1113.Add_Shown({ $textBox11111.Select() })
        $result11111 = $form1113.ShowDialog()
        $gmhwebhooktxt = ""
        if ($result11111 -eq [System.Windows.Forms.DialogResult]::OK) {
            Write-Log $textBox11111.Text
            if ($($textBox11111.Text).StartsWith("https")) {
                $gmhwebhooktxt = $textBox11111.Text
                Write-Log "Webhook URL: $gmhwebhooktxt"
            }
            else {
                Write-Log "Webhook URLが無効、または入力されていません。Skipされます。"
                $gmhwebhooktxt = "None"
            }
        }    
    }    
}
#################################################################################################>
#ProcessorAffinity
#################################################################################################>
if ($CheckedBox.CheckedItems -contains "NOS CPU Affinity") {
    if (($scid -eq "NOS") -or ($scid -eq "NOT")) {
        $form11113 = New-Object System.Windows.Forms.Form
        $form11113.Text = "NOS CPU Affinity"
        $form11113.Size = New-Object System.Drawing.Size(400, 150)
        $form11113.StartPosition = 'CenterScreen'
        $form11113.Icon = "$dsk\AUMADS.ico"
        $form11113.font = $Font

        $okButton111111 = New-Object System.Windows.Forms.Button
        $okButton111111.Location = New-Object System.Drawing.Point(300, 80)
        $okButton111111.Size = New-Object System.Drawing.Size(75, 23)
        $okButton111111.Text = 'OK'
        $okButton111111.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form11113.AcceptButton = $okButton111111
        $form11113.Controls.Add($okButton111111)
           
        # フォームに各アイテムを入れる
        $MyGroupBox124 = New-Object System.Windows.Forms.GroupBox
        $MyGroupBox124.Location = New-Object System.Drawing.Point(10, 10)
        $MyGroupBox124.size = New-Object System.Drawing.Size(380, 60)
        $MyGroupBox124.text = $(Get-Translate("CPU Affinityの値を選択してください。"))

        # グループの中のラジオボタンを作る
        $RadioButton128 = New-Object System.Windows.Forms.RadioButton
        $RadioButton128.Location = New-Object System.Drawing.Point(10, 20)
        $RadioButton128.size = New-Object System.Drawing.Size(70, 30)
        $RadioButton128.Text = $(Get-Translate("無制限")) #0

        $RadioButton129 = New-Object System.Windows.Forms.RadioButton
        $RadioButton129.Location = New-Object System.Drawing.Point(90, 20)
        $RadioButton129.size = New-Object System.Drawing.Size(70, 30)
        $RadioButton129.Text = $(Get-Translate("2コアHT")) #1

        $RadioButton127 = New-Object System.Windows.Forms.RadioButton
        $RadioButton127.Location = New-Object System.Drawing.Point(170, 20)
        $RadioButton127.size = New-Object System.Drawing.Size(70, 30)
        $RadioButton127.Text = $(Get-Translate("2コア")) #2

        $RadioButton126 = New-Object System.Windows.Forms.RadioButton
        $RadioButton126.Location = New-Object System.Drawing.Point(250, 20)
        $RadioButton126.size = New-Object System.Drawing.Size(70, 30)
        $RadioButton126.Text = $(Get-Translate("1コア")) #3
        $RadioButton126.Checked = $True

        # グループにラジオボタンを入れる
        $MyGroupBox124.Controls.AddRange(@($Radiobutton128, $RadioButton129, $RadioButton127, $RadioButton126))
        # フォームに各アイテムを入れる
        $form11113.Controls.Add($MyGroupBox124)
        $form11113.Topmost = $true        
        $result111111 = $form11113.ShowDialog()

        $gmhwebhooktxt = ""
        if ($result111111 -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($RadioButton126.Checked) {
                #1コア
                $gmhwebhooktxt = "3"
            }
            elseif ($RadioButton127.Checked) {
                #2コア
                $gmhwebhooktxt = "2"
            }
            elseif ($RadioButton128.Checked) {
                #無制限
                $gmhwebhooktxt = "0"
            }
            elseif ($RadioButton129.Checked) {
                #2CHT
                $gmhwebhooktxt = "1"
            }
            Write-Log "CPU Affinity: $gmhwebhooktxt"
        }    
    }    
}
#################################################################################################>
#カスタムサーバー追加
#################################################################################################>
if ($CheckedBox.CheckedItems -contains "カスタムサーバー情報追加") {
    $form11130 = New-Object System.Windows.Forms.Form
    $form11130.Text = $(Get-Translate("カスタムサーバー情報追加"))
    $form11130.Size = New-Object System.Drawing.Size(500, 280)
    $form11130.StartPosition = 'CenterScreen'
    $form11130.Icon = "$dsk\AUMADS.ico"
    $form11130.font = $Font

    $okButton111110 = New-Object System.Windows.Forms.Button
    $okButton111110.Location = New-Object System.Drawing.Point(380, 200)
    $okButton111110.Size = New-Object System.Drawing.Size(75, 23)
    $okButton111110.Text = 'OK'
    $okButton111110.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form11130.AcceptButton = $okButton111110
    $form11130.Controls.Add($okButton111110)
    
    $label111110 = New-Object System.Windows.Forms.Label
    $label111110.Location = New-Object System.Drawing.Point(10, 10)
    $label111110.Size = New-Object System.Drawing.Size(320, 20)
    $label111110.Text = $(Get-Translate("追加したいカスタムサーバーの名前を入力してください。"))
    $form11130.Controls.Add($label111110)
    
    $textBox111110 = New-Object System.Windows.Forms.TextBox
    $textBox111110.Location = New-Object System.Drawing.Point(10, 30)
    $textBox111110.Size = New-Object System.Drawing.Size(460, 20)
    $form11130.Controls.Add($textBox111110)

    $label111111 = New-Object System.Windows.Forms.Label
    $label111111.Location = New-Object System.Drawing.Point(10, 60)
    $label111111.Size = New-Object System.Drawing.Size(320, 20)
    $label111111.Text = $(Get-Translate("追加したいカスタムサーバーのFQDN/IPを入力してください。"))
    $form11130.Controls.Add($label111111)
    
    $textBox111111 = New-Object System.Windows.Forms.TextBox
    $textBox111111.Location = New-Object System.Drawing.Point(10, 80)
    $textBox111111.Size = New-Object System.Drawing.Size(460, 20)
    $form11130.Controls.Add($textBox111111)  

    $label111112 = New-Object System.Windows.Forms.Label
    $label111112.Location = New-Object System.Drawing.Point(10, 110)
    $label111112.Size = New-Object System.Drawing.Size(320, 20)
    $label111112.Text = $(Get-Translate("追加したいカスタムサーバーのポートを入力してください。"))
    $form11130.Controls.Add($label111112)
    
    $textBox111112 = New-Object System.Windows.Forms.TextBox
    $textBox111112.Location = New-Object System.Drawing.Point(10, 130)
    $textBox111112.Size = New-Object System.Drawing.Size(460, 20)
    $textBox111112.Text = "22000"
    $form11130.Controls.Add($textBox111112)


    $fqcheck = $false
    $ipcheck = $false
    $namechk = $false
    $portchk = $false
    $passchk = $false
    $form11130.Topmost = $true   
    $form11130.Add_Shown({ $textBox111110.Select() })

    while (!$passchk) {
        $result111110 = $form11130.ShowDialog()
        if ($result111110 -eq [System.Windows.Forms.DialogResult]::OK) {
            $fqregex = '(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'
            if ($textBox111111.Text -match $fqregex) {
                $fqcheck = $true
            }
            $ipregex = '^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$'
            if ($textBox111111.Text -match $ipregex) {
                $ipcheck = $true
            }
            
            if ($null -eq $textBox111110.Text) {
            }
            elseif ($textBox111110.Text -eq "") {
            }
            else {
                $namechk = $true
            }
    
            if ($null -eq $textBox111112.Text) {
            }
            elseif ($textBox111112.Text -eq "") {
            }
            else {
                $portchk = $true
            }
            if (($fqcheck -or $ipcheck) -and $namechk -and $portchk) {
                $passchk = $true
            }

            $xfqip = $textBox111111.Text      
            $xname = $textBox111110.Text
            $xport = $textBox111112.Text
        }
        else {
            Write-Log "Skipped."
            $xfqip = "skip"
            $xname = "skip"
            $xport = "skip"
            break
        }
    }
}        
#################################################################################################>

# プログレスバー
$Form2 = New-Object System.Windows.Forms.Form
$Form2.Size = "500,150"
$Form2.Text = "Among Us Mod Auto Deploy Tool"
$form2.Icon = "$dsk\AUMADS.ico"
$form2.FormBorderStyle = "Fixed3D"
$Form2.Topmost = $True
$Form2.font = $Font

$form2.StartPosition = "Manual"
$form2.Left = ($wdh / 2) - ($form2.Width / 2)
$form2.Top = ($hgt / 2) + 3 * ($form2.Height / 2)

$label222 = New-Object System.Windows.Forms.Label
$label222.Location = New-Object System.Drawing.Point(10, 60)
$label222.Size = New-Object System.Drawing.Size(480, 60)
$label222.Text = $(Get-Translate("Among Us Mod $scid のDeployが進行中です。`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
$form2.Controls.Add($label222)

# プログレスバー
$Bar = New-Object System.Windows.Forms.ProgressBar
$Bar.Location = "10,20"
$Bar.Size = "460,30"
$Bar.Maximum = "100"
$Bar.Minimum = "0"
$Bar.Style = "Continuous"
$Form2.Controls.Add($Bar)
$checkgm = $true
$torgmdll
$Bar.Value = "0"
$nosdll = $false

    # Modern GUI とのプログレス同期
    if ($null -ne $script:mainWindow -and $null -eq $Args1) {
        $Bar | Add-Member -MemberType ScriptProperty -Name 'Value' -Value {
            $this.GetType().GetProperty('Value').GetValue($this)
        } -SecondValue {
            param($val)
            $this.GetType().GetProperty('Value').SetValue($this, [int]$val)
            if ($null -ne $script:ProgBar) {
                try {
                    $intVal = [int]$val
                    $script:ProgBar.Value = $intVal
                    if ($script:TxtPercent) { $script:TxtPercent.Text = "$intVal%" }
                    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)
                } catch {}
            }
        } -Force
    }

if ($tio) {

    if ($null -eq $script:mainWindow -or $null -ne $Args1) { $Form2.Show() }
    $Bar.Value = "10"
    #################################################################################################
    $web = Invoke-WebRequest $releasepage -UseBasicParsing
    $web2 = ConvertFrom-Json $web.Content
    $Bar.Value = "15"
    $torv = $torpv
    Write-Log "$scid Version $torv が選択されました"

    $Bar.Value = "20"
    $langdata
    $langd = @()
    $exfoldn
    if ($scid -eq "TOR MR") {
        for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
            if ($($web2.assets.browser_download_url[$aii]).IndexOf("MR.zip") -gt 0) {
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for ($aii = 0; $aii -lt $langd.Length; $aii++) {
            if ($($langd[$aii]).IndexOf("${torv}") -gt 0) {
                $tordlp = $langd[$aii]
            }
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
        #$tordlp = "https://github.com/miru-y/TheOtherRoles-MR/releases/download/${torv}/TheOtherRolesMR.zip"
    }
    elseif ($scid -eq "TOR") {
        $tordlp = "https://github.com/Eisbison/TheOtherRoles/releases/download/${torv}/TheOtherRoles.zip"
    }
    elseif ($scid -eq "TOU-R") {
        $tordlp = "https://github.com/eDonnes124/Town-Of-Us-R/releases/download/${torv}/ToU.${torv}.zip"
    }
    elseif ($scid -eq "SRA") {
        #ZIPが無いときに一個前のZIPあるとこまでさかのぼる必要あり
        $langd = @()
        $langz = @()
        $sradllc = $false
        $srazipc = $false

        for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
            if ($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0) {
                $langz += $web2.assets.browser_download_url[$aii]
            }
        }
        for ($aiiii = 0; $aiiii -lt $langz.Length; $aiiii++) {
            if ($($web2.tag_name[$aiiii]) -eq "$torv") {
                $srazip = $($langz[$aiiii])
                $srazipc = $true
            }
        }

        if (!$srazipc) {
            for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
                if ($($web2.assets.browser_download_url[$aii]).IndexOf(".dll") -gt 0) {
                    $langd += $web2.assets.browser_download_url[$aii]
                }
            }
            for ($aiiii = 0; $aiiii -lt $langd.Length; $aiiii++) {
                if ($($web2.tag_name[$aiiii]) -eq "$torv") {
                    $sradll = $($langd[$aiiii])
                    $sradllc = $true
                }
            }    
        }

        if ($srazipc) {
            $tordlp = $srazip
        }
        elseif ($sradllc) {
            $detzip = $true
            $temptorv = $torv
            $retryCount = 0
            while ($detzip -and ($retryCount -lt 20)) {
                $retryCount++
                if ($temptorv.Length -ge 5) {
                    if ($($temptorv.Substring($temptorv.Length - 1, 1)) -eq 0) {
                        $temptorv = "$($temptorv.Substring(0, 2))$($temptorv.Substring(2, 1)-1).9"
                    }
                    else {
                        $temptorv = "$($temptorv.Substring(0, 4))$($temptorv.Substring(4, 1)-1)"
                    }
                    for ($aiiii = 0; $aiiii -lt $langz.Length; $aiiii++) {
                        if ($($web2.tag_name[$aiiii]) -eq "$temptorv") {
                            $srazip = $($langz[$aiiii])
                            $detzip = $false
                        }
                    }
                }
                else {
                    break
                }
            }
            $tordlp = $srazip
            $sradll
        }
        else {
            Write-Log "Critical Error: File Not Found."
        }

    }
    elseif ($scid -eq "ER") {
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.zip"
        $exve = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeVoiceEngine.dll"
    }
    elseif ($scid -eq "ER+ES") {
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.with.Extreme.Skins.zip"
        $exve = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeVoiceEngine.dll"
    }
    elseif ($scid -eq "TOH") {
        $tohver = $torv.Substring(1)
        Write-Log $tohver
        if ($platform -eq "Steam") {
            for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
                if ($($web2.assets.browser_download_url[$aii]).IndexOf("${tohver}_Steam.zip") -gt 0) {
                    $langd += $web2.assets.browser_download_url[$aii]
                }
            }
            for ($aii = 0; $aii -lt $langd.Length; $aii++) {
                if ($($langd[$aii]).IndexOf("${tohver}") -gt 0) {
                    $tordlp = $langd[$aii]
                }
            }
            if ($tordlp.Indexof("${torv}_Steam.zip") -gt 0) {
                $tordlp = "https://github.com/tukasa0001/TownOfHost/releases/download/${torv}/TownOfHost-${torv}_Steam.zip"
            }
        }
        else {
            for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
                if ($($web2.assets.browser_download_url[$aii]).IndexOf("${tohver}_Epic.zip") -gt 0) {
                    $langd += $web2.assets.browser_download_url[$aii]
                }
            }
            for ($aii = 0; $aii -lt $langd.Length; $aii++) {
                if ($($langd[$aii]).IndexOf("${tohver}") -gt 0) {
                    $tordlp = $langd[$aii]
                }
            }
            if ($tordlp.Indexof("${torv}_Epic.zip") -gt 0) {
                $tordlp = "https://github.com/tukasa0001/TownOfHost/releases/download/${torv}/TownOfHost-${torv}_Epic.zip"
            }
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
    }
    elseif ($scid -eq "TOY") {
        for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
            if (($($web2.assets.browser_download_url[$aii]).IndexOf("Y-${torv}") -gt 0) -and ($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0)) {
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for ($aii = 0; $aii -lt $langd.Length; $aii++) {
            if ($($langd[$aii]).IndexOf("${torv}") -gt 0) {
                $tordlp = $langd[$aii]
            }
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
        #$tordlp = "https://github.com/Yumenopai/TownOfHost_Y/releases/download/${torv}/TownOfHost_Y.-.${torv}.zip"
    }
    elseif ($scid -eq "LM") {
        $tordlp = "https://github.com/KiraYamato94/LasMonjas/releases/download/${torv}/Las.Monjas.${torv}.zip"
    }
    elseif ($scid -eq "SNR") {
        if ($platform -eq "Steam") {
            $tordlp = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/SuperNewRoles-v${torv}_Steam.zip"
        }
        else {
            $tordlp = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/SuperNewRoles-v${torv}_Epic.zip"
        }
        #$Agartha = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/Agartha.dll"


    }
    elseif ($scid -eq "AMS") {
        $tordlp = "https://github.com/BepInEx/BepInEx/releases/download/v6.0.0-pre.1/BepInEx_UnityIL2CPP_x86_6.0.0-pre.1.zip"
        $langd = @()
        for ($aii = 0; $aii -lt $($web2.assets.browser_download_url).Length; $aii++) {
            if ($($web2.assets.browser_download_url[$aii]).IndexOf(".dll") -gt 0) {
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for ($aiiii = 0; $aiiii -lt $langd.Length; $aiiii++) {
            if ($($web2.tag_name[$aiiii]) -eq "$torv") {
                $amsdll = $($langd[$aiiii])
            }
        }
        if ($amsdll.indexof(".dll") -le 0) {
            Write-Log "Critical Error: missing dll"
            Pause
            exit
        }
    }
    elseif (($scid -eq "NOS") -or ($scid -eq "NOT")) {
        <#https://github.com/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest
        $aucap= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest" -UseBasicParsing)).assets.browser_download_url
        if($aucap[0].length -gt 1){
            for($ii = 0;$ii -lt  $aucap.Length;$ii++){
                if($($aucap[$ii]).IndexOf("Japanese.dat") -gt 0){
                    $nebulangdata = $($aucap[$ii])
                }
                if($($aucap[$ii]).IndexOf("Japanese_Color.dat") -gt 0){
                    $nebulangdatajpc = $($aucap[$ii])
                }
                if($($aucap[$ii]).IndexOf(".7z") -gt 0){
                    $nebulangdata = $($aucap[$ii])
                }
                if($($aucap[$ii]).IndexOf("Japanese.zip") -gt 0){
                    $nebulangdata = $($aucap[$ii])
                }
            }    
        }else{
            $nebulangdata = $aucap
        }
        $langdata = $nebulangdata
        #>
        
        Add-Type -AssemblyName System.Web
        $tordlptmp = @()
        $tempver = [System.Web.HttpUtility]::UrlEncode("$torv")
        $allUrls = @($web2 | ForEach-Object { $_.assets } | ForEach-Object { $_.browser_download_url })
        if ($allUrls.Count -eq 0 -and $web2.assets) {
            $allUrls = @($web2.assets.browser_download_url)
        }
        for ($aii = 0; $aii -lt $allUrls.Length; $aii++) {
            $u = $allUrls[$aii]
            if ($u -like "*.zip" -and ($u.IndexOf("$tempver") -gt 0 -or $u.IndexOf("$torv") -gt 0)) {
                $tordlptmp += $u
                $nosdll = $true
            }
        }
        if (!$nosdll -or $tordlptmp.Count -eq 0) {
            $tordlp = "https://github.com/Dolly1016/Nebula/releases/latest/download/Nebula.zip"
        }
        else {
            $targetKeyword = if ($platform -eq "Steam") { "Steam" } else { "Epic" }
            $matched = $tordlptmp | Where-Object { $_.IndexOf($targetKeyword, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 } | Select-Object -First 1
            if ($matched) {
                $tordlp = $matched
            }
            else {
                $tordlp = $tordlptmp[0]
            }
        }
        if ([string]::IsNullOrWhiteSpace($tordlp)) {
            $tordlp = "https://github.com/Dolly1016/Nebula/releases/latest/download/Nebula.zip"
        }
        Write-Log "NOS Selected Version: $torv"
        Write-Log "NOS Download URL: $tordlp"
    }
    else {
        Write-Log "Critical Error 3"
        $Form2.Close()
        pause
        exit
    }

    Write-Output $tordlp

    $Bar.Value = "23"
    $debugc = $false
    ###作成したModのExeへのショートカットをDesktopに配置する
    if ($RadioButton1.Checked) {
        $shortcut = $true
    }
    elseif ($RadioButton2.Checked) {
        $shortcut = $false 
    }
    elseif ($RadioButton42.Checked) {
        $shortcut = $true
        $debugc = $true
    }
    else {
        Write-Log "Critical Error: Shortcut"
    }
    $Bar.Value = "27"
    ###作成したModのExeへのショートカットをDesktopに配置する
    ###作成したModを即座に実行する
    #デフォルトでは実行しない
    #The Other Hatの読み込みを先に終えておきたい人向け
    if ($RadioButton3.Checked) {
        $startexewhendone = $true
    }
    elseif ($RadioButton4.Checked) {
        $startexewhendone = $false
    }
    else {
        Write-Log "Critical Error: StartCheck"
    }

    $Bar.Value = "32"

    #################################################################################################
    #処理フェイズ
    #################################################################################################

    #OriginalのAmongusをフォルダ毎コピーして新規Mod用フォルダを作成する
    if (Test-Path $aupathm) {
        ###作り直しを有効にする $trueだと有効になる。デフォルト無効
        if ($RadioButton5.Checked) {
            $retry = $true
            $ovwrite = $false
            $clean = $false
        }
        elseif ($RadioButton6.Checked) {
            $retry = $false
            $ovwrite = $false
            $clean = $false
        }
        elseif ($RadioButton7.Checked) {
            $retry = $false
            $ovwrite = $true
            $clean = $false
        }
        elseif ($RadioButton17.Checked) {
            $retry = $true
            $ovwrite = $false
            $clean = $true
        }
        else {
            Write-Log "Critical Error: Retry"
        }
        $Bar.Value = "36"

        if ($scid -eq "TOU-R") {
            if (test-path "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg") {                
                Copy-Item "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg" "C:\Temp\com.slushiegoose.townofus.cfg" -Force
            }
        }
        elseif ($scid -eq "SRA") {
            if (test-path "$aupathm\BepInEx\config\me.fluff.stellarroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.fluff.stellarroles.cfg" "C:\Temp\me.fluff.stellarroles.cfg" -Force               
                New-Item -Path "C:\Temp\StellarHats" -ItemType Directory
                Copy-Item "$aupathm\StellarHats\*" -Recurse "C:\Temp\StellarHats"
                New-Item -Path "C:\Temp\StellarVisors" -ItemType Directory
                Copy-Item "$aupathm\StellarVisors\*" -Recurse "C:\Temp\StellarVisors"
            }
        }
        elseif ($scid -eq "ER") {
            if (test-path "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" "C:\Temp\me.yukieiji.extremeroles.cfg" -Force               
            }
        }
        elseif ($scid -eq "ER+ES") {
            if (test-path "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" "C:\Temp\me.yukieiji.extremeroles.cfg" -Force               
            }
            if (test-path "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg" "C:\Temp\me.yukieiji.extremeskins.cfg" -Force               
                New-Item -Path "C:\Temp\ExtremeHat" -ItemType Directory
                Copy-Item "$aupathm\ExtremeHat\*" -Recurse "C:\Temp\ExtremeHat"
                New-Item -Path "C:\Temp\ExtremeNamePlate" -ItemType Directory
                Copy-Item "$aupathm\ExtremeNamePlate\*" -Recurse "C:\Temp\ExtremeNamePlate"
                New-Item -Path "C:\Temp\ExtremeVisor" -ItemType Directory
                Copy-Item "$aupathm\ExtremeVisor\*" -Recurse "C:\Temp\ExtremeVisor"
            }
        }
        elseif (($scid -eq "NOS") -or ($scid -eq "NOT")) {
            if (test-path "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg") {
                Copy-Item "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force               
            }
            if (test-path "$aupathm\MoreCosmic") {
                New-Item -Path "C:\Temp\MoreCosmic" -ItemType Directory
                Copy-Item "$aupathm\MoreCosmic\*" -Recurse "C:\Temp\MoreCosmic"
            }
            if (test-path "$aupathm\Addons") {
                New-Item -Path "C:\Temp\Addons" -ItemType Directory
                Copy-Item "$aupathm\Addons\*" -Recurse "C:\Temp\Addons"
            }
        }
        elseif ($scid -eq "LM") {
            if (test-path "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg" "C:\Temp\me.allul.lasmonjas.cfg" -Force
            }
        }
        elseif ($scid -eq "SNR") {
            if (test-path "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg" "C:\Temp\jp.ykundesu.supernewroles.cfg" -Force               
                New-Item -Path "C:\Temp\SuperNewRoles" -ItemType Directory
                Copy-Item "$aupathm\SuperNewRoles\*" -Recurse "C:\Temp\SuperNewRoles"
            }
        }
        elseif ($scid -eq "TOH") {
            if (test-path "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg") {
                Copy-Item "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" "C:\Temp\com.emptybottle.townofhost.cfg" -Force               
            }
            if (!(test-path "$aupathm\TOH_DATA")) {
                New-Item -Path "C:\Temp\TOH_DATA" -ItemType Directory
            }
            Copy-Item "$aupathm\TOH_DATA\*" "C:\Temp\TOH_DATA" -Force               
        }
        elseif ($scid -eq "TOY") {
            if (test-path "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg") {
                Copy-Item "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" "C:\Temp\com.emptybottle.townofhost.cfg" -Force               
            }
        }
        elseif ($scid -eq "AMS") {
            if (test-path "$aupathm\BepInEx\config\me.tomarai.aumod.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.tomarai.aumod.cfg" "C:\Temp\me.tomarai.aumod.cfg" -Force               
            }
        }
        elseif ($scid -eq "TOR MR") {
            if (test-path "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" "C:\Temp\me.eisbison.theotherroles.cfg" -Force
                New-Item -Path "C:\Temp\TheOtherHats" -ItemType Directory
                Copy-Item "$aupathm\TheOtherHats\*" -Recurse "C:\Temp\TheOtherHats"
            }
        }
        else {
            if (test-path "$aupathm\CustomPreset") {
                New-Item -Path "C:\Temp\CustomPreset" -ItemType Directory
                Copy-Item "$aupathm\CustomPreset\*" -Recurse "C:\Temp\CustomPreset"
            }

            if (test-path "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg") {
                Copy-Item "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" "C:\Temp\me.eisbison.theotherroles.cfg" -Force
                New-Item -Path "C:\Temp\TheOtherHats" -ItemType Directory
                Copy-Item "$aupathm\TheOtherHats\*" -Recurse "C:\Temp\TheOtherHats"
            }
        }
        $Bar.Value = "42"
        if ($clean -eq $true) {
            if (Test-Path "C:\Program Files (x86)\Steam\Steam.exe") {
                $rn = "steam"
                Write-Log "$rn が検知されました。"
                $stm = $true
            }

            if (Test-Path "C:\Program Files (x86)\Epic Games") {
                $rn = "epic"
                Write-Log "$rn が検知されました。"
                $epc = $true
            }
            
            if ($stm -and $epc) {
                if ($null -ne $Args1 -or ![string]::IsNullOrEmpty($DeployPlatform) -or ![string]::IsNullOrEmpty($env:TARGET_PLATFORM)) {
                    $rn = if (($DeployPlatform -ieq "epic") -or ($env:TARGET_PLATFORM -ieq "epic") -or ($script:platform -eq "epic")) { "epic" } else { "steam" }
                }
                else {
                    Write-Log $(Get-Translate("SteamとEpic両方のインストールが確認されました。ユーザーに確認します。"))
                    if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("SteamとEpic両方のインストールが確認されました。`nどちらのAmongusをクリーンインストールしますか？`nSteamの場合は「はい」を、Epicの場合は「いいえ」を押してください。")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                        $rn = "steam"
                    }
                    else {
                        $rn = "epic"
                    }                
                }
                Write-Log "$rn が選択されました。"
            }

            # 選択されたプラットフォームに合わせてパスとプラットフォーム変数を同期
            if ($rn -eq "epic") {
                $script:platform = "epic"
                $platform = "epic"
                if (!(Test-Path "$au_path_epic_org\Among Us.exe") -and (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe")) {
                    $au_path_epic_org = "C:\Program Files\Epic Games\Among Us"
                }
                $aupatho = $au_path_epic_org
                $script:aupatho = $au_path_epic_org
                Write-Log "プラットフォームを Epic に切り替えました: $aupatho"
            }
            else {
                $script:platform = "steam"
                $platform = "steam"
                $aupatho = $au_path_steam_org
                $script:aupatho = $au_path_steam_org
                Write-Log "プラットフォームを Steam に切り替えました: $aupatho"
            }

            Write-Log "クリーンインストールプロセス開始"
            if ($rn -eq "steam") {
                $fpth2 = "$npl\AmongusCleanInstall_Steam.ps1"
                if (!(Test-Path $fpth2)) {
                    Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Steam.ps1" -OutFile $fpth2 -UseBasicParsing
                }
                Unblock-File $fpth2
                $cleanProc = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -File ""$fpth2"" -Args1 `"Yes`"" -PassThru
                $cleanProc.WaitForExit()
                Write-Log "クリーンインストールプロセス終了 (ExitCode: $($cleanProc.ExitCode))"
                Start-Sleep -Seconds 5

                # 本体再配置待機 (最大600秒ポーリング)
                $waitLimitSec = 600
                $waitElapsedSec = 0
                while (!(Test-Path "$aupatho\Among Us.exe") -and ($waitElapsedSec -lt $waitLimitSec)) {
                    Start-Sleep -Seconds 5
                    $waitElapsedSec += 5
                    Write-Log "本体の配置待機中... (${waitElapsedSec}s/${waitLimitSec}s)"
                }
                if (!(Test-Path "$aupatho\Among Us.exe")) {
                    Write-Log "警告: 本体の再インストールがタイムアウトしました。"
                    if (-not $Args1) { Pause }
                }
                Remove-Item $fpth2 -Force -ErrorAction SilentlyContinue
            }
            elseif ($rn -eq "epic") {
                $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                if (!(Test-Path $fpth2)) {
                    Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1" -OutFile $fpth2 -UseBasicParsing
                }
                Unblock-File $fpth2
                $cleanProc = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2"" -Args1 `"Yes`"" -PassThru
                $cleanProc.WaitForExit()
                Write-Log "クリーンインストールプロセス終了 (ExitCode: $($cleanProc.ExitCode))"
                Start-Sleep -Seconds 5

                # 本体再配置待機 (最大600秒ポーリング)
                $waitLimitSec = 600
                $waitElapsedSec = 0
                while (!(Test-Path "$aupatho\Among Us.exe") -and ($waitElapsedSec -lt $waitLimitSec)) {
                    if (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\Among Us"
                        $script:aupatho = $aupatho
                        $au_path_epic_org = $aupatho
                        break
                    }
                    elseif (Test-Path "C:\Program Files\Epic Games\AmongUs\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\AmongUs"
                        $script:aupatho = $aupatho
                        $au_path_epic_org = $aupatho
                        break
                    }
                    Start-Sleep -Seconds 5
                    $waitElapsedSec += 5
                    Write-Log "本体の配置待機中... (${waitElapsedSec}s/${waitLimitSec}s)"
                }
                if (!(Test-Path "$aupatho\Among Us.exe")) {
                    Write-Log "警告: 本体の再インストールがタイムアウトしました。"
                    if (-not $Args1) { Pause }
                }
                Remove-Item $fpth2 -Force -ErrorAction SilentlyContinue
            }
            else {
                Write-Log "Critical Platform Selection"
                Pause
                Exit
            }
            Start-Sleep -Seconds 10
        }

        if ($retry -eq $true) {
            Write-Log "既存のフォルダを中身を含めて削除します"
            Remove-Item $aupathm -Recurse -Force
            # フォルダを中身を含めてコピーする
            if ($prebool) {
                Expand-7Zip -ArchiveFileName "$aupathb\$prefpth" -TargetPath $aupathm
                $filename = [IO.Path]::GetFileNameWithoutExtension($prefpth);
                if (Test-Path "$aupathm\depot_945361") {
                    robocopy "$aupathm\depot_945361" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\depot_945361" -recurse -Force
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }
                elseif (Test-Path "$aupathm\$filename") {
                    robocopy "$aupathm\$filename" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\$filename" -recurse -Force
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }
                elseif (Test-Path "$aupathm\Among Us") {
                    robocopy "$aupathm\Among Us" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\Among Us" -recurse -Force
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }
                elseif (Test-Path "$aupathm\AmongUs") {
                    robocopy "$aupathm\AmongUs" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\AmongUs" -recurse -Force
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }
            }
            else {
                            if ($platform -eq "epic" -or $script:platform -eq "epic") {
                if (!(Test-Path "$aupatho\Among Us.exe")) {
                    if (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\Among Us"
                        $script:aupatho = $aupatho
                    }
                    elseif (Test-Path "C:\Program Files\Epic Games\AmongUs\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\AmongUs"
                        $script:aupatho = $aupatho
                    }
                }
            }
            robocopy "$aupatho" "$aupathm" /E /MT:8 /R:1 /W:1 /NP /unilog:C:\Temp\temp.log >nul 2>&1
                if (Test-Path "C:\Temp\temp.log") {
                    $content = Get-Content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force
                }
                Write-Log "$aupatho を $aupathm にコピーしました"
            }
        }
        else {
            # コピー先のパスにファイルやフォルダが存在する場合は処理を中止
            Write-Log "$aupathm には既にファイル又はフォルダが存在します"
            if ($ovwrite) {
                Write-Log "上書き処理が選択されました"
            }
            else {
                Write-Log "処理を中止しました"
                $Form2.Close()
                pause
                Exit
            }
        }
        $Bar.Value = "48"
    }
    else {
        # フォルダを中身を含めてコピーする
        if ($prebool) {
            Expand-7Zip -ArchiveFileName "$aupathb\$prefpth" -TargetPath $aupathm
            $filename = [IO.Path]::GetFileNameWithoutExtension($prefpth);
            if (Test-Path "$aupathm\depot_945361") {
                robocopy "$aupathm\depot_945361" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\depot_945361" -recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }
            elseif (Test-Path "$aupathm\$filename") {
                robocopy "$aupathm\$filename" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\$filename" -recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }
            elseif (Test-Path "$aupathm\Among Us") {
                robocopy "$aupathm\Among Us" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\Among Us" -recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }
            elseif (Test-Path "$aupathm\AmongUs") {
                robocopy "$aupathm\AmongUs" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\AmongUs" -recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }
        }
        else {
                        if ($platform -eq "epic" -or $script:platform -eq "epic") {
                if (!(Test-Path "$aupatho\Among Us.exe")) {
                    if (Test-Path "C:\Program Files\Epic Games\Among Us\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\Among Us"
                        $script:aupatho = $aupatho
                    }
                    elseif (Test-Path "C:\Program Files\Epic Games\AmongUs\Among Us.exe") {
                        $aupatho = "C:\Program Files\Epic Games\AmongUs"
                        $script:aupatho = $aupatho
                    }
                }
            }
            robocopy "$aupatho" "$aupathm" /E /MT:8 /R:1 /W:1 /NP /unilog:C:\Temp\temp.log >nul 2>&1
            if (Test-Path "C:\Temp\temp.log") {
                $content = Get-Content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
            Write-Log "$aupatho を $aupathm にコピーしました"
        }
    }    

    $Bar.Value = "53"

    ####
    #まずはTORをDL
    Write-Log "Download ZIP 開始"
    Write-Log $tordlp
    #Invoke-WebRequest $tordlp -OutFile "$aupathm\TheOtherRoles.zip" -UseBasicParsing
    #curl.exe -L $tordlp -o "$aupathm\TheOtherRoles.zip"
    aria2c -x16 -s16 -j16 -V --dir "$aupathm" -o "TheOtherRoles.zip" $tordlp

    Write-Log "Download ZIP 完了"
    $Bar.Value = "57"

    #DLしたTORを解凍
    if (test-path "$aupathm\TheOtherRoles.zip") {
        Write-Log "ZIP Download OK"
        Write-Log "ZIP 解凍開始"
        Expand-7zip -ArchiveFileName $aupathm\TheOtherRoles.zip -TargetPath $aupathm
        Write-Log "ZIP 解凍完了"
    }
    else {
        if ($scid -eq "SRA") {
            #ZIPないパターンあり。誰も使ってないから適当でええやろ
        }
        else {
            Write-Log "ZIP Download NG $tordlp "
            Write-Log "何かがおかしい・・・。もう一度試してみてください。"
            exit                
        }
    }

    $Bar.Value = "59"

    if (test-path "$aupathm\BepInEx") {
        Write-Log "ZIP 解凍OK"
    }
    $Bar.Value = "60"

    #mini.regioninstall
    $miniri = "https://api.github.com/repos/miniduikboot/Mini.RegionInstall/releases"        
    $mweb = Invoke-WebRequest $miniri -UseBasicParsing
    $mweb2 = ConvertFrom-Json $mweb.Content   
    for ($aii = 0; $aii -lt $($mweb2.assets.browser_download_url).Length; $aii++) {
        if ($($mweb2.assets.browser_download_url[$aii]).IndexOf("Mini.RegionInstall.dll") -gt 0) {
            $mdl = $mweb2.assets.browser_download_url[$aii]
            break
        }
    }

    if (Test-Path "$aupathm\BepInEx\plugins\Mini.RegionInstall.dll") {
        Remove-item -Path "$aupathm\BepInEx\plugins\Mini.RegionInstall.dll" -Force
        Write-Log 'Delete Original Mini.RegionInstall DLL'
    }

    #LevelImposter DLLをDLして配置
    Write-Log "Download $scid Mini.RegionInstall DLL 開始"
    Write-Log $mdl
    aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "Mini.RegionInstall.dll" $mdl
    Write-Log "Download $scid Mini.RegionInstall DLL 完了"
    $regioninstalltxt = "[General]`r`nRegions = "
    #region check

    $addon2 = ""
    if ($scid -eq "TOU-R") {
        if (test-path "C:\Temp\com.slushiegoose.townofus.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.slushiegoose.townofus.cfg" "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg" -Force
            Remove-Item "C:\Temp\com.slushiegoose.townofus.cfg" -Force    
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded NA (MNA)","PingServer": "https://www.aumods.us","Servers": [{"Name": "Http-1","Ip": "https://www.aumods.us","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003},{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded EU (MEU)","PingServer": "https://au-eu.duikbo.at","Servers": [{"Name": "Http-1","Ip": "https://au-eu.duikbo.at","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003},{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded Asia (MAS)","PingServer": "https://au-as.duikbo.at","Servers": [{"Name": "Http-1","Ip": "https://au-as.duikbo.at","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003}]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>'
        $regioninstalltxt += "`r`n"
    }
    elseif ($scid -eq "SRA") {
        if (test-path "C:\Temp\me.fluff.stellarroles.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.fluff.stellarroles.cfg" "$aupathm\BepInEx\config\me.fluff.stellarroles.cfg" -Force
            Remove-Item "C:\Temp\me.fluff.stellarroles.cfg" -Force    
        }
        if (test-path "C:\Temp\StellarHats") {
            if (!(Test-Path "$aupathm\StellarHats")) {
                New-Item -Path "$aupathm\StellarHats" -ItemType Directory
            }
            if (!(Test-Path "$aupathm\StellarVisors")) {
                New-Item -Path "$aupathm\StellarVisors" -ItemType Directory
            }
            robocopy "C:\Temp\StellarHats" "$aupathm\StellarHats" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\StellarHats" -Recurse -Force
            robocopy "C:\Temp\StellarVisors" "$aupathm\StellarVisors" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\StellarVisors" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    elseif ($scid -eq "ER") {
        if (test-path "C:\Temp\me.yukieiji.extremeroles.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeroles.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeroles.cfg" -Force    
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"
    }
    elseif ($scid -eq "ER+ES") {
        if (test-path "C:\Temp\me.yukieiji.extremeroles.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeroles.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeroles.cfg" -Force    
        }
        if (test-path "C:\Temp\me.yukieiji.extremeskins.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeskins.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeskins.cfg" -Force    
        }
        if (test-path "C:\Temp\ExtremeHat") {
            if (!(Test-Path "$aupathm\ExtremeHat")) {
                New-Item -Path "$aupathm\ExtremeHat" -ItemType Directory
            }
            if (!(Test-Path "$aupathm\ExtremeNamePlate")) {
                New-Item -Path "$aupathm\ExtremeNamePlate" -ItemType Directory
            }
            if (!(Test-Path "$aupathm\ExtremeVisor")) {
                New-Item -Path "$aupathm\ExtremeVisor" -ItemType Directory
            }
            robocopy "C:\Temp\ExtremeHat" "$aupathm\ExtremeHat" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\ExtremeHat" -Recurse -Force
            robocopy "C:\Temp\ExtremeNamePlate" "$aupathm\ExtremeNamePlate" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\ExtremeNamePlate" -Recurse -Force
            robocopy "C:\Temp\ExtremeVisor" "$aupathm\ExtremeVisor" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\ExtremeVisor" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    elseif (($scid -eq "NOS") -or ($scid -eq "NOT")) {
        if (test-path "C:\Temp\jp.dreamingpig.amongus.nebula.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" -Force
            Remove-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force    
        }
        if (test-path "C:\Temp\MoreCosmic") {
            if (!(Test-Path "$aupathm\MoreCosmic")) {
                New-Item -Path "$aupathm\MoreCosmic" -ItemType Directory
            }    
            robocopy "C:\Temp\MoreCosmic" "$aupathm\MoreCosmic" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\MoreCosmic" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if (test-path "C:\Temp\Addons") {
            if (!(Test-Path "$aupathm\Addons")) {
                New-Item -Path "$aupathm\Addons" -ItemType Directory
            }    
            robocopy "C:\Temp\Addons" "$aupathm\Addons" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\Addons" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Nebula","PingServer":"cs.supernewroles.com","Servers":[{"Name":"http-1","Ip":"http://168.138.44.249","Port":22023,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":1003}]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"
        
    }
    elseif ($scid -eq "LM") {
        if (test-path "C:\Temp\me.allul.lasmonjas.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.allul.lasmonjas.cfg" "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg" -Force
            Remove-Item "C:\Temp\me.allul.lasmonjas.cfg" -Force    
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    elseif ($scid -eq "TOH") {
        if (test-path "C:\Temp\com.emptybottle.townofhost.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.emptybottle.townofhost.cfg" "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" -Force
            Remove-Item "C:\Temp\com.emptybottle.townofhost.cfg" -Force    
        }
        if (test-path "C:\Temp\TOH_DATA") {
            if (!(test-path "$aupathm\TOH_DATA\")) {
                New-Item -Path "$aupathm\TOH_DATA\" -ItemType Directory
            }
            Copy-Item "C:\Temp\TOH_DATA\*" "$aupathm\TOH_DATA" -Force               
            Remove-Item "C:\Temp\TOH_DATA" -Recurse -Force    
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    elseif ($scid -eq "TOY") {
        if (test-path "C:\Temp\com.emptybottle.townofhost.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.emptybottle.townofhost.cfg" "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" -Force
            Remove-Item "C:\Temp\com.emptybottle.townofhost.cfg" -Force    
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    elseif ($scid -eq "SNR") {
        if (test-path "C:\Temp\jp.ykundesu.supernewroles.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.ykundesu.supernewroles.cfg" "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg" -Force
            Remove-Item "C:\Temp\jp.ykundesu.supernewroles.cfg" -Force    
            if (!(Test-Path "$aupathm\SuperNewRoles")) {
                New-Item -Path "$aupathm\SuperNewRoles" -ItemType Directory
            }
            if (test-path "C:\Temp\SuperNewRoles") {
                robocopy "C:\Temp\SuperNewRoles" "$aupathm\SuperNewRoles" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "C:\Temp\SuperNewRoles" -Recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)'
        $regioninstalltxt += "`r`n"        
    }
    else {
        if (test-path "C:\Temp\me.eisbison.theotherroles.cfg") {
            if (!(test-path "$aupathm\BepInEx\config")) {
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.eisbison.theotherroles.cfg" "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" -Force
            Remove-Item "C:\Temp\me.eisbison.theotherroles.cfg" -Force    
        }
        if (test-path "C:\Temp\TheOtherHats") {
            if (!(Test-Path "$aupathm\TheOtherHats")) {
                New-Item -Path "$aupathm\TheOtherHats" -ItemType Directory
            }
            robocopy "C:\Temp\TheOtherHats" "$aupathm\TheOtherHats" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\TheOtherHats" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        $regioninstalltxt += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
        $regioninstalltxt += "`r`nRemoveRegions = "
        $regioninstalltxt += 'haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=\"center\">Tokyo</align>'
        $regioninstalltxt += "`r`n"        
    }
    $Bar.Value = "64"
    #regioninstall config make
    if (Test-Path "$aupathm\BepInEx\config\at.duikbo.regioninstall.cfg") {
        Copy-Item "$aupathm\BepInEx\config\at.duikbo.regioninstall.cfg" "$aupathm\BepInEx\config\at.duikbo.regioninstall.cfg.old" -Force
        Remove-Item "$aupathm\BepInEx\config\at.duikbo.regioninstall.cfg" -Force
    }
    if (!(test-path "$aupathm\BepInEx\config")) {
        New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
    }
    $regioninstalltxt | Out-File -Encoding "UTF8" -FilePath "$aupathm\BepInEx\config\at.duikbo.regioninstall.cfg" 
    
    $Bar.Value = "69"

    if ($scid -eq "TOR GMH") {
        if (test-path "$aupathm\TheOtherRoles-GM-Haoming.$torv") {
            robocopy "$aupathm\TheOtherRoles-GM-Haoming.$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles-GM-Haoming.$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if ($checkgm) {
            #Mod Original DLL削除
            Remove-item -Path "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll"
            Write-Log 'Delete Original Mod DLL'
            Write-Log $torgmdll
            #TOR+ DLLをDLして配置
            Write-Log "Download $scid DLL 開始"
            aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "TheOtherRolesGM.dll" $torgmdll
            Write-Log "Download $scid DLL 完了"
        }
    }
    elseif ($scid -eq "TOR GMT") {
        if (test-path "$aupathm\TheOtherRoles-GM-Haoming.$torv") {
            robocopy "$aupathm\TheOtherRoles-GM-Haoming.$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles-GM-Haoming.$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        #Mod Original DLL削除
        Remove-item -Path "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll"
        Write-Log 'Delete Original Mod DLL'
        Write-Log $torgmdll
        #TOR+ DLLをDLして配置
        Write-Log "Download $scid DLL 開始"
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "TheOtherRolesGM.dll" $torgmdll
        Write-Log "Download $scid DLL 完了"
    }
    elseif ($scid -eq "TOU-R") {
        if (test-path "$aupathm\ToU $torv") {
            robocopy "$aupathm\ToU $torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ToU $torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "SRA") { 
        if (test-path "$aupathm\StellarRoles") {
            robocopy "$aupathm\StellarRoles" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\StellarRoles" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        #Latest DLL DL and replace.
        if (!$srazipc) {
            #Mod Original DLL削除
            Remove-item -Path "$aupathm\BepInEx\plugins\StellarRoles.dll"
            Write-Log 'Delete Original Mod DLL'
            Write-Log $torgmdll
            #TOR+ DLLをDLして配置
            Write-Log "Download $scid DLL 開始"
            aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "StellarRoles.dll" $sradll
            Write-Log "Download $scid DLL 完了"
        }
    }
    elseif ($scid -eq "TOR") {
        if (test-path "$aupathm\TheOtherRoles") {
            robocopy "$aupathm\TheOtherRoles" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "TOR MR") {
        if (test-path "$aupathm\$exfoldn") {
        }
        elseif (test-path "$aupathm\TheOtherRoles MR") {
            $exfoldn = "TheOtherRoles MR"
        }
        else {
            $exfoldn2 = $exfoldn.Replace('.', ' ')
            if (Test-Path "$aupathm\$exfoldn2") {
                $exfoldn = $exfoldn2
            }
        }
        if (test-path "$aupathm\$exfoldn") {
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "ER") {
        if (test-path "$aupathm\ExtremeRoles-$torv") {
            robocopy "$aupathm\ExtremeRoles-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ExtremeRoles-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        #ExVE DLLをDLして配置
        Write-Log "Download $scid Extreme Voice Engine DLL 開始"
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "ExtremeVoiceEngine.dll" $exve
        Write-Log "Download $scid Extreme Voice Engine DLL 完了"                 
    }
    elseif ($scid -eq "ER+ES") {
        if (test-path "$aupathm\ExtremeRoles-$torv") {
            robocopy "$aupathm\ExtremeRoles-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ExtremeRoles-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        #ExVE DLLをDLして配置
        Write-Log "Download $scid Extreme Voice Engine DLL 開始"
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "ExtremeVoiceEngine.dll" $exve
        Write-Log "Download $scid Extreme Voice Engine DLL 完了"                 
    }
    elseif ($scid -eq "LM") {
        if (test-path "$aupathm\Las Monjas $torv") {
            robocopy "$aupathm\Las Monjas $torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Las Monjas $torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "TOY") {
        if (test-path "$aupathm\$exfoldn") {
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "TOH") {
        if (test-path "$aupathm\TownOfHost-$torv") {
            robocopy "$aupathm\TownOfHost-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TownOfHost-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        elseif (test-path "$aupathm\$exfoldn") {
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    elseif ($scid -eq "SNR") {
        if (test-path "$aupathm\SuperNewRoles-v$torv") {
            robocopy "$aupathm\SuperNewRoles-v$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\SuperNewRoles-v$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if (Test-Path "$aupathm\BepInEx\plugins\Agartha.dll") {
            Remove-item -Path "$aupathm\BepInEx\plugins\Agartha.dll"
            Write-Log 'Delete Original Agartha Mod DLL'
        }
        #Agartha DLLをDLして配置
        #Write-Log "Download $scid Agartha DLL 開始"
        #aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "Agartha.dll" $Agartha
        #Write-Log "Download $scid Agartha DLL 完了"         

    }
    elseif ($scid -eq "AMS") {
        if (test-path "$aupathm\BepInEx") {
            if (Test-Path "$aupathm\BepInEx\plugins\AUModS.dll") {
                Remove-item -Path "$aupathm\BepInEx\plugins\AUModS.dll"
                Write-Log 'Delete Original AUModS Mod DLL'
            }
            #AUModS DLLをDLして配置
            if (!(Test-Path "$aupathm\BepInEx\plugins")) {
                New-Item "$aupathm\BepInEx\plugins" -ItemType Directory 
            }
            Write-Log $amsdll
            Write-Log "Download $scid AUModS DLL 開始"
            aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "AUModS.dll" $amsdll
            Write-Log "Download $scid AUModS DLL 完了"    
        }
    }
    elseif (($scid -eq "NOS") -or ($scid -eq "NOT")) {
        if (test-path "$aupathm\Nebula") {
            robocopy "$aupathm\Nebula" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Nebula" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if (!(Test-Path "$aupathm\Addons\")) {
            New-Item "$aupathm\Addons\" -Type Directory
        }
        Write-Log "日本語 データ Download 開始"
        Write-Log "日本語 データ $langdata"
        if (Test-Path "$aupathm\Addons\Localization_the_Nebula.zip") {
            Remove-Item "$aupathm\Addons\Localization_the_Nebula.zip" -Force
        }
        if (Test-Path "$aupathm\Addons\Colors_from_SNR.zip") {
            Remove-Item "$aupathm\Addons\Colors_from_SNR.zip" -Force
        }
        if (Test-Path "$aupathm\Addons\Ninja.zip") {
            Remove-Item "$aupathm\Addons\Ninja.zip" -Force
        }
        if (Test-Path "$aupathm\Addons\SchrodingersCat.zip") {
            Remove-Item "$aupathm\Addons\SchrodingersCat.zip" -Force
        }
        if (Test-Path "$aupathm\Addons\mdngus01.zip") {
            Remove-Item "$aupathm\Addons\mdngus01.zip" -Force
        }




        $addonpage = "https://api.github.com/repos/Maximilian2022/Nebula-in-the-library/releases/latest"
        $addon = Invoke-WebRequest $addonpage -UseBasicParsing
        $addon2 = ConvertFrom-Json $addon.Content
        #v2.11
        $langdata = ($addon2.assets.browser_download_url | Select-String "Localization_the_Nebula").ToString()
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "Localization_the_Nebula.zip" $langdata --allow-overwrite=true 
        $cfsnr = ($addon2.assets.browser_download_url | Select-String "Colors_from_SNR").ToString()
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "Colors_from_SNR.zip" $cfsnr --allow-overwrite=true 
        Write-Log "日本語 データ Download 完了"

        $mdnpage = "https://api.github.com/repos/Mido-otosae/Midohat-For-Nos/releases/latest"
        $mdn = Invoke-WebRequest $mdnpage -UseBasicParsing
        $mdn2 = ConvertFrom-Json $mdn.Content
        $mdnr = ($mdn2.assets.browser_download_url | Select-String ".zip").ToString()
        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "mdngus01.zip" $mdnr --allow-overwrite=true 
        Write-Log "Midohat Download 完了"

    }
    else {
    }
    $Bar.Value = "71"

    #解凍チェック
    if (test-path "$aupathm\BepInEx\plugins") {
        Write-Log "ZIP 解凍OK"
        BackupMod
        Remove-item -Path "$aupathm\TheOtherRoles.zip"
        Write-Log "DLしたZIPを削除"
    }
    else {
        Write-Log "ZIP 解凍NG"
    }
    $Bar.Value = "77"

    if ($shortcut -eq $true) {
        ##Desktopにショートカットを配置する
        $scpath = [System.Environment]::GetFolderPath("Desktop")

        if (test-path "$scpath\Among Us Mod $scid.lnk") {
            Remove-item -Path "$scpath\Among Us Mod $scid.lnk"
            Write-Log '既存のMod用Shortcut削除'
        }
        $Bar.Value = "79"

        # ショートカットを作る
        $WsShell = New-Object -ComObject WScript.Shell
        $sShortcut = $WsShell.CreateShortcut("$scpath\Among Us Mod $scid.lnk")

        $scid2 = $scid.replace(" ", "_")

        if ($debugc) {
            if (Test-Path $aupathb) {
                if (($platform -ne "Steam") -and ($platform -ne "Epic")) {
                    if ([System.Windows.Forms.MessageBox]::Show("PlatformはSteamですか?", "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                        $platform = "Steam"
                    }
                    else {
                        $platform = "Epic"
                    }
                }
                if (test-path "C:\temp\gmhtechsupport.ps1") {
                    Remove-Item "C:\temp\gmhtechsupport.ps1" -Force
                }
                if (test-path "C:\temp\amongusrun_$scid2.ps1") {
                    Remove-Item "C:\temp\amongusrun_$scid2.ps1" -Force 
                }
                if (test-path "C:\temp\startamongusrun_$scid2.bat") {
                    Remove-Item "C:\temp\startamongusrun_$scid2.bat" -Force
                }
                if (test-path "$dsk\gmhtechsupport.ps1") {
                    Remove-Item "$dsk\gmhtechsupport.ps1" -Force
                }
                if (test-path "$dsk\amongusrun_$scid2.ps1") {
                    Remove-Item "$dsk\amongusrun_$scid2.ps1" -Force
                }
                if (test-path "$dsk\startamongusrun_$scid2.bat") {
                    Remove-Item "$dsk\startamongusrun_$scid2.bat" -Force
                }
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1" -OutFile "$dsk\gmhtechsupport.ps1" -UseBasicParsing
                $batscript = "chcp 65001 `r`n"
                $batscript += "@echo off `r`n"
                $batscript += "powershell -NoProfile -ExecutionPolicy Unrestricted -File `"$dsk\amongusrun_$scid2.ps1`" `r`n"
                $batscript += "exit"
                $batscript | Out-File -Encoding default -FilePath "$dsk\startamongusrun_$scid2.bat" 
                $ps1script = '$platform="'
                $ps1script += "$platform`"`r`n"
                $ps1script += '$aupathb="'
                $ps1script += "$aupathb`"`r`n"
                $ps1script += '$aupathm="'
                $ps1script += "$aupathm`"`r`n"
                $ps1script += '$scid="'
                $ps1script += "$scid`"`r`n"
                $ps1name = "$dsk\amongusrun_$scid2.ps1"
                $ps1script += '
                #################################################################################################
                # Run w/ Powershell v7 if available.
                #################################################################################################
                $npl = Get-Location
                $v5run = $false
                if($PSVersionTable.PSVersion.major -eq 5){
                    if(test-path "$env:ProgramFiles\PowerShell\7"){
                        pwsh.exe -NoProfile -ExecutionPolicy Unrestricted '
                $ps1script += "$ps1name"
                $ps1script += '
                    }else{
                        $v5run = $true
                        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                            Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted -File `'
                $ps1script += "$ps1name"
                $ps1script += '`"" -Verb RunAs -Wait
                            exit
                        }
                    }
                }elseif($PSVersionTable.PSVersion.major -gt 5){
                    $v5run = $true
                    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -WindowStyle Minimized -ExecutionPolicy Unrestricted -File `'
                $ps1script += "$ps1name"
                $ps1script += '`"" -Verb RunAs -Wait
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
                # Translate Function
                #################################################################################################
                $Cult  = Get-Culture
                function Get-Translate($transtext){
                    if($Cult -ne "ja-JP"){
                        $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($Cult)&dt=t&q=$transtext"
                        $Response = (Invoke-WebRequest -Uri $Uri -Method Get).Content
                        $Resulttxt = $Response -split '
                $ps1script += "'"
                $ps1script += '\\r\\n'
                $ps1script += "'"
                $ps1script += ' -replace'
                $ps1script += "'"
                $ps1script += ' ^(","?)|(null.*?\[")|\[{3}"'
                $ps1script += "'"
                $ps1script += ' -split '
                $ps1script += "'"
                $ps1script += '","'
                $ps1script += "'"
                $ps1script += "
                        return `$Resulttxt[0]
                    }else{
                        return `$transtext
                    }
                }
                if(`$platform -eq `"Steam`"){
                    Start-Process `"`$aupathm\Among Us.exe`"
                }elseif(`$platform -eq `"Epic`"){
                    legendary.exe auth --import 
                    legendary.exe launch Among Us
                }else{
                    Write-Output `"ERROR:Critical run apps`"
                }
                Start-Sleep -Seconds 2
                Write-Output `"`r`nAmong Us 本体の起動中です。本体が終了するまでこのまま放置してください。`r`n`"
                `$procName = `"Among Us`"
                `$execPath = `"`$aupathm\Among Us.exe`"
                `$checkpro = `$true
                `$tsp = &`"$dsk\gmhtechsupport.ps1`" `"`$scid`" `"`$aupathm`" `"`$platform`" |Select-Object -Last 1
                Write-Output `"Game Start:`$tsp`"
                while(`$checkpro){
                    try{
                        `$p = Get-Process `$procName -ErrorAction SilentlyContinue
                        `$p.WaitForExit()
                    }
                    catch{
                        Write-Output `"No Process`"
                    }
                    finally{
                        `$tsp = &`"$dsk\gmhtechsupport.ps1`" `"`$scid`" `"`$aupathm`" `"`$platform`" |Select-Object -Last 1
                        `$erchk = Get-content `"`$tsp`" -Raw
                        Write-Output `"Game Exit:`$tsp`"
                        if(`$erchk.LastIndexOf(`"error`") -gt 0){
                            Write-Output `"Done.`"
                        }else{
                            Write-Output `"No Error founds.`"
                        }
                        `$checkpro = `$false
                    }
                }"
                $ps1script | Out-File -Encoding "UTF8BOM" -FilePath "$dsk\amongusrun_$scid2.ps1" 
            }
            else {
                Write-Log "Something Wrong. Check Path."
            }
            $sShortcut.TargetPath = "$dsk\startamongusrun_$scid2.bat"
        }
        else {
            if ($platform -eq "Steam") {
                if ($cpun -eq 1) {
                    $sShortcut.TargetPath = "pwsh.exe"
                    $sShortcut.Arguments = "-WindowStyle Hidden -Command `"Start-Process `'$aupathm\Among Us.exe`' && Start-Sleep -seconds 5 && Get-Process -Name 'Among Us' | % { `$_.ProcessorAffinity=1;}`""
                }
                elseif ($cpun -eq 3) {
                    $sShortcut.TargetPath = "pwsh.exe"
                    $sShortcut.Arguments = "-WindowStyle Hidden -Command `"Start-Process `'$aupathm\Among Us.exe`' && Start-Sleep -seconds 5 && Get-Process -Name 'Among Us' | % { `$_.ProcessorAffinity=3;}`""
                }
                else {
                    $sShortcut.TargetPath = "$aupathm\Among Us.exe"
                }
                $sShortcut.WorkingDirectory = $aupathm
            }
            elseif ($platform -eq "Epic") {
                $sShortcut.TargetPath = "pwsh.exe"
                if ($cpun -eq 1) {
                    $batscript = "chcp 65001 `r`n"
                    $batscript += "@echo off `r`n"
                    $batscript += "powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Unrestricted -File `"$dsk\amongusrun_$scid2.ps1`" `r`n"
                    $batscript += "exit"
                    $batscript | Out-File -Encoding default -FilePath "$dsk\startamongusrun_$scid2.bat" 
                    #$ps1script = "legendary auth --import && legendary -y uninstall Among Us --keep-files  && legendary -y import 'Among Us' '$aupathm' && legendary -y egl-sync && legendary launch Among Us && Start-sleep -seconds 5 && Get-Process -Name 'Among Us' | % { $_.ProcessorAffinity=1;}"
                    $ps1script = "if ((!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`"Administrators`")) -or (`$(`$PSVersionTable.PSVersion.Major) -ne `"7`")) {`r`n"
                    $ps1script += "Start-Process pwsh.exe -ArgumentList `"-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File ```"$dsk\amongusrun_$scid2.ps1```"`" -Verb RunAs -Wait`r`n"
                    $ps1script += "exit`r`n}`r`n"
                    $ps1script += "legendary auth --import;`r`n legendary -y uninstall Among Us --keep-files;`r`n legendary -y import 'Among Us' 'C:\Program Files\Epic Games\AmongUs $scid2 Mod';`r`n legendary -y egl-sync;`r`n legendary launch Among Us;`r`n Start-sleep -seconds 30;`r`n Get-Process -Name 'Among Us' | % {`$_.ProcessorAffinity=1;}`r`n"
                    $ps1name = "$dsk\amongusrun_$scid2.ps1"
                    $ps1script | Out-File -Encoding "UTF8BOM" -FilePath "$ps1name" 
                    $sShortcut.Arguments = "-Command Start-Process '$dsk\startamongusrun_$scid2.bat'"
                }
                elseif ($cpun -eq 3) {
                    $batscript = "chcp 65001 `r`n"
                    $batscript += "@echo off `r`n"
                    $batscript += "powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Unrestricted -File `"$dsk\amongusrun_$scid2.ps1`" `r`n"
                    $batscript += "exit"
                    $batscript | Out-File -Encoding default -FilePath "$dsk\startamongusrun_$scid2.bat" 
                    #$ps1script = "legendary auth --import && legendary -y uninstall Among Us --keep-files  && legendary -y import 'Among Us' '$aupathm' && legendary -y egl-sync && legendary launch Among Us && Start-sleep -seconds 5 && Get-Process -Name 'Among Us' | % { $_.ProcessorAffinity=3;}"
                    $ps1script = "if ((!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`"Administrators`")) -or (`$(`$PSVersionTable.PSVersion.Major) -ne `"7`")) {`r`n"
                    $ps1script += "Start-Process pwsh.exe -ArgumentList `"-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File ```"$dsk\amongusrun_$scid2.ps1```"`" -Verb RunAs -Wait`r`n"
                    $ps1script += "exit`r`n}`r`n"
                    $ps1script += "legendary auth --import;`r`n legendary -y uninstall Among Us --keep-files ;`r`n legendary -y import 'Among Us' 'C:\Program Files\Epic Games\AmongUs $scid2 Mod' ;`r`n legendary -y egl-sync ;`r`n legendary launch Among Us ;`r`n Start-sleep -seconds 30 ;`r`n Get-Process -Name 'Among Us' | % {`$_.ProcessorAffinity=3;}`r`n"
                    $ps1name = "$dsk\amongusrun_$scid2.ps1"
                    $ps1script | Out-File -Encoding "UTF8BOM" -FilePath "$ps1name" 
                    $sShortcut.Arguments = "-Command Start-Process '$dsk\startamongusrun_$scid2.bat'"
                }
                else {
                    $sShortcut.Arguments = "-WindowStyle Hidden -Command `"legendary auth --import && legendary -y uninstall Among Us --keep-files  && legendary -y import 'Among Us' '$aupathm' && legendary -y egl-sync && legendary launch Among Us`""
                }
                $sShortcut.WorkingDirectory = $aupathm
            }
            else {
                Write-Log "ERROR: Critical Shortcut"
            }                
        }

        $sShortcut.IconLocation = "$aupathm\Among Us.exe"
        $sShortcut.Save()
        if ($platform -eq "Epic") {
            $bytes = [System.IO.File]::ReadAllBytes("$scpath\Among Us Mod $scid.lnk")
            $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
            [System.IO.File]::WriteAllBytes("$scpath\Among Us Mod $scid.lnk", $bytes)    
        }

        $aupathb

        if (test-path "$scpath\Among Us Mod $scid.lnk") {
            Write-Log "Shortcut 作成確認OK"
        }
        else {
            Write-Log "Shortcut 作成失敗"
        }
    }
    else {
        $here = Get-Location
        Set-Location -Path $aupathm
        Invoke-Item .
        Set-Location -Path $here
    }
}

$Bar.Value = "80"

if ($tio -eq $false) {
    if ($null -eq $script:mainWindow -or $null -ne $Args1) { $Form2.Show() }
}
$Bar.Value = "82"

#reorder checkeditems
$ckbci = @()
$tempoitems = @()
$kenkoitems = @()
$ckbci2 = @()
$tempoitems2 = @()
$kenkoitems2 = @()
for ($aa = 0; $aa -lt $CheckedBox.CheckedItems.Count; $aa++) {
    if ($CheckedBox.CheckedItems[$aa] -eq "健康ランド") {
        $kenkoitems2 += $CheckedBox.CheckedItems[$aa]
    }
    else {
        $tempoitems2 += $CheckedBox.CheckedItems[$aa]
    }
}
$ckbci2 = $kenkoitems2 + $tempoitems2
for ($aa = 0; $aa -lt $ckbci2.Count; $aa++) {
    if ($ckbci2[$aa] -eq "サーバー情報初期化") {
        $kenkoitems += $ckbci2[$aa]
    }
    else {
        $tempoitems += $ckbci2[$aa]
    }
}
$ckbci = $kenkoitems + $tempoitems

Write-Log $ckbci

if ($ckbci.Count -gt 0) {
    for ($aa = 0; $aa -lt $ckbci.Count; $aa++) {
        if ($ckbci[$aa] -eq "BetterCrewLink") {
            Write-Log "BCL Install Start"
            $bcl = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/OhMyGuus/BetterCrewLink/releases/latest" -UseBasicParsing)).assets.browser_download_url
            for ($ab = 0; $ab -lt $bcl.Length; $ab++) {
                if ($bcl[$ab] -match ".exe") {
                    if ($bcl[$ab] -match ".exe.") {
                    }
                    else {
                        $bcldlp = $bcl[$ab]
                    }
                }
            }
            $md = [System.Environment]::GetFolderPath("MyDocuments")
            $bclfile = split-path $bcldlp -Leaf
            Invoke-WebRequest $bcldlp -OutFile "$md\$bclfile" -UseBasicParsing
            Start-Process "$md\$bclfile" -wait
            Write-Log "BCL Install Done"
            Remove-Item $md\$bclfile -Force
            $Bar.Value = "83"
        }
        elseif ($ckbci[$aa] -eq "AmongUsReplayInWindow") {
            $qureq = $true
            if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802) {
            }
            else {
                if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("必要な.Net 5 Frameworkがインストールされていません。インストールしますか？")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                    try {
                        choco -v
                    }
                    catch {
                        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                    }
        
                    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet -y" -Verb RunAs -Wait        
                }
                else {
                    Write-Log "AmongUsReplayInWindowの処理を中止します"
                    $qureq = $false
                }    

            }
            if ($qureq) {
                $auriw = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/sawa90/AmongUsReplayInWindow/releases/latest" -UseBasicParsing)).assets.browser_download_url
                $auriwfile = split-path $auriw -Leaf 
                $auriwfn = $auriwfile.Substring(0, $auriwfile.LastIndexOf('.'))
                $md = [System.Environment]::GetFolderPath("MyDocuments")
                $aurcheck = $true
                if (Test-Path $md\$auriwfn) {
                    if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("既に存在するようです。上書き展開しますか？")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                        $aurcheck = $true
                    }
                    else {
                        $aurcheck = $false
                    }
                }
                if ($aurcheck) {
                    aria2c -x16 -s16 -j16 -V --allow-overwrite=true --dir "$md" -o "$auriwfile" $auriw
                    #Invoke-WebRequest $auriw -OutFile "$md\$auriwfile" -UseBasicParsing
                    Expand-7zip -ArchiveFileName $md\$auriwfile -TargetPath $md\$auriwfn
                    Remove-Item $md\$auriwfile -Force
                    Set-Location -Path $md\$auriwfn
                    Invoke-Item .
                }
                else {
                    Write-Log "AmongUsReplayInWindowの処理を中止します"
                }
            }
            $Bar.Value = "84"
        }
        elseif ($ckbci[$aa] -eq "AmongUsCapture") {
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet -y" -Verb RunAs -Wait   
            $aucap = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/automuteus/amonguscapture/releases/latest" -UseBasicParsing)).assets.browser_download_url
            $aucapfile = split-path $aucap[0] -Leaf 
            $aucapfn = $aucapfile.Substring(0, $aucapfile.LastIndexOf('.'))
            $md = [System.Environment]::GetFolderPath("MyDocuments")
            $aucapcheck = $true
            if (Test-Path $md\$aucapfn) {
                if ([System.Windows.Forms.MessageBox]::Show($(Get-Translate("既に存在するようです。上書き展開しますか？")), "Among Us Mod Auto Deploy Tool", 4) -eq "Yes") {
                    $aucapcheck = $true
                }
                else {
                    $aucapcheck = $false
                }
            }
            if ($aucapcheck) {
                #Invoke-WebRequest $aucap[0] -OutFile "$md\$aucapfile" -UseBasicParsing
                aria2c -x16 -s16 -j16 -V --allow-overwrite=true --dir "$md" -o "$aucapfile" $aucap[0]                
                Expand-7Zip -ArchiveFileName $md\$aucapfile -TargetPath $md\$aucapfn
                Remove-Item $md\$aucapfile -Force
                Set-Location -Path $md\$aucapfn
                Invoke-Item .
            }
            else {
                Write-Log "AmongUsCaptureの処理を中止します"
            }
            if (Test-Path "$md\$aucapfn\AmongUsCapture.exe") {
                $scpath = [System.Environment]::GetFolderPath("Desktop")
                $WsShell = New-Object -ComObject WScript.Shell
                $sShortcut = $WsShell.CreateShortcut("$scpath\AmongUsCapture.lnk")
                $sShortcut.TargetPath = "$md\$aucapfn\AmongUsCapture.exe"
                $sShortcut.IconLocation = "$md\$aucapfn\AmongUsCapture.exe"
                $sShortcut.Save()
            }
            $Bar.Value = "85"
        }
        elseif ($ckbci[$aa] -eq "LevelImposter") {
            if (($scid -eq "IUS") -or ($scid -eq "TIO")) {
                Write-Log "$scid では LevelImposterは入りません"
            }
            else {
                try {
                    choco -v
                }
                catch {
                    Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                }
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet-9.0-desktopruntime dotnet -y" -Verb RunAs -Wait   
    
                $snL = "https://api.github.com/repos/DigiWorm0/LevelImposter/releases"        
                $sweb = Invoke-WebRequest $snL -UseBasicParsing
                $sweb2 = ConvertFrom-Json $sweb.Content   
                for ($aii = 0; $aii -lt $($sweb2.assets.browser_download_url).Length; $aii++) {
                    if ($($sweb2.assets.browser_download_url[$aii]).IndexOf("LevelImposter.dll") -gt 0) {
                        $snLevel = $sweb2.assets.browser_download_url[$aii]
                        break
                    }
                }
        
                $snRe = "https://api.github.com/repos/NuclearPowered/Reactor/releases"        
                $snweb = Invoke-WebRequest $snRe -UseBasicParsing
                $snweb2 = ConvertFrom-Json $snweb.Content   
                for ($aii = 0; $aii -lt $($snweb2.assets.browser_download_url).Length; $aii++) {
                    if ($($snweb2.assets.browser_download_url[$aii]).IndexOf("Reactor.dll") -gt 0) {
                        $snreactor = $snweb2.assets.browser_download_url[$aii]
                        break
                    }
                }
        
                if (Test-Path "$aupathm\BepInEx\plugins\Reactor.dll") {
                    Remove-item -Path "$aupathm\BepInEx\plugins\Reactor.dll" -Force
                    Write-Log 'Delete Original Reactor Mod DLL'
                }
                #Reactor DLLをDLして配置
                Write-Log "Download $scid Reactor DLL 開始"
                Write-Log $snreactor
                aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "Reactor.dll" $snreactor
                Write-Log "Download $scid Reactor DLL 完了"         
        
                if (Test-Path "$aupathm\BepInEx\plugins\LevelImposter.dll") {
                    Remove-item -Path "$aupathm\BepInEx\plugins\LevelImposter.dll" -Force
                    Write-Log 'Delete Original LevelImposter Mod DLL'
                }
                #LevelImposter DLLをDLして配置
                Write-Log "Download $scid LevelImposter DLL 開始"
                Write-Log $snLevel
                aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "LevelImposter.dll" $snLevel
                Write-Log "Download $scid LevelImposter DLL 完了"             
            }
        }
        elseif ($ckbci[$aa] -eq "Submerged") {
            if (($scid -eq "IUS") -or ($scid -eq "TIO")) {
                Write-Log "$scid では Submergedは入りません"
            }
            else {
                try {
                    choco -v
                }
                catch {
                    Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                }
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet-9.0-desktopruntime dotnet -y" -Verb RunAs -Wait   
    
                $snL = "https://api.github.com/repos/SubmergedAmongUs/Submerged/releases"        
                $sweb = Invoke-WebRequest $snL -UseBasicParsing
                $sweb2 = ConvertFrom-Json $sweb.Content   
                for ($aii = 0; $aii -lt $($sweb2.assets.browser_download_url).Length; $aii++) {
                    if ($($sweb2.assets.browser_download_url[$aii]).IndexOf("Submerged.dll") -gt 0) {
                        $snLevel = $sweb2.assets.browser_download_url[$aii]
                        break
                    }
                }
                
                if (Test-Path "$aupathm\BepInEx\plugins\Submerged.dll") {
                    Remove-item -Path "$aupathm\BepInEx\plugins\Submerged.dll" -Force
                    Write-Log 'Delete Original Submerged Mod DLL'
                }
                #Submerged DLLをDLして配置
                Write-Log "Download $scid Submerged DLL 開始"
                Write-Log $snLevel
                aria2c -x16 -s16 -j16 -V --dir "$aupathm\BepInEx\plugins" -o "Submerged.dll" $snLevel
                Write-Log "Download $scid Submerged DLL 完了"             
            }
        }
        elseif ($ckbci[$aa] -eq "VOICEVOX") {
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            #https://github.com/VOICEVOX/voicevox/releases/tag/0.14.6
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet-9.0-desktopruntime dotnet -y" -Verb RunAs -Wait   
            $aucap = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/VOICEVOX/voicevox/releases/latest" -UseBasicParsing)).assets.browser_download_url
            #GPU check
            # ビデオカード
            try {
                $VideoController = Get-WmiObject Win32_VideoController
                Write-log "ビデオカード:" $VideoController.Name    
            }
            catch {
                for ($vve = 0; $vve -lt $aucap.count; $vve++) {
                    if ($($aucap[$vve]).contains("VOICEVOX.Web.Setup")) {
                        $vvexe = $($aucap[$vve])
                    }
                }    
            }
            if ($($VideoController.Name).contains("nvidia")) {
                for ($vve = 0; $vve -lt $aucap.count; $vve++) {
                    if ($($aucap[$vve]).contains("VOICEVOX-CUDA.Web.Setup")) {
                        $vvexe = $($aucap[$vve])
                    }
                }    
            }
            else {
                for ($vve = 0; $vve -lt $aucap.count; $vve++) {
                    if ($($aucap[$vve]).contains("VOICEVOX.Web.Setup")) {
                        $vvexe = $($aucap[$vve])
                    }
                }    
            }
            Write-Log $vvexe          
            aria2c -x16 -s16 -j16 -V --allow-overwrite=true --dir "$dsk" -o "VOICEVOX.Web.Setup.exe" $vvexe                
            Start-process "$dsk\VOICEVOX.Web.Setup.exe" -Verb RunAs -Wait
            Remove-Item "$dsk\VOICEVOX*" -Force
            $Bar.Value = "85"
        }
        elseif ($ckbci[$aa] -eq "VC Redist") {
            Write-Log "VC Redist Install start"
            Start-Transcript -Append -Path "$LogFileName"
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 vcredist-all -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log "VC Redist Install ends"
            $Bar.Value = "86"
        }
        elseif ($ckbci[$aa] -eq "PowerShell 7") {
            Write-Log "PS7 Install start"
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 pwsh powershell-core -y" -Verb RunAs -Wait
            Write-Log "PS7 Install ends"
            $Bar.Value = "87"
        }
        elseif ($ckbci[$aa] -eq "dotNetFramework") {
            Write-Log ".Net Framework Install start"
            Start-Transcript -Append -Path "$LogFileName"
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-6.0-desktopruntime dotnet-7.0-desktopruntime dotnet-8.0-desktopruntime dotnet-9.0-desktopruntime dotnet -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log ".Net Framework Install ends"
            $Bar.Value = "88"
        }
        elseif ($ckbci[$aa] -eq "NOS Webhook") {
            Write-Log "NOS/NOT Webhook starts"
            if (($scid -eq "NOS") -or ($scid -eq "NOT")) {
                if ($gmhwebhooktxt -eq "None") {
                    Write-Log "NOS/NOT Webhook skipped."
                }
                else {
                    $gmhconfig = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"
                    if (!(Test-Path $gmhconfig)) {
                        Write-Log "Configが見つからないため、一時的なConfigとして健康ランドレギュレーションをロードします"
                        $kenkoconf = $(invoke-webrequest https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/kenkoland.txt).Content
                        if (!(Test-Path $(Join-Path $aupathm "\BepInEx\config\"))) {
                            New-Item $(Join-Path $aupathm "\BepInEx\config\") -Type Directory
                        }
                        $kenkoconf | Out-File $gmhconfig
                    }
                    $gmhconfigtmp = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg.beforewebhook.old"
                    Copy-Item $gmhconfig $gmhconfigtmp
                    $gmhfile = (Get-Content -Encoding utf8 $gmhconfig) -as [string[]]
                    $gmhnewconfig = ""
                    foreach ($gmhline in $gmhfile) {
                        if ($gmhline.StartsWith("WebhookUrl")) {
                            if ($gmhwebhooktxt -eq "None") {
                                $gmhnewconfig += "$gmhline `r`n"
                            }
                            else {
                                $gmhnewconfig += "WebhookUrl = $gmhwebhooktxt `r`n"                    
                                Write-Log "GMH Webhook : $gmhwebhooktxt"
                            }
                        }
                        else {
                            $gmhnewconfig += "$gmhline `r`n"
                        }
                    }
                    Remove-Item $gmhconfig -Force
                    $gmhnewconfig | Out-File $gmhconfig
                }   
            }
            else {
                Write-Log "NOS/NOT Webhook skipped."
            }
            Write-Log "NOS/NOT Webhook ends"
            $Bar.Value = "89"
        }
        elseif ($ckbci[$aa] -eq "サーバー情報初期化") {
            Write-Log "サーバー情報を初期化します。"
            if (Test-Path "$env:APPDATA\..\LocalLow\Innersloth") {
                $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                if (Test-Path $aurifile) {
                    Remove-Item $aurifile -Force
                }
                $defjson = '{"CurrentRegionIdx":3,"Regions":[{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":289},{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":290},{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":291},{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"imposter.kenko.land","DefaultIp":"imposter.kenko.land","Port":443,"UseDtls":false,"Name":"Custom","TranslateName":1003,"TargetServer":null}]}'
                $aurijson = ConvertFrom-Json $defjson
                ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                Write-Log "サーバー情報を初期化しました。"
            }
            else {
                Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
            }
            $Bar.Value = "88"
        }
        elseif ($ckbci[$aa] -eq "カスタムサーバー情報追加") {
            Write-Log "カスタムサーバー情報を追加します。"
            if (Test-Path "$env:APPDATA\..\LocalLow\Innersloth") {
                $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                if (Test-Path $aurifile) {
                }
                else {
                    $defjson = '{"CurrentRegionIdx":3,"Regions":[{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":289},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":290},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":291},{"$type":"DnsRegionInfo,Assembly-CSharp","Fqdn":"127.0.0.1","DefaultIp":"127.0.0.1","Port":22023,"UseDtls":false,"Name":"Custom","TranslateName":1003}]}'
                    $aurijson = ConvertFrom-Json $defjson
                    ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile   
                }
                if ($xport -eq "443") {
                    $kenkojson2 = "{`"`$type`":`"StaticHttpRegionInfo, Assembly-CSharp`",`"Name`":`"$xname`",`"PingServer`":`"$xfqip`",`"Servers`":[{`"Name`":`"Http-1`",`"Ip`":`"https://$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Players`":0,`"ConnectionFailures`":0}],`"TranslateName`":1003}"  
                }
                else {
                    $kenkojson2 = "{`"`$type`":`"StaticHttpRegionInfo, Assembly-CSharp`",`"Name`":`"$xname`",`"PingServer`":`"$xfqip`",`"Servers`":[{`"Name`":`"Http-1`",`"Ip`":`"$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Players`":0,`"ConnectionFailures`":0}],`"TranslateName`":1003}"  
                }
                #$kenkojson2 = "{`"`$type`":`"DnsRegionInfo, Assembly-CSharp`",`"Fqdn`":`"$xfqip`",`"DefaultIp`":`"$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Name`":`"$xname`",`"TranslateName`": 1003}"
                $auritext = Get-Content $aurifile -Raw
                $aurijson = ConvertFrom-Json $auritext
                $aurijson.Regions += $($kenkojson2 | ConvertFrom-Json)
                if (!(Test-Path "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old")) {
                    Copy-Item $aurifile "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old"
                }
                ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                Write-Log "カスタムサーバー情報を追加しました。"
            }
            else {
                Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
            }
            $Bar.Value = "89"
        }
        elseif ($ckbci[$aa] -eq "NOS/NOT 追加役職") {
            if (($scid -eq "NOS") -or ($scid -eq "NOT")) {
                Write-Log "NOS/NOTに追加役職Addonを追加します"
                if (Test-Path "$aupathm\Addons\Ninja.zip") {
                    Remove-Item "$aupathm\Addons\Ninja.zip" -Force
                }
                if (Test-Path "$aupathm\Addons\SchrodingersCat.zip") {
                    Remove-Item "$aupathm\Addons\SchrodingersCat.zip" -Force
                }
                Write-Log "Ninja." #v2
                Write-Log "SchrodingersCat." #v1.0.0
                $ninja = ($addon2.assets.browser_download_url | Select-String "Ninja").ToString()
                $scat = ($addon2.assets.browser_download_url | Select-String "SchrodingersCat").ToString()

                if ($RadioButton115.Checked) {
                    #prev1
                    if ($ninja.Contains("__" + $nosmin1)) {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "Ninja.zip" $ninja --allow-overwrite=true                         
                    }
                    if ($scat.Contains("__" + $nosmin1)) {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "SchrodingersCat.zip" $scat --allow-overwrite=true                         
                    }
                }
                elseif ($RadioButton116.Checked) {
                    #prev2
                    if ($ninja.Contains("__" + $nosmin2)) {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "Ninja.zip" $ninja --allow-overwrite=true 
                    }
                    if ($scat.Contains("__" + $nosmin2)) {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "SchrodingersCat.zip" $scat --allow-overwrite=true 
                    }
                }
                else {
                    #latest
                    if ($ninja.Contains("__" + $nosmin1)) {
                        Write-Log "Ninja  は互換性の問題でインストールされませんでした"
                    }
                    elseif ($ninja.Contains("__" + $nosmin2)) {
                        Write-Log "Ninja  は互換性の問題でインストールされませんでした"
                    }
                    else {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "Ninja.zip" $ninja --allow-overwrite=true 
                    }
                    if ($scat.Contains("__" + $nosmin1)) {
                        Write-Log "SchrodingersCat  は互換性の問題でインストールされませんでした"
                    }
                    elseif ($scat.Contains("__" + $nosmin2)) {
                        Write-Log "SchrodingersCat は互換性の問題でインストールされませんでした"
                    }
                    else {
                        aria2c -x16 -s16 -j16 -V --dir "$aupathm\Addons" -o "SchrodingersCat.zip" $scat --allow-overwrite=true 
                    }
                }
                Write-Log "NOS/NOTに追加役職Addonを追加しました。"
            }
            else {
                Write-Log "追加役職AddonはNOS/NOTにだけ適用可能です。"
            }
            $Bar.Value = "89"
        }
        elseif ($ckbci[$aa] -eq "健康ランド") {
            if (($scid -eq "NOS") -or ($scid -eq "NOT") -or ($scid -eq "SNR")) {
                Write-Host "健康ランド化 start"
                #regioninfo.json
                if (Test-Path "$env:APPDATA\..\LocalLow\Innersloth") {
                    $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                    if (Test-Path $aurifile) {
                        $auritext = Get-Content $aurifile -Raw
                        if ($auritext.IndexOf("Modded EU (MEU)") -gt 0) {
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded EU (MEU)","PingServer":"https://au-eu.duikbo.at","Servers":[{"Name":"Http-1","Ip":"https://au-eu.duikbo.at","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')
                            Write-Log "MEU Deleted."
                        }
                        if ($auritext.IndexOf("Modded NA (MNA)") -gt 0) {
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded NA (MNA)","PingServer":"https://aumods.one","Servers":[{"Name":"Http-1","Ip":"https://aumods.one","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "MNA Deleted."
                        }
                        if ($auritext.IndexOf("Modded Asia (MAS)") -gt 0) {
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded Asia (MAS)","PingServer":"https://au-as.duikbo.at","Servers":[{"Name":"Http-1","Ip":"https://au-as.duikbo.at","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "MAS Deleted."
                        }
                        if ($auritext.IndexOf("haoming-server.com") -gt 0) {
                            $torjson = ',{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"haoming-server.com","DefaultIp":"haoming-server.com","Port":22023,"UseDtls":false,"Name":"haoming-server","TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "HS Deleted."
                        }
                        Write-Log $auritext
                        #$kenkonewjson = '{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"amongus.kenko.land","DefaultIp":"amongus.kenko.land","Port":22023,"UseDtls":false,"Name":"健康ランド","TranslateName": 1003}'
                        #$kenkonewtjson = '{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"imposter.kenko.land","DefaultIp":"imposter.kenko.land","Port":22023,"UseDtls":false,"Name":"健康ランドテスト","TranslateName": 1003}'
                        $kenkonewjson = '{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"健康ランド","PingServer":"amongus.kenko.land","Servers":[{"Name":"Http-1","Ip":"http://amongus.kenko.land","Port":22023,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer": null,"TranslateName":1003}'  
                        $kenkonewtjson = '{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"健康ランドテスト","PingServer":"imposter.kenko.land","Servers":[{"Name":"Http-1","Ip":"http://imposter.kenko.land","Port":22023,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer": null,"TranslateName":1003}'  
                        $aurijson = ConvertFrom-Json $auritext

                        if ($auritext.IndexOf("`"Name`":`"健康ランドテスト`"") -lt 0) {
                            $aurijson.Regions += $($kenkonewtjson | ConvertFrom-Json)
                        }
                        else {
                            Write-Log "健康ランド済:Staging Server"
                        }
                        if ($auritext.IndexOf("`"Name`":`"健康ランド`"") -lt 0) {
                            $aurijson.Regions += $($kenkonewjson | ConvertFrom-Json)
                        }
                        else {
                            Write-Log "健康ランド済:Production Server"
                        }

                        if (!(Test-Path "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old")) {
                            Copy-Item $aurifile "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old"
                        }
                        ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                        Write-Log "健康ランド化完了:Server"
                    }
                    else {
                        Write-Log "サーバー情報ファイルが見つかりません。"
                        Write-Log "Among Us本体を一度起動してから再度実行してください。"
                    }
                }
                else {
                    Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
                }        
                Write-Log "健康ランド化 ends"
                $Bar.Value = "88"
            }
        }
        elseif ($ckbci[$aa] -eq "配信ソフト") {
            Write-Log "配信ソフトセットアップ"
            Start-Transcript -Append -Path "$LogFileName"
            try {
                choco -v
            }
            catch {
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade streamlabs-obs obs-studio  -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log "配信ソフトセットアップ完了"
            $Bar.Value = "91"
        }
        else {
        }
    }
}

$Bar.Value = "92"

<#####
# Nebula Server 追加
#####
if(($scid -eq "NOS") -OR ($scid -eq "NOT")){
    Write-Log "Nebulaサーバー情報を追加します。"
    if(Test-Path "$env:APPDATA\..\LocalLow\Innersloth"){
        $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
        if(Test-Path $aurifile){
        }else{
            $defjson = '{"CurrentRegionIdx":0,"Regions":[{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":289},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":290},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":291},{"$type":"DnsRegionInfo,Assembly-CSharp","Fqdn":"127.0.0.1","DefaultIp":"127.0.0.1","Port":22023,"UseDtls":false,"Name":"Custom","TranslateName":1003}]}'
            $aurijson = ConvertFrom-Json $defjson
            ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile       
        }
        Start-Sleep -Seconds 1
        $kenkojson2 = '{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Nebula 公式","PingServer":"160.251.22.225","Servers":[{"Name":"Http-1","Ip":"160.251.22.225","Port":22000,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'  
        $auritext = Get-Content $aurifile -Raw
        if($auritext.IndexOf("`"Name`":`"Nebula 公式`"") -lt 0){
            $aurijson = ConvertFrom-Json $auritext
            $aurijson.Regions += $($kenkojson2 | ConvertFrom-Json)
            if(!(Test-Path "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old")){
                Copy-Item $aurifile "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old"
            }
            ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
            Write-Log "Nebulaサーバー情報を追加しました。"
        }else{
            Write-Log "Nebula 公式追加済 Server"
        }   
    }else{
        Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
    }
}

#>
####################
#bat file auto update
####################
try {
    choco -v
}
catch {
    Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
}
# 最新の BAT ファイルを一時ファイル (.bat.new) としてダウンロード
$batUrl = "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/StartAmongUsModTORplusDeployScript.bat"
$newBatDsk = Join-Path $dsk "StartAmongUsModTORplusDeployScript.bat.new"
Invoke-WebRequest $batUrl -OutFile $newBatDsk -UseBasicParsing

# 実行中 BAT への直接上書きを避け、cmd.exe 終了後に安全に置換するコマンド群を構築
$delayedCmds = @()

if (Test-Path (Join-Path $dsk "StartAmongUsModTORplusDeployScript.bat")) {
    # 既に存在する場合は cmd.exe 終了後に遅延置換
    $delayedCmds += "move /y `"$newBatDsk`" `"$dsk\StartAmongUsModTORplusDeployScript.bat`" >nul"
}
else {
    # 初回実行で未存在の場合は直ちに配置
    Move-Item -Path $newBatDsk -Destination (Join-Path $dsk "StartAmongUsModTORplusDeployScript.bat") -Force
}

# ユーザーが別の場所 ($npl2) で古い BAT を実行していた場合、元の場所の BAT も最新に遅延更新
if ($npl2.Path -ne $dsk -and (Test-Path "$($npl2.Path)\StartAmongUsModTORplusDeployScript.bat")) {
    $newBatNpl = Join-Path $npl2.Path "StartAmongUsModTORplusDeployScript.bat.new"
    $sourceBat = if (Test-Path $newBatDsk) { $newBatDsk } else { "$dsk\StartAmongUsModTORplusDeployScript.bat" }
    Copy-Item -Path $sourceBat -Destination $newBatNpl -Force
    $delayedCmds += "move /y `"$newBatNpl`" `"$($npl2.Path)\StartAmongUsModTORplusDeployScript.bat`" >nul"
}

# 万が一 BAT 側での削除がスキップされた場合のセーフティネット（PS1 の遅延クリーンアップ）
$delayedCmds += "del /f /q `"$dsk\AmongUsModTORplusDeployScript.ps1`" >nul 2>&1"
if ($npl2.Path -ne $dsk) {
    $delayedCmds += "del /f /q `"$($npl2.Path)\AmongUsModTORplusDeployScript.ps1`" >nul 2>&1"
}

# 親の cmd.exe が正常終了（del 等完了）した2秒後に、安全に move とクリーンアップを実行するバックグラウンドタスク
if ($delayedCmds.Count -gt 0) {
    $delayedScript = "ping 127.0.0.1 -n 3 >nul & " + ($delayedCmds -join " & ")
    Start-Process cmd.exe -ArgumentList "/c $delayedScript" -WindowStyle Hidden
}

# ログ取得用バッチの生成（変数汚染を防止し、初期化して出力）
$logBatContent = "chcp 65001 >nul`r`n@echo off`r`nsetlocal`r`npushd `"%~dp0`"`r`n"
$logBatContent += "curl.exe -k -s -S -L --retry 2 -o `"%~dp0gmhtechsupport.ps1`" https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1`r`n"
$logBatContent += "set `"PS_EXE=powershell.exe`"`r`nwhere pwsh.exe >nul 2>&1 && set `"PS_EXE=pwsh.exe`"`r`n"
$logBatContent += "`"%PS_EXE%`" -NoProfile -ExecutionPolicy Bypass -File `"%~dp0gmhtechsupport.ps1`" `"$scid`" `"$aupathm`" `"$platform`"`r`n"
$logBatContent += "del /F /Q `"%~dp0gmhtechsupport.ps1`"`r`npopd`r`n"
$logBatContent | Out-File -Encoding "UTF8BOM" -FilePath "$dsk\StartAmongUsGetLogScript_$scid.bat"

if (Test-Path "$scpath\StartAmongUsModTORplusDeployScript.lnk") {
    Remove-Item "$scpath\StartAmongUsModTORplusDeployScript.lnk" -Force
}
$sShortcut = $WsShell.CreateShortcut("$scpath\StartAmongUsModTORplusDeployScript.lnk")
$sShortcut.TargetPath = "$dsk\StartAmongUsModTORplusDeployScript.bat"
$sShortcut.WorkingDirectory = "$dsk"
$sShortcut.IconLocation = "$dsk\AUMADS.ico"
$sShortcut.Save()
Write-Log $npl2.Path
Write-Log $dsk
if ($npl2.Path -eq $dsk) {
    Write-Log "Current location is Working Directory"
}
else {
    Write-Log "Current location is not Working Directory"
    Write-Log $npl2.Path
    Write-Log $dsk
}

####################
## Option Check
####################
if ($opflag) {
    if (!(Test-Path "$aupathb")) {
        New-Item $aupathb -Type Directory 
    }
    Remove-Item "$aupathb\chk*.txt" -Force
    Write-Output $ym | Out-File -FilePath "$aupathb\chk$ym.txt"
}
####################

$Bar.Value = "93"
if ($platform -eq "Epic") {

    try {
        legendary.exe -V
    }
    catch {
        try {
            choco -v
        }
        catch {
            Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
        }
        Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade legendary -y" -Verb RunAs -Wait   
    }
    
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command cup legendary -y" -Verb RunAs -Wait   
    Start-Transcript -Append -Path "$LogFileName"
    Set-Location "$aupathb"
    legendary.exe auth --import
    legendary.exe -y uninstall Among Us --keep-files 
    legendary.exe -y import "Among Us" "$aupathm"
    legendary.exe -y egl-sync
    Stop-Transcript
    Start-Sleep -Seconds 5

}
elseif ($platform -eq "Steam") {
    if (!(Test-Path "$aupathm\steam_appid.txt")) {
        Write-Output "945360"> "$aupathm\steam_appid.txt"
        Write-Log "Steam AppID Patched."
    }
}
$Bar.Value = "97"
$fntime = Get-Date
$difftime = ($fntime - $sttime).TotalSeconds

$Bar.Value = "98"

#Backup!
BackUpAU

Write-Log "$difftime 秒で完了しました。"

if ($tio) {
    if ($startexewhendone -eq $true) {
        if ($platform -eq "Steam") {
            Start-Process "$aupathm\Among Us.exe"   
        }
        elseif ($platform -eq "Epic") {
            Set-Location "$aupathb"
            legendary.exe launch Among Us
        }
        else {
            Write-Log "ERROR:Critical run apps"
        }
    }
    else {
    }
}


if ($debugc) {
    if ($startexewhendone -eq $true) {
        Write-Output "`r`nAmong Us 本体の起動中です。本体が終了するまでこのまま放置してください。`r`n"
        #監視プロセス名
        $procName = "Among Us"
        $checkpro = $true
        Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1" -OutFile "$npl\gmhtechsupport.ps1" -UseBasicParsing
        $tsp = &"$npl\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" | Select-Object -Last 1
        Write-Log "-----------------------------------------------------------------"
        Write-Log "Error Check"
        Write-Log "-----------------------------------------------------------------"
        Write-Log $(Get-Translate("After Installation:$tsp"))
        #監視&自動起動
        while ($checkpro) {
            try {
                #プロセスを取得
                $p = Get-Process $procName -ErrorAction SilentlyContinue
                #始したプロセスが終了するまで待機するように指示
                $p.WaitForExit()
            }
            catch {
                Write-Output "No Process"
            }
            finally {
                $tsp = &"$npl\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" | Select-Object -Last 1
                Remove-Item "$npl\gmhtechsupport.ps1" -Force
                $erchk = Get-content "$tsp" -Raw
                Write-Log $(Get-Translate("After Game Exit:$tsp"))
                if ($erchk.LastIndexOf("error") -gt 0) {
                    Write-Log "Done."
                }
                else {
                    Write-Log "No Error founds."
                }
                $checkpro = $false
            }
        }
    }
}


Write-Log "-----------------------------------------------------------------"
Write-Log "Install Error check"
Write-Log "-----------------------------------------------------------------"
Write-Log $error.Count

if ($error.Count -eq 0) {
    Write-Log "Script実行時のエラーはなさそうです"
}
else {
    Write-Log $error
    for ($abc = 0; $abc -lt $error.Count; $abc++) {
        $($error[$abc]) | Out-string | Write-Log 
    }    
}

Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Ends"
Write-Log "-----------------------------------------------------------------"

Start-Sleep -Seconds 1
$Bar.Value = "100"
if ($null -ne $script:mainWindow -and $null -eq $Args1) {
    # WPF シングルウィンドウ内の完了画面 (ViewComplete) に遷移
    $script:isDeploying = $false
    $script:ProgBar.Value = 100
    $script:TxtPercent.Text = "100%"
    $script:ViewProgress.Visibility = [System.Windows.Visibility]::Collapsed
    $script:ViewComplete.Visibility = [System.Windows.Visibility]::Visible

    if ($script:TxtCompleteModDesc) {
        $script:TxtCompleteModDesc.Text = "$mod の導入とショートカット作成が完了しました。"
    }
    if ($script:TxtCompletePath) {
        $script:TxtCompletePath.Text = "$script:aupathm"
    }
    if ($script:TxtCompleteShortcut) {
        $script:TxtCompleteShortcut.Text = "Among Us - $scid"
    }
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Render)

    # ユーザーが「今すぐゲームを起動」または「完了して閉じる」を押すまで待機
    $script:completeAction = $null
    while ($null -eq $script:completeAction -and $script:mainWindow.IsVisible) {
        [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        Start-Sleep -Milliseconds 100
    }

    if ($script:completeAction -eq "Launch") {
        if (Test-Path "$script:aupathm\Among Us.exe") {
            Start-Process "$script:aupathm\Among Us.exe"
        }
    }
    $script:mainWindow.Close()
}
else {
    $Form2.Close()
}

exit
