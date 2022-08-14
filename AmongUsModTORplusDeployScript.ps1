#################################################################################################
#
# Among Us Mod Auto Deploy Script
#
$version = "1.4.8"
#
#################################################################################################
### minimum version for v2022.06.21
$snrmin = "1.4.0.9"
$tohmin = "v2.1.0"
$tormin = "v4.1.5"
$ermin = "v3.0.0.0"
$esmin = "v3.0.0.0"
$torhmin = "v2.1.60"
$nosmin = "1.9.6,2022.6.21"
$tourmin = "v3.2.0"
$tormmin = "MR_v2.1.2"

#TOR plus, TOR GM, AUM is depricated.

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
# Run w/ Powershell v7 if available.
#################################################################################################
$npl = Get-Location
Write-Output $(Get-Translate("実行前チェック開始"))
try{
    pwsh -Command '$PSVersionTable.PSVersion.major'
}
catch{
    Write-Output $(Get-Translate("初起動時のみ: Powershell 7を導入中・・・。"))
    $com = 'Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"'
    $com | Out-File -Encoding "UTF8" -FilePath ".\ps.ps1" 
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\ps.ps1`"" -Verb RunAs -Wait
    Remove-Item "$npl\ps.ps1" -Force
    Write-Output "`r`n"
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Unrestricted -File `"$npl\AmongUsModTORplusDeployScript.ps1`"" -Verb RunAs -Wait
    Write-Output "`r`n"
    Exit
}

Unblock-File "$npl\AmongUsModTORplusDeployScript.ps1"
function IsZenkaku
{
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateLength(1, 1)]
        [string]
        $Text
    )
    process
    {
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

$v5run = $false
if($PSVersionTable.PSVersion.major -eq 5){
    if(test-path "$env:ProgramFiles\PowerShell\7"){
        pwsh.exe -NoProfile -ExecutionPolicy Unrestricted "$npl\AmongUsModTORplusDeployScript.ps1"
    }else{
        $v5run = $true
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongUsModTORplusDeployScript.ps1`"" -Verb RunAs -Wait
            exit
        }
    }
}elseif($PSVersionTable.PSVersion.major -gt 5){
    $v5run = $true
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\AmongUsModTORplusDeployScript.ps1`"" -Verb RunAs -Wait
        exit
    }
}else{
    write-host $(Get-Translate("ERROR - PowerShell Version : not supported."))
}

if(!($v5run)){
    exit
}
#>

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
# バイト配列を16進数文字列に変換する. 
function ToHex([byte[]] $hashBytes)
{
    $builder = New-Object System.Text.StringBuilder
    $hashBytes | ForEach-Object{ [void] $builder.Append($_.ToString("x2")) }
    $builder.ToString()
}

# 指定したフォルダ以下の全てのファイルを取得する.
# (ファイルが指定された場合はファイル自身を返す)
function GetFilesRecurse([string] $path)
{
    Get-ChildItem $path -Recurse |
        Where-Object -FilterScript {
            # ディレクトリ以外のみ (ディレクトリのビットマスク値は16)
            ($_.Attributes -band 16) -eq 0
        }
}

function MakeEntry
{
    process {
        New-Object PSObject -Property @{
            LastWriteTime = $_.LastWriteTime;
            Length = $_.Length;
            FullName = $_.FullName;
        }
    }
}

# パイプラインからのファイルのハッシュ情報を取得する.
#https://gist.github.com/seraphy/4674696
function MakeHashInfo([string] $algoName = $(throw "MD5, SHA1, SHA512などを指定します."))
{
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
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco install aria2 -y" -Verb RunAs -Wait   
}

<#
if(Test-Path "C:\Temp"){
    if(!(Test-Path "C:\Temp\aria2\aria2c.exe")){
        $ar2 = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/aria2/aria2/releases/latest" -UseBasicParsing)).assets.browser_download_url
        for($arxx=0;$arxx -lt $ar2.Length;$arxx++ ){
            if($($ar2[$arxx]).Contains("64bit")){
                $ardl = $($ar2[$arxx])
            }
        }
        curl.exe -L $ardl -o "C:\Temp\aria2.zip"
        Expand-Archive -path "C:\Temp\aria2.zip" -DestinationPath "C:\Temp\aria2" -Force
        $ar2fol = split-path $ardl -Leaf
        $ar2fol = $ar2fol.Substring(0,$ar2fol.Length -4)
        robocopy "C:\Temp\aria2\$ar2fol" "C:\Temp\aria2" /E >nul 2>&1 
        Remove-Item "C:\Temp\aria2\$ar2fol" -Recurse
        if(Test-Path "C:\Temp\aria2\aria2c.exe"){
            write-host "ar2 loading done"
        }
    }else{
        write-host "aria2 loaded."
    }
}else{
    write-host "error no temp folder on C."
}
#>
#################################################################################################
# Clock Sync
#################################################################################################

w32tm /config /syncfromflags:manual /manualpeerlist:time.google.com /update
w32tm /resync
$ntpres = w32tm /query /status 
Write-Log $ntpres

#################################################################################################
### GM Mod or TOR+ 選択メニュー表示
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
$form.Size = New-Object System.Drawing.Size(800,680)
$form.StartPosition = "CenterScreen"
$form.font = $Font
$form.FormBorderStyle = "Fixed3D"
$form.MaximumSize = "800,850"

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
$MyGroupBox3.size = New-Object System.Drawing.Size(350,100)
$MyGroupBox3.text = $(Get-Translate("既存のフォルダを上書き/再作成しますか？"))

# グループの中のラジオボタンを作る
$RadioButton5 = New-Object System.Windows.Forms.RadioButton
$RadioButton5.Location = New-Object System.Drawing.Point(20,30)
$RadioButton5.size = New-Object System.Drawing.Size(120,30)
$RadioButton5.Checked = $True
$RadioButton5.Text = $(Get-Translate("再作成する"))

$RadioButton6 = New-Object System.Windows.Forms.RadioButton
$RadioButton6.Location = New-Object System.Drawing.Point(20,60)
$RadioButton6.size = New-Object System.Drawing.Size(130,30)
$RadioButton6.Text = $(Get-Translate("再作成しない"))

$RadioButton7 = New-Object System.Windows.Forms.RadioButton
$RadioButton7.Location = New-Object System.Drawing.Point(150,30)
$RadioButton7.size = New-Object System.Drawing.Size(120,30)
$RadioButton7.Text = $(Get-Translate("上書きする"))

$RadioButton17 = New-Object System.Windows.Forms.RadioButton
$RadioButton17.Location = New-Object System.Drawing.Point(150,60)
$RadioButton17.size = New-Object System.Drawing.Size(190,30)
$RadioButton17.Text = $(Get-Translate("クリーンインストール"))

# グループにラジオボタンを入れる
$MyGroupBox3.Controls.AddRange(@($Radiobutton5,$RadioButton6,$RadioButton7,$RadioButton17))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox3)


