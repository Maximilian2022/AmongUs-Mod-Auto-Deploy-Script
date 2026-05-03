# =========================================================================================
# Utils.psm1 (Among Us Mod Auto Deploy Tool - V4.1.0)
# =========================================================================================

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$Global:Cult = Get-Culture
$Global:TranslationCache = @{}
$Global:TransEnabled = $true

function Get-Translate($transtext) {
    if ($Global:Cult.Name -ne "ja-JP" -and $Global:TransEnabled) {
        if ($Global:TranslationCache.ContainsKey($transtext)) { return $Global:TranslationCache[$transtext] }
        try {
            $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($Global:Cult.Name)&dt=t&q=$([uri]::EscapeDataString($transtext))"
            $Response = Invoke-RestMethod -Uri $Uri -Method Get -TimeoutSec 5
            $result = $Response[0][0][0]
            $Global:TranslationCache[$transtext] = $result; return $result
        } catch { return $transtext }
    }
    return $transtext
}

function Write-Log($LogString, $LogFile) {
    $Now = Get-Date; $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + "  " + $LogString
    if ($LogFile) { Write-Output $(Get-Translate $Log) | Out-File -FilePath $LogFile -Encoding utf8 -Append }
    Return $(Get-Translate $Log)
}

Add-Type -AssemblyName System.Windows.Forms
function Get-FolderPathG {
    param([string]$Description = $(Get-Translate "フォルダを選択してください"))
    $process = [Diagnostics.Process]::GetCurrentProcess(); $window = New-Object Windows.Forms.NativeWindow; $window.AssignHandle($process.MainWindowHandle)
    $fd = New-Object System.Windows.Forms.FolderBrowserDialog; $fd.Description = $Description
    if ($fd.ShowDialog($window) -eq [System.Windows.Forms.DialogResult]::OK) { return $fd.SelectedPath }
    return $null
}

function ToHex([byte[]] $hashBytes) { $b = New-Object System.Text.StringBuilder; $hashBytes | ForEach-Object { [void] $b.Append($_.ToString("x2")) }; return $b.ToString() }
function GetFilesRecurse([string] $path) { Get-ChildItem $path -Recurse | Where-Object -FilterScript { ($_.Attributes -band 16) -eq 0 } }
function MakeEntry { process { New-Object PSObject -Property @{ LastWriteTime = $_.LastWriteTime; Length = $_.Length; FullName = $_.FullName; } } }
function MakeHashInfo([string] $algoName = "SHA1") { begin { $algo = [System.Security.Cryptography.HashAlgorithm]::Create($algoName) } process { $is = New-Object IO.StreamReader $_.FullName; try { $hashVal = ToHex($algo.ComputeHash($is.BaseStream)); $_ | Add-Member -MemberType NoteProperty -Name $algoName -Value $hashVal; return $_ } finally { $is.Close() } } end { [void] $algo.Dispose() } }

Function ConvertFrom-VDF {
    param([Parameter(Position=0, Mandatory=$true)][System.String[]]$InputObject)
    process {
        $root = New-Object -TypeName PSObject; $chain = [ordered]@{}; $depth = 0; $parent = $root; $element = $null
        ForEach ($line in $InputObject) {
            $q = (Select-String -Pattern '(?<=")([^\"\t\s]+\s?)+(?=")' -InputObject $line -AllMatches).Matches
            if ($q.Count -eq 1) { $element = New-Object -TypeName PSObject; Add-Member -InputObject $parent -MemberType NoteProperty -Name $q[0].Value -Value $element }
            elseif ($q.Count -eq 2) { Add-Member -InputObject $element -MemberType NoteProperty -Name $q[0].Value -Value $q[1].Value }
            elseif ($line -match "{") { $chain.Add($depth, $element); $depth++; $parent = $chain.($depth - 1) }
            elseif ($line -match "}") { $depth--; $parent = $chain.($depth - 1); $element = $parent; $chain.Remove($depth) }
        }
        return $root
    }  
}

