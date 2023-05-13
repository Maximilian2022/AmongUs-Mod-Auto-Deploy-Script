Param($Args1) #modnum
################################################################################################
#
# Among Us Mod Auto Deploy Script
#
$version = "1.9.4.5"
#
#################################################################################################
### minimum version for v2023.3.28
$ermin = "v7.0.0.0"
$esmin = "v7.0.0.0"
$nosmin = "2.3,2023.3.28"
$notmin = "2.3,2023.3.28"
$tormin = "v4.3.1"
$tourmin = "v4.0.4 "
$tohmin = "v4.1.2"
$snrmin = "1.7.0.0"
$tormmin = "NONE"
$lmmin = "3.1.6"
$amsmin = "v23.2.28.0"
$toymin = "v412.8"

### minimum version for v2023.2.28
$ermin1 = "v6.0.0.0"
$esmin1 = "v6.0.0.0"
$nosmin1 = "2.2,2023.2.28"
$notmin1 = "2.2,2023.2.28"
$tormin1 = "v4.3.0"
$tourmin1 = "v4.0.3"
$tohmin1 = "v4.1.1"
$snrmin1 = "1.6.0.0"
$tormmin1 = "NONE"
$lmmin1 = "3.1.2"
$amsmin1 = "v23.2.28.0"
$toymin1 = "v411.7"

### minimum version for v2022.12.16
$ermin2 = "v5.0.0.0"
$esmin2 = "v5.0.0.0"
$nosmin2 = "2.0.1,2022.12.8"
$notmin2 = "2.0.1,2022.12.8"
$tormin2 = "v4.2.1"
$tourmin2 = "v4.0.0"
$tohmin2 = "v4.0.1"
$snrmin2 = "1.5.0.0"
$tormmin2 = "NONE"
$lmmin2 = "3.0.4"
$amsmin2 = "v22.12.14.0"
$toymin2 = "v402.3.9"

<### minimum version for v2022.10.25
$ermin2 = "v4.0.0.0"
$esmin2 = "v4.0.0.0"
$nosmin2 = "1.16,2022.10.25"
$notmin2 = "1.16,2022.10.25"
$tormin2 = "v4.2.0"
$tourmin2 = "v3.4.0"
$tohmin2 = "v3.0.2"
$snrmin2 = "1.4.2.4"
$tormmin2 = "MR_v2.5.0"
$lmmin2 = "3.0.0"
$amsmin2 = "v0.0.1"
$toymin2 = "v3.0.2.2"

### minimum version for v2022.10.18
$ermin2 = "v3.3.0.3"
$esmin2 = "v3.3.0.3"
$nosmin2 = "NONE"
$notmin2 = "NONE"
$tormin2 = "NONE"
$tourmin2 = "NONE"
$tohmin2 = "NONE"
$snrmin2 = "1.4.2.3"
$tormmin2 = "NONE"
$lmmin2 = "NONE"
$amsmin2 = "NONE"
$toymin2 = "NONE"

### minimum version for v2022.9.20(8.24)
$ermin2 = "v3.2.2.0"
$esmin2 = "v3.2.2.0"
$nosmin2 = "1.12.11,2022.8.24"
$tormin2 = "v4.1.7"
$tourmin2 = "v3.3.0"
$tohmin2 = "v2.2.2"
$snrmin2 = "1.4.2.0"
$tormmin2 = "MR_v2.3.0"
$lmmin2 = "2.1.3"
$amsmin2 = "NONE"
$toymin2 = "NONE"
#>

#Frequent changing parameter https://steamdb.info/depot/945361/manifests/

$prever0 = "2023.2.28"
$prevtargetid0 = "1390179653173000898"
$prever1 = "2022.12.14"
$prevtargetid1 = "3833836818403923932"
#$prever1 = "2022.10.25"
#$prevtargetid1 = "4338750749031095433"
#$prever1 = "2022.10.19"
#$prevtargetid1 = "4338750749031095433"
#$prever1 = "2022.9.20"
#$prevtargetid1 = "2481435393334839152"

$gmhbool = $true
$nebubool = $false
#Testdll: Snapshot 22.11.21c
$torgmdll = "https://github.com/Dolly1016/Nebula/releases/download/snapshot/Nebula.dll"

#TOR plus, TOR GM, TOR GMH, AUM is depricated.
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

#################################################################################################
# Translate Function
#################################################################################################
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
# 権限チェック
#################################################################################################
if(!((net localgroup Administrators) -contains $env:username -or (net localgroup Administrators) -contains "$env:userdomain\$env:username")){
    Write-Host $(Get-Translate("このWindowsユーザーアカウントでは本Scriptは動作しません。管理者権限が必要です。"))
    Write-Host $(Get-Translate("あなたのユーザー名($env:username)は管理者権限グループに属していません"))
    Write-Host $(Get-Translate("管理者権限グループに属しているユーザーは以下の通りです"))
    $nn = net localgroup Administrators
    Write-Host $nn
    pause
    exit
}

#################################################################################################
# Run w/ Powershell v7 if available.
#################################################################################################
$npl = Get-Location
$npl2 = Get-Location
Write-Output $(Get-Translate("実行前チェック開始"))
try{
    pwsh -Command '$PSVersionTable.PSVersion.major'
}
catch{
    Write-Output $(Get-Translate("初起動時のみ: Powershell 7を導入中・・・。"))
    Start-Process powershell.exe -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
    Write-Output "`r`n"
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade pwsh powershell-core aria2 legendary -y" -Verb RunAs -Wait   
    Write-Output "`r`n"
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`"" -Verb RunAs -Wait
    Write-Output "`r`n"
    Exit
}

Unblock-File "$npl\AmongUsModTORplusDeployScript.ps1"
function IsZenkaku{
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateLength(1, 1)]
        [string]
        $Text
    )
    process{
        $shiftJis = [System.Text.Encoding]::GetEncoding("Shift_JIS")
        $shiftJis.GetByteCount($Text) -eq 2
    }
}

$a = hostname
$achk = $false
for ($x=0; $x -lt $a.Length; $x++){
    if(IsZenkaku $($a.Split())[$x]){
        $achk = $true
        break;
    }
}
if ($achk){
    Write-Output $(Get-Translate("PCの名前に全角が含まれています。Modがうまく起動しない場合があります。英数字への名前変更を推奨します。"))
    Start-Process "https://support.lenovo.com/jp/ja/solutions/ht105079"
}

Write-Output $(Get-Translate("実行前チェック完了"))

if ((!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) -or ($($PSVersionTable.PSVersion.Major) -ne "7")) {
    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`"" -Verb RunAs -Wait
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
$LogFile = $LogName + "_" +$Now.ToString("yyyy-MM-dd-HH-mm-ss") + ".log"
# ログフォルダーがなかったら作成
if( -not (Test-Path $LogPath) ) {
    New-Item $LogPath -Type Directory
}
# ログファイル名
$LogFileName = Join-Path $LogPath $LogFile

$scpath = [System.Environment]::GetFolderPath("Desktop")
$WsShell = New-Object -ComObject WScript.Shell
$dsk = "$scpath\AUMADS"

if(!(Test-Path $dsk)){
    New-Item $dsk -Type Directory
}

function Write-Log($logstring){
    $Now = Get-Date
    # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
    $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
    $Log += $LogString
    # ログ出力
    Write-Output $(Get-Translate($Log)) | Out-File -FilePath $LogFileName -Encoding utf8 -Append
    # echo させるために出力したログを戻す
    Return $(Get-Translate($Log))
}
Write-Log "Running With Powershell Version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Log "                                                                 "
Write-Log "-----------------------------------------------------------------"
Write-Log "                                                                 "
Write-Log "                    AmongUs Mod Deploy Script                    "
Write-Log "                                                   Version: $version"
Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Starts"
Write-Log "-----------------------------------------------------------------"
if($((Get-Module -Name 7Zip4Powershell -ListAvailable).Name | select-string 7Zip4Powershell).count -eq 0){
    Install-Module -Name 7Zip4Powershell -Force
}
#################################################################################################
# Icon and AUMADS Folder on Desktop
#################################################################################################
if(Test-Path "$dsk\AUMADS.ico"){
    Remove-Item "$dsk\AUMADS.ico" -Force 
}
aria2c -x5 -V --dir "$dsk" -o "AUMADS.ico" "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/AUMADS.ico" --disable-ipv6
if(!(Test-Path "$dsk\AUMADS.ico")){
    try{
        magick.exe -help | Out-Null
    }catch{
        Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco install -y imagemagick.app -PackageParameters "InstallDevelopmentHeaders=true LegacySupport=true"' -Verb RunAs -Wait
    }
    aria2c -x5 -V --dir "$dsk" -o "icon.png" "https://3dicons.sgp1.cdn.digitaloceanspaces.com/v1/dynamic/premium/rocket-dynamic-premium.png" --disable-ipv6
    magick.exe convert "$dsk\icon.png" -define icon:auto-resize=16,48,256 -compress zip "$dsk\AUMADS.ico"    
    Remove-Item "$dsk\icon.png" -Force 
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
    }else{
        return $null
    }
}
#################################################################################################
# バイト配列を16進数文字列に変換する. 
#################################################################################################
function ToHex([byte[]] $hashBytes){
    $builder = New-Object System.Text.StringBuilder
    $hashBytes | ForEach-Object{ [void] $builder.Append($_.ToString("x2")) }
    $builder.ToString()
}

# 指定したフォルダ以下の全てのファイルを取得する.
# (ファイルが指定された場合はファイル自身を返す)
function GetFilesRecurse([string] $path){
    Get-ChildItem $path -Recurse |
        Where-Object -FilterScript {
            # ディレクトリ以外のみ (ディレクトリのビットマスク値は16)
            ($_.Attributes -band 16) -eq 0
        }
}

function MakeEntry{
    process {
        New-Object PSObject -Property @{
            LastWriteTime = $_.LastWriteTime;
            Length = $_.Length;
            FullName = $_.FullName;
        }
    }
}
#func backup
Add-Type -AssemblyName UIAutomationClient
$oldtype = $true

