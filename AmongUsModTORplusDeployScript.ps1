# =========================================================================================
# Among Us Mod Auto Deploy Script (Self-Repairing Version - V4.2.0)
# =========================================================================================
Param($Args1) 

$version = "4.2.0"
$build   = "20260503010"
$npl = Get-Location
$baseUrl = "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main"

# --- 1. 旧BAT環境からの救済ロジック (不足ファイルの自動ダウンロード) ---
$requiredFiles = @("Utils.psm1", "ModConfig.json", "GlobalVersionSettings.json")
foreach ($f in $requiredFiles) {
    if (-not (Test-Path ".\$f")) {
        Write-Host "アップデート用の不足ファイルをダウンロード中: $f"
        try {
            Invoke-WebRequest -Uri "$baseUrl/$f" -OutFile ".\$f" -UseBasicParsing -ErrorAction Stop
        } catch {
            Write-Host "致命的なエラー: $f のダウンロードに失敗しました。ネットワークを確認してください。"
            Pause; Exit
        }
    }
}

# --- 2. 初期化・モジュールロード ---
$UtilsPath = Join-Path $npl "Utils.psm1"
$ModConfigPath = Join-Path $npl "ModConfig.json"
$GlobalConfigPath = Join-Path $npl "GlobalVersionSettings.json"

Import-Module $UtilsPath -Force
$ModConfigs = Get-Content $ModConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$GlobalVer  = Get-Content $GlobalConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json

# ログ設定
$LogPath = "C:\Temp\AUM_Deploy"; $global:LogFileName = Join-Path $LogPath "AmongUsMod_DeployLog_$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss').log"
if (-not (Test-Path $LogPath)) { New-Item $LogPath -Type Directory -Force | Out-Null }

# 時刻同期とPS7ブートストラップ
$w32tmStatus = w32tm /query /status | Out-String
if ($w32tmStatus -match "0x80070426" -or $w32tmStatus -match "エラー") {
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -Command `"net start 'windows time'; Start-Sleep 2; w32tm /config /syncfromflags:manual /manualpeerlist:'time.google.com,0x8 time.aws.com,0x8' /reliable:yes /update; w32tm /resync`"" -Verb RunAs -Wait
}

