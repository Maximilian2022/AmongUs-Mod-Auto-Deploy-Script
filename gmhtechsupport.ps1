# =========================================================================================
# Among Us Mod Tech Support Script (Optimized - V1.1.0)
# =========================================================================================
Param($Arg1, $Arg2, $Arg3) # modid, modpath, platform

$version = "1.1.0"
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# 1. 共通モジュールの読み込み試行 (メインスクリプトと同じディレクトリにある場合)
$npl = Get-Location
$utilsPath = Join-Path $npl "Utils.psm1"
if (Test-Path $utilsPath) {
    Import-Module $utilsPath -Force
} else {
    # 単体動作時のための最低限のログ関数
    function Write-Log($logstring, $path) {
        $msg = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss.fff') $logstring"
        Write-Output $msg | Out-File -FilePath $path -Append
        return $msg
    }
}

# 2. 権限チェック
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Write-Host "管理者権限が必要です。終了します。"
    Pause; Exit
}

# 3. パラメータ初期化
$scid = if ($Arg1) { $Arg1 } else { "NOS" }
$aupathm = if ($Arg2) { $Arg2 } else { "C:\Program Files (x86)\Steam\steamapps\common\Among Us $scid Mod" }
$platform = if ($Arg3) { $Arg3 } else { "Steam" }

# ログ出力先の設定
$LogPath = "C:\Temp\AUM_Tech"
if (-not (Test-Path $LogPath)) { New-Item $LogPath -Type Directory -Force | Out-Null }
$LogFileName = Join-Path $LogPath "AmongUs_$($scid)_TechSupportLog_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

Write-Log "Gathering Tech Support Info Starts - v$version" $LogFileName
Write-Log "ModID: $scid / Platform: $platform / Path: $aupathm" $LogFileName

# 4. ログ収集フェーズ
$logFiles = @(
    @{ Name = "Nebula Log"; Path = Join-Path $aupathm "NebulaLog.txt" },
    @{ Name = "BepInEx Log"; Path = Join-Path $aupathm "BepInEx\LogOutput.log" },
    @{ Name = "persLog"; Path = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\persLog.log" },
    @{ Name = "Player.log"; Path = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\Player.log" },
    @{ Name = "Player-prev.log"; Path = "$env:APPDATA\..\LocalLow\Innersloth\Among Us\Player-prev.log" }
)

foreach ($log in $logFiles) {
    Write-Log "------------------- $($log.Name) -------------------" $LogFileName
    if (Test-Path $log.Path) {
        Get-Content $log.Path -Raw -ErrorAction SilentlyContinue | Out-File -FilePath $LogFileName -Append
    } else {
        Write-Log "File not found: $($log.Path)" $LogFileName
    }
}

# 5. 構成ツリー取得
Write-Log "------------------- Directory Tree -------------------" $LogFileName
if (Test-Path $aupathm) {
    cmd /c "tree `"$aupathm`" /F" | Out-File -FilePath $LogFileName -Append
}

# 6. システム・ネットワーク診断
Write-Log "------------------- DXDiag (System Info) -------------------" $LogFileName
$diagPath = Join-Path $LogPath "dxdiag_temp.txt"
Start-Process dxdiag.exe -ArgumentList "/t $diagPath" -Wait
if (Test-Path $diagPath) {
    Get-Content $diagPath -Encoding Shift_JIS | Out-File -FilePath $LogFileName -Append
    Remove-Item $diagPath -Force
}

Write-Log "------------------- Network Diagnostic -------------------" $LogFileName
"1.1.1.1", "8.8.8.8" | ForEach-Object {
    Write-Log "Pinging $_ ..." $LogFileName
    ping.exe $_ -n 4 | Out-File -FilePath $LogFileName -Append
}

# 7. スピードテスト (1-③ 一括インストールの思想を適用)
if (-not (Get-Command speedtest -ErrorAction SilentlyContinue)) {
    Write-Log "Installing Speedtest CLI..." $LogFileName
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade speedtest -y" -Verb RunAs -Wait
}
if (Get-Command speedtest -ErrorAction SilentlyContinue) {
    Write-Log "Running Speedtest..." $LogFileName
    speedtest --accept-license --accept-gdpr | Out-File -FilePath $LogFileName -Append
}

# 8. Discord送信フェーズ (V3.3.0以降の Invoke-RestMethod 版)
$chkenabled = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/optional/enabledebug.txt" -UseBasicParsing
if ($chkenabled -match "true" -and (Get-Culture).Name -eq "ja-JP") {
    
    $agreementPath = "C:\Temp\agreement.txt"
    $agree = Test-Path $agreementPath
    $usnm = if ($agree) { Get-Content $agreementPath -Raw } else { "" }

    if (-not $agree) {
        $result = [System.Windows.Forms.MessageBox]::Show("結果を診断サーバーに送信しますか？`n(個人情報が含まれる可能性があります)", "Debug Bot", 4)
        if ($result -eq "Yes") {
            Add-Type -AssemblyName Microsoft.VisualBasic
            $usnm = [Microsoft.VisualBasic.Interaction]::InputBox("プレイヤー名を入力してください", "Debug Bot")
            if ($usnm) {
                $usnm | Out-File $agreementPath -Encoding UTF8
                $agree = $true
            }
        }
    }

    if ($agree -and $usnm) {
        Write-Log "Sending data to Discord..." $LogFileName
        $dishook = "https://discord.com/api/webhooks/978249789361754172/Ae0qSR5YmfrtjLU44oTol_p70ciE1agNsg7-__rV_-K4wZHfKWc-cZN5a-9BdMmY7tig"
        
        # PowerShellネイティブなマルチパートフォームデータ送信
        $Form = @{
            content = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $usnm がデバッグ情報を送信しました。"
            file    = Get-Item $LogFileName
        }
        try {
            Invoke-RestMethod -Uri $dishook -Method Post -Form $Form
            Write-Log "送信完了。" $LogFileName
        } catch {
            Write-Log "Discord送信エラー: $($_.Exception.Message)" $LogFileName
        }
    }
}

Write-Log "Tech Support Script Ends." $LogFileName
Invoke-Item $LogPath
return $LogFileName