if(Test-Path "C:\Program Files\Epic Games\AmongUs"){
    $legver = legendary.exe -V            
    if($legver -ge 'legendary version "0.20.29", codename "Dark Energy (hotfix #3)"'){
    }else{
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
        for($aaai = 0;$aaai -lt $aus.Length;$aaai++){
            if($($aus[$aaai]).IndexOf(".exe") -gt 0){
                aria2c -x5 -V --allow-overwrite=true --dir "$Env:ALLUSERSPROFILE\chocolatey\bin" -o "legendary.exe" $($aus[$aaai])
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

function BackupMod{
    if($scid -ne "NOT"){
        #Backup Mod
        if(!(Test-Path $aupathb)){
            New-Item $aupathb -ItemType Directory
        }
        if(!(Test-Path $aupathb\$scid)){
            New-Item $aupathb\$scid -ItemType Directory
        }
        Write-Log $(Get-Translate("Mod Backup Feature Start"))
        if($scid -ne "AMS"){
            if(Test-Path "$aupathb\$scid\$scid-$torv.zip"){
                $orgsize = (Get-Item "$aupathb\$scid\$scid-$torv.zip").Length
                $dlfsize = (Get-Item "$aupathm\TheOtherRoles.zip").Length
        
                if($orgsize -lt $dlfsize){
                    Copy-Item "$aupathm\TheOtherRoles.zip" "$aupathb\$scid\$scid-$torv.zip" -Force
                }
            }else{
                Copy-Item "$aupathm\TheOtherRoles.zip" "$aupathb\$scid\$scid-$torv.zip"
            }    
        }else{
            if(Test-Path "$aupathb\$scid\$scid-$torv.dll"){
                $orgsize = (Get-Item "$aupathb\$scid\$scid-$torv.dll").Length
                $dlfsize = (Get-Item "$aupathm\BepInEx\plugins\AUModS.dll").Length
        
                if($orgsize -lt $dlfsize){
                    Copy-Item "$aupathm\BepInEx\plugins\AUModS.dll" "$aupathb\$scid\$scid-$torv.dll" -Force
                }
            }else{
                Copy-Item "$aupathm\BepInEx\plugins\AUModS.dll" "$aupathb\$scid\$scid-$torv.dll" -Force
            }    
        }
        Write-Log "Mod Backup Feature End"
    }
}

function BackUpAU{
    #Backup System
    if(Test-Path $aupathb){
    }else{
        New-Item $aupathb -ItemType Directory
    }
    Write-Log "Backup Feature Start"

    #Current Ver check
    $datest = Get-Date -Format "yyyyMMdd-hhmmss"
    $backhashtxt = "$aupathb\backuphash.txt"
    $backuptxt = "$aupathb\backupfn.txt"
    if(test-path "$backuptxt"){
        $f = (Get-Content $backuptxt) -as [string[]]
        $filen = $f[0]
        Write-Log $filen
        $t = ""
        $r = ""
        $e = ""
        
        $t = (GetFilesRecurse $aupatho | MakeEntry | MakeHashInfo "SHA1" ).SHA1
        foreach($l in $t){
            $r += " $l"
        }
        $e = (Get-Content $backhashtxt) -as [string[]]

        Write-Log $(Get-Content $backuptxt)
        Write-Log $(Get-Content $backuptxt).IndexOf($amver)
        
        if($(Get-Content $backuptxt).IndexOf($amver) -lt 0){
            $e = "retake"
        }

        if($r -eq $e){
            Write-Log "古い同一Backupが見つかったのでSkipします"
        }else{
            Write-Log "新しいBackupが見つかったので生成します"
            Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
            write-log $e
            Write-log $r
            Compress-7Zip -Path $aupatho -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$amver.zip")
            Remove-Item -Path $backhashtxt -Force
            Remove-Item -Path $backuptxt -Force
            $thash = (GetFilesRecurse $aupatho | MakeEntry | MakeHashInfo "SHA1" ).SHA1
            Write-Output " $thash"> $backhashtxt
            Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
        }
    }else{
        Write-Log "Backupが見つかりません。生成します。"
        $thash = (GetFilesRecurse $aupatho | MakeEntry | MakeHashInfo "SHA1" ).SHA1
        Write-Output " $thash"> $backhashtxt
        Write-Output $(Join-path $aupathb "Among Us-$datest-v$amver.zip") > $backuptxt
        Compress-7Zip -Path $aupatho -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$amver.zip")
    }

    #Manifest Backup
    if($platform -eq "epic"){
        if(!(Test-Path "$aupathb\epic_manifest")){
            New-Item "$aupathb\epic_manifest" -Type Directory
        }
        if(Test-Path "$aupatho\.egstore"){
            if(!(Test-Path "$aupathb\$amver.manifest")){
                $egmani = Get-ChildItem -path "$aupatho\.egstore\*.manifest"
                Copy-Item "$aupatho\.egstore\$($egmani[0].Name)" "$aupathb\epic_manifest\v$amver.manifest"
            }
        }
    }

    #Previous ver check
    $items = Get-ChildItem $aupathb -File
    $prevchk = $true
    foreach ($item in $items) {        
        if(($item.Name).IndexOf("$prever") -gt 0 ){
            $prevchk = $false
        }
    }
    if($prevchk){
        if($platform -eq "steam"){
            $steampth = "C:\Program Files (x86)\Steam\Steam.exe"
            if (Test-Path $steampth){
                Write-Log "Steam アプリは以下で見つかりました。 $steampth"
            }else{
                Write-Log "Steam アプリがデフォルトの場所に見つかりませんでした。"
                Param(
                    [Parameter()]
                    [String] $FilePath
                )     
                # $FilePath が設定されていない、又はファイルが存在しない
                if([string]::IsNullOrEmpty($steampth) -Or (Test-Path -LiteralPath $steampth -PathType Leaf) -eq $false) {
                    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")    
                    $dialog = New-Object System.Windows.Forms.OpenFileDialog
                    $dialog.Filter = $(Get-Translate("EXE ファイル(*.EXE)|*.EXE"))
                    $dialog.InitialDirectory = "C:\"
                    $dialog.Title = $(Get-Translate("Steam.exe ファイルを選択してください"))
                
                    # キャンセルを押された時は処理を止める
                    if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::NG){
                        exit 1
                    }
                
                    # 選択したファイルパスを $FilePath に設定
                    $steampth = $dialog.FileName
                }
            }

            #操作したいウィンドウのタイトル
            $MAIN_WINDOW_TITLE="Steam"
            #Get-Processで取得できた1つ目のハンドルを対象とする。
            $steamruncheck = $true
            $steamrunner = $true

            while($steamruncheck){
                try{
                    $hwnd=(Get-Process |Where-Object{$_.MainWindowTitle -like $MAIN_WINDOW_TITLE})[0].MainWindowHandle
                }catch{
                    Write-Log "Steam.exe 起動チェック。ログインできていない場合はログインしてください。"       
                }
                if($null -eq $hwnd){
                    if($steamrunner){
                        Start-Process $steampth 
                        $steamrunner = $false
                    }
                }else{
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
            $window=[System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
            $windowPattern=$window.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)
            #ウィンドウサイズを最小化する
            $windowPattern.SetWindowVisualState([System.Windows.Automation.WindowVisualState]::Minimized)    

            Start-Sleep -Seconds 2

            $stfolder = Split-Path $steampth -Parent
            $bupfolder = Join-Path $stfolder "steamapps\content\app_945360\depot_945361"
            $delfoldser = Join-Path $stfolder "steamapps\content\app_945360"
            $counter = 0;
            while(!(Test-Path $bupfolder)){
                Start-Sleep -Seconds 2
            }
            Write-Log "Steam.exe は前バージョン($prever)をダウンロード中です。しばらくお待ちください。(Max10分でタイムアウトします)#0"
            $presu = $false
            while (((Get-ChildItem $bupfolder | Measure-Object).Count) -ne 8){
                Start-sleep -Seconds 15
                #timeout 10min.
                if($counter -lt 40){
                    $counter++
                    Write-Log "Steam.exe は前バージョン($prever)をダウンロード中です。しばらくお待ちください。#$counter $((Get-ChildItem $bupfolder | Measure-Object).Count)/8"
                    $presu = $true
                }else{
                    break
                    Write-Log "Steam.exe の前バージョン($prever)をダウンロードがタイムアウトしました。再度お試しください。$((Get-ChildItem $bupfolder | Measure-Object).Count)/8"
                }
            }
            if($presu){
                Compress-7Zip -Path $bupfolder -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$prever.zip")
                Start-Sleep -Seconds 2
                Remove-Item -Path $delfoldser -Recurse -Force    
            }else{
                Write-Log "前バージョン($prever)のロードに失敗しました。再度お試しください。"
            }
        }elseif($platform -eq "epic"){
            if($oldtype){
                $epicmanifestchk = $true
                if(Test-Path "$aupathb\epic_manifest"){
                    $eitems = Get-ChildItem "$aupathb\epic_manifest" -File
                    foreach ($item in $eitems) {        
                        if(($item.Name).IndexOf("$prever") -gt 0 ){
                            $epicmanifestchk = $false
                            $epicmanifestfile = "$aupathb\epic_manifest\$prever.manifest"
                        }
                    }
                }
                if($epicmanifestchk){
                    #manifestがないから指定してもらう
                    Write-Log "Epic Game の過去のManifestファイルが見つかりません。Manifestファイルを指定してください。"     
                
                    Add-Type -assemblyName System.Windows.Forms
                    $dialog = New-Object System.Windows.Forms.OpenFileDialog
                    $dialog.Filter = $(Get-Translate("manifest ファイル(*.manifest)|*.manifest"))
                    $dialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
                    $dialog.Title = $(Get-Translate("Manifestファイルを選択してください"))
                    if ($dialog.ShowDialog() -eq "OK") {
                        $epicmanifestfile = $dialog.FileName
                    } else {
                        Write-Log "ファイルを選択しませんでした"
                    }
                }

                Write-Log "選択: $epicmanifestfile"
                if(!(Test-Path "$aupathb\epic_manifest")){
                    New-Item "$aupathb\epic_manifest" -Type Directory
                }
                $mfileName = Split-Path $epicmanifestfile -Leaf
                Copy-Item $epicmanifestfile "$aupathb\epic_manifest\$mfilename"
                $epicmanifestfile = "$aupathb\epic_manifest\$mfilename"
                Write-Log "コピー: $epicmanifestfile"

                #legendary でAmongusを落とす
                legendary.exe auth --import
                legendary.exe -y import 'Among Us' "$aupatho"
                legendary.exe uninstall "Among Us" --keep-files -y
                Copy-Item $aupatho "$aupathb\AmongUs" -Recurse
                legendary.exe -y import 'Among Us' "$aupathb\AmongUs"
                Start-Sleep -Seconds 1
                if(Test-Path "$aupathb\AmongUs"){
                    Remove-item "$aupathb\AmongUs" -Recurse -Force
                    legendary.exe install "Among Us" --old-manifest "$epicmanifestfile" --disable-patching --enable-reordering --repair -y
                }else{
                    Write-Log "何かがおかしい・・・"
                }

                $ptt = (Format-Hex -Path "$aupathb\AmongUs\Among Us_Data\globalgamemanagers").Bytes
                $ptt2 = [System.Text.Encoding]::UTF8.GetString($ptt)
                $ptt3 = [regex]::Matches($ptt2, "(19|20)[0-9]{2}[- /.]([1-9]|0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])")
                $pmver = $ptt3[1].Value
                
                if($pmver -eq $prever){
                    #success
                    Write-Log $(Get-Translate("Download 成功"))
                    Compress-7Zip -Path "$aupathb\AmongUs" -ArchiveFileName $(Join-path $aupathb "Among Us-$datest-v$prever.zip")

                    if(!(Test-Path "$aupathb\epic_manifest")){
                        New-Item "$aupathb\epic_manifest" -Type Directory
                    }
                    if(($epicmanifestchk) -and ($epicmanifestfile -eq "$aupathb\epic_manifest\v$prever.manifest")){
                    }else{
                        Copy-Item $epicmanifestfile "$aupathb\epic_manifest\v$prever.manifest"        
                        Remove-Item $epicmanifestfile -Force
                    }
                }else{
                    Write-Log "Download 失敗か、指定されたManifestが選択されたバージョンではありませんでした"
                    Write-Log "指定したManifestを確認するか、再度やり直してください"
                    Remove-Item $epicmanifestfile -Force
                    Pause
                    Exit
                }

                if(Test-Path "$aupathb\AmongUs"){
                    Remove-item "$aupathb\AmongUs" -Recurse -Force
                } 
            }
        }
    }
    Write-Log "Backup Feature Ends"
}

# パイプラインからのファイルのハッシュ情報を取得する.
#https://gist.github.com/seraphy/4674696
function MakeHashInfo([string] $algoName = $(throw "MD5, SHA1, SHA512などを指定します.")){
    begin {
        $algo = [System.Security.Cryptography.HashAlgorithm]::Create($algoName)

        # ファイルのハッシュ値を計算するスクリプトブロック(Closure)
        function CalcurateHash([string] $path) {
            $inputStream = New-Object IO.StreamReader $path
            try {
                $algo.ComputeHash($inputStream.BaseStream)
         
            } finally {
                $inputStream.Close()
            }
        }
    }
    process { # パイプライン処理
    $hashVal = ToHex(CalcurateHash $_.FullName)
        $_ | Add-Member -MemberType NoteProperty -Name $algoName -Value $hashVal
    return $_
    }
    end {
        [void] $algo.Dispose # voidを指定しないと後続パイプラインにnullが渡される
    }
}
#################################################################################################
### Convertfrom-vdf
### Ref. from https://github.com/ChiefIntegrator/Steam-GetOnTop
#################################################################################################
Function ConvertFrom-VDF {
    param
    (
		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [System.String[]]$InputObject
	)
    process
    {
        $root = New-Object -TypeName PSObject
        $chain = [ordered]@{}
        $depth = 0
        $parent = $root
        $element = $null
        ForEach ($line in $InputObject)
        {
            $quotedElements = (Select-String -Pattern '(?<=")([^\"\t\s]+\s?)+(?=")' -InputObject $line -AllMatches).Matches
            if ($quotedElements.Count -eq 1) # Create a new (sub) object
            {
                $element = New-Object -TypeName PSObject
                Add-Member -InputObject $parent -MemberType NoteProperty -Name $quotedElements[0].Value -Value $element
            }
            elseif ($quotedElements.Count -eq 2) # Create a new String hash
            {
                Add-Member -InputObject $element -MemberType NoteProperty -Name $quotedElements[0].Value -Value $quotedElements[1].Value
            }
            elseif ($line -match "{")
            {
                $chain.Add($depth, $element)
                $depth++
                $parent = $chain.($depth - 1) # AKA $element
            }
            elseif ($line -match "}")
            {
                $depth--
                $parent = $chain.($depth - 1)
				$element = $parent
                $chain.Remove($depth)
            }
            else # Comments etc
            {
            }
        }
        return $root
    }  
}
#################################################################################################
### 高速Download
#################################################################################################

if(!(Test-Path "C:\Temp")){
    New-Item "C:\Temp" -Type Directory
}

try{
    aria2c -v | Out-Null
}
catch{
    try{
        choco -v
    }catch{
        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
    }
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 legendary microsoft-windows-terminal -y" -Verb RunAs -Wait   
}
#################################################################################################
# Clock Sync
#################################################################################################

$l = w32tm /query /status 
if ($l.contains("0x80070426")){
    net start "windows time"
    start-sleep -Seconds 5
}
#Write-Log $l
$l = w32tm /monitor /computers:time.google.com
#Write-Log $l
$l = w32tm /config /syncfromflags:manual /manualpeerlist:"time.google.com,0x8 time.aws.com,0x8 time.cloudflare.com,0x8" /reliable:yes /update
#Write-Log $l
$l = w32tm /resync
#Write-Log $l
$l = w32tm /query /status 
#Write-Log $l

#################################################################################################
### Mod 選択メニュー表示
#################################################################################################
#Special Thanks
#https://letspowershell.blogspot.com/2015/07/powershell_29.html
# アセンブリのロード
#　アセンブリの読み込み
[void][System.Reflection.Assembly]::Load("Microsoft.VisualBasic, Version=8.0.0.0, Culture=Neutral, PublicKeyToken=b03f5f7f11d50a3a")
[System.Windows.Forms.Application]::EnableVisualStyles()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$platform = ""

# フォントの指定
$Font = New-Object System.Drawing.Font("メイリオ",12)

# フォーム全体の設定
$form = New-Object System.Windows.Forms.Form
$form.Text = "Among Us Mod Auto Deploy Tool"
$form.Size = New-Object System.Drawing.Size(815,680)
$form.StartPosition = "CenterScreen"
$form.font = $Font
$form.FormBorderStyle = "Fixed3D"
$form.MaximumSize = "815,850"

# ラベルを表示
$label8 = New-Object System.Windows.Forms.Label
$label8.Location = New-Object System.Drawing.Point(15,15)
$label8.Size = New-Object System.Drawing.Size(270,30)
$label8.Text = "$version"
$form.Controls.Add($label8)

# ラベルを表示
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(15,55)
$label.Size = New-Object System.Drawing.Size(370,40)
$label.Text = $(Get-Translate("インストールしたいModを選択してください"))
$form.Controls.Add($label)

# OKボタンの設定
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(580,590)
$OKButton.Size = New-Object System.Drawing.Size(75,30)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

# キャンセルボタンの設定
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(680,590)
$CancelButton.Size = New-Object System.Drawing.Size(75,30)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

# グループを作る
$MyGroupBox3 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox3.Location = New-Object System.Drawing.Point(400,10)
$MyGroupBox3.size = New-Object System.Drawing.Size(375,100)
$MyGroupBox3.text = $(Get-Translate("既存のフォルダを上書き/再作成しますか？"))

# グループの中のラジオボタンを作る
$RadioButton5 = New-Object System.Windows.Forms.RadioButton
$RadioButton5.Location = New-Object System.Drawing.Point(10,30)
$RadioButton5.size = New-Object System.Drawing.Size(120,30)
$RadioButton5.Checked = $True
$RadioButton5.Text = $(Get-Translate("再作成する"))

$RadioButton6 = New-Object System.Windows.Forms.RadioButton
$RadioButton6.Location = New-Object System.Drawing.Point(10,60)
$RadioButton6.size = New-Object System.Drawing.Size(130,30)
$RadioButton6.Text = $(Get-Translate("再作成しない"))

$RadioButton7 = New-Object System.Windows.Forms.RadioButton
$RadioButton7.Location = New-Object System.Drawing.Point(160,30)
$RadioButton7.size = New-Object System.Drawing.Size(120,30)
$RadioButton7.Text = $(Get-Translate("上書きする"))

$RadioButton17 = New-Object System.Windows.Forms.RadioButton
$RadioButton17.Location = New-Object System.Drawing.Point(160,60)
$RadioButton17.size = New-Object System.Drawing.Size(190,30)
$RadioButton17.Text = $(Get-Translate("クリーンインストール"))

# グループにラジオボタンを入れる
$MyGroupBox3.Controls.AddRange(@($Radiobutton5, $RadioButton6, $RadioButton7, $RadioButton17))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox3)

###本体バージョン！
# グループを作る
$MyGroupBox4 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox4.Location = New-Object System.Drawing.Point(400,120)
$MyGroupBox4.size = New-Object System.Drawing.Size(375,70)
$MyGroupBox4.text = $(Get-Translate("本体Versionを選択してください"))

# グループの中のラジオボタンを作る
$RadioButton114 = New-Object System.Windows.Forms.RadioButton
$RadioButton114.Location = New-Object System.Drawing.Point(10,30)
$RadioButton114.size = New-Object System.Drawing.Size(120,30)
$RadioButton114.Text = $(Get-Translate("A"))
$RadioButton114.Checked = $True

$RadioButton115 = New-Object System.Windows.Forms.RadioButton
$RadioButton115.Location = New-Object System.Drawing.Point(130,30)
$RadioButton115.size = New-Object System.Drawing.Size(120,30)
$RadioButton115.Text = $(Get-Translate("B"))

$RadioButton116 = New-Object System.Windows.Forms.RadioButton
$RadioButton116.Location = New-Object System.Drawing.Point(250,30)
$RadioButton116.size = New-Object System.Drawing.Size(120,30)
$RadioButton116.Text = $(Get-Translate("C"))


# グループにラジオボタンを入れる
$MyGroupBox4.Controls.AddRange(@($Radiobutton114, $RadioButton115, $RadioButton116))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox4)

###作成したModのExeへのショートカットをDesktopに配置する
# グループを作る
$MyGroupBox = New-Object System.Windows.Forms.GroupBox
$MyGroupBox.Location = New-Object System.Drawing.Point(400,200)
$MyGroupBox.size = New-Object System.Drawing.Size(375,70)
$MyGroupBox.text = $(Get-Translate("ショートカットを作成しますか？"))

# グループの中のラジオボタンを作る
$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = New-Object System.Drawing.Point(10,30)
$RadioButton1.size = New-Object System.Drawing.Size(100,30)
$RadioButton1.Checked = $True
$RadioButton1.Text = $(Get-Translate("作成する"))

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = New-Object System.Drawing.Point(130,30)
$RadioButton2.size = New-Object System.Drawing.Size(110,30)
$RadioButton2.Text = $(Get-Translate("作成しない"))

$RadioButton42 = New-Object System.Windows.Forms.RadioButton
$RadioButton42.Location = New-Object System.Drawing.Point(250,30)
$RadioButton42.size = New-Object System.Drawing.Size(100,30)
$RadioButton42.Text = $(Get-Translate("デバッグ"))

# グループにラジオボタンを入れる
$MyGroupBox.Controls.AddRange(@($Radiobutton1, $RadioButton2, $RadioButton42))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox)

###作成したModを即座に実行する
#デフォルトでは実行しない
# グループを作る
$MyGroupBox2 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox2.Location = New-Object System.Drawing.Point(400,280)
$MyGroupBox2.size = New-Object System.Drawing.Size(375,70)
$MyGroupBox2.text = $(Get-Translate("すぐに起動しますか？"))

# グループの中のラジオボタンを作る
$RadioButton3 = New-Object System.Windows.Forms.RadioButton
$RadioButton3.Location = New-Object System.Drawing.Point(10,30)
$RadioButton3.size = New-Object System.Drawing.Size(150,30)
$RadioButton3.Text = $(Get-Translate("起動する"))

$RadioButton4 = New-Object System.Windows.Forms.RadioButton
$RadioButton4.Location = New-Object System.Drawing.Point(160,30)
$RadioButton4.size = New-Object System.Drawing.Size(150,30)
$RadioButton4.Text = $(Get-Translate("起動しない"))
$RadioButton4.Checked = $True

# グループにラジオボタンを入れる
$MyGroupBox2.Controls.AddRange(@($Radiobutton3, $RadioButton4))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox2)

# フォームに各アイテムを入れる
$MyGroupBox24 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox24.Location = New-Object System.Drawing.Point(400,360)
$MyGroupBox24.size = New-Object System.Drawing.Size(375,70)
$MyGroupBox24.text = $(Get-Translate("Submerged を同梱しますか？"))

# グループの中のラジオボタンを作る
$RadioButton28 = New-Object System.Windows.Forms.RadioButton
$RadioButton28.Location = New-Object System.Drawing.Point(10,30)
$RadioButton28.size = New-Object System.Drawing.Size(100,30)
$RadioButton28.Text = $(Get-Translate("同梱する"))

$RadioButton29 = New-Object System.Windows.Forms.RadioButton
$RadioButton29.Location = New-Object System.Drawing.Point(130,30)
$RadioButton29.size = New-Object System.Drawing.Size(110,30)
$RadioButton29.Text = $(Get-Translate("同梱しない"))
$RadioButton29.Checked = $True

$RadioButton27 = New-Object System.Windows.Forms.RadioButton
$RadioButton27.Location = New-Object System.Drawing.Point(250,30)
$RadioButton27.size = New-Object System.Drawing.Size(100,30)
$RadioButton27.Text = $(Get-Translate("除去する"))

# グループにラジオボタンを入れる
$MyGroupBox24.Controls.AddRange(@($Radiobutton28, $RadioButton29, $RadioButton27))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox24)


# ラベルを表示
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(15,240)
$label2.Size = New-Object System.Drawing.Size(370,30)
$label2.Text = $(Get-Translate("インストールしたいToolを選択してください"))
$form.Controls.Add($label2)

# チェックボックスを作成
$CheckedBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedBox.Location = "55,270"
$CheckedBox.Size = "330,185"

# 配列を作成 ,"OBS","Streamlabs OBS""GMH Webhook",,"NOS CPU Affinity"
$RETU = ("AmongUsCapture","VC Redist","BetterCrewLink","PowerShell 7","dotNetFramework","カスタムサーバー情報追加","サーバー情報初期化","配信ソフト","健康ランド")
# チェックボックスに10項目を追加
$CheckedBox.Items.AddRange($RETU)

# すべての既存の選択をクリア
$CheckedBox.ClearSelected()
$form.Controls.Add($CheckedBox)