if ($PSVersionTable.PSVersion.Major -lt 7) {
    if (-not (Test-Path "$env:ProgramFiles\PowerShell\7\pwsh.exe")) {
        Start-Process powershell.exe -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade pwsh aria2 legendary -y" -Verb RunAs -Wait
    }
    $argsStr = if ($Args1) { "-Args1 `"$Args1`"" } else { "" }
    Start-Process "$env:ProgramFiles\PowerShell\7\pwsh.exe" -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$PSCommandPath`" $argsStr" -Verb RunAs -Wait
    Exit
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    $argsStr = if ($Args1) { "-Args1 `"$Args1`"" } else { "" }
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -File `"$PSCommandPath`" $argsStr" -Verb RunAs -Wait
    Exit
}

# --- 3. GUIフェーズ ---
if ($null -eq $Args1) {
    Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing
    $form = New-Object System.Windows.Forms.Form; $form.Text = "AUMADS v$version"; $form.Size = "815,680"; $form.StartPosition = "CenterScreen"; $form.Font = New-Object System.Drawing.Font("メイリオ", 12)
    $dskPath = Join-Path ([System.Environment]::GetFolderPath("Desktop")) "AUMADS"; if (Test-Path "$dskPath\AUMADS.ico") { $form.Icon = "$dskPath\AUMADS.ico" }

    $ComboMod = New-Object System.Windows.Forms.Combobox; $ComboMod.Location = "55, 95"; $ComboMod.Size = "330, 30"; $ComboMod.DropDownStyle = "DropDownList"
    foreach ($mod in $ModConfigs) { [void]$ComboMod.Items.Add($mod.DisplayName) }
    [void]$ComboMod.Items.Add("Install/Update Selected"); [void]$ComboMod.Items.Add("Tool Install Only")

    $ComboVer = New-Object System.Windows.Forms.Combobox; $ComboVer.Location = "55, 180"; $ComboVer.Size = "330, 30"; $ComboVer.DropDownStyle = "DropDownList"
    $CheckedBoxTools = New-Object System.Windows.Forms.CheckedListBox; $CheckedBoxTools.Location = "55, 270"; $CheckedBoxTools.Size = "330, 185"
    $CheckedBoxTools.Items.AddRange(@("AmongUsCapture", "VC Redist", "BetterCrewLink", "PowerShell 7", "dotNetFramework", "LevelImposter", "Submerged", "VOICEVOX", "カスタムサーバー情報追加", "サーバー情報初期化", "配信ソフト", "健康ランド"))

    $GrpAuVer = New-Object System.Windows.Forms.GroupBox; $GrpAuVer.Location="400,10"; $GrpAuVer.Size="375,70"; $GrpAuVer.Text="本体Versionを選択してください"
    $RadAuA = New-Object System.Windows.Forms.RadioButton; $RadAuA.Location="10,30"; $RadAuA.Text=$GlobalVer.GameVersions.Latest.Label; $RadAuA.Checked=$true
    $RadAuB = New-Object System.Windows.Forms.RadioButton; $RadAuB.Location="130,30"; $RadAuB.Text=$GlobalVer.GameVersions.Previous.Label
    $RadAuC = New-Object System.Windows.Forms.RadioButton; $RadAuC.Location="250,30"; $RadAuC.Text=$GlobalVer.GameVersions.Legacy.Label
    $GrpAuVer.Controls.AddRange(@($RadAuA, $RadAuB, $RadAuC))

    $GrpFolder = New-Object System.Windows.Forms.GroupBox; $GrpFolder.Location="400,90"; $GrpFolder.Size="375,70"; $GrpFolder.Text="フォルダ設定"
    $RadRecreate = New-Object System.Windows.Forms.RadioButton; $RadRecreate.Location="10,30"; $RadRecreate.Text="再作成する"; $RadRecreate.Checked=$true
    $RadOverwrite = New-Object System.Windows.Forms.RadioButton; $RadOverwrite.Location="160,30"; $RadOverwrite.Text="上書きする"
    $GrpFolder.Controls.AddRange(@($RadRecreate, $RadOverwrite))

    $GrpShortcut = New-Object System.Windows.Forms.GroupBox; $GrpShortcut.Location="400,170"; $GrpShortcut.Size="375,70"; $GrpShortcut.Text="ショートカット"
    $RadScCreate = New-Object System.Windows.Forms.RadioButton; $RadScCreate.Location="10,30"; $RadScCreate.Text="作成する"; $RadScCreate.Checked=$true
    $RadScDebug = New-Object System.Windows.Forms.RadioButton; $RadScDebug.Location="160,30"; $RadScDebug.Text="デバッグ"; $RadScNone = New-Object System.Windows.Forms.RadioButton; $RadScNone.Location="270,30"; $RadScNone.Text="作成しない"
    $GrpShortcut.Controls.AddRange(@($RadScCreate, $RadScDebug, $RadScNone))

    $GrpCpu = New-Object System.Windows.Forms.GroupBox; $GrpCpu.Location="400,250"; $GrpCpu.Size="375,70"; $GrpCpu.Text="CPU Affinity"
    $RadCpu1 = New-Object System.Windows.Forms.RadioButton; $RadCpu1.Location="10,30"; $RadCpu1.Text="CPU 0のみ"; $RadCpu3 = New-Object System.Windows.Forms.RadioButton; $RadCpu3.Location="130,30"; $RadCpu3.Text="CPU 0 1"; $RadCpu0 = New-Object System.Windows.Forms.RadioButton; $RadCpu0.Location="250,30"; $RadCpu0.Text="設定しない"; $RadCpu0.Checked=$true
    $GrpCpu.Controls.AddRange(@($RadCpu1, $RadCpu3, $RadCpu0))

    $BtnOK = New-Object System.Windows.Forms.Button; $BtnOK.Location="580,590"; $BtnOK.Text="OK"; $BtnOK.DialogResult="OK"
    $form.Controls.AddRange(@($ComboMod, $ComboVer, $CheckedBoxTools, $GrpAuVer, $GrpFolder, $GrpShortcut, $GrpCpu, $BtnOK)); $form.AcceptButton = $BtnOK; $form.TopMost = $true

    $ApiCache = @{}
    $ComboMod.add_SelectedIndexChanged({
        if ($ComboMod.Text -in @("Install/Update Selected", "Tool Install Only")) { $ComboVer.Enabled = $false; return }
        $ComboVer.Enabled = $true; $modData = $ModConfigs | Where-Object { $_.DisplayName -eq $ComboMod.Text }
        $modCompat = $GlobalVer.ModCompatibility.($modData.Id); $minVer = if ($RadAuA.Checked) { $modCompat.MinVerLatest } elseif ($RadAuB.Checked) { $modCompat.MinVerPrev } else { $modCompat.MinVerLegacy }
        $url = $modData.ReleaseUrl
        if (-not $ApiCache.ContainsKey($url)) { try { $ApiCache[$url] = Invoke-RestMethod -Uri $url -UseBasicParsing -TimeoutSec 5 } catch {} }
        if ($ApiCache.ContainsKey($url)) {
            $versions = @($ApiCache[$url]).tag_name | Where-Object { $_ -ge $minVer } | Sort-Object { $_ -replace '[^0-9\.]','' -as [version] } -Descending
            $ComboVer.DataSource = $versions
        }
    })
    $ComboMod.SelectedIndex = 0

    $ym = Get-Date -Format "yyyyMM"; if (-not (Test-Path "C:\Temp\AUM_Deploy\chk$ym.txt")) { @("VC Redist", "dotNetFramework", "PowerShell 7") | ForEach-Object { $CheckedBoxTools.SetItemChecked($CheckedBoxTools.Items.IndexOf($_), $true) }; New-Item "C:\Temp\AUM_Deploy\chk$ym.txt" -ItemType File -Force | Out-Null }

    if ($form.ShowDialog() -ne "OK") { Exit }

    if ($ComboMod.Text -eq "Install/Update Selected") {
        for ($i = 0; $i -lt $ModConfigs.Count; $i++) { Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -WindowStyle Minimized -File `"$PSCommandPath`" -Args1 `"$i`"" -Verb RunAs -Wait }
        Exit
    }

    $targetModData = $ModConfigs | Where-Object { $_.DisplayName -eq $ComboMod.Text }; $targetVersion = $ComboVer.Text; $selectedTools = @($CheckedBoxTools.CheckedItems); $cpuAffinityValue = if ($RadCpu1.Checked) { 1 } elseif ($RadCpu3.Checked) { 3 } else { 0 }
    $isRecreate = $RadRecreate.Checked; $scMode = if ($RadScCreate.Checked) { "Create" } elseif ($RadScDebug.Checked) { "Debug" } else { "None" }
    $auTargetVer = ""; $auDepotId = ""; if ($RadAuB.Checked) { $auTargetVer = $GlobalVer.GameVersions.Previous.Version; $auDepotId = $GlobalVer.GameVersions.Previous.SteamDepotId } elseif ($RadAuC.Checked) { $auTargetVer = $GlobalVer.GameVersions.Legacy.Version; $auDepotId = $GlobalVer.GameVersions.Legacy.SteamDepotId }

} else {
    $targetModData = $ModConfigs[$Args1]; $targetVersion = (@(Invoke-RestMethod -Uri $targetModData.ReleaseUrl -UseBasicParsing).tag_name | Sort-Object { $_ -replace '[^0-9\.]','' -as [version] } -Descending)[0]
    $selectedTools = @(); $cpuAffinityValue = 0; $isRecreate = $true; $scMode = "Create"; $auTargetVer = ""; $auDepotId = ""
}

# --- 4. 実行フェーズ ---
if (-not (Get-Module -Name 7Zip4Powershell -ListAvailable)) { Install-Module -Name 7Zip4Powershell -Force -Scope CurrentUser }
$jsondata = "{`"date`":`"$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss.fff')`", `"mod`":`"$($targetModData.Id)`", `"version`":`"$targetVersion`", `"main`":`"Auto`"}"
try { curl.exe -X POST -H "Content-Type: application/json" -d $jsondata -L "https://script.google.com/macros/s/AKfycbyr8P-sfWEgG9IdYNeillASu7dtnnnhV607XimGh3NXJY8OiWm51_LvP6VPU79zfvx0/exec" | Out-Null } catch {}

if ($ComboMod.Text -eq "Tool Install Only") { Install-AmongUsPeripheralTools -SelectedTools $selectedTools -ModId "TIO" -ModPath $npl -LogFileName $global:LogFileName; Exit }

$AuEnv = Get-AmongUsEnvironment -ModId $targetModData.Id -LogFileName $global:LogFileName
if (-not $AuEnv.IsValid) { Exit }
$aupatho = $AuEnv.OriginalPath; $aupathm = $AuEnv.ModPath; $aupathb = $AuEnv.BackupPath; $platform = $AuEnv.Platform

$currentBaseVer = Get-AmongUsVersion -GamePath $aupatho
$BaseGameZip = Invoke-AmongUsBackupAndDowngrade -OriginalPath $aupatho -BackupPath $aupathb -Platform $platform -CurrentVersion $currentBaseVer -TargetVersion $auTargetVer -TargetDepotId $auDepotId -LogFileName $global:LogFileName
if ($null -eq $BaseGameZip) { Exit }

if (Test-Path $aupathm) {
    foreach ($cfg in $targetModData.ConfigFiles) { if (Test-Path "$aupathm\BepInEx\config\$cfg") { Copy-Item "$aupathm\BepInEx\config\$cfg" "C:\Temp\$cfg" -Force } }
    foreach ($f in $targetModData.BackupFolders) { if (Test-Path "$aupathm\$f") { New-Item "C:\Temp\$f" -ItemType Directory -Force | Out-Null; Copy-Item "$aupathm\$f\*" -Recurse "C:\Temp\$f" -Force } }
    if ($isRecreate) { Remove-Item $aupathm -Recurse -Force }
}

if (-not (Test-Path $aupathm)) { New-Item $aupathm -ItemType Directory -Force | Out-Null }
Expand-7Zip -ArchiveFileName $BaseGameZip -TargetPath $aupathm

$zipUrl = (@(Invoke-RestMethod -Uri $targetModData.ReleaseUrl -UseBasicParsing) | Where-Object { $_.tag_name -eq $targetVersion }).assets | Where-Object { $_.name -match "\.zip$" } | Select-Object -ExpandProperty browser_download_url -First 1
if ($zipUrl) { aria2c -x5 -V --dir "$aupathm" -o "ModFile.zip" $zipUrl | Out-Null; Expand-7Zip -ArchiveFileName "$aupathm\ModFile.zip" -TargetPath $aupathm; Remove-Item "$aupathm\ModFile.zip" -Force }

Invoke-ModSpecificPatches -ModId $targetModData.Id -ModPath $aupathm -TargetVersion $targetVersion -LogFileName $global:LogFileName
foreach ($cfg in $targetModData.ConfigFiles) { if (Test-Path "C:\Temp\$cfg") { New-Item "$aupathm\BepInEx\config" -ItemType Directory -Force | Out-Null; Copy-Item "C:\Temp\$cfg" "$aupathm\BepInEx\config\$cfg" -Force; Remove-Item "C:\Temp\$cfg" -Force } }
foreach ($f in $targetModData.BackupFolders) { if (Test-Path "C:\Temp\$f") { New-Item "$aupathm\$f" -ItemType Directory -Force | Out-Null; robocopy "C:\Temp\$f" "$aupathm\$f" /E >$null 2>&1; Remove-Item "C:\Temp\$f" -Recurse -Force } }

Install-AmongUsPeripheralTools -SelectedTools $selectedTools -ModId $targetModData.Id -ModPath $aupathm -LogFileName $global:LogFileName

if ($selectedTools -contains "健康ランド") {
    $regionFile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
    if (Test-Path $regionFile) { $jsonObj = Get-Content $regionFile -Raw | ConvertFrom-Json; $jsonObj.Regions = @($jsonObj.Regions | Where-Object { $_.Name -notin @("Modded EU (MEU)", "Modded NA (MNA)", "Modded Asia (MAS)", "haoming-server") }); if (-not ($jsonObj.Regions | Where-Object { $_.Name -eq "健康ランド" })) { $jsonObj.Regions += @{ '$type'="StaticHttpRegionInfo, Assembly-CSharp"; Name="健康ランド"; PingServer="amongus.kenko.land"; Servers=@(@{Name="Http-1";Ip="http://amongus.kenko.land";Port=22023;UseDtls=$false;Players=0;ConnectionFailures=0}); TranslateName=1003 } }; $jsonObj | ConvertTo-Json -Depth 10 -Compress | Out-File $regionFile -Encoding utf8 }
}

if ($scMode -ne "None") { New-AmongUsShortcut -ModId $targetModData.Id -ModPath $aupathm -Platform $platform -CpuAffinity $cpuAffinityValue -IsDebugMode ($scMode -eq "Debug") -LogFileName $global:LogFileName }
if ($platform -eq "Steam" -and -not (Test-Path "$aupathm\steam_appid.txt")) { "945360" | Out-File "$aupathm\steam_appid.txt" -Encoding ascii }
if ($platform -eq "Epic") { Set-Location $aupathb; legendary.exe auth --import | Out-Null; legendary.exe -y uninstall "Among Us" --keep-files | Out-Null; legendary.exe -y import "Among Us" $aupathm | Out-Null; legendary.exe -y egl-sync | Out-Null; Set-Location $npl }

# --- 5. 自身のBATファイルを最新化 (欠落機能の復元 & スムーズな移行) ---
$batPath = Join-Path $PSScriptRoot "StartAmongUsModTORplusDeployScript.bat"
if (Test-Path $batPath) {
    Write-Log "ランチャーBATを最新版に更新中..." $global:LogFileName
    try {
        Invoke-WebRequest -Uri "$baseUrl/StartAmongUsModTORplusDeployScript.bat" -OutFile $batPath -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {}
}

Write-Log "Deploy Completed Successfully."
Start-Sleep -Seconds 2; Exit