###作成したModのExeへのショートカットをDesktopに配置する
# グループを作る
$MyGroupBox = New-Object System.Windows.Forms.GroupBox
$MyGroupBox.Location = New-Object System.Drawing.Point(400,120)
$MyGroupBox.size = New-Object System.Drawing.Size(350,90)
$MyGroupBox.text = $(Get-Translate("ショートカットを作成しますか？"))

# グループの中のラジオボタンを作る
$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = New-Object System.Drawing.Point(20,30)
$RadioButton1.size = New-Object System.Drawing.Size(100,30)
$RadioButton1.Checked = $True
$RadioButton1.Text = $(Get-Translate("作成する"))

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = New-Object System.Drawing.Point(120,30)
$RadioButton2.size = New-Object System.Drawing.Size(110,30)
$RadioButton2.Text = $(Get-Translate("作成しない"))

$RadioButton42 = New-Object System.Windows.Forms.RadioButton
$RadioButton42.Location = New-Object System.Drawing.Point(230,30)
$RadioButton42.size = New-Object System.Drawing.Size(100,30)
$RadioButton42.Text = $(Get-Translate("デバッグ"))

# グループにラジオボタンを入れる
$MyGroupBox.Controls.AddRange(@($Radiobutton1,$RadioButton2,$RadioButton42))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox)

###作成したModを即座に実行する
#デフォルトでは実行しない
# グループを作る
$MyGroupBox2 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox2.Location = New-Object System.Drawing.Point(400,230)
$MyGroupBox2.size = New-Object System.Drawing.Size(350,90)
$MyGroupBox2.text = $(Get-Translate("作成したModをすぐに起動しますか？"))

# グループの中のラジオボタンを作る
$RadioButton3 = New-Object System.Windows.Forms.RadioButton
$RadioButton3.Location = New-Object System.Drawing.Point(20,30)
$RadioButton3.size = New-Object System.Drawing.Size(150,30)
$RadioButton3.Checked = $True
$RadioButton3.Text = $(Get-Translate("起動する"))

$RadioButton4 = New-Object System.Windows.Forms.RadioButton
$RadioButton4.Location = New-Object System.Drawing.Point(180,30)
$RadioButton4.size = New-Object System.Drawing.Size(150,30)
$RadioButton4.Text = $(Get-Translate("起動しない"))

# グループにラジオボタンを入れる
$MyGroupBox2.Controls.AddRange(@($Radiobutton3,$RadioButton4))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox2)

$MyGroupBox4 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox4.Location = New-Object System.Drawing.Point(400,290)
$MyGroupBox4.size = New-Object System.Drawing.Size(350,70)
$MyGroupBox4.text = $(Get-Translate("AUShipMOD を同梱しますか？"))

# グループの中のラジオボタンを作る
$RadioButton8 = New-Object System.Windows.Forms.RadioButton
$RadioButton8.Location = New-Object System.Drawing.Point(20,30)
$RadioButton8.size = New-Object System.Drawing.Size(150,30)
$RadioButton8.Checked = $True
$RadioButton8.Text = $(Get-Translate("同梱する"))

$RadioButton9 = New-Object System.Windows.Forms.RadioButton
$RadioButton9.Location = New-Object System.Drawing.Point(180,30)
$RadioButton9.size = New-Object System.Drawing.Size(150,30)
$RadioButton9.Text = $(Get-Translate("同梱しない"))

# グループにラジオボタンを入れる
$MyGroupBox4.Controls.AddRange(@($Radiobutton8,$RadioButton9))
# フォームに各アイテムを入れる
#$form.Controls.Add($MyGroupBox4)