# コンボボックスを作成
$Combo = New-Object System.Windows.Forms.Combobox
$Combo.Location = New-Object System.Drawing.Point(55,95)
$Combo.size = New-Object System.Drawing.Size(330,30)
$Combo.DropDownStyle = "DropDownList"
$Combo.FlatStyle = "standard"
$Combo.font = $Font
$form.Icon = "$dsk\AUMADS.ico"
# コンボボックスに項目を追加
#[void] $Combo.Items.Add("TOR GMH :haoming37/TheOtherRoles-GM-Haoming")
#[void] $Combo.Items.Add("TOR GMH Test :haoming37/TheOtherRoles-GM-Haoming-Test")
[void] $Combo.Items.Add("NOS :Dolly1016/Nebula on the Ship")
if($gmhbool){
    [void] $Combo.Items.Add("NOT :Dolly1016/Nebula on the Test")
}
[void] $Combo.Items.Add("AMS :AUModS/AUModS")
#[void] $Combo.Items.Add("TOR MR :miru-y/TheOtherRoles-MR")
[void] $Combo.Items.Add("TOR :TheOtherRolesAU/TheOtherRoles")
[void] $Combo.Items.Add("TOU-R :eDonnes124/Town-Of-Us-R")
[void] $Combo.Items.Add("ER :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("ER+ES :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("LM :KiraYamato94/LasMonjas")
[void] $Combo.Items.Add("SNR :ykundesu/SuperNewRoles")
[void] $Combo.Items.Add("TOH :tukasa0001/TownOfHost")
[void] $Combo.Items.Add("TOY :Yumenopai/TownOfHost_Y")
[void] $Combo.Items.Add("Install/Update Selected")
[void] $Combo.Items.Add("Tool Install Only")
$Combo.SelectedIndex = 0

$isall = $false
$opflag = $false
$ym = Get-Date -Format yyyyMM

##############################################

# ラベルを表示
$label7 = New-Object System.Windows.Forms.Label
$label7.Location = New-Object System.Drawing.Point(15,140)
$label7.Size = New-Object System.Drawing.Size(370,30)
$label7.Text = $(Get-Translate("インストールしたいVersionを選択してください"))
$form.Controls.Add($label7)

# コンボボックスを作成
$Combo2 = New-Object System.Windows.Forms.Combobox
$Combo2.Location = New-Object System.Drawing.Point(55,180)
$Combo2.size = New-Object System.Drawing.Size(330,30)
$Combo2.DropDownStyle = "DropDownList"
$Combo2.FlatStyle = "standard"
$Combo2.font = $Font

# ラベルを表示
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(15,460)
$label3.Size = New-Object System.Drawing.Size(570,20)
$label3.Text = $(Get-Translate("オリジナルのAmongUsは以下の場所に検出されました"))
$form.Controls.Add($label3)

# ラベルを表示
$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(20,480)
$label4.Size = New-Object System.Drawing.Size(770,50)
$label4.Text = ""
$form.Controls.Add($label4)

# ラベルを表示
$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(15,530)
$label5.Size = New-Object System.Drawing.Size(570,20)
$label5.Text = $(Get-Translate("Mod化バージョンは以下の場所に作成されます"))
$form.Controls.Add($label5)

# ラベルを表示
$label6 = New-Object System.Windows.Forms.Label
$label6.Location = New-Object System.Drawing.Point(20,550)
$label6.Size = New-Object System.Drawing.Size(770,50)
$label6.Text = ""
$form.Controls.Add($label6)

$scid = "TOR GMH"
$tio = $true
$aumin = ""
$aumax = "NONE"
$aupatho = ""
$aupathm = ""
$aupathb = ""
$releasepage =""
$ovwrite = $false
$amver = ""
$prebool = $false
$latestflag = 0

function VerMinMax($ver0, $ver1, $ver2){
    if($RadioButton114.Checked){
        if($ver0 -eq "NONE"){
            $script:aumin = "NONE"
            $script:aumax = "NONE"
        }else{
            $script:aumax = "NONE"
            $script:aumin = $ver0
        }
        $script:latestflag = 1
    }elseif($RadioButton115.Checked){
        if($ver1 -eq "NONE"){
            $script:aumax = "NONE"
            $script:aumin = "NONE"
        }else{
            if($ver0 -eq "NONE"){
                $script:aumax = "NONE"
                $script:aumin = $ver1
            }elseif($ver0 -eq $ver1){
                $script:aumax = "NONE"
                $script:aumin = $ver1
            }else{
                $script:aumax = $ver0
                $script:aumin = $ver1    
            }
        }
        $script:latestflag = 2
    }elseif($RadioButton116.Checked){
        if($ver2 -eq "NONE"){
            $script:aumax = "NONE"
            $script:aumin = "NONE"
        }else{
            if($ver1 -eq "NONE"){
                if($ver0 -eq "NONE"){
                    $script:aumax = "NONE"
                    $script:aumin = $ver2
                }else{
                    $script:aumax = $ver0
                    $script:aumin = $ver2    
                }
            }elseif($ver1 -eq $ver2){
                $script:aumax = $ver0
                $script:aumin = $ver2    
            }else{
                $script:aumax = $ver1
                $script:aumin = $ver2
            }
        }
        $script:latestflag = 3
    }
}

function Reload(){
    function Write-Log($LogString){
        $Now = Get-Date
        # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $LogString)
        $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
        $Log += $LogString
        # ログ出力
        Write-Output $Log | Out-File -FilePath $script:LogFileName -Encoding Default -Append
        # echo させるために出力したログを戻す
        Write-Host $Log
    }

    $combo2.Text = ""
    $combo2.DataSource=@()
    $combo2.Enabled = $true
    $tio = $true

    Switch ($combo.text){
        default{
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            VerMinMax $nosmin $nosmin1 $nosmin2
            Write-Log "NOS Selected"
            $RadioButton29.Checked = $True
        }"AMS :AUModS/AUModS"{
            $releasepage2 = "https://api.github.com/repos/AUModS/AUModS/releases"
            $scid = "AMS"
            VerMinMax $amsmin $amsmin1 $amsmin2
            Write-Log "AMS Selected"
            $RadioButton29.Checked = $True
        }"TOR MR :miru-y/TheOtherRoles-MR"{
            $releasepage2 = "https://api.github.com/repos/miru-y/TheOtherRoles-MR/releases"
            $scid = "TOR MR"
            VerMinMax $tormmin $tormmin1 $tormmin2
            Write-Log "TOR MR Selected"
            $RadioButton29.Checked = $True
        }"NOT :Dolly1016/Nebula on the Test"{
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOT"
            VerMinMax $notmin $notmin1 $notmin2
            Write-Log "NOT Selected"
            $RadioButton29.Checked = $True
        }"TOR GMH :haoming37/TheOtherRoles-GM-Haoming"{
            $releasepage2 = "https://api.github.com/repos/haoming37/TheOtherRoles-GM-Haoming/releases"
            $scid = "TOR GMH"
            VerMinMax $torhmin $torhmin1 $torhmin2
            Write-Log "TOR GMH Selected"
            $RadioButton29.Checked = $True
        }"TOR :TheOtherRolesAU/TheOtherRoles"{
            $releasepage2 = "https://api.github.com/repos/TheOtherRolesAU/TheOtherRoles/releases"
            $scid = "TOR"
            VerMinMax $tormin $tormin1 $tormin2
            Write-Log "TOR Selected"
            $RadioButton28.Checked = $True
        }"TOU-R :eDonnes124/Town-Of-Us-R"{
            $releasepage2 = "https://api.github.com/repos/eDonnes124/Town-Of-Us-R/releases"
            $scid = "TOU-R"
            VerMinMax $tourmin $tourmin1 $tourmin2
            Write-Log "TOU-R Selected"
            $RadioButton29.Checked = $True
        }"ER :yukieiji/ExtremeRoles"{
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER"
            VerMinMax $ermin $ermin1 $ermin2
            Write-Log "ER Selected"
            $RadioButton29.Checked = $True
        }"ER+ES :yukieiji/ExtremeRoles"{
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER+ES"
            VerMinMax $esmin $esmin1 $esmin2
            $aumin = $esmin
            Write-Log "ER+ES Selected"
            $RadioButton29.Checked = $True
        }"NOS :Dolly1016/Nebula"{
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            VerMinMax $nosmin $nosmin1 $nosmin2
            Write-Log "NOS Selected"
            $RadioButton29.Checked = $True
        }"LM :KiraYamato94/LasMonjas"{
            $releasepage2 = "https://api.github.com/repos/KiraYamato94/LasMonjas/releases"
            $scid = "LM"
            VerMinMax $lmmin $lmmin1 $lmmin2
            Write-Log "LM Selected"
            $RadioButton29.Checked = $True
        }"SNR :ykundesu/SuperNewRoles"{
            $releasepage2 = "https://api.github.com/repos/ykundesu/SuperNewRoles/releases"
            $scid = "SNR"
            VerMinMax $snrmin $snrmin1 $snrmin2
            Write-Log "SNR Selected"
            $RadioButton29.Checked = $True
        }"TOH :tukasa0001/TownOfHost"{
            $releasepage2 = "https://api.github.com/repos/tukasa0001/TownOfHost/releases"
            $scid = "TOH"
            VerMinMax $tohmin $tohmin1 $tohmin2
            Write-Log "TOH Selected"
            $RadioButton29.Checked = $True
        }"TOY :Yumenopai/TownOfHost_Y"{
            $releasepage2 = "https://api.github.com/repos/Yumenopai/TownOfHost_Y/releases"
            $scid = "TOY"
            VerMinMax $toymin $toymin1 $toymin2
            Write-Log "TOY Selected"
            $RadioButton29.Checked = $True
        }"Install/Update Selected"{
            $scid = "IUS"
            $tio = $false
            Write-Log "SAL Selected"
            $combo2.Enabled = $false
            $script:isall = $true
        }"Tool Install Only"{
            $scid = "TIO"
            $tio = $false
            Write-Log "TIO Selected"
            $combo2.Enabled = $false
        }
    }

    if($tio){
        #GithubのRelease一覧からぶっこぬく
        if(($scid -eq "TOR GMH") -or ($scid -eq "TOR GMT")){
            if($null -eq $script:gmhweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:gmhweb = $web
            }else{
                $web = $script:gmhweb
            }
        }elseif($scid -eq "TOR MR"){
            if($null -eq $script:mrweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:mrweb = $web
            }else{
                $web = $script:mrweb
            }
        }elseif($scid -eq "TOR"){
            if($null -eq $script:torweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:torweb = $web
            }else{
                $web = $script:torweb
            }
        }elseif($scid -eq "TOU-R"){
            if($null -eq $script:tourweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:tourweb = $web
            }else{
                $web = $script:tourweb
            }
        }elseif(($scid -eq "ER") -or ($scid -eq "ER+ES")){
            if($null -eq $script:erweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:erweb = $web
            }else{
                $web = $script:erweb
            }
        }elseif(($scid -eq "NOS") -or ($scid -eq "NOT")){
            if($null -eq $script:nosweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:nosweb = $web
            }else{
                $web = $script:nosweb
            }
        }elseif($scid -eq "LM"){
            if($null -eq $script:lmweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:lmweb = $web
            }else{
                $web = $script:lmweb
            }
        }elseif($scid -eq "SNR"){
            if($null -eq $script:snrweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:snrweb = $web
            }else{
                $web = $script:snrweb
            }
        }elseif($scid -eq "TOH"){
            if($null -eq $script:tohweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:tohweb = $web
            }else{
                $web = $script:tohweb
            }
        }elseif($scid -eq "TOY"){
            if($null -eq $script:toyweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:toyweb = $web
            }else{
                $web = $script:toyweb
            }
        }elseif($scid -eq "AMS"){
            if($null -eq $script:amsweb){
                $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
                $script:amsweb = $web
            }else{
                $web = $script:amsweb
            }
        }else{
            $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
        }

        $web2 = ConvertFrom-Json $web.Content
    
        $list2 =@()
        # コンボボックスに項目を追加
        $OKButton.Enabled=$True
        if($script:aumin -ne "NONE"){
            if($script:aumax -ne "NONE"){
                if(($scid -eq "NOS") -or ($scid -eq "NOT")){
                    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                        if(($web2.tag_name[$ai] -ge $script:aumin) -and ($web2.tag_name[$ai] -lt $script:aumax)){
                            if($($($web2.tag_name[$ai]).ToLower()).indexof("lang") -lt 0){
                                $list2 += $($web2.tag_name[$ai])
                            }        
                        }
                    }            
                }else{            
                    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                        if(($web2.tag_name[$ai] -ge $script:aumin) -and ($web2.tag_name[$ai] -lt $script:aumax)){
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }    
            }else{
                if(($scid -eq "NOS") -or ($scid -eq "NOT")){
                    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                        if(($web2.tag_name[$ai] -ge $script:aumin)){
                            if($($($web2.tag_name[$ai]).ToLower()).indexof("lang") -lt 0){
                                if($($web2.tag_name[$ai]) -ne "snapshot"){
                                    $list2 += $($web2.tag_name[$ai])
                                }
                            }        
                        }
                    }            
                }else{            
                    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                        if(($web2.tag_name[$ai] -ge $script:aumin)){
                            $list2 += $($web2.tag_name[$ai])
                        }
                    }
                }    

            }
        }else{
            $OKButton.Enabled=$false
        }

        $combo2.DataSource = $list2
        if($list2.Length -gt 0){
            $Combo2.SelectedIndex = 0            
        }

        #################################################################################################
        #AutoDetect用Static
        #################################################################################################

        #Among Us Original Steam Path
        $au_path_steam_org = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
        #Among Us Modded Path ：Steam Mod用フォルダ
        $au_path_steam_mod = "C:\Program Files (x86)\Steam\steamapps\common\Among Us $scid Mod"
        #Among Us Backup ：Backup用フォルダ
        $au_path_steam_back = "C:\Program Files (x86)\Steam\steamapps\common\Among Us Backup"
        #Among Us Original Epic Path
        $au_path_epic_org = "C:\Program Files\Epic Games\AmongUs"
        #Among Us Modded Path ：Steam Mod用フォルダ
        $au_path_epic_mod = "C:\Program Files\Epic Games\AmongUs $scid Mod"
        #Among Us Backup ：Backup用フォルダ
        $au_path_epic_back = "C:\Program Files\Epic Games\AmongUsBackup"
  
        #detector
        #E:\SteamLibrary\steamapps\common
        foreach ($num in 65..90) {                                     
            if(Test-Path "$([char]$num):\SteamLibrary\steamapps\common\Among Us"){
                $detected_path = "$([char]$num):\SteamLibrary\steamapps\common\Among Us"
                $detected_path_mod = "$([char]$num):\SteamLibrary\steamapps\common\Among Us $scid Mod"
                $detected_path_back = "$([char]$num):\SteamLibrary\steamapps\common\Among Us Backup"
                break
            }     
        }

        if(Test-path "$au_path_steam_org\Among Us.exe"){
            #original check Steamのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$au_path_steam_org\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("オリジナルパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
                    $fpth2 = "$npl\AmongusCleanInstall_Steam.ps1"
                    if(test-path "$env:ProgramFiles\PowerShell\7"){
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }else{
                        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }
                    Start-Sleep -Seconds 10
                    $fichk = Test-Path "$aupatho\Among Us.exe"
                    while ($fichk){
                        Start-Sleep -Seconds 10
                        Write-Log "再インストールが完了したことを確認してから以下の動作を実行してください"
                        Pause
                        $fichk = Test-Path "$aupatho\Among Us.exe"
                    }
                    Remove-Item $fpth2 -Force
                }else{
                    Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください"
                    Write-Log "処理を中止します"
                    pause
                    exit
                }     
                Remove-Item "$npl\AmongusCleanInstall_Steam.ps1"
            }
            $aupatho = $au_path_steam_org
            $aupathm = $au_path_steam_mod
            $aupathb = $au_path_steam_back
            $script:platform = "steam"
        }elseif(Test-path "$au_path_epic_org\Among Us.exe"){
            #original check Epicのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$au_path_epic_org\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("オリジナルパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1" -OutFile "$npl\AmongusCleanInstall_Epic.ps1" -UseBasicParsing
                    $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                    if(test-path "$env:ProgramFiles\PowerShell\7"){
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }else{
                        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }
                    Remove-Item $fpth2 -Force
                }else{
                    Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください"
                    Write-Log "処理を中止します"
                    pause
                    exit
                }     
                Remove-Item "$npl\AmongusCleanInstall_Epic.ps1"
            }
            $aupatho = $au_path_epic_org
            $aupathm = $au_path_epic_mod
            $aupathb = $au_path_epic_back
            $script:platform = "epic"
        }elseif(Test-Path "$detected_path\Among Us.exe"){
            #original check Epicのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$detected_path\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("オリジナルパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
                    $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                    if(test-path "$env:ProgramFiles\PowerShell\7"){
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }else{
                        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                    }
                    Remove-Item $fpth2 -Force
                }else{
                    Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください"
                    Write-Log "処理を中止します"
                    pause
                    exit
                }     
                Remove-Item "$npl\AmongusCleanInstall_Steam.ps1"
            }
            $aupatho = $detected_path
            $aupathm = $detected_path_mod
            $aupathb = $detected_path_back
            $script:platform = "steam"
        }else{
            $fileName2 = Join-path $npl "\AmongUsModDeployScript.conf"
            $fileName = Join-path $dsk "\AmongUsModDeployScript.conf"
            if(test-path "$fileName2"){
                Move-Item -Path $fileName2 -Destination $fileName
            }
            $chkvdf = $false
            if(Test-Path "C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"){
                $stvdf = Get-Content "C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"
                $chkvdf = $true
            }elseif(Test-Path "D:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"){
                $stvdf = Get-Content "D:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"
                $chkvdf = $true
            }
            ### Load
            if(test-path "$fileName"){
                $spath2 = Get-content "$fileName"
                $spath3 = $spath2.split("_:_")
                $spath = $spath3[0] 
                $script:platform = $spath3[1]
                Remove-Item $fileName
            }else{
                $loadfail = $false
                if($chkvdf){
                    $cfvdf = ConvertFrom-VDF $stvdf
                    foreach( $property in $cfvdf.libraryfolders.psobject.properties.name ){
                        if(([string]$($cfvdf.libraryfolders."$property".apps)).contains("945360")){
                            $cfpth = Join-Path $cfvdf.libraryfolders."$property".path "\steamapps\common\Among Us"
                        }
                    }
                    if(Test-Path $cfpth){
                        Write-Log "detected from VDF."
                        $spath = $cfpth
                        $script:platform = "steam"
                        $loadfail = $false
                    }else{
                        Write-Log "Among Us may not installed with Steam."
                        $loadfail = $true
                    }
                }else{
                    $loadfail = $true
                }

                if($loadfail){
                    #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
                    Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"
                    Write-Log "フォルダをユーザーに選択するようダイアログを出します"
                    [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っていないAmongUsがインストールされているフォルダを選択してください")), "Among Us Mod Auto Deploy Tool")
                    $spath = Get-FolderPathG
                }
            }
            if($null -eq $spath){
                Write-Log "Scriptを再実行してAmong Usが含まれるフォルダを指定してください。$spath"
                pause
                Exit
            }
            if(test-path "$spath\Among Us.exe"){
                Write-Log "$spath にAmongUsのインストールパスを確認しました Platform:$script:platform"
                if(($script:platform -ne "Steam") -and ($script:platform -ne "Epic")){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("PlatformはSteamですか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                        $script:platform = "Steam"
                    }else{
                        $script:platform = "Epic"
                    }
                }
            }else{
                Write-Log "$spath にAmongUsのインストールが確認できませんでした"
                pause
                Exit
            }
            if(test-path $spath){
                if(Test-path "$spath\BepInEx"){
                    Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                    if($script:platform -eq "Steam"){
                        if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("指定されたパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                            Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
                            $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                            if(test-path "$env:ProgramFiles\PowerShell\7"){
                                Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                            }else{
                                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                            }
                            Remove-Item $fpth2 -Force
                            Write-Log "クリーンインストールが行われたため、処理を中止します"
                            Write-Log "Scriptを再度実行してください。"
                            pause
                            exit
                        }else{
                            Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください"
                            Write-Log "処理を中止します"
                            pause
                            exit
                        }     
                        Remove-Item "$npl\AmongusCleanInstall_Steam.ps1"
                    }elseif($script:platform -eq "Epic"){
                        if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("指定されたパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                            Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1" -OutFile "$npl\AmongusCleanInstall_Epic.ps1" -UseBasicParsing
                            $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                            if(test-path "$env:ProgramFiles\PowerShell\7"){
                                Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                            }else{
                                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                            }
                            Remove-Item $fpth2 -Force
                            Write-Log "クリーンインストールが行われたため、処理を中止します"
                            Write-Log "Scriptを再度実行してください。"
                            pause
                            exit
                        }else{
                            Write-Log "フォルダ指定が正しい場合は、手動でクリーンインストールを試してみてください"
                            Write-Log "処理を中止します"
                            pause
                            exit
                        }     
                        Remove-Item "$npl\AmongusCleanInstall_Epic.ps1"
                    }else{
                        Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                        Write-Log "フォルダ指定が正しい場合は、クリーンインストールを試してみてください"
                        Write-Log "処理を中止します"
                        pause
                        exit
                    }


                }
    
 
                $aupatho = $spath
                Set-Location $spath
                Set-Location ..
                $str_path = (Convert-Path .)
                Write-Log $str_path
                $aupathm = "$str_path\Among Us $scid Mod"
                $aupathb = "$str_path\Among Us Backup"
                Write-Log "Mod入りAmongUsは以下のフォルダにDeployされます"
                Write-Log $aupathm
                Write-Log $aupathb
                ### Auto Save
                $confcont = $aupatho
                $confcont += "_:_"
                $confcont += $script:platform
                Write-Output "$confcont"> $fileName
                Write-Log "Amongus ModDeployScript Autosave function"

            }else{
                Write-Log "選択されたフォルダにAmongUsを見つけることに失敗しました"
                Write-Log "処理を中止します"
                pause
                exit
            }
        }
        $label4.Text = $aupatho
        $label6.Text = $aupathm
        $script:aupatho = $aupatho
        $script:aupathm = $aupathm
        $script:aupathb = $aupathb
        $script:releasepage = $releasepage2
        $script:scid = $scid
        $script:aumin = $aumin
        $script:tio = $tio
        $ym = $script:ym
        if(!(Test-Path "$aupathb\chk$ym.txt")){
            $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("VC Redist"), $true)
            $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("dotNetFramework"), $true)                         
            $pwshv = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" -UseBasicParsing)).tag_name
            if("v$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)" -ne "$pwshv"){
                $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("PowerShell 7"), $true)
            }
            $script:opflag = $true
        }
    }
    $script:tio = $tio
    #version detect
    $tt = (Format-Hex -Path "$script:aupatho\Among Us_Data\globalgamemanagers").Bytes
    $tt2 = [System.Text.Encoding]::UTF8.GetString($tt)
    $tt3 = [regex]::Matches($tt2, "(19|20)[0-9][2-9][- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|1[0-9]|2[0-9]|3[01]|[1-9])")
    $script:amver = $tt3[0].Value
    Write-Log "$script:amver が検出されました"
    $RadioButton114.Text = $(Get-Translate("$script:amver"))
    $RadioButton115.Text = $(Get-Translate("$script:prever0"))        
    $RadioButton116.Text = $(Get-Translate("$script:prever1"))        
    if($RadioButton114.Checked){
        Write-Log "本体バージョン v$script:amver が選択されています"
    }elseif($RadioButton115.Checked){
        Write-Log "本体バージョン v$($RadioButton115.Text) が選択されています"
    }elseif($RadioButton116.Checked){
        Write-Log "本体バージョン v$($RadioButton116.Text) が選択されています"
    }else{
        Write-Log "Unknown ERROR:本体バージョン"
    }
}

