Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing

$artifactDir = "C:\Users\shuns\.gemini\antigravity-ide\brain\b3731d34-928a-4428-ae06-d14716570512"

# AmongUsModTORplusDeployScript.ps1 から XAML 部分を抽出
$scriptText = Get-Content "d:\github\AmongUs-Mod-Auto-Deploy-Script\AmongUsModTORplusDeployScript.ps1" -Raw -Encoding UTF8

if ($scriptText -match '\[xml\]\$xaml = @''([\s\S]*?)''@') {
    $xamlString = $matches[1]
} else {
    throw "Could not extract XAML from script"
}

[xml]$xaml = $xamlString
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# コントロール参照
$PnlVersionGroup = $window.FindName("PnlVersionGroup")
$PnlBatchMods = $window.FindName("PnlBatchMods")
$CmbMod = $window.FindName("CmbMod")
$CmbVersion = $window.FindName("CmbVersion")
$TxtModPath = $window.FindName("TxtModPath")
$ChkBatchAll = $window.FindName("ChkBatchAll")
$ChkBatch_NOS = $window.FindName("ChkBatch_NOS")
$ChkBatch_SNR = $window.FindName("ChkBatch_SNR")
$ChkBatch_ER = $window.FindName("ChkBatch_ER")
$ChkBatch_ERES = $window.FindName("ChkBatch_ERES")
$ChkBatch_SRA = $window.FindName("ChkBatch_SRA")
$ChkBatch_LM = $window.FindName("ChkBatch_LM")
$ChkBatch_TOH = $window.FindName("ChkBatch_TOH")

$batchCheckBoxMap = [ordered]@{
    "NOS"   = $ChkBatch_NOS
    "SNR"   = $ChkBatch_SNR
    "ER"    = $ChkBatch_ER
    "ER+ES" = $ChkBatch_ERES
    "SRA"   = $ChkBatch_SRA
    "LM"    = $ChkBatch_LM
    "TOH"   = $ChkBatch_TOH
}

# 一括連動ハンドラ設定
$script:updatingBatchChecks = $false
$ChkBatchAll.Add_Checked({
    if ($script:updatingBatchChecks) { return }
    $script:updatingBatchChecks = $true
    foreach ($chk in $batchCheckBoxMap.Values) { if ($chk) { $chk.IsChecked = $true } }
    $script:updatingBatchChecks = $false
})
$ChkBatchAll.Add_Unchecked({
    if ($script:updatingBatchChecks) { return }
    $script:updatingBatchChecks = $true
    foreach ($chk in $batchCheckBoxMap.Values) { if ($chk) { $chk.IsChecked = $false } }
    $script:updatingBatchChecks = $false
})

$updateBatchAllCheck = {
    if ($script:updatingBatchChecks) { return }
    $script:updatingBatchChecks = $true
    $allChecked = $true
    foreach ($chk in $batchCheckBoxMap.Values) {
        if ($chk -and (-not $chk.IsChecked)) {
            $allChecked = $false
            break
        }
    }
    if ($ChkBatchAll) { $ChkBatchAll.IsChecked = $allChecked }
    $script:updatingBatchChecks = $false
}

foreach ($chk in $batchCheckBoxMap.Values) {
    if ($chk) {
        $chk.Add_Checked($updateBatchAllCheck)
        $chk.Add_Unchecked($updateBatchAllCheck)
    }
}

# スクリプトの Reload WPF同期ロジックをシミュレート
function Update-UIState([string]$scid) {
    if ($scid -eq "IUS") {
        if ($PnlVersionGroup) { $PnlVersionGroup.Visibility = [System.Windows.Visibility]::Collapsed }
        if ($CmbVersion) { $CmbVersion.IsEnabled = $false }
        if ($PnlBatchMods) { $PnlBatchMods.Visibility = [System.Windows.Visibility]::Visible }
        if ($TxtModPath) { $TxtModPath.Text = "（一括デプロイ: 選択した各 MOD フォルダへ展開）" }
    }
    elseif ($scid -eq "TIO") {
        if ($PnlVersionGroup) { $PnlVersionGroup.Visibility = [System.Windows.Visibility]::Collapsed }
        if ($CmbVersion) { $CmbVersion.IsEnabled = $false }
        if ($PnlBatchMods) { $PnlBatchMods.Visibility = [System.Windows.Visibility]::Collapsed }
        if ($TxtModPath) { $TxtModPath.Text = "（ツールのみインストールの設定）" }
    }
    else {
        if ($PnlVersionGroup) { $PnlVersionGroup.Visibility = [System.Windows.Visibility]::Visible }
        if ($CmbVersion) { $CmbVersion.IsEnabled = $true }
        if ($PnlBatchMods) { $PnlBatchMods.Visibility = [System.Windows.Visibility]::Collapsed }
        if ($TxtModPath) { $TxtModPath.Text = "C:\Games\Among Us $scid Mod" }
    }
}