$MyGroupBox24 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox24.Location = New-Object System.Drawing.Point(400,340)
$MyGroupBox24.size = New-Object System.Drawing.Size(350,90)
$MyGroupBox24.text = $(Get-Translate("Submerged を同梱しますか？"))

# グループの中のラジオボタンを作る
$RadioButton28 = New-Object System.Windows.Forms.RadioButton
$RadioButton28.Location = New-Object System.Drawing.Point(20,30)
$RadioButton28.size = New-Object System.Drawing.Size(100,30)
$RadioButton28.Text = $(Get-Translate("同梱する"))

$RadioButton29 = New-Object System.Windows.Forms.RadioButton
$RadioButton29.Location = New-Object System.Drawing.Point(120,30)
$RadioButton29.size = New-Object System.Drawing.Size(110,30)
$RadioButton29.Text = $(Get-Translate("同梱しない"))
$RadioButton29.Checked = $True

$RadioButton27 = New-Object System.Windows.Forms.RadioButton
$RadioButton27.Location = New-Object System.Drawing.Point(230,30)
$RadioButton27.size = New-Object System.Drawing.Size(100,30)
$RadioButton27.Text = $(Get-Translate("除去する"))

# グループにラジオボタンを入れる
$MyGroupBox24.Controls.AddRange(@($Radiobutton28,$RadioButton29,$RadioButton27))
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
$CheckedBox.Size = "270,185"

# 配列を作成 ,"OBS","Streamlabs OBS"
$RETU = ("AmongUsCapture","VC Redist","BetterCrewLink","AmongUsReplayInWindow","PowerShell 7","dotNetFramework")
# チェックボックスに10項目を追加
$CheckedBox.Items.AddRange($RETU)

$pwshv = (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" -UseBasicParsing)).tag_name

if("v$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)" -ne "$pwshv"){
    $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("PowerShell 7"),$true)
}

# すべての既存の選択をクリア
$CheckedBox.ClearSelected()
$form.Controls.Add($CheckedBox)

# コンボボックスを作成
$Combo = New-Object System.Windows.Forms.Combobox
$Combo.Location = New-Object System.Drawing.Point(55,95)
$Combo.size = New-Object System.Drawing.Size(270,30)
$Combo.DropDownStyle = "DropDownList"
$Combo.FlatStyle = "standard"
$Combo.font = $Font
$form.ShowIcon = $False