$Combo_SelectedIndexChanged= {
    Reload
}

$RadioButton114.Add_CheckedChanged({
    Reload
})
$RadioButton115.Add_CheckedChanged({
    Reload
})
$RadioButton116.Add_CheckedChanged({
    Reload
})

$sttime = Get-Date

# フォームにコンボボックスを追加
$form.Controls.Add($Combo)
$form.Controls.Add($Combo2)
Invoke-Command -ScriptBlock $Combo_SelectedIndexChanged
$Combo.add_SelectedIndexChanged($Combo_SelectedIndexChanged)

if($null -eq $Args1){
    # フォームを最前面に表示
    $form.Topmost = $True
    # フォームを表示＋選択結果を変数に格納
    $result = $form.ShowDialog()

    # 選択後、OKボタンが押された場合、選択項目を表示
    if ($result -eq "OK"){
        $mod = $combo.Text
        $torpv = $combo2.Text
    }else{
        exit
    }
}else{
    if($latestflag -eq 1){
        $RadioButton114.Checked = $True
    }elseif($latestflag -eq 2){
        $RadioButton115.Checked = $True
    }elseif($latestflag -eq 3){
        $RadioButton116.Checked = $True
    }else{
        Write-Log "Critical:Latest Flag"
    }
    $combo.SelectedIndex = $Args1
    Reload
    $mod = $combo.Text
    $torpv = $combo2.Text
}