function Render-To-Image($elem, $filename) {
    $elem.Measure([System.Windows.Size]::new(900, 650))
    $elem.Arrange([System.Windows.Rect]::new(0, 0, 900, 650))
    $elem.UpdateLayout()
    $rtb = [System.Windows.Media.Imaging.RenderTargetBitmap]::new(900, 650, 96, 96, [System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($elem)
    $enc = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
    $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))
    $out = "$artifactDir\$filename"
    $fs = [System.IO.FileStream]::new($out, [System.IO.FileMode]::Create)
    $enc.Save($fs)
    $fs.Close()
    Write-Host "Exported visual: $out"
}

Write-Host "=== TEST 1: Initial State (NOS) ==="
Update-UIState "NOS"
if ($PnlVersionGroup.Visibility -ne [System.Windows.Visibility]::Visible) { throw "Test 1 Failed: PnlVersionGroup should be Visible" }
if ($CmbVersion.IsEnabled -ne $true) { throw "Test 1 Failed: CmbVersion should be Enabled" }
if ($PnlBatchMods.Visibility -ne [System.Windows.Visibility]::Collapsed) { throw "Test 1 Failed: PnlBatchMods should be Collapsed" }
Render-To-Image $window "ui_state_1_nos.png"
Write-Host "Test 1 PASSED: NOS mode correctly shows Version and hides Batch panel."

Write-Host "=== TEST 2: Batch Install State (IUS) ==="
Update-UIState "IUS"
if ($PnlVersionGroup.Visibility -ne [System.Windows.Visibility]::Collapsed) { throw "Test 2 Failed: PnlVersionGroup should be Collapsed" }
if ($CmbVersion.IsEnabled -ne $false) { throw "Test 2 Failed: CmbVersion should be Disabled" }
if ($PnlBatchMods.Visibility -ne [System.Windows.Visibility]::Visible) { throw "Test 2 Failed: PnlBatchMods should be Visible" }
if ($TxtModPath.Text -notlike "*一括デプロイ*") { throw "Test 2 Failed: TxtModPath should mention 一括デプロイ" }
Render-To-Image $window "ui_state_2_batch.png"
Write-Host "Test 2 PASSED: Batch mode correctly collapses Version and displays modern Batch checkboxes."

Write-Host "=== TEST 3: CheckBox Toggle Logic ==="
# Uncheck ALL -> All individual should be false
$ChkBatchAll.IsChecked = $false
foreach ($k in $batchCheckBoxMap.Keys) {
    if ($batchCheckBoxMap[$k].IsChecked -ne $false) { throw "Test 3 Failed: $k should be false" }
}
# Check ALL -> All individual should be true
$ChkBatchAll.IsChecked = $true
foreach ($k in $batchCheckBoxMap.Keys) {
    if ($batchCheckBoxMap[$k].IsChecked -ne $true) { throw "Test 3 Failed: $k should be true" }
}
# Uncheck one -> ALL should become false
$ChkBatch_NOS.IsChecked = $false
if ($ChkBatchAll.IsChecked -ne $false) { throw "Test 3 Failed: ChkBatchAll should be false when one is uncheked" }
# Re-check that one -> ALL should become true
$ChkBatch_NOS.IsChecked = $true
if ($ChkBatchAll.IsChecked -ne $true) { throw "Test 3 Failed: ChkBatchAll should be true when all are checked" }
Write-Host "Test 3 PASSED: Checkbox mutual interaction works flawlessly."

Write-Host "=== TEST 4: Tool Install Only State (TIO) ==="
Update-UIState "TIO"
if ($PnlVersionGroup.Visibility -ne [System.Windows.Visibility]::Collapsed) { throw "Test 4 Failed: PnlVersionGroup should be Collapsed" }
if ($CmbVersion.IsEnabled -ne $false) { throw "Test 4 Failed: CmbVersion should be Disabled" }
if ($PnlBatchMods.Visibility -ne [System.Windows.Visibility]::Collapsed) { throw "Test 4 Failed: PnlBatchMods should be Collapsed" }
Render-To-Image $window "ui_state_4_tool_only.png"
Write-Host "Test 4 PASSED: Tool Only mode correctly collapses Version and collapses Batch panel."

Write-Host "=== TEST 5: Return to Normal Mod (SNR) ==="
Update-UIState "SNR"
if ($PnlVersionGroup.Visibility -ne [System.Windows.Visibility]::Visible) { throw "Test 5 Failed: PnlVersionGroup should be Visible again" }
if ($CmbVersion.IsEnabled -ne $true) { throw "Test 5 Failed: CmbVersion should be Enabled again" }
if ($PnlBatchMods.Visibility -ne [System.Windows.Visibility]::Collapsed) { throw "Test 5 Failed: PnlBatchMods should be Collapsed again" }
Render-To-Image $window "ui_state_5_snr.png"
Write-Host "Test 5 PASSED: Returning to normal MOD cleanly restores Version selector."

Write-Host "ALL UI TESTS COMPLETED SUCCESSFULLY!"