# コンボボックスに項目を追加
[void] $Combo.Items.Add("TOR GMH :haoming37/TheOtherRoles-GM-Haoming")
[void] $Combo.Items.Add("TOR MR :miru-y/TheOtherRoles-MR")
[void] $Combo.Items.Add("TOR :TheOtherRolesAU/TheOtherRoles")
[void] $Combo.Items.Add("TOU-R :eDonnes124/Town-Of-Us-R")
[void] $Combo.Items.Add("ER :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("ER+ES :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("NOS :Dolly1016/Nebula")
[void] $Combo.Items.Add("SNR :ykundesu/SuperNewRoles")
[void] $Combo.Items.Add("TOH :tukasa0001/TownOfHost")
[void] $Combo.Items.Add("Tool Install Only")
$Combo.SelectedIndex = 0

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
$Combo2.size = New-Object System.Drawing.Size(270,30)
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

$scid = "TOR Plus"
$tio = $true
$aumin =""
$aupatho=""
$aupathm=""
$aupathb=""
$checkt = $true
$releasepage =""
$ausmod = $false
$ovwrite = $false

$Combo_SelectedIndexChanged= {
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
            $releasepage2 = "https://api.github.com/repos/haoming37/TheOtherRoles-GM-Haoming/releases"
            $scid = "TOR GMH"
            $aumin = $torhmin
            Write-Log "TOR GMH Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"TOR MR :miru-y/TheOtherRoles-MR"{
            $releasepage2 = "https://api.github.com/repos/miru-y/TheOtherRoles-MR/releases"
            $scid = "TOR MR"
            $aumin = $tormmin
            Write-Log "TOR MR Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"TOR GMH :haoming37/TheOtherRoles-GM-Haoming"{
            $releasepage2 = "https://api.github.com/repos/haoming37/TheOtherRoles-GM-Haoming/releases"
            $scid = "TOR GMH"
            $aumin = $torhmin
            Write-Log "TOR GMH Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"TOR :Eisbison/TheOtherRoles"{
            $releasepage2 = "https://api.github.com/repos/TheOtherRolesAU/TheOtherRoles/releases"
            $scid = "TOR"
            $aumin = $tormin
            Write-Log "TOR Selected"
            $RadioButton9.Checked = $True
            $RadioButton28.Checked = $True
        }"TOU-R :eDonnes124/Town-Of-Us-R"{
            $releasepage2 = "https://api.github.com/repos/eDonnes124/Town-Of-Us-R/releases"
            $scid = "TOU-R"
            $aumin = $tourmin
            Write-Log "TOU-R Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"ER :yukieiji/ExtremeRoles"{
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER"
            $aumin = $ermin
            Write-Log "ER Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"ER+ES :yukieiji/ExtremeRoles"{
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER+ES"
            $aumin = $esmin
            Write-Log "ER+ES Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"NOS :Dolly1016/Nebula"{
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            $aumin = $nosmin
            Write-Log "NOS Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"SNR :ykundesu/SuperNewRoles"{
            $releasepage2 = "https://api.github.com/repos/ykundesu/SuperNewRoles/releases"
            $scid = "SNR"
            $aumin = $snrmin
            Write-Log "SNR Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"TOH :tukasa0001/TownOfHost"{
            $releasepage2 = "https://api.github.com/repos/tukasa0001/TownOfHost/releases"
            $scid = "TOH"
            $aumin = $tohmin
            Write-Log "TOH Selected"
            $RadioButton9.Checked = $True
            $RadioButton29.Checked = $True
        }"Tool Install Only"{
            $tio = $false
            Write-Log "TOI Selected"
            $combo2.Enabled = $false
        }
    }

    if($tio){
        #GithubのRelease一覧からぶっこぬく
        $web = Invoke-WebRequest $releasepage2 -UseBasicParsing
        $web2 = ConvertFrom-Json $web.Content
    
        $list2 =@()
        # コンボボックスに項目を追加
        if($scid -eq "NOS"){
            for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                if($web2.tag_name[$ai] -ge $nosmin){
                    if($($($web2.tag_name[$ai]).ToLower()).indexof("lang") -lt 0){
                        $list2 += $($web2.tag_name[$ai])
                    }        
                }
            }            
        }else{            
            for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                if($web2.tag_name[$ai] -ge $aumin){
                    $list2 += $($web2.tag_name[$ai])
                }
            }
        }
        $combo2.DataSource = $list2
        $Combo2.SelectedIndex = 0

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
  
        if(Test-path "$au_path_steam_org\Among Us.exe"){
            #original check Steamのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$au_path_steam_org\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("オリジナルパスにMod入りAmong Usが検出されました。クリーンインストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
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
                    Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongusCleanInstall_Epic.ps1" -OutFile "$npl\AmongusCleanInstall_Epic.ps1" -UseBasicParsing
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
        }else{
            $fileName = Join-path $npl "\AmongUsModDeployScript.conf"
            ### Load
            if(test-path "$fileName"){
                $spath2 = Get-content "$fileName"
                $spath3 = $spath2.split("_:_")
                $spath = $spath3[0] 
                $script:platform = $spath3[1]
                Remove-Item $fileName
            }else{
                #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
                Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"      
                Write-Log "フォルダをユーザーに選択するようダイアログを出します"      
                [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っていないAmongUsがインストールされているフォルダを選択してください")), "Among Us Mod Auto Deploy Tool")
                $spath = Get-FolderPathG
            }
            if($spath -eq $null){
                Write-Log "Failed $spath"
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
                    Write-Log "フォルダ指定が正しい場合は、クリーンインストールを試してみてください"
                    Write-Log "処理を中止します"      
                    pause
                    exit
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
        $ym = Get-Date -Format yyyyMM
        if(!(Test-Path "$aupathb\chk$ym.txt")){
            $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("VC Redist"),$true)
            $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("dotNetFramework"),$true)                       
            $CheckedBox.SetItemChecked($CheckedBox.items.IndexOf("PowerShell 7"),$true)                       
            Write-Output $ym |Out-File -FilePath "$aupathb\chk$ym.txt"
            $ym2 = $ym -1
            if(Test-Path "$aupathb\chk$ym2.txt"){
                Remove-Item "$aupathb\chk$ym2.txt" -Force
            }
        }
    }
    $script:tio = $tio
}

$sttime = Get-Date

# フォームにコンボボックスを追加
$form.Controls.Add($Combo)
$form.Controls.Add($Combo2)
Invoke-Command -ScriptBlock $Combo_SelectedIndexChanged
$Combo.add_SelectedIndexChanged($Combo_SelectedIndexChanged)

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
Write-Log "$mod が選択されました"
Write-Log "Version $torpv が選択されました"
Write-Log $releasepage

if($RadioButton8.Checked){
    $ausmod = $true
}else{
    $ausmod = $false
}
if($RadioButton28.Checked){
    $submerged = $true
}else{
    $submerged = $false
}
#################################################################################################>