if($isall){
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
    $modnum = $($combo.items.count) -2

    $RETU2 =@("ALL")
    # 配列を作成
    for($ial = 0;$ial -lt $modnum;$ial++){
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
    if ( $result0 -eq "OK" ){
        $AAA2 = @($CheckedBox0.CheckedItems)
    }else{
        exit
    }

    # プログレスバー
    $Form22 = New-Object System.Windows.Forms.Form
    $Form22.Size = "520,270"
    $Form22.Startposition = "CenterScreen"
    $Form22.Text = "Among Us Mod Auto Deploy Tool"
    $form22.Icon = "$dsk\AUMADS.ico"
    $form22.FormBorderStyle = "Fixed3D"
    $Form22.font = $Font

    $label2222 = New-Object System.Windows.Forms.Label
    $label2222.Location = New-Object System.Drawing.Point(10,10)
    $label2222.Size = New-Object System.Drawing.Size(500,120)
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
    if($AAA2.contains("ALL")){
        $modsel = $modnum
    }else{
        $modsel = $AAA2.Count
    }
    $currentphase = 0
    Write-Log "SAL: $modnum $modsel"
    Write-Log "SAL: $AAA2"
    for($iall = 0;$iall -lt $modnum;$iall++){
        $Bar2.Value = "$($iall + 1)"
        if($AAA2.contains("$($combo.items[$iall])") -OR $AAA2.contains("ALL")){
            $currentphase++
            Write-Log "$($combo.items[$iall]) のインストールを開始しました。$currentphase/$modsel"
            $label2222.Text = $(Get-Translate("Among Us Mod $($combo.items[$iall])`r`nDeploy中です。 $currentphase/$modsel`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
            if(Test-Path "$npl\AmongUsModTORplusDeployScript.ps1"){
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$npl\AmongUsModTORplusDeployScript.ps1`" -Args1 `"$iall`" " -Verb RunAs -Wait
            }elseif(Test-Path "$dsk\AmongUsModTORplusDeployScript.ps1"){
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$dsk\AmongUsModTORplusDeployScript.ps1`" -Args1 `"$iall`" " -Verb RunAs -Wait
            }else{
                Write-Log "何かがおかしい。"
            }
            Write-Log "$($combo.items[$iall]) のインストールが完了しました。 $currentphase/$modsel"    
            $label2222.Text = $(Get-Translate("Among Us Mod のInstall/Update Selected が進行中です。`r`n$currentphase/$modsel`r`nこの画面が消えるまでできるだけ何も触らず待ってください"))
        }
    }

    $Form22.Close()
}


$prefpth = ""
if($RadioButton114.Checked){
    $prebool = $false
    Write-Log "本体バージョン v$amver が選択されています"
    $oldtype = $false
    $prevtargetid = $prevtargetid0
    $prever = $prever0
}elseif($RadioButton115.Checked){
    $prevtargetid = $prevtargetid0
    $prever = $prever0
    #ファイル一覧
    BackUpAU
    $items = Get-ChildItem $aupathb -File
    $nbool = $false
    foreach ($item in $items) {
        if(($item.Name).IndexOf("$prever") -gt 0){
            if(($item.Name).IndexOf(".zip") -gt 0){
                $prefpth = $item.Name 
                Write-Log $prefpth
                $nbool = $true
            }
        }
    }
    #chk pth
    if($nbool){
        if(Test-Path "$aupathb\$prefpth"){
            $prebool = $true
            Write-Log "本体バージョン v$prever が選択されています"
        }else{
            $prebool = $false    
            Write-Log "本体バージョン v$amver に選択が変更されました"
        }    
    }else{
        $prebool = $false    
        Write-Log "本体バージョン v$amver に選択が変更されました"
    }
}elseif($RadioButton116.Checked){
    $prevtargetid = $prevtargetid1
    $prever = $prever1
    #ファイル一覧
    BackUpAU
    $items = Get-ChildItem $aupathb -File
    $nbool = $false
    foreach ($item in $items) {
        if(($item.Name).IndexOf("$prever1") -gt 0){
            if(($item.Name).IndexOf(".zip") -gt 0){
                $prefpth = $item.Name 
                Write-Log $prefpth
                $nbool = $true
            }
        }
    }
    #chk pth
    if($nbool){
        if(Test-Path "$aupathb\$prefpth"){
            $prebool = $true
            Write-Log "本体バージョン v$prever が選択されています"
        }else{
            $prebool = $false    
            Write-Log "本体バージョン v$amver に選択が変更されました"
        }    
    }else{
        $prebool = $false    
        Write-Log "本体バージョン v$amver に選択が変更されました"
    }
}else{
    Write-Log "Critical:AU ver chk"
    exit
}

Write-Log "$mod が選択されました"
Write-Log "Version $torpv が選択されました"
Write-Log $releasepage

if($RadioButton28.Checked){
    $submerged = $true
}else{
    $submerged = $false
}
#################################################################################################>
#Webhook
#################################################################################################>
if($CheckedBox.CheckedItems -contains "GMH Webhook"){
    if($scid -eq "TOR GMH"){
        $form1113 = New-Object System.Windows.Forms.Form
        $form1113.Text = "GMH Webhook URL"
        $form1113.Size = New-Object System.Drawing.Size(500,140)
        $form1113.StartPosition = 'CenterScreen'
        $form1113.Icon = "$dsk\AUMADS.ico"
        $form1113.font = $Font

        $okButton11111 = New-Object System.Windows.Forms.Button
        $okButton11111.Location = New-Object System.Drawing.Point(380,70)
        $okButton11111.Size = New-Object System.Drawing.Size(75,23)
        $okButton11111.Text = 'OK'
        $okButton11111.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form1113.AcceptButton = $okButton11111
        $form1113.Controls.Add($okButton11111)
        
        $label11111 = New-Object System.Windows.Forms.Label
        $label11111.Location = New-Object System.Drawing.Point(10,10)
        $label11111.Size = New-Object System.Drawing.Size(280,20)
        $label11111.Text = "Discord のWebhook URLを入力してください。"
        $form1113.Controls.Add($label11111)
        
        $textBox11111 = New-Object System.Windows.Forms.TextBox
        $textBox11111.Location = New-Object System.Drawing.Point(10,30)
        $textBox11111.Size = New-Object System.Drawing.Size(460,20)
        $form1113.Controls.Add($textBox11111)
        
        $form1113.Topmost = $true
        
        $form1113.Add_Shown({$textBox11111.Select()})
        $result11111 = $form1113.ShowDialog()
        $gmhwebhooktxt = ""
        if ($result11111 -eq [System.Windows.Forms.DialogResult]::OK)
        {
            Write-Log $textBox11111.Text
            if($($textBox11111.Text).StartsWith("https")){
                $gmhwebhooktxt = $textBox11111.Text
                Write-Log "Webhook URL: $gmhwebhooktxt"
            }else{
                Write-Log "Webhook URLが無効、または入力されていません。Skipされます。"
                $gmhwebhooktxt = "None"
            }
        }    
    }    
}
#################################################################################################>
#ProcessorAffinity
#################################################################################################>
if($CheckedBox.CheckedItems -contains "NOS CPU Affinity"){
    if(($scid -eq "NOS") -or ($scid -eq "NOT")){
        $form11113 = New-Object System.Windows.Forms.Form
        $form11113.Text = "NOS CPU Affinity"
        $form11113.Size = New-Object System.Drawing.Size(400,150)
        $form11113.StartPosition = 'CenterScreen'
        $form11113.Icon = "$dsk\AUMADS.ico"
        $form11113.font = $Font

        $okButton111111 = New-Object System.Windows.Forms.Button
        $okButton111111.Location = New-Object System.Drawing.Point(300,80)
        $okButton111111.Size = New-Object System.Drawing.Size(75,23)
        $okButton111111.Text = 'OK'
        $okButton111111.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form11113.AcceptButton = $okButton111111
        $form11113.Controls.Add($okButton111111)
           
        # フォームに各アイテムを入れる
        $MyGroupBox124 = New-Object System.Windows.Forms.GroupBox
        $MyGroupBox124.Location = New-Object System.Drawing.Point(10,10)
        $MyGroupBox124.size = New-Object System.Drawing.Size(380,60)
        $MyGroupBox124.text = $(Get-Translate("CPU Affinityの値を選択してください。"))

        # グループの中のラジオボタンを作る
        $RadioButton128 = New-Object System.Windows.Forms.RadioButton
        $RadioButton128.Location = New-Object System.Drawing.Point(10,20)
        $RadioButton128.size = New-Object System.Drawing.Size(70,30)
        $RadioButton128.Text = $(Get-Translate("無制限")) #0

        $RadioButton129 = New-Object System.Windows.Forms.RadioButton
        $RadioButton129.Location = New-Object System.Drawing.Point(90,20)
        $RadioButton129.size = New-Object System.Drawing.Size(70,30)
        $RadioButton129.Text = $(Get-Translate("2コアHT")) #1

        $RadioButton127 = New-Object System.Windows.Forms.RadioButton
        $RadioButton127.Location = New-Object System.Drawing.Point(170,20)
        $RadioButton127.size = New-Object System.Drawing.Size(70,30)
        $RadioButton127.Text = $(Get-Translate("2コア")) #2

        $RadioButton126 = New-Object System.Windows.Forms.RadioButton
        $RadioButton126.Location = New-Object System.Drawing.Point(250,20)
        $RadioButton126.size = New-Object System.Drawing.Size(70,30)
        $RadioButton126.Text = $(Get-Translate("1コア")) #3
        $RadioButton126.Checked = $True

        # グループにラジオボタンを入れる
        $MyGroupBox124.Controls.AddRange(@($Radiobutton128, $RadioButton129, $RadioButton127, $RadioButton126))
        # フォームに各アイテムを入れる
        $form11113.Controls.Add($MyGroupBox124)
        $form11113.Topmost = $true        
        $result111111 = $form11113.ShowDialog()

        $gmhwebhooktxt = ""
        if ($result111111 -eq [System.Windows.Forms.DialogResult]::OK){
            if($RadioButton126.Checked){#1コア
                $gmhwebhooktxt = "3"
            }elseif($RadioButton127.Checked){ #2コア
                $gmhwebhooktxt = "2"
            }elseif($RadioButton128.Checked){ #無制限
                $gmhwebhooktxt = "0"
            }elseif($RadioButton129.Checked){ #2CHT
                $gmhwebhooktxt = "1"
            }
            Write-Log "CPU Affinity: $gmhwebhooktxt"
        }    
    }    
}
#################################################################################################>
#カスタムサーバー追加
#################################################################################################>
if($CheckedBox.CheckedItems -contains "カスタムサーバー情報追加"){
    $form11130 = New-Object System.Windows.Forms.Form
    $form11130.Text = $(Get-Translate("カスタムサーバー情報追加"))
    $form11130.Size = New-Object System.Drawing.Size(500,280)
    $form11130.StartPosition = 'CenterScreen'
    $form11130.Icon = "$dsk\AUMADS.ico"
    $form11130.font = $Font

    $okButton111110 = New-Object System.Windows.Forms.Button
    $okButton111110.Location = New-Object System.Drawing.Point(380,200)
    $okButton111110.Size = New-Object System.Drawing.Size(75,23)
    $okButton111110.Text = 'OK'
    $okButton111110.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form11130.AcceptButton = $okButton111110
    $form11130.Controls.Add($okButton111110)
    
    $label111110 = New-Object System.Windows.Forms.Label
    $label111110.Location = New-Object System.Drawing.Point(10,10)
    $label111110.Size = New-Object System.Drawing.Size(320,20)
    $label111110.Text = $(Get-Translate("追加したいカスタムサーバーの名前を入力してください。"))
    $form11130.Controls.Add($label111110)
    
    $textBox111110 = New-Object System.Windows.Forms.TextBox
    $textBox111110.Location = New-Object System.Drawing.Point(10,30)
    $textBox111110.Size = New-Object System.Drawing.Size(460,20)
    $form11130.Controls.Add($textBox111110)

    $label111111 = New-Object System.Windows.Forms.Label
    $label111111.Location = New-Object System.Drawing.Point(10,60)
    $label111111.Size = New-Object System.Drawing.Size(320,20)
    $label111111.Text = $(Get-Translate("追加したいカスタムサーバーのFQDN/IPを入力してください。"))
    $form11130.Controls.Add($label111111)
    
    $textBox111111 = New-Object System.Windows.Forms.TextBox
    $textBox111111.Location = New-Object System.Drawing.Point(10,80)
    $textBox111111.Size = New-Object System.Drawing.Size(460,20)
    $form11130.Controls.Add($textBox111111)  

    $label111112 = New-Object System.Windows.Forms.Label
    $label111112.Location = New-Object System.Drawing.Point(10,110)
    $label111112.Size = New-Object System.Drawing.Size(320,20)
    $label111112.Text = $(Get-Translate("追加したいカスタムサーバーのポートを入力してください。"))
    $form11130.Controls.Add($label111112)
    
    $textBox111112 = New-Object System.Windows.Forms.TextBox
    $textBox111112.Location = New-Object System.Drawing.Point(10,130)
    $textBox111112.Size = New-Object System.Drawing.Size(460,20)
    $textBox111112.Text = "22000"
    $form11130.Controls.Add($textBox111112)


    $fqcheck = $false
    $ipcheck = $false
    $namechk = $false
    $portchk = $false
    $passchk = $false
    $form11130.Topmost = $true   
    $form11130.Add_Shown({$textBox111110.Select()})

    while(!$passchk){
        $result111110 = $form11130.ShowDialog()
        if($result111110 -eq [System.Windows.Forms.DialogResult]::OK){
            $fqregex = '(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)'
            if($textBox111111.Text -match $fqregex){
                $fqcheck = $true
            }
            $ipregex = '^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$'
            if($textBox111111.Text -match $ipregex){
                $ipcheck = $true
            }
            
            if($null -eq $textBox111110.Text){
            }elseif($textBox111110.Text -eq ""){
            }else{
                $namechk = $true
            }
    
            if($null -eq $textBox111112.Text){
            }elseif($textBox111112.Text -eq ""){
            }else{
                $portchk = $true
            }
            if(($fqcheck -or $ipcheck) -and $namechk -and $portchk){
                $passchk = $true
            }

            $xfqip = $textBox111111.Text      
            $xname = $textBox111110.Text
            $xport = $textBox111112.Text
        }else{
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
$Form2.Startposition = "CenterScreen"
$Form2.Text = "Among Us Mod Auto Deploy Tool"
$form2.Icon = "$dsk\AUMADS.ico"
$form2.FormBorderStyle = "Fixed3D"
$Form2.Topmost = $True
$Form2.font = $Font

$label222 = New-Object System.Windows.Forms.Label
$label222.Location = New-Object System.Drawing.Point(10,60)
$label222.Size = New-Object System.Drawing.Size(480,60)
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

if($tio){

    $Form2.Show()
    $Bar.Value = "10"
    #################################################################################################
    $web = Invoke-WebRequest $releasepage -UseBasicParsing
    $web2 = ConvertFrom-Json $web.Content
    $Bar.Value = "15"
    $torv = $torpv
    Write-Log "$scid Version $torv が選択されました"

    $Bar.Value = "20"
    $langdata
    $langd=@()
    $exfoldn
    if($scid -eq "TOR MR"){
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf("MR.zip") -gt 0){
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for($aii = 0;$aii -lt $langd.Length;$aii++){
            if($($langd[$aii]).IndexOf("${torv}") -gt 0){
                $tordlp = $langd[$aii]
            }
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
        #$tordlp = "https://github.com/miru-y/TheOtherRoles-MR/releases/download/${torv}/TheOtherRolesMR.zip"
    }elseif($scid -eq "TOR"){
        $tordlp = "https://github.com/Eisbison/TheOtherRoles/releases/download/${torv}/TheOtherRoles.zip"
    }elseif($scid -eq "TOU-R"){
        $tordlp = "https://github.com/eDonnes124/Town-Of-Us-R/releases/download/${torv}/ToU.${torv}.zip"
    }elseif($scid -eq "ER"){
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.zip"
    }elseif($scid -eq "ER+ES"){
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.with.Extreme.Skins.zip"
    }elseif($scid -eq "TOH"){
        $tohver = $torv.Substring(1)
        Write-Log $tohver
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf("${tohver}.zip") -gt 0){
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }      
        for($aii = 0;$aii -lt $langd.Length;$aii++){
            if($($langd[$aii]).IndexOf("${tohver}") -gt 0){
                $tordlp = $langd[$aii]
            }
        }
        if($tordlp.Indexof(${torv}.zip) -gt 0){
            $tordlp = "https://github.com/tukasa0001/TownOfHost/releases/download/${torv}/TownOfHost-${torv}.zip"
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
    }elseif($scid -eq "TOY"){
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if(($($web2.assets.browser_download_url[$aii]).IndexOf("Y-${torv}") -gt 0) -and ($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0)){
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for($aii = 0;$aii -lt $langd.Length;$aii++){
            if($($langd[$aii]).IndexOf("${torv}") -gt 0){
                $tordlp = $langd[$aii]
            }
        }
        Write-Log $tordlp
        $exfoldn = [IO.Path]::GetFileNameWithoutExtension($(Split-Path $tordlp -Leaf));
        #$tordlp = "https://github.com/Yumenopai/TownOfHost_Y/releases/download/${torv}/TownOfHost_Y.-.${torv}.zip"
    }elseif($scid -eq "LM"){
        $tordlp = "https://github.com/KiraYamato94/LasMonjas/releases/download/${torv}/Las.Monjas.${torv}.zip"
    }elseif($scid -eq "SNR"){
        $tordlp = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/SuperNewRoles-v${torv}.zip"
        $Agartha = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/Agartha.dll"
    }elseif($scid -eq "AMS"){
        $tordlp = "https://github.com/BepInEx/BepInEx/releases/download/v6.0.0-pre.1/BepInEx_UnityIL2CPP_x86_6.0.0-pre.1.zip"
        $langd = @()
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".dll") -gt 0){
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        for($aiiii = 0;$aiiii -lt  $langd.Length;$aiiii++){
            if($($web2.tag_name[$aiiii]) -eq "$torv"){
                $amsdll = $($langd[$aiiii])
            }
        }
        if($amsdll.indexof(".dll") -le 0){
            Write-Log "Critical Error: missing dll"
            Pause
            exit
        }
    }elseif($scid -eq "NOS"){
        $torvtmp = $torv.Replace(",","%2C")
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0){
                if($($web2.assets.browser_download_url[$aii]).IndexOf("$torvtmp") -gt 0){
                    $tordlp = $web2.assets.browser_download_url[$aii]
                }
            }  
        }
        #https://github.com/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest
        $aucap= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest" -UseBasicParsing)).assets.browser_download_url
        $z7tr = $true
        if($aucap[0].length -gt 1){
            for($ii = 0;$ii -lt  $aucap.Length;$ii++){
                if($($aucap[$ii]).IndexOf(".7z") -gt 0){
                    $nebulangdata = $($aucap[$ii])
                    $z7tr = $false
                }
            }
            if($z7tr){
                for($ii = 0;$ii -lt  $aucap.Length;$ii++){
                    if($($aucap[$ii]).IndexOf("Japanese.dat") -gt 0){
                        $nebulangdata = $($aucap[$ii])
                    }
                    if($($aucap[$ii]).IndexOf("Japanese_Color.dat") -gt 0){
                        $nebulangdatajpc = $($aucap[$ii])
                    }
                }    
            }
        }else{
            $nebulangdata = $aucap
        }
        $langdata = $nebulangdata
    }elseif($scid -eq "NOT"){
        $torvtmp = $torv.Replace(",","%2C")
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0){
                if($($web2.assets.browser_download_url[$aii]).IndexOf("$torvtmp") -gt 0){
                    $tordlp = $web2.assets.browser_download_url[$aii]
                }
            }  
        }

        #temp
        if($nebubool){
            $tordlp = "https://github.com/Dolly1016/Nebula/releases/download/snapshot/Nebula.zip"
        }

        #https://github.com/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest
        $aucap= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/Umineko1993/Nebula-on-the-Ship-for-Japanese/releases/latest" -UseBasicParsing)).assets.browser_download_url
        $z7tr = $true
        if($aucap[0].length -gt 1){
            for($ii = 0;$ii -lt  $aucap.Length;$ii++){
                if($($aucap[$ii]).IndexOf(".7z") -gt 0){
                    $nebulangdata = $($aucap[$ii])
                    $z7tr = $false
                }
            }    
            if($z7tr){
                for($ii = 0;$ii -lt  $aucap.Length;$ii++){
                    if($($aucap[$ii]).IndexOf("Japanese.dat") -gt 0){
                        $nebulangdata = $($aucap[$ii])
                    }
                    if($($aucap[$ii]).IndexOf("Japanese_Color.dat") -gt 0){
                        $nebulangdatajpc = $($aucap[$ii])
                    }
                }    
            }   
        }else{
            $nebulangdata = $aucap
        }
        $langdata = $nebulangdata
    }else{
        Write-Log "Critical Error 3"
        $Form2.Close()
        pause
        exit
    }

    Write-Output $tordlp

    $Bar.Value = "23"
    $debugc = $false
    ###作成したModのExeへのショートカットをDesktopに配置する
    if($RadioButton1.Checked){
        $shortcut = $true
    }elseif($RadioButton2.Checked){
        $shortcut = $false 
    }elseif($RadioButton42.Checked){
        $shortcut = $true
        $debugc = $true
    }else{
        Write-Log "Critical Error: Shortcut"
    }
    $Bar.Value = "27"
    ###作成したModのExeへのショートカットをDesktopに配置する
    ###作成したModを即座に実行する
    #デフォルトでは実行しない
    #The Other Hatの読み込みを先に終えておきたい人向け
    if($RadioButton3.Checked){
        $startexewhendone = $true
    }elseif($RadioButton4.Checked){
        $startexewhendone = $false
    }else{
        Write-Log "Critical Error: StartCheck"
    }

    $Bar.Value = "32"

    #################################################################################################
    #処理フェイズ
    #################################################################################################

    #OriginalのAmongusをフォルダ毎コピーして新規Mod用フォルダを作成する
    if(Test-Path $aupathm){
        ###作り直しを有効にする $trueだと有効になる。デフォルト無効
        if($RadioButton5.Checked){
            $retry = $true
            $ovwrite = $false
            $clean = $false
        }elseif($RadioButton6.Checked){
            $retry = $false
            $ovwrite = $false
            $clean = $false
        }elseif($RadioButton7.Checked){
            $retry = $false
            $ovwrite = $true
            $clean = $false
        }elseif($RadioButton17.Checked){
            $retry = $true
            $ovwrite = $false
            $clean = $true
        }else{
            Write-Log "Critical Error: Retry"
        }
        $Bar.Value = "36"

        if($scid -eq "TOU-R"){
            if(test-path "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg"){                
                Copy-Item "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg" "C:\Temp\com.slushiegoose.townofus.cfg" -Force
            }
        }elseif($scid -eq "ER"){
            if(test-path "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" "C:\Temp\me.yukieiji.extremeroles.cfg" -Force               
            }
        }elseif($scid -eq "ER+ES"){
            if(test-path "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" "C:\Temp\me.yukieiji.extremeroles.cfg" -Force               
            }
            if(test-path "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg" "C:\Temp\me.yukieiji.extremeskins.cfg" -Force               
                New-Item -Path "C:\Temp\ExtremeHat" -ItemType Directory
                Copy-Item "$aupathm\ExtremeHat\*" -Recurse "C:\Temp\ExtremeHat"
            }
        }elseif(($scid -eq "NOS") -or ($scid -eq "NOT")){
            if(test-path "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"){
                Copy-Item "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force               
            }
            if(test-path "$aupathm\MoreCosmic"){
                New-Item -Path "C:\Temp\MoreCosmic" -ItemType Directory
                Copy-Item "$aupathm\MoreCosmic\*" -Recurse "C:\Temp\MoreCosmic"
            }
            if(test-path "$aupathm\Presets"){
                New-Item -Path "C:\Temp\Presets" -ItemType Directory
                Copy-Item "$aupathm\Presets\*" -Recurse "C:\Temp\Presets"
            }
            if(test-path "$aupathm\TexturePack"){
                New-Item -Path "C:\Temp\TexturePack" -ItemType Directory
                Copy-Item "$aupathm\TexturePack\*" -Recurse "C:\Temp\TexturePack"
            }
        }elseif($scid -eq "LM"){
            if(test-path "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg" "C:\Temp\me.allul.lasmonjas.cfg" -Force
            }
        }elseif($scid -eq "SNR"){
            if(test-path "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg" "C:\Temp\jp.ykundesu.supernewroles.cfg" -Force               
                New-Item -Path "C:\Temp\SuperNewRoles" -ItemType Directory
                Copy-Item "$aupathm\SuperNewRoles\*" -Recurse "C:\Temp\SuperNewRoles"
            }
        }elseif($scid -eq "TOH"){
            if(test-path "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg"){
                Copy-Item "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" "C:\Temp\com.emptybottle.townofhost.cfg" -Force               
            }
            if(!(test-path "$aupathm\TOH_DATA")){
                New-Item -Path "C:\Temp\TOH_DATA" -ItemType Directory
            }
            Copy-Item "$aupathm\TOH_DATA\*" "C:\Temp\TOH_DATA" -Force               
        }elseif($scid -eq "TOY"){
            if(test-path "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg"){
                Copy-Item "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" "C:\Temp\com.emptybottle.townofhost.cfg" -Force               
            }
        }elseif($scid -eq "AMS"){
            if(test-path "$aupathm\BepInEx\config\me.tomarai.aumod.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.tomarai.aumod.cfg" "C:\Temp\me.tomarai.aumod.cfg" -Force               
            }
        }elseif($scid -eq "TOR MR"){
            if(test-path "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" "C:\Temp\me.eisbison.theotherroles.cfg" -Force
                New-Item -Path "C:\Temp\TheOtherHats" -ItemType Directory
                Copy-Item "$aupathm\TheOtherHats\*" -Recurse "C:\Temp\TheOtherHats"
            }
        }else{
            if(test-path "$aupathm\CustomPreset"){
                New-Item -Path "C:\Temp\CustomPreset" -ItemType Directory
                Copy-Item "$aupathm\CustomPreset\*" -Recurse "C:\Temp\CustomPreset"
            }

            if(test-path "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" "C:\Temp\me.eisbison.theotherroles.cfg" -Force
                New-Item -Path "C:\Temp\TheOtherHats" -ItemType Directory
                Copy-Item "$aupathm\TheOtherHats\*" -Recurse "C:\Temp\TheOtherHats"
            }
        }
        $Bar.Value = "42"
        if($clean -eq $true){
            if (Test-Path "C:\Program Files (x86)\Steam\Steam.exe"){
                $rn = "steam"
                Write-Log "Assume $rn is used."
                $stm = $true
            }

            if (Test-Path "C:\Program Files (x86)\Epic Games"){
                $rn = "epic"
                Write-Log "Assume $rn is used."
                $epc = $true
            }
            
            if($stm -and $epc){
                Write-Log $(Get-Translate("Both Steam and Epic is detected. Ask User."))
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("SteamとEpic両方のインストールが確認されました。`nどちらのAmongusをクリーンインストールしますか？`nSteamの場合は「はい」を、Epicの場合は「いいえ」を押してください。")), "Among Us Clean Install Tool",4) -eq "Yes"){
                    $rn = "steam"
                }else{
                    $rn = "epic"
                }                
            }

            if($rn -eq "steam"){
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
                $fpth2 = "$npl\AmongusCleanInstall_Steam.ps1"
                if(test-path "$env:ProgramFiles\PowerShell\7"){
                    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                }else{
                    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                }
                Start-Sleep -Seconds 10
                while (!(test-path "$aupatho\Among Us.exe")){
                    Start-Sleep -Seconds 10
                    Write-Log "再インストールが完了したことを確認してから以下の動作を実行してください"
                    write-log (test-path "$aupatho\Among Us.exe")
                    write-log "$aupathm\Among Us.exe"                  
                    Pause
                }
                Remove-Item $fpth2 -Force
            }elseif($rn -eq "epic"){
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_Epic.ps1" -OutFile "$npl\AmongusCleanInstall_Epic.ps1" -UseBasicParsing
                $fpth2 = "$npl\AmongusCleanInstall_Epic.ps1"
                if(test-path "$env:ProgramFiles\PowerShell\7"){
                    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                }else{
                    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth2""" -Verb RunAs -Wait
                }
                Remove-Item $fpth2 -Force
            }else{
                Write-Log "Critical Platform Selection"
                Pause
                Exit
            }
            Start-Sleep -Seconds 10
        }

        if ($retry -eq "true"){
            Write-Log "既存のフォルダを中身を含めて削除します"
            Remove-Item $aupathm -Recurse
            # フォルダを中身を含めてコピーする
            if($prebool){
                Expand-7Zip -ArchiveFileName "$aupathb\$prefpth" -TargetPath $aupathm
                $filename = [IO.Path]::GetFileNameWithoutExtension($prefpth);
                if(Test-Path "$aupathm\depot_945361"){
                    robocopy "$aupathm\depot_945361" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\depot_945361" -recurse
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }elseif(Test-Path "$aupathm\$filename"){
                    robocopy "$aupathm\$filename" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\$filename" -recurse
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }elseif(Test-Path "$aupathm\Among Us"){
                    robocopy "$aupathm\Among Us" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\Among Us" -recurse
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }elseif(Test-Path "$aupathm\AmongUs"){
                    robocopy "$aupathm\AmongUs" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                    Remove-Item "$aupathm\AmongUs" -recurse
                    $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                    Write-Log "`r`n $content"
                    Remove-Item "C:\Temp\temp.log" -Force        
                }
            }else{
                Copy-Item $aupatho -destination $aupathm -recurse
                Write-Log "$aupatho を $aupathm にコピーしました"
            }
        }else{
            # コピー先のパスにファイルやフォルダが存在する場合は処理を中止
            Write-Log "$aupathm には既にファイル又はフォルダが存在します"
            if($ovwrite){
                Write-Log "上書き処理が選択されました"
            }else{
                Write-Log "処理を中止しました"
                $Form2.Close()
                pause
                Exit
            }
        }
        $Bar.Value = "48"
    }else{
        # フォルダを中身を含めてコピーする
        if($prebool){
            Expand-7Zip -ArchiveFileName "$aupathb\$prefpth" -TargetPath $aupathm
            $filename = [IO.Path]::GetFileNameWithoutExtension($prefpth);
            if(Test-Path "$aupathm\depot_945361"){
                robocopy "$aupathm\depot_945361" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\depot_945361" -recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }elseif(Test-Path "$aupathm\$filename"){
                robocopy "$aupathm\$filename" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\$filename" -recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }elseif(Test-Path "$aupathm\Among Us"){
                robocopy "$aupathm\Among Us" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\Among Us" -recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }elseif(Test-Path "$aupathm\AmongUs"){
                robocopy "$aupathm\AmongUs" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "$aupathm\AmongUs" -recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force        
            }
        }else{
            Copy-Item $aupatho -destination $aupathm -recurse
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
    aria2c -x5 -V --dir "$aupathm" -o "TheOtherRoles.zip" $tordlp

    Write-Log "Download ZIP 完了"
    $Bar.Value = "57"

    #DLしたTORを解凍
    if (test-path "$aupathm\TheOtherRoles.zip"){
        Write-Log "ZIP Download OK"
        Write-Log "ZIP 解凍開始"
        Expand-7zip -ArchiveFileName $aupathm\TheOtherRoles.zip -TargetPath $aupathm
        Write-Log "ZIP 解凍完了"
    }else{
        Write-Log "ZIP Download NG $tordlp "
        Write-Log "何かがおかしい・・・。もう一度試してみてください。"
        exit
    }

    $Bar.Value = "59"

    if(test-path "$aupathm\BepInEx"){
        Write-Log "ZIP 解凍OK"
    }
    $Bar.Value = "60"

    if($scid -eq "TOU-R"){
        if(test-path "C:\Temp\com.slushiegoose.townofus.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.slushiegoose.townofus.cfg" "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg" -Force
            Remove-Item "C:\Temp\com.slushiegoose.townofus.cfg" -Force    
        }
    }elseif($scid -eq "ER"){
        if(test-path "C:\Temp\me.yukieiji.extremeroles.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeroles.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeroles.cfg" -Force    
        }
    }elseif($scid -eq "ER+ES"){
        if(test-path "C:\Temp\me.yukieiji.extremeroles.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeroles.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeroles.cfg" -Force    
        }
        if(test-path "C:\Temp\me.yukieiji.extremeskins.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.yukieiji.extremeskins.cfg" "$aupathm\BepInEx\config\me.yukieiji.extremeskins.cfg" -Force
            Remove-Item "C:\Temp\me.yukieiji.extremeskins.cfg" -Force    
        }
        if(test-path "C:\Temp\ExtremeHat"){
            if(!(Test-Path "$aupathm\ExtremeHat")){
                New-Item -Path "$aupathm\ExtremeHat" -ItemType Directory
            }
            robocopy "C:\Temp\ExtremeHat" "$aupathm\ExtremeHat" /unilog:C:\Temp\temp.log /E >nul 2>&1 
            Remove-Item "C:\Temp\ExtremeHat" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif(($scid -eq "NOS") -or ($scid -eq "NOT")){
        if(test-path "C:\Temp\jp.dreamingpig.amongus.nebula.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" -Force
            Remove-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force    
        }
        if(test-path "C:\Temp\MoreCosmic"){
            if(!(Test-Path "$aupathm\MoreCosmic")){
                New-Item -Path "$aupathm\MoreCosmic" -ItemType Directory
            }    
            robocopy "C:\Temp\MoreCosmic" "$aupathm\MoreCosmic" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\MoreCosmic" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if(test-path "C:\Temp\Presets"){
            if(!(Test-Path "$aupathm\Presets")){
                New-Item -Path "$aupathm\Presets" -ItemType Directory
            }    
            robocopy "C:\Temp\Presets" "$aupathm\Presets" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\Presets" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if(test-path "C:\Temp\TexturePack"){
            if(!(Test-Path "$aupathm\TexturePack")){
                New-Item -Path "$aupathm\TexturePack" -ItemType Directory
            }    
            robocopy "C:\Temp\TexturePack" "$aupathm\TexturePack" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\TexturePack" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        
    }elseif($scid -eq "LM"){
        if(test-path "C:\Temp\me.allul.lasmonjas.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.allul.lasmonjas.cfg" "$aupathm\BepInEx\config\me.allul.lasmonjas.cfg" -Force
            Remove-Item "C:\Temp\me.allul.lasmonjas.cfg" -Force    
        }
    }elseif($scid -eq "TOH"){
        if(test-path "C:\Temp\com.emptybottle.townofhost.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.emptybottle.townofhost.cfg" "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" -Force
            Remove-Item "C:\Temp\com.emptybottle.townofhost.cfg" -Force    
        }
        if(test-path "C:\Temp\TOH_DATA"){
            if(!(test-path "$aupathm\TOH_DATA\")){
                New-Item -Path "$aupathm\TOH_DATA\" -ItemType Directory
            }
            Copy-Item "C:\Temp\TOH_DATA\*" "$aupathm\TOH_DATA" -Force               
            Remove-Item "C:\Temp\TOH_DATA" -Recurse -Force    
        }
    }elseif($scid -eq "TOY"){
        if(test-path "C:\Temp\com.emptybottle.townofhost.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.emptybottle.townofhost.cfg" "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" -Force
            Remove-Item "C:\Temp\com.emptybottle.townofhost.cfg" -Force    
        }
    }elseif($scid -eq "AMS"){
        if(test-path "C:\Temp\me.tomarai.aumod.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.tomarai.aumod.cfg" "$aupathm\BepInEx\config\me.tomarai.aumod.cfg" -Force
            Remove-Item "C:\Temp\me.tomarai.aumod.cfg" -Force    
        }
    }elseif($scid -eq "SNR"){
        if(test-path "C:\Temp\jp.ykundesu.supernewroles.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.ykundesu.supernewroles.cfg" "$aupathm\BepInEx\config\jp.ykundesu.supernewroles.cfg" -Force
            Remove-Item "C:\Temp\jp.ykundesu.supernewroles.cfg" -Force    
            if(!(Test-Path "$aupathm\SuperNewRoles")){
                New-Item -Path "$aupathm\SuperNewRoles" -ItemType Directory
            }
            if(test-path "C:\Temp\SuperNewRoles"){
                robocopy "C:\Temp\SuperNewRoles" "$aupathm\SuperNewRoles" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "C:\Temp\SuperNewRoles" -Recurse -Force
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
    }elseif($scid -eq "TOR MR"){
        if(test-path "C:\Temp\me.eisbison.theotherroles.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.eisbison.theotherroles.cfg" "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" -Force
            Remove-Item "C:\Temp\me.eisbison.theotherroles.cfg" -Force    
            if(!(Test-Path "$aupathm\TheOtherHats")){
                New-Item -Path "$aupathm\TheOtherHats" -ItemType Directory
            }
            if(test-path "C:\Temp\TheOtherHats"){
                robocopy "C:\Temp\TheOtherHats" "$aupathm\TheOtherHats" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "C:\Temp\TheOtherHats" -Recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
        if(test-path "C:\Temp\CustomPreset"){
            robocopy "C:\Temp\CustomPreset" "$aupathm\CustomPreset" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\CustomPreset" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }else{
        if(test-path "C:\Temp\me.eisbison.theotherroles.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\me.eisbison.theotherroles.cfg" "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" -Force
            Remove-Item "C:\Temp\me.eisbison.theotherroles.cfg" -Force    
        }
        if(test-path "C:\Temp\TheOtherHats"){
            if(!(Test-Path "$aupathm\TheOtherHats")){
                New-Item -Path "$aupathm\TheOtherHats" -ItemType Directory
            }
            robocopy "C:\Temp\TheOtherHats" "$aupathm\TheOtherHats" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "C:\Temp\TheOtherHats" -Recurse -Force
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }
    $Bar.Value = "64"
    $Bar.Value = "68"

    if($submerged){
        Write-Log "対応する最新のSubmerged配置開始"
        Write-Log "Submerged DLL download start"
        if (!(Test-Path "$aupathm\BepInEx\plugins\")) {
            New-Item "$aupathm\BepInEx\plugins\" -Type Directory
        }

        if($RadioButton114.Checked){
            $submdll = "https://github.com/SubmergedAmongUs/Submerged/releases/download/v2022.10.26/Submerged.dll"
        }elseif($RadioButton115.Checked){
            Write-Log "Submerged is not compatible this version yet."
            $submdll = "NONE"
        }elseif($RadioButton116.Checked){
            $submdll = "https://github.com/SubmergedAmongUs/Submerged/releases/download/v2022.8.26/Submerged.dll"
        }

        if($submdll -ne "NONE"){
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins\" -o "Submerged.dll" $submdll
            Write-Log "$submdll"
            Write-Log "Submerged DLL download done"
            Write-Log "対応する最新のSubmerged配置完了"
        }else{
            Write-Log "対応するSubmergedがありません"
        }
    }
    $Bar.Value = "69"

    if($RadioButton27.Checked){
        if(Test-Path "$aupathm\BepInEx\plugins\Submerged.dll"){
            Remove-item "$aupathm\BepInEx\plugins\Submerged.dll" -Force
        }        
    }

    if($scid -eq "TOR GMH"){
        if(test-path "$aupathm\TheOtherRoles-GM-Haoming.$torv"){
            robocopy "$aupathm\TheOtherRoles-GM-Haoming.$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles-GM-Haoming.$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if($checkgm){
            #Mod Original DLL削除
            Remove-item -Path "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll"
            Write-Log 'Delete Original Mod DLL'
            Write-Log $torgmdll
            #TOR+ DLLをDLして配置
            Write-Log "Download $scid DLL 開始"
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "TheOtherRolesGM.dll" $torgmdll
            Write-Log "Download $scid DLL 完了"
        }
    }elseif($scid -eq "TOR GMT"){
        if(test-path "$aupathm\TheOtherRoles-GM-Haoming.$torv"){
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
        aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "TheOtherRolesGM.dll" $torgmdll
        Write-Log "Download $scid DLL 完了"
    }elseif($scid -eq "TOU-R"){
        if(test-path "$aupathm\ToU $torv"){
            robocopy "$aupathm\ToU $torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ToU $torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "TOR"){
        if(test-path "$aupathm\TheOtherRoles"){
            robocopy "$aupathm\TheOtherRoles" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "TOR MR"){
        if(test-path "$aupathm\$exfoldn"){
        }elseif(test-path "$aupathm\TheOtherRoles MR"){
            $exfoldn = "TheOtherRoles MR"
        }else{
            $exfoldn2 = $exfoldn.Replace('.',' ')
            if(Test-Path "$aupathm\$exfoldn2"){
                $exfoldn = $exfoldn2
            }
        }
        if(test-path "$aupathm\$exfoldn"){
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "ER"){
        if(test-path "$aupathm\ExtremeRoles-$torv"){
            robocopy "$aupathm\ExtremeRoles-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ExtremeRoles-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "ER+ES"){
        if(test-path "$aupathm\ExtremeRoles-$torv"){
            robocopy "$aupathm\ExtremeRoles-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\ExtremeRoles-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "LM"){
        if(test-path "$aupathm\Las Monjas $torv"){
            robocopy "$aupathm\Las Monjas $torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Las Monjas $torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "TOY"){
        if(test-path "$aupathm\$exfoldn"){
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "TOH"){
        if(test-path "$aupathm\TownOfHost-$torv"){
            robocopy "$aupathm\TownOfHost-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TownOfHost-$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }elseif(test-path "$aupathm\$exfoldn"){
            robocopy "$aupathm\$exfoldn" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\$exfoldn" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
    }elseif($scid -eq "SNR"){
        if(test-path "$aupathm\SuperNewRoles-v$torv"){
            robocopy "$aupathm\SuperNewRoles-v$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\SuperNewRoles-v$torv" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force

            if(Test-Path "$aupathm\BepInEx\plugins\Agartha.dll"){
                Remove-item -Path "$aupathm\BepInEx\plugins\Agartha.dll"
                Write-Log 'Delete Original Agartha Mod DLL'
            }
            #Agartha DLLをDLして配置
            Write-Log "Download $scid Agartha DLL 開始"
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "Agartha.dll" $Agartha
            Write-Log "Download $scid Agartha DLL 完了"         
        }
    }elseif($scid -eq "AMS"){
        if(test-path "$aupathm\BepInEx"){
            if(Test-Path "$aupathm\BepInEx\plugins\AUModS.dll"){
                Remove-item -Path "$aupathm\BepInEx\plugins\AUModS.dll"
                Write-Log 'Delete Original AUModS Mod DLL'
            }
            #AUModS DLLをDLして配置
            if(!(Test-Path "$aupathm\BepInEx\plugins")){
                New-Item "$aupathm\BepInEx\plugins" -ItemType Directory 
            }
            Write-Log $amsdll
            Write-Log "Download $scid AUModS DLL 開始"
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "AUModS.dll" $amsdll
            Write-Log "Download $scid AUModS DLL 完了"    
        }
    }elseif($scid -eq "NOS"){
        if(test-path "$aupathm\Nebula"){
            robocopy "$aupathm\Nebula" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Nebula" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if (!(Test-Path "$aupathm\Language\")) {
            New-Item "$aupathm\Language\" -Type Directory
        }
        Write-Log "日本語 データ Download 開始"
        Write-Log "日本語 データ $langdata"
        if(Test-Path "$aupathm\Language\Japanese.dat"){
            Copy-Item "$aupathm\Language\Japanese.dat" "$aupathm\Language\Japanese.dat.old"
        }
        $extens = $langdata.Substring($langdata.Length - 3, 3);
        Write-Host $extens
        if($extens -eq "dat"){
            aria2c -x5 -V --dir "$aupathm\Language" -o "Japanese.dat" $langdata
            aria2c -x5 -V --dir "$aupathm\Language" -o "Japanese_Color.dat" $nebulangdatajpc
        }elseif ($extens -eq "zip") {
            aria2c -x5 -V --dir "$aupathm\Language" -o "Language.zip" $langdata
            Expand-7Zip -ArchiveFileName "$aupathm\Language\Language.zip" -TargetPath "$aupathm\Language"
        }elseif($extens -eq ".7z"){
            aria2c -x5 -V --dir "$aupathm\Language" -o "Language.7z" $langdata
            Expand-7Zip -ArchiveFileName "$aupathm\Language\Language.7z" -TargetPath "$aupathm\Language"
        }
        if(test-path "$aupathm\Language\Language"){
            robocopy "$aupathm\Language\Language" "$aupathm\Language" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Language\Language" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        Write-Log "日本語 データ Download 完了"
        if(Test-Path "$aupathm\TexturePack"){
        }else{
            New-Item "$aupathm\TexturePack" -Type Directory
        }
        Write-Log "Download Small Tracker Arrow 開始"
        if(!(Test-Path "$aupathm\TexturePack\MoreSmallTrackerArrow.zip")){
            aria2c -x5 -V --dir "$aupathm\TexturePack" -o "MoreSmallTrackerArrow.zip" "https://cdn.discordapp.com/attachments/906766074131927071/1080729380667535390/MoreSmallTrackerArrow.zip"
        }
        Write-Log "Download Small Tracker Arrow 完了"
    }elseif($scid -eq "NOT"){
        if(test-path "$aupathm\Nebula"){
            robocopy "$aupathm\Nebula" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Nebula" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        if (!(Test-Path "$aupathm\Language\")) {
            New-Item "$aupathm\Language\" -Type Directory
        }
        Write-Log "日本語 データ Download 開始"
        Write-Log "日本語 データ $langdata"
        if(Test-Path "$aupathm\Language\Japanese.dat"){
            Copy-Item "$aupathm\Language\Japanese.dat" "$aupathm\Language\Japanese.dat.old"
        }
        $extens = $langdata.Substring($langdata.Length - 3, 3);
        Write-Host $extens
        if($extens -eq "dat"){
            aria2c -x5 -V --dir "$aupathm\Language" -o "Japanese.dat" $langdata
        }elseif ($extens -eq "zip") {
            aria2c -x5 -V --dir "$aupathm\Language" -o "Language.zip" $langdata
            Expand-7Zip -ArchiveFileName "$aupathm\Language\Language.zip" -TargetPath "$aupathm\Language"
        }elseif($extens -eq ".7z"){
            aria2c -x5 -V --dir "$aupathm\Language" -o "Language.7z" $langdata
            Expand-7Zip -ArchiveFileName "$aupathm\Language\Language.7z" -TargetPath "$aupathm\Language"
        }
        if(test-path "$aupathm\Language\Language"){
            robocopy "$aupathm\Language\Language" "$aupathm\Language" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\Language\Language" -recurse
            $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode

            Write-Log "`r`n $content"
            Remove-Item "C:\Temp\temp.log" -Force
        }
        Write-Log "日本語 データ Download 完了"
        if(!($nebubool)){
            #Mod Original DLL削除
            Remove-item -Path "$aupathm\BepInEx\plugins\Nebula.dll"
            Write-Log 'Delete Original Mod DLL'
            Write-Log $torgmdll
            #TOR+ DLLをDLして配置
            Write-Log "Download $scid DLL 開始"
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "Nebula.dll" $torgmdll
            Write-Log "Download $scid DLL 完了"
        }
        if(Test-Path "$aupathm\TexturePack"){
        }else{
            New-Item "$aupathm\TexturePack" -Type Directory
        }
        Write-Log "Download Small Tracker Arrow 開始"
        if(!(Test-Path "$aupathm\TexturePack\MoreSmallTrackerArrow.zip")){
            aria2c -x5 -V --dir "$aupathm\TexturePack" -o "MoreSmallTrackerArrow.zip" "https://cdn.discordapp.com/attachments/906766074131927071/1080729380667535390/MoreSmallTrackerArrow.zip"
        }
        Write-Log "Download Small Tracker Arrow 完了"
    }else{
    }
    $Bar.Value = "71"

    #解凍チェック
    if (test-path "$aupathm\BepInEx\plugins"){
        Write-Log "ZIP 解凍OK"
        BackupMod
        Remove-item -Path "$aupathm\TheOtherRoles.zip"
        Write-Log "DLしたZIPを削除"
    }else{
        Write-Log "ZIP 解凍NG"
    }
    $Bar.Value = "77"

    if($shortcut -eq $true){
        ##Desktopにショートカットを配置する
        $scpath = [System.Environment]::GetFolderPath("Desktop")

        if(test-path "$scpath\Among Us Mod $scid.lnk"){
            Remove-item -Path "$scpath\Among Us Mod $scid.lnk"
            Write-Log '既存のMod用Shortcut削除'
        }
        $Bar.Value = "79"

        # ショートカットを作る
        $WsShell = New-Object -ComObject WScript.Shell
        $sShortcut = $WsShell.CreateShortcut("$scpath\Among Us Mod $scid.lnk")

        $scid2 = $scid.replace(" ","_")

        if($debugc){
            if(Test-Path $aupathb){
                if(($platform -ne "Steam") -and ($platform -eq "Steam")){
                    if([System.Windows.Forms.MessageBox]::Show("PlatformはSteamですか?", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                        $platform = "Steam"
                    }else{
                        $platform = "Epic"
                    }
                }
                if(test-path "C:\temp\gmhtechsupport.ps1"){
                    Remove-Item "C:\temp\gmhtechsupport.ps1"
                }
                if(test-path "C:\temp\amongusrun_$scid2.ps1"){
                    Remove-Item "C:\temp\amongusrun_$scid2.ps1"
                }
                if(test-path "C:\temp\startamongusrun_$scid2.bat"){
                    Remove-Item "C:\temp\startamongusrun_$scid2.bat"
                }
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1" -OutFile "C:\temp\gmhtechsupport.ps1" -UseBasicParsing
                $batscript = "chcp 65001 `r`n"
                $batscript += "@echo off `r`n"
                $batscript += "powershell -NoProfile -ExecutionPolicy Unrestricted `"C:\temp\amongusrun_$scid2.ps1`" `r`n"
                $batscript += "exit"
                $batscript | Out-File -Encoding default -FilePath "C:\temp\startamongusrun_$scid2.bat" 
                $ps1script = '$platform="'
                $ps1script += "$platform`"`r`n"
                $ps1script += '$aupathb="'
                $ps1script += "$aupathb`"`r`n"
                $ps1script += '$aupathm="'
                $ps1script += "$aupathm`"`r`n"
                $ps1script += '$scid="'
                $ps1script += "$scid`"`r`n"
                $ps1name = "C:\temp\amongusrun_$scid2.ps1"
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
                            Start-Process powershell.exe -ArgumentList "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `'
                $ps1script += "$ps1name"
                $ps1script += '`"" -Verb RunAs -Wait
                            exit
                        }
                    }
                }elseif($PSVersionTable.PSVersion.major -gt 5){
                    $v5run = $true
                    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `'
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
                $ps1script += '
                        return $Resulttxt[0]
                    }else{
                        return $transtext
                    }
                }

                if($platform -eq "Steam"){
                    Start-Process "$aupathm\Among Us.exe"
                }elseif($platform -eq "Epic"){
                    legendary.exe launch Among Us
                }else{
                    Write-Output "ERROR:Critical run apps"
                }
                Start-Sleep -Seconds 2
                Write-Output "`r`nAmong Us 本体の起動中です。本体が終了するまでこのまま放置してください。`r`n"
                $procName = "Among Us"
                $execPath = "$aupathm\Among Us.exe"
                $checkpro = $true
                $tsp = &"C:\temp\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" |Select-Object -Last 1
                Write-Output "Game Start:$tsp"
                while($checkpro){
                    try{
                        $p = Get-Process $procName -ErrorAction SilentlyContinue
                        $p.WaitForExit()
                    }
                    catch{
                        Write-Output "No Process"
                    }
                    finally{
                        $tsp = &"C:\temp\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" |Select-Object -Last 1
                        $erchk = Get-content "$tsp" -Raw
                        Write-Output "Game Exit:$tsp"
                        if($erchk.LastIndexOf("error") -gt 0){
                            Write-Output "Done."
                        }else{
                            Write-Output "No Error founds."
                        }
                        $checkpro = $false
                    }
                }'
                $ps1script | Out-File -Encoding "UTF8BOM" -FilePath "C:\temp\amongusrun_$scid2.ps1" 
            }else{
                Write-Log "Something Wrong. Check Path."
            }
            $sShortcut.TargetPath = "C:\temp\startamongusrun_$scid2.bat"
        }else{
            if($platform -eq "Steam"){
                $sShortcut.TargetPath = "$aupathm\Among Us.exe"
            }elseif($platform -eq "Epic"){
                $sShortcut.TargetPath = "pwsh.exe"
                $sShortcut.Arguments = "-Command legendary auth --import && legendary -y uninstall Among Us --keep-files  && legendary -y import 'Among Us' '$aupathm' && legendary -y egl-sync && legendary launch Among Us"
                $sShortcut.WorkingDirectory = $aupathm
            }else{
                Write-Log "ERROR: Critical Shortcut"
            }                
        }

        $sShortcut.IconLocation = "$aupathm\Among Us.exe"
        $sShortcut.Save()
        if($platform -eq "epic"){
            $bytes = [System.IO.File]::ReadAllBytes("$scpath\Among Us Mod $scid.lnk")
            $bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
            [System.IO.File]::WriteAllBytes("$scpath\Among Us Mod $scid.lnk", $bytes)    
        }

        $aupathb

        if(test-path "$scpath\Among Us Mod $scid.lnk"){
            Write-Log "Shortcut 作成確認OK"
        }else{
            Write-Log "Shortcut 作成失敗"
        }
    }else{
        $here = Get-Location
        Set-Location -Path $aupathm
        Invoke-Item .
        Set-Location -Path $here
    }
}

$Bar.Value = "80"

if($tio -eq $false){
    $Form2.Show()
}
$Bar.Value = "82"

#reorder checkeditems
$ckbci = @()
$tempoitems = @()
$kenkoitems = @()
$ckbci2 = @()
$tempoitems2 = @()
$kenkoitems2 = @()
for($aa=0;$aa -le $CheckedBox.CheckedItems.Count;$aa++){
    if($CheckedBox.CheckedItems[$aa] -eq "健康ランド"){
        $kenkoitems2 += $CheckedBox.CheckedItems[$aa]
    }else{
        $tempoitems2 += $CheckedBox.CheckedItems[$aa]
    }
}
$ckbci2 = $kenkoitems2 + $tempoitems2
for($aa=0;$aa -le $ckbci2.Count;$aa++){
    if($ckbci2[$aa] -eq "サーバー情報初期化"){
        $kenkoitems += $ckbci2[$aa]
    }else{
        $tempoitems += $ckbci2[$aa]
    }
}
$ckbci = $kenkoitems + $tempoitems

Write-Log $ckbci

if($ckbci.Count -gt 0){

    for($aa=0;$aa -le $ckbci.Count;$aa++){
        if($ckbci[$aa] -eq "BetterCrewLink"){
            Write-Log "BCL Install Start"
            $bcl= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/OhMyGuus/BetterCrewLink/releases/latest" -UseBasicParsing)).assets.browser_download_url
            for($ab=0;$ab -le $bcl.Length;$ab++){
                if($bcl[$ab] -match ".exe"){
                    if($bcl[$ab] -match ".exe."){
                    }else{
                        $bcldlp = $bcl[$ab]
                    }
                }
            }
            $md = [System.Environment]::GetFolderPath("MyDocuments")
            $bclfile = split-path $bcldlp -Leaf
            Invoke-WebRequest $bcldlp -OutFile "$md\$bclfile" -UseBasicParsing
            Start-Process "$md\$bclfile" -wait
            Write-Log "BCL Install Done"
            Remove-Item $md\$bclfile
            $Bar.Value = "83"
        }elseif($ckbci[$aa] -eq "AmongUsReplayInWindow"){
            $qureq = $true
            if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802){
            }else{
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("必要な.Net 5 Frameworkがインストールされていません。インストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    try{
                        choco -v
                    }catch{
                        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                    }
        
                    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet -y" -Verb RunAs -Wait        
                }else{
                    Write-Log "AmongUsReplayInWindowの処理を中止します"
                    $qureq = $false
                }    

            }
            if($qureq){
                $auriw= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/sawa90/AmongUsReplayInWindow/releases/latest" -UseBasicParsing)).assets.browser_download_url
                $auriwfile = split-path $auriw -Leaf 
                $auriwfn = $auriwfile.Substring(0, $auriwfile.LastIndexOf('.'))
                $md = [System.Environment]::GetFolderPath("MyDocuments")
                $aurcheck = $true
                if(Test-Path $md\$auriwfn){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("既に存在するようです。上書き展開しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                        $aurcheck = $true
                    }else{
                        $aurcheck = $false
                    }
                }
                if($aurcheck){
                    aria2c -x5 -V --allow-overwrite=true --dir "$md" -o "$auriwfile" $auriw
                    #Invoke-WebRequest $auriw -OutFile "$md\$auriwfile" -UseBasicParsing
                    Expand-7zip -ArchiveFileName $md\$auriwfile -TargetPath $md\$auriwfn
                    Remove-Item $md\$auriwfile
                    Set-Location -Path $md\$auriwfn
                    Invoke-Item .
                }else{
                    Write-Log "AmongUsReplayInWindowの処理を中止します"
                }
            }
            $Bar.Value = "84"
        }elseif($ckbci[$aa] -eq "AmongUsCapture"){
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet -y" -Verb RunAs -Wait   
            $aucap= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/automuteus/amonguscapture/releases/latest" -UseBasicParsing)).assets.browser_download_url
            $aucapfile = split-path $aucap[0] -Leaf 
            $aucapfn = $aucapfile.Substring(0, $aucapfile.LastIndexOf('.'))
            $md = [System.Environment]::GetFolderPath("MyDocuments")
            $aucapcheck = $true
            if(Test-Path $md\$aucapfn){
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("既に存在するようです。上書き展開しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    $aucapcheck = $true
                }else{
                    $aucapcheck = $false
                }
            }
            if($aucapcheck){
                #Invoke-WebRequest $aucap[0] -OutFile "$md\$aucapfile" -UseBasicParsing
                aria2c -x5 -V --allow-overwrite=true --dir "$md" -o "$aucapfile" $aucap[0]                
                Expand-7Zip -ArchiveFileName $md\$aucapfile -TargetPath $md\$aucapfn
                Remove-Item $md\$aucapfile
                Set-Location -Path $md\$aucapfn
                Invoke-Item .
            }else{
                Write-Log "AmongUsCaptureの処理を中止します"
            }
            if(Test-Path "$md\$aucapfn\AmongUsCapture.exe"){
                $scpath = [System.Environment]::GetFolderPath("Desktop")
                $WsShell = New-Object -ComObject WScript.Shell
                $sShortcut = $WsShell.CreateShortcut("$scpath\AmongUsCapture.lnk")
                $sShortcut.TargetPath = "$md\$aucapfn\AmongUsCapture.exe"
                $sShortcut.IconLocation = "$md\$aucapfn\AmongUsCapture.exe"
                $sShortcut.Save()
            }
            $Bar.Value = "85"
        }elseif($ckbci[$aa] -eq "VC Redist"){
            Write-Log "VC Redist Install start"
            Start-Transcript -Append -Path "$LogFileName"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 vcredist-all -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log "VC Redist Install ends"
            $Bar.Value = "86"
        }elseif($ckbci[$aa] -eq "PowerShell 7"){
            Write-Log "PS7 Install start"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 pwsh powershell-core -y" -Verb RunAs -Wait
            Write-Log "PS7 Install ends"
            $Bar.Value = "87"
        }elseif($ckbci[$aa] -eq "dotNetFramework"){
            Write-Log ".Net Framework Install start"
            Start-Transcript -Append -Path "$LogFileName"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -WindowStyle Minimized -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 dotnet-desktopruntime dotnet-5.0-desktopruntime dotnet-6.0-desktopruntime dotnet -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log ".Net Framework Install ends"
            $Bar.Value = "88"
        }elseif($ckbci[$aa] -eq "NOS Webhook"){
            Write-Log "NOS/NOT Webhook starts"
            if(($scid -eq "NOS") -or ($scid -eq "NOT")){
                if($gmhwebhooktxt -eq "None"){
                    Write-Log "NOS/NOT Webhook skipped."
                }else{
                    $gmhconfig = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"
                    if(!(Test-Path $gmhconfig)){
                        Write-Log "Configが見つからないため、一時的なConfigとして健康ランドレギュレーションをロードします"
                        $kenkoconf = $(invoke-webrequest https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/kenkoland.txt).Content
                        if(!(Test-Path $(Join-Path $aupathm "\BepInEx\config\"))){
                            New-Item $(Join-Path $aupathm "\BepInEx\config\") -Type Directory
                        }
                        $kenkoconf |Out-File $gmhconfig
                    }
                    $gmhconfigtmp = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg.beforewebhook.old"
                    Copy-Item $gmhconfig $gmhconfigtmp
                    $gmhfile = (Get-Content -Encoding utf8 $gmhconfig) -as [string[]]
                    $gmhnewconfig = ""
                    foreach ($gmhline in $gmhfile) {
                        if ($gmhline.StartsWith("WebhookUrl")){
                            if($gmhwebhooktxt -eq "None"){
                                $gmhnewconfig += "$gmhline `r`n"
                            }else{
                                $gmhnewconfig += "WebhookUrl = $gmhwebhooktxt `r`n"                    
                                Write-Log "GMH Webhook : $gmhwebhooktxt"
                            }
                        }else{
                            $gmhnewconfig += "$gmhline `r`n"
                        }
                    }
                    Remove-Item $gmhconfig -Force
                    $gmhnewconfig |Out-File $gmhconfig
                }   
            }else{
                Write-Log "NOS/NOT Webhook skipped."
            }
            Write-Log "NOS/NOT Webhook ends"
            $Bar.Value = "89"
        }elseif($ckbci[$aa] -eq "サーバー情報初期化"){
            Write-Log "サーバー情報を初期化します。"
            if(Test-Path "$env:APPDATA\..\LocalLow\Innersloth"){
                $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                if(Test-Path $aurifile){
                    Remove-Item $aurifile
                }
                $defjson = '{"CurrentRegionIdx":0,"Regions":[{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":289},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":290},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":291},{"$type":"DnsRegionInfo,Assembly-CSharp","Fqdn":"127.0.0.1","DefaultIp":"127.0.0.1","Port":22023,"UseDtls":false,"Name":"Custom","TranslateName":1003}]}'
                $aurijson = ConvertFrom-Json $defjson
                ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                Write-Log "サーバー情報を初期化しました。"
            }else{
                Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
            }
            $Bar.Value = "88"
        }elseif($ckbci[$aa] -eq "カスタムサーバー情報追加"){
            Write-Log "カスタムサーバー情報を追加します。"
            if(Test-Path "$env:APPDATA\..\LocalLow\Innersloth"){
                $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                if(Test-Path $aurifile){
                }else{
                    $defjson = '{"CurrentRegionIdx":0,"Regions":[{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":289},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":290},{"$type":"StaticHttpRegionInfo,Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":true,"Players":0,"ConnectionFailures":0}],"TranslateName":291},{"$type":"DnsRegionInfo,Assembly-CSharp","Fqdn":"127.0.0.1","DefaultIp":"127.0.0.1","Port":22023,"UseDtls":false,"Name":"Custom","TranslateName":1003}]}'
                    $aurijson = ConvertFrom-Json $defjson
                    ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile   
                }
                if($xport -eq "443"){
                    $kenkojson2 = "{`"`$type`":`"StaticHttpRegionInfo, Assembly-CSharp`",`"Name`":`"$xname`",`"PingServer`":`"$xfqip`",`"Servers`":[{`"Name`":`"Http-1`",`"Ip`":`"https://$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Players`":0,`"ConnectionFailures`":0}],`"TranslateName`":1003}"  
                }else{
                    $kenkojson2 = "{`"`$type`":`"StaticHttpRegionInfo, Assembly-CSharp`",`"Name`":`"$xname`",`"PingServer`":`"$xfqip`",`"Servers`":[{`"Name`":`"Http-1`",`"Ip`":`"$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Players`":0,`"ConnectionFailures`":0}],`"TranslateName`":1003}"  
                }
                #$kenkojson2 = "{`"`$type`":`"DnsRegionInfo, Assembly-CSharp`",`"Fqdn`":`"$xfqip`",`"DefaultIp`":`"$xfqip`",`"Port`":$xport,`"UseDtls`":false,`"Name`":`"$xname`",`"TranslateName`": 1003}"
                $auritext = Get-Content $aurifile -Raw
                $aurijson = ConvertFrom-Json $auritext
                $aurijson.Regions += $($kenkojson2 | ConvertFrom-Json)
                if(!(Test-Path "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old")){
                    Copy-Item $aurifile "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old"
                }
                ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                Write-Log "カスタムサーバー情報を追加しました。"
            }else{
                Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
            }
            $Bar.Value = "89"
        }elseif($ckbci[$aa] -eq "健康ランド"){
            if(($scid -eq "NOS") -or ($scid -eq "NOT")){
                Write-Host "健康ランド化 start"
                #regioninfo.json
                if(Test-Path "$env:APPDATA\..\LocalLow\Innersloth"){
                    $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                    if(Test-Path $aurifile){
                        $auritext = Get-Content $aurifile -Raw
                        if($auritext.IndexOf("Modded EU (MEU)") -gt 0){
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded EU (MEU)","PingServer":"https://au-eu.duikbo.at","Servers":[{"Name":"Http-1","Ip":"https://au-eu.duikbo.at","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')
                            Write-Log "MEU Deleted."
                        }
                        if($auritext.IndexOf("Modded NA (MNA)") -gt 0){
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded NA (MNA)","PingServer":"https://aumods.one","Servers":[{"Name":"Http-1","Ip":"https://aumods.one","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "MNA Deleted."
                        }
                        if($auritext.IndexOf("Modded Asia (MAS)") -gt 0){
                            $torjson = ',{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Modded Asia (MAS)","PingServer":"https://au-as.duikbo.at","Servers":[{"Name":"Http-1","Ip":"https://au-as.duikbo.at","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "MAS Deleted."
                        }
                        if($auritext.IndexOf("haoming-server.com") -gt 0){
                            $torjson =',{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"haoming-server.com","DefaultIp":"haoming-server.com","Port":22023,"UseDtls":false,"Name":"haoming-server","TranslateName":1003}'
                            $auritext = $auritext.Replace($torjson, '')    
                            Write-Log "HS Deleted."
                        }
                        Write-Log $auritext
                        #$kenkonewjson = '{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"amongus.kenko.land","DefaultIp":"amongus.kenko.land","Port":22023,"UseDtls":false,"Name":"健康ランド","TranslateName": 1003}'
                        #$kenkonewtjson = '{"$type":"DnsRegionInfo, Assembly-CSharp","Fqdn":"imposter.kenko.land","DefaultIp":"imposter.kenko.land","Port":22023,"UseDtls":false,"Name":"健康ランドテスト","TranslateName": 1003}'
                        $kenkonewjson = '{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"健康ランド","PingServer":"amongus.kenko.land","Servers":[{"Name":"Http-1","Ip":"https://amongus.kenko.land","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'  
                        $kenkonewtjson = '{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"健康ランドテスト","PingServer":"imposter.kenko.land","Servers":[{"Name":"Http-1","Ip":"https://imposter.kenko.land","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TranslateName":1003}'  
                        $aurijson = ConvertFrom-Json $auritext

                        if($auritext.IndexOf("`"Name`":`"健康ランドテスト`"") -lt 0){
                            $aurijson.Regions += $($kenkonewtjson | ConvertFrom-Json)
                        }else{
                            Write-Log "健康ランド済:Staging Server"
                        }
                        if($auritext.IndexOf("`"Name`":`"健康ランド`"") -lt 0){
                            $aurijson.Regions += $($kenkonewjson | ConvertFrom-Json)
                        }else{
                            Write-Log "健康ランド済:Production Server"
                        }

                        if(!(Test-Path "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old")){
                            Copy-Item $aurifile "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json.old"
                        }
                        ConvertTo-Json($aurijson) -Compress -Depth 4 | Out-File $aurifile
                        Write-Log "健康ランド化完了:Server"
                    }else{
                        Write-Log "サーバー情報ファイルが見つかりません。"
                        Write-Log "Among Us本体を一度起動してから再度実行してください。"
                    }
                }else{
                    Write-Log "AmongUsが一度も起動されていないようです。一度起動してから再度Scriptを動作させてください。"
                }        

<#
                if(!(Test-Path "$aupathm\BepInEx\config")){
                    New-Item "$aupathm\BepInEx\config" -Type Directory
                }
                $kenkofile = "$aupathm\BepInEx\config\kenkoland.txt"
                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/kenkoland.txt" -OutFile "$kenkofile" -UseBasicParsing
                $gmhconfig = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"
                $gmhconfigtmp = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg.beforekenkoland.old"

                if(Test-Path $gmhconfig){
                    #configからWebhookを救出
                    $gmhfile = (Get-Content -Encoding utf8 $gmhconfig) -as [string[]]
                    foreach ($gmhline2 in $gmhfile) {
                        if ($gmhline2.StartsWith("WebhookUrl = https://")){
                            Write-Log "WebhookUrl is already set: $gmhline2"
                            $gmhwh = "$gmhline2"
                        }
                    } 
                    #configからProcessorAffinityを救出
                    foreach ($gmhline4 in $gmhfile) {
                        if ($gmhline4.StartsWith("ProcessorAffinity = 0")){
                            Write-Log "ProcessorAffinity is already set: $gmhline4"
                            $gmhpa = "$gmhline4"
                        }
                        if ($gmhline4.StartsWith("ProcessorAffinity = 1")){
                            Write-Log "ProcessorAffinity is already set: $gmhline4"
                            $gmhpa = "$gmhline4"
                        }
                        if ($gmhline4.StartsWith("ProcessorAffinity = 2")){
                            Write-Log "ProcessorAffinity is already set: $gmhline4"
                            $gmhpa = "$gmhline4"
                        }
                        if ($gmhline4.StartsWith("ProcessorAffinity = 3")){
                            Write-Log "ProcessorAffinity is already set: $gmhline4"
                            $gmhpa = "$gmhline4"
                        }
                    } 
                }
                #optionconf
                $ghfile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\gameHostOptions"
                $ghurl = "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/gameHostOptions"
                $indeedgo = $true
                if(Test-Path $ghfile){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("健康ランド化を行うと、既存の部屋設定は全て上書きされます。続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -ne "Yes"){
                        $indeedgo = $false
                    }
                }

                if($indeedgo){
                    if(Test-Path $gmhconfig){
                        Copy-Item $gmhconfig $gmhconfigtmp
                        Remove-Item $gmhconfig -Force
                    }
                    if(Test-Path $ghfile){
                        Remove-Item $ghfile -Force
                    }
                    curl.exe $ghurl -o "$env:APPDATA\..\LocalLow\Innersloth\Among Us\gameHostOptions"

                    $gmhnewconfig = ""           
                    $kenkoconf = (Get-Content -Encoding utf8 $kenkofile) -as [string[]]
                    foreach ($gmhline3 in $kenkoconf) {
                        if ($gmhline3.StartsWith("WebhookUrl")){
                            if($null -ne $gmhwebhooktxt){
                                $gmhnewconfig += "WebhookUrl = $gmhwebhooktxt `r`n"
                            }elseif($null -ne $gmhwh){
                                $gmhnewconfig += "$gmhwh `r`n"
                            }elseif($gmhwebhooktxt -ne ""){
                                $gmhnewconfig += "WebhookUrl = $gmhwebhooktxt `r`n"
                            }elseif($gmhwh -ne ""){
                                $gmhnewconfig += "$gmhwh `r`n"
                            }else{
                                $gmhnewconfig += "$gmhline3 `r`n"
                            }
                        }elseif ($gmhline3.StartsWith("ProcessorAffinity")){
                            if($null -ne $gmhwebhooktxt){
                                $gmhnewconfig += "ProcessorAffinity = $gmhwebhooktxt `r`n"
                            }elseif($null -ne $gmhpa){
                                $gmhnewconfig += "$gmhpa `r`n"
                            }elseif($gmhwebhooktxt -ne ""){
                                $gmhnewconfig += "ProcessorAffinity = $gmhwebhooktxt `r`n"
                            }elseif($gmhpa -ne ""){
                                $gmhnewconfig += "$gmhpa `r`n"
                            }else{
                                $gmhnewconfig += "$gmhline3 `r`n"
                            }
                        }else{
                                $gmhnewconfig += "$gmhline3 `r`n"
                        }
                    }
                    if(!(Test-Path $(Join-Path $aupathm "\BepInEx\config\"))){
                        New-Item $(Join-Path $aupathm "\BepInEx\config\") -Type Directory
                    }
                    Start-Sleep -Seconds 2
                    $gmhnewconfig |Out-File $gmhconfig
                    Remove-Item $kenkofile -Force
                    Write-Log "健康ランド化完了:Config"
                }
#>
                #regu
                if(!(Test-Path "$aupathm\Presets")){
                    New-Item $(Join-Path $aupathm "Presets") -Type Directory
                }
#                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/KenkoLand.json" -OutFile "$aupathm\Presets\KenkoLand.json" -UseBasicParsing
#                Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/Nakarita.json" -OutFile "$aupathm\Presets\Nakarita.json" -UseBasicParsing
#                Write-Log $(Get-Translate("健康ランド化完了:Regulation"))
                Write-Log "健康ランド化 ends"
                $Bar.Value = "88"
            }elseif($ckbci[$aa] -eq "NOS CPU Affinity"){
                Write-Log "NOS CPU Affinity start"
                if(($scid -eq "NOS") -or ($scid -eq "NOT")){
                    if($gmhwebhooktxt -eq "None"){
                        Write-Log "NOS CPU Affinity skipped."
                    }else{
                        $gmhconfig = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"
                        if(!(Test-Path $gmhconfig)){
                            Write-Log "Configが見つからないため、一時的なConfigとして健康ランドレギュレーションをロードします"
                            $kenkoconf = $(invoke-webrequest https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/kenkoland.txt).Content
                            if(!(Test-Path $(Join-Path $aupathm "\BepInEx\config\"))){
                                New-Item $(Join-Path $aupathm "\BepInEx\config\") -Type Directory
                            }
                            $kenkoconf |Out-File $gmhconfig
                        }
                        $gmhconfigtmp = Join-Path $aupathm "\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg.beforewebhook.old"
                        Copy-Item $gmhconfig $gmhconfigtmp
                        $gmhfile = (Get-Content -Encoding utf8 $gmhconfig) -as [string[]]
                        $gmhnewconfig = ""
                        foreach ($gmhline in $gmhfile) {
                            if ($gmhline.StartsWith("ProcessorAffinity")){
                                if($gmhwebhooktxt -eq "None"){
                                    $gmhnewconfig += "$gmhline `r`n"
                                }else{
                                    $gmhnewconfig += "ProcessorAffinity = $gmhwebhooktxt `r`n"                    
                                    Write-Log "CPU Affinity : $gmhwebhooktxt"
                                }
                            }else{
                                $gmhnewconfig += "$gmhline `r`n"
                            }
                        }
                        Remove-Item $gmhconfig -Force
                        $gmhnewconfig |Out-File $gmhconfig
                    }   
                }else{
                    Write-Log "NOS CPU Affinity skipped."
                }
                Write-Log "NOS CPU Affinity ends"
                $Bar.Value = "89"
            }else{
                Write-Log "健康ランド化を実行するにはNOS/NOTを選択してください。"
            }
        }elseif($ckbci[$aa] -eq "配信ソフト"){
            Write-Log "配信ソフトセットアップ"
            Start-Transcript -Append -Path "$LogFileName"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade streamlabs-obs obs-studio  -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log "配信ソフトセットアップ完了"
            $Bar.Value = "91"
        }else{
        }
    }
}

$Bar.Value = "92"

#####
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

####################
#bat file auto update
####################
try{
    choco -v
}catch{
    Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
}
Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/StartAmongUsModTORplusDeployScript.bat" -OutFile "$dsk\StartAmongUsModTORplusDeployScript.bat" -UseBasicParsing
$ps1script += "chcp 65001 `r`n"
$ps1script += "@echo off `r`n"
$ps1script += "curl.exe -k -O -L https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1 `r`n"
$ps1script += "pwsh -NoProfile -ExecutionPolicy Unrestricted .\gmhtechsupport.ps1"
$ps1script += " `"$scid`" `"$aupathm`" `"$platform`" `r`n" 
$ps1script += "del /F /Q .\gmhtechsupport.ps1 `r`n"
$ps1script | Out-File -Encoding "UTF8BOM" -FilePath "$dsk\StartAmongUsGetLogScript_$scid.bat" 

if(Test-Path "$scpath\StartAmongUsModTORplusDeployScript.lnk"){
    Remove-Item "$scpath\StartAmongUsModTORplusDeployScript.lnk"    
}
$sShortcut = $WsShell.CreateShortcut("$scpath\StartAmongUsModTORplusDeployScript.lnk")
$sShortcut.TargetPath = "$dsk\StartAmongUsModTORplusDeployScript.bat"
$sShortcut.WorkingDirectory = "$dsk"
$sShortcut.IconLocation = "$dsk\AUMADS.ico"
$sShortcut.Save()
Write-Log $npl2.Path
Write-Log $dsk
if($npl2.Path -eq $dsk){
    Write-Log "Current location is Working Directory"
}else{
    Write-Log "Current location is not Working Directory"
    Write-Log $npl2.Path
    Write-Log $dsk
    Write-Log $($npl2.Path).length
    Write-Log $dsk.length
    if(Test-Path "$npl2\StartAmongUsModTORplusDeployScript.bat"){
        Remove-Item "$npl2\StartAmongUsModTORplusDeployScript.bat" -Force
    }
    if(Test-Path "$npl2\StartAmongUsGetLogScript_$scid.bat"){
        Remove-Item "$npl2\StartAmongUsGetLogScript_$scid.bat" -Force
    }
 #   if(Test-Path "$npl2\AmongUsModTORplusDeployScript.ps1"){
 #       Remove-Item "$npl2\AmongUsModTORplusDeployScript.ps1" -Force
 #   }
}

####################
## Option Check
####################
if($opflag){
    if(!(Test-Path "$aupathb")){
        New-Item $aupathb -Type Directory 
    }
    Write-Output $ym |Out-File -FilePath "$aupathb\chk$ym.txt"
    $ym2 = $ym -1
    if(Test-Path "$aupathb\chk$ym2.txt"){
        Remove-Item "$aupathb\chk$ym2.txt" -Force
    }    
}
####################

$Bar.Value = "93"
if($platform -eq "Epic"){

    try{
        legendary.exe -V
    }
    catch{
        try{
            choco -v
        }catch{
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

}elseif($platform -eq "Steam"){
    if(!(Test-Path "$aupathm\steam_appid.txt")){
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

if($tio){
    if($startexewhendone -eq $true){
        if($platform -eq "Steam"){
            Start-Process "$aupathm\Among Us.exe"   
        }elseif($platform -eq "Epic"){
            Set-Location "$aupathb"
            legendary.exe launch Among Us
        }else{
            Write-Log "ERROR:Critical run apps"
        }
    }else{
    }
}


if($debugc){
    if($startexewhendone -eq $true){
        Write-Output "`r`nAmong Us 本体の起動中です。本体が終了するまでこのまま放置してください。`r`n"
        #監視プロセス名
        $procName = "Among Us"
        $checkpro = $true
        Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1" -OutFile "$npl\gmhtechsupport.ps1" -UseBasicParsing
        $tsp = &"$npl\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" |Select-Object -Last 1
        Write-Log "-----------------------------------------------------------------"
        Write-Log "Error Check"
        Write-Log "-----------------------------------------------------------------"
        Write-Log $(Get-Translate("After Installation:$tsp"))
        #監視&自動起動
        while($checkpro){
            try{
                #プロセスを取得
                $p = Get-Process $procName -ErrorAction SilentlyContinue
                #始したプロセスが終了するまで待機するように指示
                $p.WaitForExit()
            }
            catch{
                Write-Output "No Process"
            }
            finally{
                $tsp = &"$npl\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" |Select-Object -Last 1
                Remove-Item "$npl\gmhtechsupport.ps1" -Force
                $erchk = Get-content "$tsp" -Raw
                Write-Log $(Get-Translate("After Game Exit:$tsp"))
                if($erchk.LastIndexOf("error") -gt 0){
                    Write-Log "Done."
                }else{
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
Write-Log $error.length

if($error.length -eq 0){
    Write-Log "Script実行時のエラーはなさそうです"
}else{
    Write-Log $error
    for($abc=0;$abc -le $error.Length;$abc++){
        $($error[$abc]) | Out-string | Write-Log 
    }    
}

Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Ends"
Write-Log "-----------------------------------------------------------------"

Start-Sleep -Seconds 1
$Bar.Value = "100"
$Form2.Close()

exit