function Get-AmongUsEnvironment {
    param ([string]$ModId, [string]$LogFileName)
    $envInfo = @{ OriginalPath = ""; ModPath = ""; BackupPath = ""; Platform = ""; IsValid = $false }
    $npl = Get-Location; $dskConfFile = Join-Path ([System.Environment]::GetFolderPath("Desktop")) "AUMADS\AmongUsModDeployScript.conf"
    $steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue; $epicProc = Get-Process -Name "EpicGamesLauncher" -ErrorAction SilentlyContinue

    $pathsToCheck = @( @{ Platform = "Steam"; Path = "C:\Program Files (x86)\Steam\steamapps\common\Among Us" }, @{ Platform = "Epic"; Path = "C:\Program Files (x86)\Epic Games\AmongUs" } )

    if ($steamProc) {
        $detectedSteamPath = Join-Path (Split-Path $steamProc.Path -Parent) "SteamLibrary\steamapps\common\Among Us"
        if (-not (Test-Path $detectedSteamPath)) { foreach ($num in 65..90) { $drivePath = "$([char]$num):\SteamLibrary\steamapps\common\Among Us"; if (Test-Path $drivePath) { $detectedSteamPath = $drivePath; break } } }
        if (Test-Path $detectedSteamPath) { $pathsToCheck += @{ Platform = "Steam"; Path = $detectedSteamPath } }
    }

    if ($epicProc -and (Get-Command legendary.exe -ErrorAction SilentlyContinue)) {
        legendary.exe auth --import | Out-Null; $epicInfo = legendary.exe info AmongUs *>&1; $epicPathLine = $epicInfo | Select-String "Install path"
        if ($epicPathLine) { $epicReal = (Split-Path -Path ($epicPathLine.ToString() -split ": ")[1]) + "/AmongUs"; if (Test-Path $epicReal) { $pathsToCheck += @{ Platform = "Epic"; Path = $epicReal } } }
    }

    $targetPath = ""; $targetPlatform = ""
    foreach ($p in $pathsToCheck) { if (Test-Path "$($p.Path)\Among Us.exe") { $targetPath = $p.Path; $targetPlatform = $p.Platform; break } }

    if ($targetPath -eq "") {
        if (Test-Path $dskConfFile) { $confData = (Get-Content $dskConfFile) -split "_:_"; $targetPath = $confData[0]; $targetPlatform = $confData[1]; Remove-Item $dskConfFile -Force }
        else {
            $vdfParsed = $false
            if ($steamProc) {
                $vdfPath = Join-Path (Split-Path $steamProc.Path -Parent) "steamapps\libraryfolders.vdf"
                if (Test-Path $vdfPath) {
                    $cfvdf = ConvertFrom-VDF (Get-Content $vdfPath)
                    foreach ($property in $cfvdf.libraryfolders.psobject.properties.name) {
                        if (([string]$($cfvdf.libraryfolders."$property".apps)).Contains("945360")) { $vdfDetect = Join-Path $cfvdf.libraryfolders."$property".path "steamapps\common\Among Us"; if (Test-Path "$vdfDetect\Among Us.exe") { $targetPath = $vdfDetect; $targetPlatform = "Steam"; $vdfParsed = $true; break } }
                    }
                }
            }
            if (-not $vdfParsed) {
                [System.Windows.Forms.MessageBox]::Show($(Get-Translate "Modが入っていないAmong Usのフォルダを選択してください"), "AUMADS")
                $targetPath = Get-FolderPathG
                if ($targetPath -and (Test-Path "$targetPath\Among Us.exe")) { $targetPlatform = if ([System.Windows.Forms.MessageBox]::Show("PlatformはSteamですか？", "AUMADS", 4) -eq "Yes") { "Steam" } else { "Epic" } } else { return $envInfo }
            }
        }
    }

    if (Test-Path "$targetPath\BepInEx") {
        if ([System.Windows.Forms.MessageBox]::Show("Mod入りが検出されました。クリーンインストールしますか？", "AUMADS", 4) -eq "Yes") {
            $cleanScriptPath = Join-Path $npl "AmongusCleanInstall_$targetPlatform.ps1"
            Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/AmongusCleanInstall_$targetPlatform.ps1" -OutFile $cleanScriptPath -UseBasicParsing
            Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$cleanScriptPath`"" -Verb RunAs -Wait; Remove-Item $cleanScriptPath -Force
            if ($targetPlatform -eq "Steam") { return $envInfo }
        } else { return $envInfo }
    }

    $envInfo.OriginalPath = $targetPath; $envInfo.ModPath = Join-Path (Split-Path $targetPath -Parent) "Among Us $ModId Mod"; $envInfo.BackupPath = Join-Path (Split-Path $targetPath -Parent) "Among Us Backup"; $envInfo.Platform = $targetPlatform; $envInfo.IsValid = $true
    "$targetPath`_:_$targetPlatform" | Out-File $dskConfFile -Encoding utf8
    return $envInfo
}

function Get-AmongUsVersion {
    param ([string]$GamePath)
    $managerFile = Join-Path $GamePath "Among Us_Data\globalgamemanagers"
    if (-not (Test-Path $managerFile)) { return $null }
    $bytes = (Format-Hex -Path $managerFile).Bytes; $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $matches = [regex]::Matches($text, "(19|20)[0-9]{2}[- /.](0[1-9]|1[012]|[1-9])[- /.](0[1-9]|[12][0-9]|3[01]|[1-9])")
    if ($null -ne $matches[1]) { return $matches[1].Value } elseif ($null -ne $matches[0]) { return $matches[0].Value }
    return $null
}

function Invoke-AmongUsBackupAndDowngrade {
    param ([string]$OriginalPath, [string]$BackupPath, [string]$Platform, [string]$CurrentVersion, [string]$TargetVersion, [string]$TargetDepotId, [string]$LogFileName)
    if (-not (Test-Path $BackupPath)) { New-Item $BackupPath -ItemType Directory -Force | Out-Null }
    $datest = Get-Date -Format "yyyyMMdd-HHmmss"
    $currentZipSearch = Get-ChildItem $BackupPath -Filter "*v$CurrentVersion.zip" -ErrorAction SilentlyContinue
    
    if (-not $currentZipSearch) {
        $backupZip = Join-Path $BackupPath "Among Us-$datest-v$CurrentVersion.zip"; Compress-7Zip -Path $OriginalPath -ArchiveFileName $backupZip
        if ($Platform -eq "Epic" -and (Test-Path "$OriginalPath\.egstore")) {
            $epicManDir = Join-Path $BackupPath "epic_manifest"; if (-not (Test-Path $epicManDir)) { New-Item $epicManDir -ItemType Directory -Force | Out-Null }
            $egmani = Get-ChildItem -Path "$OriginalPath\.egstore\*.manifest" | Select-Object -First 1; if ($egmani) { Copy-Item $egmani.FullName (Join-Path $epicManDir "v$CurrentVersion.manifest") -Force }
        }
    }
    if ($TargetVersion -eq $CurrentVersion -or $TargetVersion -eq "") { return (Get-ChildItem $BackupPath -Filter "*v$CurrentVersion.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName }
    $targetZipSearch = Get-ChildItem $BackupPath -Filter "*v$TargetVersion.zip" -ErrorAction SilentlyContinue; if ($targetZipSearch) { return ($targetZipSearch | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName }

    if ($Platform -eq "Steam") {
        $steamProc = Get-Process -Name "steam" -ErrorAction SilentlyContinue; $steampth = if ($steamProc) { $steamProc.Path } else { "C:\Program Files (x86)\Steam\Steam.exe" }
        Start-Process $steampth -ArgumentList "+download_depot 945360 945361 $TargetDepotId"; $depotFolder = Join-Path (Split-Path $steampth -Parent) "steamapps\content\app_945360\depot_945361"
        $counter = 0; $downloadSuccess = $false
        while ($counter -lt 80) { Start-Sleep -Seconds 15; if (Test-Path $depotFolder) { if ((Get-ChildItem $depotFolder | Measure-Object).Count -ge 8) { $downloadSuccess = $true; break } }; $counter++ }
        if ($downloadSuccess) { $targetZip = Join-Path $BackupPath "Among Us-$datest-v$TargetVersion.zip"; Compress-7Zip -Path $depotFolder -ArchiveFileName $targetZip; Remove-Item -Path (Split-Path $depotFolder -Parent) -Recurse -Force; return $targetZip }
    } elseif ($Platform -eq "Epic") {
        $epicManDir = Join-Path $BackupPath "epic_manifest"; $targetManifest = Join-Path $epicManDir "v$TargetVersion.manifest"
        if (-not (Test-Path $targetManifest)) {
            $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Filter = "*.manifest|*.manifest"; if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { if (-not (Test-Path $epicManDir)) { New-Item $epicManDir -ItemType Directory -Force | Out-Null }; Copy-Item $dialog.FileName $targetManifest -Force } else { return $null }
        }
        $tempAppPath = Join-Path $BackupPath "AmongUsTemp"; legendary.exe auth --import | Out-Null; legendary.exe -y import 'Among Us' $OriginalPath | Out-Null; legendary.exe uninstall "Among Us" --keep-files -y | Out-Null
        Copy-Item $OriginalPath $tempAppPath -Recurse -Force; legendary.exe -y import 'Among Us' $tempAppPath | Out-Null
        if (Test-Path $tempAppPath) { Remove-Item $tempAppPath -Recurse -Force; legendary.exe install "Among Us" --old-manifest $targetManifest --disable-patching --enable-reordering --repair -y | Out-Null; $targetZip = Join-Path $BackupPath "Among Us-$datest-v$TargetVersion.zip"; Compress-7Zip -Path $tempAppPath -ArchiveFileName $targetZip; Remove-Item $tempAppPath -Recurse -Force; return $targetZip }
    }
    return $null
}

function Invoke-ModSpecificPatches {
    param ([string]$ModId, [string]$ModPath, [string]$TargetVersion, [string]$LogFileName)
    $pluginsDir = Join-Path $ModPath "BepInEx\plugins"; if (-not (Test-Path $pluginsDir)) { New-Item $pluginsDir -ItemType Directory -Force | Out-Null }

    if ($ModId -in @("ER", "ER+ES")) {
        $exveUrl = "https://github.com/yukieiji/ExtremeRoles/releases/download/$TargetVersion/ExtremeVoiceEngine.dll"
        aria2c -x5 -V --dir $pluginsDir -o "ExtremeVoiceEngine.dll" $exveUrl | Out-Null
    }

    if ($ModId -eq "AMS") {
        $amsDllUrl = (@(Invoke-RestMethod "https://api.github.com/repos/AUModS/AUModS/releases" -UseBasicParsing) | Where-Object { $_.tag_name -eq $TargetVersion }).assets | Where-Object { $_.name -match "\.dll$" } | Select-Object -ExpandProperty browser_download_url -First 1
        if ($amsDllUrl) { aria2c -x5 -V --dir $pluginsDir -o "AUModS.dll" $amsDllUrl | Out-Null }
    }

    $regionMods = @("TOU-R", "SRA", "ER", "ER+ES", "NOS", "NOT", "LM", "TOH", "TOY", "SNR", "TOR", "TOR MR")
    if ($ModId -in $regionMods) {
        $riUrl = ((Invoke-RestMethod "https://api.github.com/repos/miniduikboot/Mini.RegionInstall/releases" -UseBasicParsing)[0].assets | Where-Object { $_.name -match "Mini.RegionInstall.dll$" })[0].browser_download_url
        if ($riUrl) { aria2c -x5 -V --dir $pluginsDir -o "Mini.RegionInstall.dll" $riUrl | Out-Null }
        $cfgContent = "[General]`r`nRegions = "
        if ($ModId -eq "TOU-R") {
            $cfgContent += '{\"CurrentRegionIdx\":0,\"Regions\":[{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded NA (MNA)","PingServer": "https://www.aumods.us","Servers": [{"Name": "Http-1","Ip": "https://www.aumods.us","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003},{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded EU (MEU)","PingServer": "https://au-eu.duikbo.at","Servers": [{"Name": "Http-1","Ip": "https://au-eu.duikbo.at","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003},{"$type": "StaticHttpRegionInfo, Assembly-CSharp","Name": "Modded Asia (MAS)","PingServer": "https://au-as.duikbo.at","Servers": [{"Name": "Http-1","Ip": "https://au-as.duikbo.at","Port": 443,"UseDtls": false,"Players": 0,"ConnectionFailures": 0}],"TargetServer": null,"TranslateName": 1003}]}'
            $cfgContent += "`r`nRemoveRegions = haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=`"center`">Tokyo</align>`r`n"
        } elseif ($ModId -in @("NOS", "NOT")) {
            $cfgContent += '{\"CurrentRegionIdx\":0,\"Regions\":[{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Nebula","PingServer":"cs.supernewroles.com","Servers":[{"Name":"http-1","Ip":"http://168.138.44.249","Port":22023,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":1003}]}'
            $cfgContent += "`r`nRemoveRegions = haoming-server,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=`"center`">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)`r`n"
        } else {
            $cfgContent += '{\"CurrentRegionIdx\":0,\"Regions\":[]}'
            $cfgContent += "`r`nRemoveRegions = haoming-server,Nebula,ExROfficialTokyo,<size=150%><color=#ffa500>Super</color><color=#ff0000>New</color><color=#00ff00>Roles</color></size>\n<align=`"center`">Tokyo</align>,Modded NA (MNA),Modded EU (MEU),Modded Asia (MAS)`r`n"
        }
        $riCfgPath = Join-Path $ModPath "BepInEx\config\at.duikbo.regioninstall.cfg"
        if (-not (Test-Path (Split-Path $riCfgPath -Parent))) { New-Item (Split-Path $riCfgPath -Parent) -ItemType Directory -Force | Out-Null }
        $cfgContent | Out-File -FilePath $riCfgPath -Encoding UTF8
    }
}

function New-AmongUsShortcut {
    param ([string]$ModId, [string]$ModPath, [string]$Platform, [int]$CpuAffinity, [bool]$IsDebugMode, [string]$LogFileName)
    $scpath = [System.Environment]::GetFolderPath("Desktop"); $dsk = Join-Path $scpath "AUMADS"; $shortcutPath = Join-Path $scpath "Among Us Mod $ModId.lnk"; $modIdSafe = $ModId -replace " ", "_"
    if (Test-Path $shortcutPath) { Remove-Item $shortcutPath -Force }
    $WsShell = New-Object -ComObject WScript.Shell; $sShortcut = $WsShell.CreateShortcut($shortcutPath)
    if ($IsDebugMode) {
        $techSupportPs1 = Join-Path $dsk "gmhtechsupport.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/gmhtechsupport.ps1" -OutFile $techSupportPs1 -UseBasicParsing
        $batPath = Join-Path $dsk "startamongusrun_$modIdSafe.bat"; $ps1Path = Join-Path $dsk "amongusrun_$modIdSafe.ps1"
        "chcp 65001`r`n@echo off`r`npowershell -NoProfile -ExecutionPolicy Unrestricted -File `"$ps1Path`"`r`nexit" | Out-File $batPath -Encoding default
        @"
`$Platform = "$Platform"; `$ModPath = "$ModPath"; `$ModId = "$ModId"; `$TechScript = "$techSupportPs1"
if (`$Platform -eq "Steam") { Start-Process "`$ModPath\Among Us.exe" } elseif (`$Platform -eq "Epic") { legendary.exe launch Among Us }
Start-Sleep -Seconds 5
if ($CpuAffinity -gt 0) { Get-Process -Name 'Among Us' -ErrorAction SilentlyContinue | ForEach-Object { `$_.ProcessorAffinity = $CpuAffinity } }
`$procName = "Among Us"; `$checkpro = `$true; `$tsp = & "`$TechScript" "`$ModId" "`$ModPath" "`$Platform" | Select-Object -Last 1
while(`$checkpro) { try { (Get-Process `$procName -ErrorAction SilentlyContinue).WaitForExit() } catch { } finally { `$checkpro = `$false } }
"@ | Out-File $ps1Path -Encoding UTF8BOM
        $sShortcut.TargetPath = $batPath; $sShortcut.WorkingDirectory = $dsk
    } else {
        if ($Platform -eq "Steam") {
            if ($CpuAffinity -gt 0) { $sShortcut.TargetPath = "pwsh.exe"; $sShortcut.Arguments = "-WindowStyle Hidden -Command `"Start-Process '$ModPath\Among Us.exe'; Start-Sleep -Seconds 15; Get-Process -Name 'Among Us' -ErrorAction SilentlyContinue | ForEach-Object { `$_.ProcessorAffinity=$CpuAffinity }`"" } else { $sShortcut.TargetPath = Join-Path $ModPath "Among Us.exe" }
            $sShortcut.WorkingDirectory = $ModPath
        } elseif ($Platform -eq "Epic") {
            $batPath = Join-Path $dsk "startamongusrun_$modIdSafe.bat"; $ps1Path = Join-Path $dsk "amongusrun_$modIdSafe.ps1"
            "chcp 65001`r`n@echo off`r`npowershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Unrestricted -File `"$ps1Path`"`r`nexit" | Out-File $batPath -Encoding default
            $affinityCmd = if ($CpuAffinity -gt 0) { "Get-Process -Name 'Among Us' -ErrorAction SilentlyContinue | ForEach-Object { `$_.ProcessorAffinity=$CpuAffinity };" } else { "" }
            "legendary launch Among Us; Start-Sleep -Seconds 30; $affinityCmd" | Out-File $ps1Path -Encoding UTF8BOM
            $sShortcut.TargetPath = "pwsh.exe"; $sShortcut.Arguments = "-Command Start-Process '$batPath'"; $sShortcut.WorkingDirectory = $ModPath
        }
    }
    $sShortcut.IconLocation = Join-Path $dsk "AUMADS.ico"; $sShortcut.Save()
    if ($Platform -eq "Epic") { try { $bytes = [System.IO.File]::ReadAllBytes($shortcutPath); $bytes[0x15] = $bytes[0x15] -bor 0x20; [System.IO.File]::WriteAllBytes($shortcutPath, $bytes) } catch {} }
}

function Install-AmongUsPeripheralTools {
    param ([string[]]$SelectedTools, [string]$ModId, [string]$ModPath, [string]$LogFileName)
    if (-not $SelectedTools -or $SelectedTools.Count -eq 0) { return }
    $md = [System.Environment]::GetFolderPath("MyDocuments")
    $chocoPackages = @()
    if ($SelectedTools -contains "VC Redist") { $chocoPackages += "vcredist-all" }
    if ($SelectedTools -contains "PowerShell 7") { $chocoPackages += "pwsh", "powershell-core" }
    if ($SelectedTools -contains "dotNetFramework") { $chocoPackages += "dotnet-desktopruntime", "dotnet-8.0-desktopruntime", "dotnet" }
    if ($SelectedTools -contains "配信ソフト") { $chocoPackages += "streamlabs-obs", "obs-studio" }
    if ($chocoPackages.Count -gt 0) { Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Minimized -Command choco upgrade aria2 $($chocoPackages -join ' ') -y" -Verb RunAs -Wait }

    foreach ($tool in $SelectedTools) {
        switch ($tool) {
            "サーバー情報初期化" {
                $aurifile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"
                $defjson = '{"CurrentRegionIdx":3,"Regions":[{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"North America","PingServer":"matchmaker.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":289},{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Europe","PingServer":"matchmaker-eu.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-eu.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":290},{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Asia","PingServer":"matchmaker-as.among.us","Servers":[{"Name":"Http-1","Ip":"https://matchmaker-as.among.us","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":291},{"$type":"StaticHttpRegionInfo, Assembly-CSharp","Name":"Custom","PingServer":"imposter.kenko.land","Servers":[{"Name":"Http-1","Ip":"http://imposter.kenko.land","Port":443,"UseDtls":false,"Players":0,"ConnectionFailures":0}],"TargetServer":null,"TranslateName":1003}]}'
                $defjson | Out-File $aurifile -Encoding utf8
            }
            "BetterCrewLink" {
                $bclUrl = ((Invoke-RestMethod "https://api.github.com/repos/OhMyGuus/BetterCrewLink/releases/latest" -UseBasicParsing).assets | Where-Object { $_.name -match "\.exe$" -and $_.name -notmatch "\.blockmap$" })[0].browser_download_url
                if ($bclUrl) { aria2c -x5 -V --allow-overwrite=true --dir "$md" -o "BCL_Setup.exe" $bclUrl | Out-Null; Start-Process "$md\BCL_Setup.exe" -Wait; Remove-Item "$md\BCL_Setup.exe" -Force }
            }
            "AmongUsCapture" {
                $aucUrl = ((Invoke-RestMethod "https://api.github.com/repos/automuteus/amonguscapture/releases/latest" -UseBasicParsing).assets | Where-Object { $_.name -match "\.zip$" })[0].browser_download_url
                if ($aucUrl) { aria2c -x5 -V --allow-overwrite=true --dir "$md" -o "AUC.zip" $aucUrl | Out-Null; Expand-7Zip -ArchiveFileName "$md\AUC.zip" -TargetPath "$md\AmongUsCapture"; Remove-Item "$md\AUC.zip" -Force; $WsShell = New-Object -ComObject WScript.Shell; $sShortcut = $WsShell.CreateShortcut(Join-Path ([System.Environment]::GetFolderPath("Desktop")) "AmongUsCapture.lnk"); $sShortcut.TargetPath = "$md\AmongUsCapture\AmongUsCapture.exe"; $sShortcut.Save() }
            }
            "VOICEVOX" {
                $vvRelease = Invoke-RestMethod "https://api.github.com/repos/VOICEVOX/voicevox/releases/latest" -UseBasicParsing; $targetName = if ((Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue).Name -match "nvidia") { "VOICEVOX-CUDA.Web.Setup" } else { "VOICEVOX.Web.Setup" }
                $vvUrl = ($vvRelease.assets | Where-Object { $_.name -match $targetName })[0].browser_download_url
                if ($vvUrl) { aria2c -x5 -V --allow-overwrite=true --dir "$md" -o "VV_Setup.exe" $vvUrl | Out-Null; Start-Process "$md\VV_Setup.exe" -Verb RunAs -Wait; Remove-Item "$md\VV_Setup.exe" -Force }
            }
            "LevelImposter" { if ($ModId -notin @("IUS", "TIO")) { $pluginsDir = Join-Path $ModPath "BepInEx\plugins"; aria2c -x5 -V --dir $pluginsDir -o "Reactor.dll" ((Invoke-RestMethod "https://api.github.com/repos/NuclearPowered/Reactor/releases/latest").assets[0].browser_download_url) | Out-Null; aria2c -x5 -V --dir $pluginsDir -o "LevelImposter.dll" ((Invoke-RestMethod "https://api.github.com/repos/DigiWorm0/LevelImposter/releases/latest").assets[0].browser_download_url) | Out-Null } }
            "Submerged" { if ($ModId -notin @("IUS", "TIO")) { aria2c -x5 -V --dir (Join-Path $ModPath "BepInEx\plugins") -o "Submerged.dll" ((Invoke-RestMethod "https://api.github.com/repos/SubmergedAmongUs/Submerged/releases/latest").assets[0].browser_download_url) | Out-Null } }
            "カスタムサーバー情報追加" {
                $formCustom = New-Object System.Windows.Forms.Form; $formCustom.Text = "カスタムサーバー情報追加"; $formCustom.Size = "500,280"; $formCustom.StartPosition = 'CenterScreen'
                $lbl1 = New-Object System.Windows.Forms.Label; $lbl1.Location="10,10"; $lbl1.Text="サーバー名:"; $txtName = New-Object System.Windows.Forms.TextBox; $txtName.Location="10,30"; $txtName.Size="460,20"
                $lbl2 = New-Object System.Windows.Forms.Label; $lbl2.Location="10,60"; $lbl2.Text="FQDN/IP:"; $txtIp = New-Object System.Windows.Forms.TextBox; $txtIp.Location="10,80"; $txtIp.Size="460,20"
                $lbl3 = New-Object System.Windows.Forms.Label; $lbl3.Location="10,110"; $lbl3.Text="ポート:"; $txtPort = New-Object System.Windows.Forms.TextBox; $txtPort.Location="10,130"; $txtPort.Size="460,20"; $txtPort.Text="22000"
                $btnOk = New-Object System.Windows.Forms.Button; $btnOk.Location="380,200"; $btnOk.Text="OK"; $btnOk.DialogResult="OK"
                $formCustom.Controls.AddRange(@($lbl1,$txtName,$lbl2,$txtIp,$lbl3,$txtPort,$btnOk)); $formCustom.AcceptButton = $btnOk; $formCustom.TopMost = $true
                if ($formCustom.ShowDialog() -eq "OK" -and $txtName.Text -and $txtIp.Text -and $txtPort.Text) { $regionFile = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\regionInfo.json"; if (Test-Path $regionFile) { $jsonObj = Get-Content $regionFile -Raw | ConvertFrom-Json; $jsonObj.Regions += @{ '$type'="StaticHttpRegionInfo, Assembly-CSharp"; Name=$txtName.Text; PingServer=$txtIp.Text; Servers=@(@{Name="Http-1";Ip="http://$($txtIp.Text)";Port=[int]$txtPort.Text;UseDtls=$false;Players=0;ConnectionFailures=0}); TranslateName=1003 }; $jsonObj | ConvertTo-Json -Depth 10 -Compress | Out-File $regionFile -Encoding utf8 } }
            }
        }
    }
}

Export-ModuleMember -Function Get-Translate, Write-Log, Get-FolderPathG, ToHex, GetFilesRecurse, MakeEntry, MakeHashInfo, ConvertFrom-VDF, Get-AmongUsEnvironment, Get-AmongUsVersion, Invoke-AmongUsBackupAndDowngrade, Invoke-ModSpecificPatches, New-AmongUsShortcut, Install-AmongUsPeripheralTools