# プログレスバー
$Form2 = New-Object System.Windows.Forms.Form
$Form2.Size = "500,100"
$Form2.Startposition = "CenterScreen"
$Form2.Text = "Among Us Mod Auto Deploy Tool"
$form2.ShowIcon = $False
$form2.FormBorderStyle = "Fixed3D"

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
    $Bar.Value = "14"
    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
        if($web2.tag_name[$ai] -eq "$torpv"){
            if($scid -eq "TOR GMH"){
                if($torpv -lt $torhmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "TheOtherRole-GM-Haoming Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "TOR"){
                if($torpv -lt $tormin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "TheOtherRole Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "TOU-R"){
                if($torpv -lt $tourmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Town of Us Reactivated Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "ER"){
                if($torpv -lt $ermin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Extreme Roles Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "ER+ES"){
                if($torpv -lt $esmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Extreme Roles Version $torv with Extreme Skins が選択されました"
                $checkt = $false
            }elseif($scid -eq "NOS"){
                if($torpv -lt $nosmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Nebula on the Ship Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "TOH"){
                if($torpv -lt $tohmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Town of Host Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "SNR"){
                if($torpv -lt $snrmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "Super New Roles Version $torv が選択されました"
                $checkt = $false
            }elseif($scid -eq "TOR MR"){
                if($torpv -lt $tormmin){
                    if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                $torv = $torpv
                Write-Log "The Other Roles: MR Edition Version $torv が選択されました"
                $checkt = $false
            }else{
                Write-Log "Critical Error 2"
                Write-Log "処理を中止します"
                $Form2.Close()
                pause
                exit
            }
        }
    }
    $Bar.Value = "17"

    if($checkt){
        Write-Log "指定されたバージョンは見つかりませんでした"
        Write-Log "処理を中止します"
        $Form2.Close()
        pause
        exit
    }
    $Bar.Value = "20"
    $langdata
    if($scid -eq "TOR GMH"){
        $langh=@()
        $langd=@()
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0){
                $langh += $web2.assets.browser_download_url[$aii]
            }elseif($($web2.assets.browser_download_url[$aii]).IndexOf(".dll") -gt 0){
                $langd += $web2.assets.browser_download_url[$aii]
            }
        }
        $checkzip = $true
        $checkdll = $true
        for($aiii = 0;$aiii -lt  $langh.Length;$aiii++){
            if($($langh[$aiii]).IndexOf("$torv") -gt 0){
                $tordlp = $($langh[$aiii])
                $checkzip = $false
                $checkgm = $false
                $checkdll = $false
            }
        }
        if($checkdll){
            for($aiiii = 0;$aiiii -lt  $langd.Length;$aiiii++){
                if($($langd[$aiiii]).IndexOf("$torv") -gt 0){
                    $torgmdll = $($langd[$aiiii])
                    $checkdll = $false
                }
            }
        }
        $wvar = $true
        while($wvar){
            $vermet = @()
            $vermet = $torv.split(".")
            if($($vermet[2]) -ne 0){
                $v3 = $vermet[2] -1
            }else{
                $v3 = 0
            }
            $torv = "$($vermet[0]).$($vermet[1]).$v3"
            if($checkzip){
                if($checkdll){
                    Write-Output "ERROR:something wrong."
                    exit
                }else{
                    for($aiv = 0;$aiv -lt  $langh.Length;$aiv++){
                        if($($langh[$aiv]).IndexOf("$torv") -gt 0){
                            $tordlp = $($langh[$aiv])
                            $checkzip = $false
                        }
                    }                
                }
            }else{
                $wvar = $false
            }
        }
    }elseif($scid -eq "TOR MR"){
        $tordlp = "https://github.com/miru-y/TheOtherRoles-MR/releases/download/${torv}/TheOtherRolesMR.zip"
    }elseif($scid -eq "TOR"){
        $tordlp = "https://github.com/Eisbison/TheOtherRoles/releases/download/${torv}/TheOtherRoles.zip"
    }elseif($scid -eq "TOU-R"){
        $tordlp = "https://github.com/eDonnes124/Town-Of-Us-R/releases/download/${torv}/ToU.${torv}.zip"
    }elseif($scid -eq "ER"){
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.zip"
    }elseif($scid -eq "ER+ES"){
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.with.Extreme.Skins.zip"
    }elseif($scid -eq "TOH"){
        $tordlp = "https://github.com/tukasa0001/TownOfHost/releases/download/${torv}/TownOfHost-${torv}.zip"
    }elseif($scid -eq "SNR"){
        $tordlp = "https://github.com/ykundesu/SuperNewRoles/releases/download/${torv}/SuperNewRoles-v${torv}.zip"
    }elseif($scid -eq "NOS"){
        $langhead=@()
        $langtail=@()
        $torvtmp = $torv.Replace(",","%2C")
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0){
                if($($web2.assets.browser_download_url[$aii]).IndexOf("$torvtmp") -gt 0){
                    $tordlp = $web2.assets.browser_download_url[$aii]
                }
            }  
            if($($web2.assets.browser_download_url[$aii]).IndexOf("Japanese.dat") -gt 0){
                if($($web2.assets.browser_download_url[$aii]).IndexOf("download/LANG") -gt 0){
                    $langhead += $web2.assets.browser_download_url[$aii]
                }else{
                    $langtail += $web2.assets.browser_download_url[$aii]
                }
            }
        }
        $lheadnum = $($($langhead|Measure-Object -Maximum).Maximum).Substring(66,7)
        $ltailnum = $($($langtail|Measure-Object -Maximum).Maximum).Substring(54,7)
        if($lheadnum -gt $ltailnum){
            $langdata = $($langhead|Measure-Object -Maximum).Maximum
        }else{
            $langdata = $($langtail|Measure-Object -Maximum).Maximum            
        }
    }else{
        Write-Log "Critical Error 2"
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
        }elseif($scid -eq "NOS"){
            if(test-path "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"){
                Copy-Item "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force               
                New-Item -Path "C:\Temp\MoreCosmic" -ItemType Directory
                Copy-Item "$aupathm\MoreCosmic\*" -Recurse "C:\Temp\MoreCosmic"
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
        }else{
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
                Write-Log "Both Steam and Epic is detected. ASk User."
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("SteamとEpic両方のインストールが確認されました。`nどちらのAmongusをクリーンインストールしますか？`nSteamの場合は「はい」を、Epicの場合は「いいえ」を押してください。")), "Among Us Clean Install Tool",4) -eq "Yes"){
                    $rn = "steam"
                }else{
                    $rn = "epic"
                }                
            }

            if($rn -eq "steam"){
                Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongusCleanInstall_Steam.ps1" -OutFile "$npl\AmongusCleanInstall_Steam.ps1" -UseBasicParsing
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
                Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongusCleanInstall_Epic.ps1" -OutFile "$npl\AmongusCleanInstall_Epic.ps1" -UseBasicParsing
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
            Copy-Item $aupatho -destination $aupathm -recurse
            Write-Log "$aupatho を $aupathm にコピーしました"           
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
        Copy-Item $aupatho -destination $aupathm -recurse
        Write-Log "$aupatho を $aupathm にコピー完了"
    } 

    #Backup System
    if(Test-Path $aupathb){
    }else{
        New-Item $aupathb -ItemType Directory
    }
        Write-Log "Backup Feature Start"
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

        if($r -eq $e){
            Write-Log "古い同一Backupが見つかったのでSkipします"
        }else{
            Write-Log "新しいBackupが見つかったので生成します"
            Write-Output $(Join-path $aupathb "Among Us-$datest.zip") > $backuptxt
            write-log $e
            Write-log $r
            Compress-Archive -Path $aupatho $(Join-path $aupathb "Among Us-$datest.zip") -Force
            Remove-Item -Path $backhashtxt -Force
            Remove-Item -Path $backuptxt -Force
            $thash = (GetFilesRecurse $aupatho | MakeEntry | MakeHashInfo "SHA1" ).SHA1
            Write-Output " $thash"> $backhashtxt
            Write-Output $(Join-path $aupathb "Among Us-$datest.zip") > $backuptxt
        }
    }else{
        Write-Log "Backupが見つかりません。生成します。"
        $thash = (GetFilesRecurse $aupatho | MakeEntry | MakeHashInfo "SHA1" ).SHA1
        Write-Output " $thash"> $backhashtxt
        Write-Output $(Join-path $aupathb "Among Us-$datest.zip") > $backuptxt
        Compress-Archive -Path $aupatho $(Join-path $aupathb "Among Us-$datest.zip") -Force
    }
    Write-Log "Backup Feature Ends"

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
        Write-Log "ZIP DL OK"
        Write-Log "ZIP 解凍開始"
        Expand-Archive -path $aupathm\TheOtherRoles.zip -DestinationPath $aupathm -Force
        Write-Log "ZIP 解凍完了"
    }else{
        Write-Log "ZIP DL NG $tordlp "
        Write-Log "Something Wrong."
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
            if(!(Test-Path "$aupathm\ExtremeHat")){
                New-Item -Path "$aupathm\ExtremeHat" -ItemType Directory
            }
            if(test-path "C:\Temp\ExtremeHat"){
                robocopy "C:\Temp\ExtremeHat" "$aupathm\ExtremeHat" /unilog:C:\Temp\temp.log /E >nul 2>&1 
                Remove-Item "C:\Temp\ExtremeHat" -Recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
    
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
    }elseif($scid -eq "NOS"){
        if(test-path "C:\Temp\jp.dreamingpig.amongus.nebula.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" -Force
            Remove-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force    
            if(!(Test-Path "$aupathm\MoreCosmic")){
                New-Item -Path "$aupathm\MoreCosmic" -ItemType Directory
            }
            if(test-path "C:\Temp\MoreCosmic"){
                robocopy "C:\Temp\MoreCosmic" "$aupathm\MoreCosmic" /unilog:C:\Temp\temp.log /E >nul 2>&1
                Remove-Item "C:\Temp\MoreCosmic" -Recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
    
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
    }elseif($scid -eq "TOH"){
        if(test-path "C:\Temp\com.emptybottle.townofhost.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\com.emptybottle.townofhost.cfg" "$aupathm\BepInEx\config\com.emptybottle.townofhost.cfg" -Force
            Remove-Item "C:\com.emptybottle.townofhost.cfg" -Force    
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
                Remove-Item "C:\Temp\SuperNewRoles" -Recurse
                $content = Get-content "C:\Temp\temp.log" -Raw -Encoding Unicode
    
                Write-Log "`r`n $content"
                Remove-Item "C:\Temp\temp.log" -Force
            }
        }
    }else{
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
    }
    $Bar.Value = "64"

    #AUShipMOD 配置
    if($ausmod){
        Write-Log "AUShipMOD is depricated."
#        Write-Log "AUShipMOD配置開始"
        #GithubのRelease一覧からぶっこぬいてLatestを置く
#        $rel2 = "https://api.github.com/repos/tomarai/AUShipMod/releases/latest"
#        $webs = Invoke-WebRequest $rel2 -UseBasicParsing
#        $webs2 = ConvertFrom-Json $webs.Content
#        $aus = $webs2.assets.browser_download_url
#        Write-Log "AUShipMOD Latest DLL download start"
 #       Write-Log "$aus"
 #       if (!(Test-Path "$aupathm\BepInEx\plugins\")) {
 #           New-Item "$aupathm\BepInEx\plugins\" -Type Directory
 #       }
 #       #Invoke-WebRequest $aus -Outfile "$aupathm\BepInEx\plugins\AUShipMod.dll" -UseBasicParsing
 #       #curl.exe -L $aus -o "$aupathm\BepInEx\plugins\AUShipMod.dll"
 #       aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "AUShipMod.dll" $aus
 #       Write-Log "AUShipMOD Latest DLL download done"
    }
    $Bar.Value = "68"

    if($submerged){
        Write-Log "Submerged配置開始"
        #GithubのRelease一覧からぶっこぬいてLatestを置く
        $rel2 = "https://api.github.com/repos/SubmergedAmongUs/Submerged/releases/latest"
        $webs = Invoke-WebRequest $rel2 -UseBasicParsing
        $webs2 = ConvertFrom-Json $webs.Content
        $aus = $webs2.assets.browser_download_url
        Write-Log "Submerged Latest DLL download start"
        if (!(Test-Path "$aupathm\BepInEx\plugins\")) {
            New-Item "$aupathm\BepInEx\plugins\" -Type Directory
        }
        for($aaai = 0;$aaai -lt $aus.Length;$aaai++){
            if($($aus[$aaai]).IndexOf(".dll") -gt 0){
                #Invoke-WebRequest $($aus[$aaai]) -Outfile "$aupathm\BepInEx\plugins\Submerged.dll" -UseBasicParsing
                #curl.exe -L $($aus[$aaai]) -o "$aupathm\BepInEx\plugins\Submerged.dll"
                aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "Submerged.dll" $($aus[$aaai])
                Write-Log "$($aus[$aaai])"
            }
        }
        Write-Log "Submerged Latest DLL download done"
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
            #Invoke-WebRequest $torgmdll -Outfile "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll" -UseBasicParsing
            #curl.exe -L $torgmdll -o "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll"
            aria2c -x5 -V --dir "$aupathm\BepInEx\plugins" -o "TheOtherRolesGM.dll" $torgmdll
            Write-Log "Download $scid DLL 完了"
        }
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
        if(test-path "$aupathm\TheOtherRolesMR"){
            robocopy "$aupathm\TheOtherRolesMR" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TheOtherRolesMR" -recurse
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
    }elseif($scid -eq "TOH"){
        if(test-path "$aupathm\TownOfHost-$torv"){
            robocopy "$aupathm\TownOfHost-$torv" "$aupathm" /unilog:C:\Temp\temp.log /E >nul 2>&1
            Remove-Item "$aupathm\TownOfHost-$torv" -recurse
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
        #Invoke-WebRequest $langdata -Outfile "$aupathm\Language\Japanese.dat" -UseBasicParsing
        #curl.exe -L $langdata -o "$aupathm\Language\Japanese.dat"
        aria2c -x5 -V --dir "$aupathm\Language" -o "Japanese.dat" $langdata
        Write-Log "日本語 データ Download 完了"
    }else{
    }
    $Bar.Value = "71"

    #解凍チェック
    if (test-path "$aupathm\BepInEx\plugins"){
        Write-Log ("ZIP 解凍OK");
        Remove-item -Path "$aupathm\TheOtherRoles.zip"
        Write-Log ("DLしたZIPを削除");
    }else{
      Write-Log ("ZIP 解凍NG");
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
                Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/gmhtechsupport.ps1" -OutFile "C:\temp\gmhtechsupport.ps1" -UseBasicParsing
                $batscript = "chcp 65001`r`n@echo off`r`npowershell -NoProfile -ExecutionPolicy Unrestricted `"C:\temp\amongusrun_$scid2.ps1`"`r`nexit"
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
                            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `'
                $ps1script += "$ps1name"
                $ps1script += '`"" -Verb RunAs -Wait
                            exit
                        }
                    }
                }elseif($PSVersionTable.PSVersion.major -gt 5){
                    $v5run = $true
                    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `'
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
                    Set-Location "$aupathb"
                    legendary launch Among Us
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
                $sShortcut.Arguments = "-Command legendary auth --import && legendary -y egl-sync && legendary launch Among Us"
                $sShortcut.WorkingDirectory = $aupathb
            }else{
                Write-Log "ERROR: Critical Shortcut"
            }                
        }

        $sShortcut.IconLocation = "$aupathm\Among Us.exe"
        $sShortcut.Save()

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

if($CheckedBox.CheckedItems.Count -gt 0){
    for($aa=0;$aa -le $CheckedBox.CheckedItems.Count;$aa++){
        if($CheckedBox.CheckedItems[$aa] -eq "BetterCrewLink"){
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
        }elseif($CheckedBox.CheckedItems[$aa] -eq "AmongUsReplayInWindow"){
            $qureq = $true
            if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802){
            }else{
                if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("必要な.Net 5 Frameworkがインストールされていません。インストールしますか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    #Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -UseBasicParsing
                    #.\dotnet-install.ps1
                    #Remove-Item .\dotnet-install.ps1
                    try{
                        choco -v
                    }catch{
                        Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                    }
        
                    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade aria2 dotnet-desktopruntime -y" -Verb RunAs -Wait        
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
                    Invoke-WebRequest $auriw -OutFile "$md\$auriwfile" -UseBasicParsing
                    Expand-Archive -path $md\$auriwfile -DestinationPath $md\$auriwfn -Force
                    Remove-Item $md\$auriwfile
                    Set-Location -Path $md\$auriwfn
                    Invoke-Item .
                }else{
                    Write-Log "AmongUsReplayInWindowの処理を中止します"
                }
            }
            $Bar.Value = "84"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "AmongUsCapture"){
            $qureq = $false
            if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802){
                $qureq = $true
            }else{
                #Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -UseBasicParsing
                #.\dotnet-install.ps1
                #Remove-Item .\dotnet-install.ps1
                try{
                    choco -v
                }catch{
                    Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
                }
    
                Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade aria2 dotnet-desktopruntime -y" -Verb RunAs -Wait   
                $qureq = $true
            }
            if($qureq){
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
                    Invoke-WebRequest $aucap[0] -OutFile "$md\$aucapfile" -UseBasicParsing
                    Expand-Archive -path $md\$aucapfile -DestinationPath $md\$aucapfn -Force
                    Remove-Item $md\$aucapfile
                    Set-Location -Path $md\$aucapfn
                    Invoke-Item .
                }else{
                    Write-Log "AmongUsCaptureの処理を中止します"
                }
            }
            $Bar.Value = "85"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "VC Redist"){
            Write-Log "VC Redist Install start"
            Start-Transcript -Append -Path "$LogFileName"
#            $fpth = Join-Path $npl "\install.ps1"
#            Invoke-WebRequest https://vcredist.com/install.ps1 -OutFile "$fpth" -UseBasicParsing
            try{
                pwsh -Command '$PSVersionTable.PSVersion.major'
            }
            catch{
                Write-Output $(Get-Translate("Powershell 7を導入中・・・。"))
                $com = 'Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"'
                $com | Out-File -Encoding "UTF8" -FilePath ".\ps.ps1" 
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$npl\ps.ps1`"" -Verb RunAs -Wait
                Remove-Item "$npl\ps.ps1" -Force
            }

            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade aria2 vcredist-all -y" -Verb RunAs -Wait
#            Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth""" -Verb RunAs -Wait
#            Remove-Item "$fpth"
            Stop-Transcript
            Write-Log "VC Redist Install ends"
            $Bar.Value = "86"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "PowerShell 7"){
            Write-Log "PS7 Install start"
            Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }
            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade aria2 pwsh powershell-core -y" -Verb RunAs -Wait
            Write-Log "PS7 Install ends"
            $Bar.Value = "87"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "dotNetFramework"){
            Write-Log ".Net Framework Install start"
            Start-Transcript -Append -Path "$LogFileName"
            #Invoke-Expression "& { $(Invoke-RestMethod https://dot.net/v1/dotnet-install.ps1) }"
            try{
                choco -v
            }catch{
                Start-Process powershell -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Verb RunAs -Wait
            }

            Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command choco upgrade aria2 dotnet-desktopruntime -y" -Verb RunAs -Wait
            Stop-Transcript
            Write-Log ".Net Framework Install ends"
            $Bar.Value = "88"
        }else{
        }
    }
}

$Bar.Value = "90"

####################
#bat file auto update
####################
if(test-path "$npl\StartAmongUsModTORplusDeployScript.bat"){
    Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/StartAmongUsModTORplusDeployScript.bat" -OutFile "$npl\StartAmongUsModTORplusDeployScript.bat" -UseBasicParsing
}
####################

$Bar.Value = "93"
if($platform -eq "Epic"){

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
    
<#
    if(!(Test-Path "$aupathb\legendary.exe")){
        Invoke-WebRequest "https://github.com/derrod/legendary/releases/download/0.20.25/legendary.exe" -OutFile "$aupathb\legendary.exe"
    }
#>
    Start-Transcript -Append -Path "$LogFileName"
    Set-Location "$aupathb"
    legendary auth --import
    legendary -y uninstall Among Us --keep-files 
    legendary -y import "Among Us" $aupathm
    legendary -y egl-sync
    Stop-Transcript
    Start-Sleep -Seconds 5
    Write-Output $(Get-Translate("`r`nEGL再起動開始`r`n"))
    Get-Process EpicGamesLauncher | foreach { Stop-Process $_; Start-Process $_.Path }
    Write-Output $(Get-Translate("`r`nEGL再起動完了`r`n"))
    Start-Sleep -Seconds 20
}elseif($platform -eq "Steam"){
    if(!(Test-Path "$aupathm\steam_appid.txt")){
        Write-Output "945360"> "$aupathm\steam_appid.txt"
        Write-Log "Steam AppID Patched."
    }
}
$Bar.Value = "97"
$fntime = Get-Date
$difftime = ($fntime - $sttime).TotalSeconds
$Bar.Value = "100"

$Form2.Close()
Write-Log "$difftime 秒で完了しました。"

if($tio){
    if($startexewhendone -eq $true){
        if($platform -eq "Steam"){
            Start-Process "$aupathm\Among Us.exe"   
        }elseif($platform -eq "Epic"){
            Set-Location "$aupathb"
            legendary launch Among Us
        }else{
            Write-Log "ERROR:Critical run apps"
        }
    }else{
    }
}

Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Ends"
Write-Log "-----------------------------------------------------------------"

if($debugc){
    if($startexewhendone -eq $true){
        Write-Output $(Get-Translate("`r`nAmong Us 本体の起動中です。本体が終了するまでこのまま放置してください。`r`n"))
        #監視プロセス名
        $procName = "Among Us"
        $checkpro = $true
        Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/gmhtechsupport.ps1" -OutFile "$npl\gmhtechsupport.ps1" -UseBasicParsing
        $tsp = &"$npl\gmhtechsupport.ps1" "$scid" "$aupathm" "$platform" |Select-Object -Last 1
        Write-Log "-----------------------------------------------------------------"
        Write-Log "Error Check"
        Write-Log "-----------------------------------------------------------------"
        Write-Log "After Installation:$tsp"
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
                Write-Log "After Game Exit:$tsp"
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

Start-Sleep -Seconds 2
exit
