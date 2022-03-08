#################################################################################################
#
# Among Us Mod Auto Deploy Script
#
$version = "Version 1.2.6"
#
#################################################################################################

###v2022.02.23対応minimum version
$tourmin = "v2.6.2"
$tormin = "v3.4.4"
$ermin = "v1.18.2.0"
$torpmin = "v3.4.4.1+"
$torgmin = "v3.5.3"
$nosmin = "1.4.5,2022.2.24"

#################################################################################################
# Run w/ Powershell v7 if available & check VC Redist.
#################################################################################################
$npl = Get-Location
$v5run = $false
if($PSVersionTable.PSVersion.major -eq 5){
    if(test-path "$env:ProgramFiles\PowerShell\7"){
        pwsh.exe -NoProfile -ExecutionPolicy Unrestricted "$npl\AmongUsModTORplusDeployScript.ps1"
    }else{
        $v5run = $true
    }
}elseif($PSVersionTable.PSVersion.major -gt 5){
    $v5run = $true
}else{
    write-host "ERROR - PowerShell Version : not supported."
}

if(!($v5run)){
    exit
}
#>

#################################################################################################
# Log用Function
#################################################################################################
# ログの出力先
$LogPath = "C:\Temp"
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
    Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append
    # echo させるために出力したログを戻す
    Return $Log
}

Write-Log "-----------------------------------------------------------------"
Write-Log "                    AmongUs Mod Deploy Script                    "
Write-Log "                                                Version: $version"
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


#################################################################################################
### GM Mod or TOR+ 選択メニュー表示
#################################################################################################
#Special Thanks
#https://letspowershell.blogspot.com/2015/07/powershell_29.html
# アセンブリのロード
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# フォントの指定
$Font = New-Object System.Drawing.Font("メイリオ",12)

# フォーム全体の設定
$form = New-Object System.Windows.Forms.Form
$form.Text = "Among Us Mod Auto Deploy Tool"
$form.Size = New-Object System.Drawing.Size(800,580)
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
$label.Text = "インストールしたいModを選択してください"
$form.Controls.Add($label)

# OKボタンの設定
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(580,490)
$OKButton.Size = New-Object System.Drawing.Size(75,30)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

# キャンセルボタンの設定
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(680,490)
$CancelButton.Size = New-Object System.Drawing.Size(75,30)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

# グループを作る
$MyGroupBox3 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox3.Location = New-Object System.Drawing.Point(400,10)
$MyGroupBox3.size = New-Object System.Drawing.Size(350,100)
$MyGroupBox3.text = "既存のフォルダを上書き/再作成しますか？"

# グループの中のラジオボタンを作る
$RadioButton5 = New-Object System.Windows.Forms.RadioButton
$RadioButton5.Location = New-Object System.Drawing.Point(20,60)
$RadioButton5.size = New-Object System.Drawing.Size(150,30)
$RadioButton5.Checked = $True
$RadioButton5.Text = "再作成する"

$RadioButton6 = New-Object System.Windows.Forms.RadioButton
$RadioButton6.Location = New-Object System.Drawing.Point(180,30)
$RadioButton6.size = New-Object System.Drawing.Size(150,30)
$RadioButton6.Text = "再作成しない"

$RadioButton7 = New-Object System.Windows.Forms.RadioButton
$RadioButton7.Location = New-Object System.Drawing.Point(20,30)
$RadioButton7.size = New-Object System.Drawing.Size(150,30)
$RadioButton7.Text = "上書きする"

# グループにラジオボタンを入れる
$MyGroupBox3.Controls.AddRange(@($Radiobutton5,$RadioButton6,$RadioButton7))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox3)


###作成したModのExeへのショートカットをDesktopに配置する
# グループを作る
$MyGroupBox = New-Object System.Windows.Forms.GroupBox
$MyGroupBox.Location = New-Object System.Drawing.Point(400,120)
$MyGroupBox.size = New-Object System.Drawing.Size(350,70)
$MyGroupBox.text = "ショートカットを作成しますか？"

# グループの中のラジオボタンを作る
$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = New-Object System.Drawing.Point(20,30)
$RadioButton1.size = New-Object System.Drawing.Size(150,30)
$RadioButton1.Checked = $True
$RadioButton1.Text = "作成する"

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = New-Object System.Drawing.Point(180,30)
$RadioButton2.size = New-Object System.Drawing.Size(150,30)
$RadioButton2.Text = "作成しない"

# グループにラジオボタンを入れる
$MyGroupBox.Controls.AddRange(@($Radiobutton1,$RadioButton2))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox)

###作成したModを即座に実行する
#デフォルトでは実行しない
# グループを作る
$MyGroupBox2 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox2.Location = New-Object System.Drawing.Point(400,205)
$MyGroupBox2.size = New-Object System.Drawing.Size(350,70)
$MyGroupBox2.text = "作成したModをすぐに起動しますか？"

# グループの中のラジオボタンを作る
$RadioButton3 = New-Object System.Windows.Forms.RadioButton
$RadioButton3.Location = New-Object System.Drawing.Point(20,30)
$RadioButton3.size = New-Object System.Drawing.Size(150,30)
$RadioButton3.Checked = $True
$RadioButton3.Text = "起動する"

$RadioButton4 = New-Object System.Windows.Forms.RadioButton
$RadioButton4.Location = New-Object System.Drawing.Point(180,30)
$RadioButton4.size = New-Object System.Drawing.Size(150,30)
$RadioButton4.Text = "起動しない"

# グループにラジオボタンを入れる
$MyGroupBox2.Controls.AddRange(@($Radiobutton3,$RadioButton4))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox2)

$MyGroupBox4 = New-Object System.Windows.Forms.GroupBox
$MyGroupBox4.Location = New-Object System.Drawing.Point(400,290)
$MyGroupBox4.size = New-Object System.Drawing.Size(350,70)
$MyGroupBox4.text = "AirShipMODを同梱しますか？"

# グループの中のラジオボタンを作る
$RadioButton8 = New-Object System.Windows.Forms.RadioButton
$RadioButton8.Location = New-Object System.Drawing.Point(20,30)
$RadioButton8.size = New-Object System.Drawing.Size(150,30)
$RadioButton8.Checked = $True
$RadioButton8.Text = "同梱する"

$RadioButton9 = New-Object System.Windows.Forms.RadioButton
$RadioButton9.Location = New-Object System.Drawing.Point(180,30)
$RadioButton9.size = New-Object System.Drawing.Size(150,30)
$RadioButton9.Text = "同梱しない"

# グループにラジオボタンを入れる
$MyGroupBox4.Controls.AddRange(@($Radiobutton8,$RadioButton9))
# フォームに各アイテムを入れる
$form.Controls.Add($MyGroupBox4)



# ラベルを表示
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(15,240)
$label2.Size = New-Object System.Drawing.Size(370,30)
$label2.Text = "インストールしたいToolを選択してください"
$form.Controls.Add($label2)

# チェックボックスを作成
$CheckedBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedBox.Location = "55,270"
$CheckedBox.Size = "270,105"

# 配列を作成
$RETU = ("AmongUsCapture","VC Redist","BetterCrewLink","AmongUsReplayInWindow","PowerShell 7")

# チェックボックスに10項目を追加
$CheckedBox.Items.AddRange($RETU)

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
[void] $Combo.Items.Add("TOR + :tomarai/TheOtherRoles")
[void] $Combo.Items.Add("TOR GM :yukinogatari/TheOtherRoles-GM")
[void] $Combo.Items.Add("TOR :Eisbison/TheOtherRoles")
[void] $Combo.Items.Add("TOU-R :eDonnes124/Town-Of-Us-R")
[void] $Combo.Items.Add("ER :yukieiji/ExtremeRoles")
[void] $Combo.Items.Add("NOS :Dolly1016/Nebula")
[void] $Combo.Items.Add("Toolインストールのみ")
$Combo.SelectedIndex = 0

##############################################

# ラベルを表示
$label7 = New-Object System.Windows.Forms.Label
$label7.Location = New-Object System.Drawing.Point(15,140)
$label7.Size = New-Object System.Drawing.Size(370,30)
$label7.Text = "インストールしたいVersionを選択してください"
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
$label3.Location = New-Object System.Drawing.Point(15,370)
$label3.Size = New-Object System.Drawing.Size(570,20)
$label3.Text = "オリジナルのAmongUsは以下の場所に検出されました"
$form.Controls.Add($label3)

# ラベルを表示
$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(20,390)
$label4.Size = New-Object System.Drawing.Size(770,50)
$label4.Text = ""
$form.Controls.Add($label4)

# ラベルを表示
$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(15,440)
$label5.Size = New-Object System.Drawing.Size(570,20)
$label5.Text = "Mod化バージョンは以下の場所に作成されます"
$form.Controls.Add($label5)

# ラベルを表示
$label6 = New-Object System.Windows.Forms.Label
$label6.Location = New-Object System.Drawing.Point(20,460)
$label6.Size = New-Object System.Drawing.Size(770,50)
$label6.Text = ""
$form.Controls.Add($label6)

$scid = "TOR Plus"
$tio = $true
$aumin =""
$aupatho=""
$aupathm=""
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
        Write-Output $Log | Out-File -FilePath $script:LogFileName -Encoding Default -append
        # echo させるために出力したログを戻す
        Write-Host $Log
    }

    $combo2.Text = ""
    $combo2.DataSource=@()
    $combo2.Enabled = $true
    $tio = $true
    Switch ($combo.text){
        #TOR + :tomarai/TheOtherRoles 
        default{
            $releasepage2 = "https://api.github.com/repos/tomarai/TheOtherRoles/releases"
            $scid = "TOR Plus"
            $aumin = $torpmin
            Write-Log "TOR+ Selected"
        }"TOR GM :yukinogatari/TheOtherRoles-GM"{
            $releasepage2 = "https://api.github.com/repos/yukinogatari/TheOtherRoles-GM/releases"
            $scid = "TOR GM"
            $aumin = $torgmin
            Write-Log "TOR GM Selected"
        }"TOR :Eisbison/TheOtherRoles"{
            $releasepage2 = "https://api.github.com/repos/Eisbison/TheOtherRoles/releases"
            $scid = "TOR"
            $aumin = $tormin
            Write-Log "TOR Selected"
        }"TOU-R :eDonnes124/Town-Of-Us-R"{
            $releasepage2 = "https://api.github.com/repos/eDonnes124/Town-Of-Us-R/releases"
            $scid = "TOU-R"
            $aumin = $tourmin
            Write-Log "TOU-R Selected"
        }"ER :yukieiji/ExtremeRoles"{
            $releasepage2 = "https://api.github.com/repos/yukieiji/ExtremeRoles/releases"
            $scid = "ER"
            $aumin = $ermin
            Write-Log "ER Selected"
        }"NOS :Dolly1016/Nebula"{
            $releasepage2 = "https://api.github.com/repos/Dolly1016/Nebula/releases"
            $scid = "NOS"
            $aumin = $nosmin
            Write-Log "NOS Selected"

        }"Toolインストールのみ"{
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
        if($scid -ne "NOS"){
            for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                if($web2.tag_name[$ai] -ge $aumin){
                    $list2 += $($web2.tag_name[$ai])
                }
            }
        }elseif($scid -eq "NOS"){
            for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
                if($web2.tag_name[$ai] -ge $nosmin){
                    if($($web2.tag_name[$ai]).indexof("LANG") -lt 0){
                        $list2 += $($web2.tag_name[$ai])
                    }        
                }
            }            
        }else{            
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
        #Among Us Original Epic Path
        $au_path_epic_org = "C:\Program Files\Epic Games\AmongUs"
        #Among Us Modded Path ：Steam Mod用フォルダ
        $au_path_epic_mod = "C:\Program Files\Epic Games\AmongUs $scid Mod"
  
        if(Test-path "$au_path_steam_org\Among Us.exe"){
            #original check Steamのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$au_path_steam_org\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                Write-Log "フォルダ指定が正しい場合は、クリーンインストールを試してみてください"
                Write-Log "処理を中止します"      
                pause
                exit
            }
            $aupatho = $au_path_steam_org
            $aupathm = $au_path_steam_mod
        }elseif(Test-path "$au_path_epic_org\Among Us.exe"){
            #original check Epicのデフォルトインストールパスが存在するかチェック。存在したらModが入ってないか簡易チェック
            if(Test-path "$au_path_epic_org\BepInEx"){
                Write-Log "オリジナルのAmong Usではないフォルダが指定されている可能性があります"
                Write-Log "フォルダ指定が正しい場合は、クリーンインストールを試してみてください"
                Write-Log "処理を中止します"      
                pause
                exit
            }
            $aupatho = $au_path_epic_org
            $aupathm = $au_path_epic_mod
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
                [System.Windows.Forms.MessageBox]::Show("Modが入っていないAmongUsがインストールされているフォルダを選択してください", "Among Us Mod Auto Deploy Tool")
                $spath = Get-FolderPathG
            }
            if($spath -eq $null){
                Write-Log "Failed $spath"
                pause
                Exit
            }
            if(test-path "$spath\Among Us.exe"){
                Write-Log "$spath にAmongUsのインストールパスを確認しました"
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
                Write-Log "Mod入りAmongUsは以下のフォルダにDeployされます"
                Write-Log $aupathm

                ### Auto Save
                Write-Output "$aupatho"> $fileName
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
        $script:releasepage = $releasepage2
        $script:scid = $scid
        $script:aumin = $aumin
    }
    $script:tio = $tio
}

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
#################################################################################################>



#　アセンブリの読み込み
[void][System.Reflection.Assembly]::Load("Microsoft.VisualBasic, Version=8.0.0.0, Culture=Neutral, PublicKeyToken=b03f5f7f11d50a3a")

# プログレスバー

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

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
$Bar.Maximum = "10"
$Bar.Minimum = "0"
$Bar.Style = "Continuous"
$Form2.Controls.Add($Bar)

if($tio){

    $Form2.Show()
    $Bar.Value = "0"

    #################################################################################################

    $web = Invoke-WebRequest $releasepage -UseBasicParsing
    $web2 = ConvertFrom-Json $web.Content

    for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
        if($web2.tag_name[$ai] -eq "$torpv"){
            if($scid -eq "TOR Plus"){
                if($torpv -eq "hotfix-0"){
                    Write-Log $torpv
                }elseif($torpv -lt $torpmin){
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                #TORのバージョンをTOR+のバージョンから指定
                $torv = $torpv.Substring(1,5)
                $tortmp = $torpv.Substring(0,8)
                Write-Log "TheOtherRole Version $torv が自動的に選択されました"
                $torplus = $web2.assets[$ai].browser_download_url
                if($torpv -eq "hotfix-0"){
                    $torpv = "hotfix-0"
                    $torv = "3.4.3"    
                }
                Write-Log $web2.tag_name[$ai]
                Write-Log $torpv
                Write-Log $torv
                Write-Log $tortmp   

                $checkt = $false
            }elseif($scid -eq "TOR GM"){
                if($torpv -lt $torgmin){
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    }else{
                        Write-Log "処理を中止します"
                        $Form2.Close()
                        pause
                        exit
                    }  
                }
                if($torpv -eq "v3.4.1.2"){
                    $torv = "v3.4.1"                    
                    Write-Log "TheOtherRole-GM Version $torpv が選択されました"
                }else{
                    $torv = $torpv
                    Write-Log "TheOtherRole-GM Version $torv が選択されました"
                }
                $checkt = $false
            }elseif($scid -eq "TOR"){
                if($torpv -lt $tormin){
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
            }elseif($scid -eq "NOS"){
                if($torpv -lt $nosmin){
                    if([System.Windows.Forms.MessageBox]::Show("古いバージョンのため、現行のAmongUsでは動作しない可能性があります。`n続行しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
            }else{
                Write-Log "Critical Error 2"
                Write-Log "処理を中止します"
                $Form2.Close()
                pause
                exit
            }
        }
    }

    if($checkt){
        Write-Log "指定されたバージョンは見つかりませんでした"
        Write-Log "処理を中止します"
        $Form2.Close()
        pause
        exit
    }
    $ziplist=@()
    $langdata
    $langbool = $true
    if($scid -eq "TOR Plus"){
        ###TOR DL Path
        $tordlp = "https://github.com/Eisbison/TheOtherRoles/releases/download/v${torv}/TheOtherRoles.zip"
    }elseif($scid -eq "TOR GM"){
        $tordlp = "https://github.com/yukinogatari/TheOtherRoles-GM/releases/download/${torv}/TheOtherRoles-GM.${torv}.zip"    
    }elseif($scid -eq "TOR"){
        $tordlp = "https://github.com/Eisbison/TheOtherRoles/releases/download/${torv}/TheOtherRoles.zip"
    }elseif($scid -eq "TOU-R"){
        $tordlp = "https://github.com/eDonnes124/Town-Of-Us-R/releases/download/${torv}/ToU.${torv}.zip"
    }elseif($scid -eq "ER"){
        $tordlp = "https://github.com/yukieiji/ExtremeRoles/releases/download/${torv}/ExtremeRoles-${torv}.zip"
    }elseif($scid -eq "NOS"){
        $xvar = "0"
        for($ai = 0;$ai -lt $web2.tag_name.Length;$ai++){
            if($web2.tag_name[$ai] -eq ${torv}){
                $xvar = $ai
            }
        }
        for($aii = 0;$aii -lt  $($web2.assets.browser_download_url).Length;$aii++){
            if($($web2.assets.browser_download_url[$aii]).IndexOf(".zip") -gt 0){
                $ziplist += $web2.assets.browser_download_url[$aii]
            }  
            if($($web2.assets.browser_download_url[$aii]).IndexOf("Japanese.dat") -gt 0){
                if($langbool){
                    $langdata = $web2.assets.browser_download_url[$aii]
                    $langbool = $false
                }
            }
        }
        $tordlp = $($ziplist[$xvar])
    }else{
        Write-Log "Critical Error 2"
        $Form2.Close()
        pause
        exit
    }

    Write-Output $tordlp

    $Bar.Value = "1"

    ###作成したModのExeへのショートカットをDesktopに配置する
    if($RadioButton1.Checked){
        $shortcut = $true
    }elseif($RadioButton2.Checked){
        $shortcut = $false 
    }else{
        Write-Log "Critical Error: Shortcut"
    }
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

    $Bar.Value = "2"

    #################################################################################################
    #処理フェイズ　この下は触らない
    #################################################################################################


    #OriginalのAmongusをフォルダ毎コピーして新規Mod用フォルダを作成する
    if(Test-Path $aupathm){
        ###作り直しを有効にする $trueだと有効になる。デフォルト無効
        if($RadioButton5.Checked){
            $retry = $true
            $ovwrite = $false
        }elseif($RadioButton6.Checked){
            $retry = $false
            $ovwrite = $false
        }elseif($RadioButton7.Checked){
            $retry = $false
            $ovwrite = $true
        }else{
            Write-Log "Critical Error: Retry"
        }

        if($scid -eq "TOU-R"){
            if(test-path "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg"){                
                Copy-Item "$aupathm\BepInEx\config\com.slushiegoose.townofus.cfg" "C:\Temp\com.slushiegoose.townofus.cfg" -Force
            }
        }elseif($scid -eq "ER"){
            if(test-path "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.yukieiji.extremeroles.cfg" "C:\Temp\me.yukieiji.extremeroles.cfg" -Force               
            }
        }elseif($scid -eq "NOS"){
            if(test-path "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg"){
                Copy-Item "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force               
            }
        }else{
            if(test-path "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg"){
                Copy-Item "$aupathm\BepInEx\config\me.eisbison.theotherroles.cfg" "C:\Temp\me.eisbison.theotherroles.cfg" -Force
                New-Item -Path "C:\Temp\TheOtherHats" -ItemType Directory
                Copy-Item "$aupathm\TheOtherHats" -Recurse "C:\Temp\TheOtherHats"
            }
        }

        if ($retry -eq "true"){
            Write-Log '既存のフォルダを中身を含めて削除します'
            Remove-Item $aupathm -Recurse
            # フォルダを中身を含めてコピーする
            Copy-Item $aupatho -destination $aupathm -recurse
            Write-Log ($aupatho + 'を' + $aupathm + 'にコピーしました');
        }else{
            # コピー先のパスにファイルやフォルダが存在する場合は処理を中止
            Write-Log ($aupathm + 'には既にファイル又はフォルダが存在します');
            if($ovwrite){
                Write-Log ("上書き処理が選択されました");
            }else{
                Write-Log ("処理を中止しました");
                $Form2.Close()
                pause
                Exit
            }
        }
    }else{
        # フォルダを中身を含めてコピーする
        Copy-Item $aupatho -destination $aupathm -recurse
        Write-Log ($aupatho + 'を' + $aupathm + 'にコピー完了');
    } 

    $Bar.Value = "3"

    ####
    #まずはTORをDL
    Write-Log 'Download ZIP 開始'
    Write-Log $tordlp
    Invoke-WebRequest $tordlp -OutFile "$aupathm\TheOtherRoles.zip" -UseBasicParsing
    Write-Log 'Download ZIP 完了'

    #DLしたTORを解凍
    if (test-path "$aupathm\TheOtherRoles.zip"){
        Write-Log ("ZIP DL OK");
        Write-Log ("ZIP 解凍開始");
        Expand-Archive -path $aupathm\TheOtherRoles.zip -DestinationPath $aupathm -Force
        Write-Log ("ZIP 解凍完了");
    }else{
        Write-Log ("ZIP DL NG $tordlp ");
    }

    $Bar.Value = "4"

    if(test-path "$aupathm\BepInEx"){
        Write-Log ("ZIP 解凍OK");
    }

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
    }elseif($scid -eq "NOS"){
        if(test-path "C:\Temp\jp.dreamingpig.amongus.nebula.cfg"){
            if(!(test-path "$aupathm\BepInEx\config")){
                New-Item -Path "$aupathm\BepInEx\config" -ItemType Directory
            }
            Copy-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" "$aupathm\BepInEx\config\jp.dreamingpig.amongus.nebula.cfg" -Force
            Remove-Item "C:\Temp\jp.dreamingpig.amongus.nebula.cfg" -Force    
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
            Copy-Item "C:\Temp\TheOtherHats" -Recurse "$aupathm\TheOtherHats"
            Remove-Item "C:\Temp\TheOtherHats" -Recurse
        }
    }

    #AUShipMOD 配置
    if($ausmod){
        Write-Log "AUShipMOD配置開始"
        #GithubのRelease一覧からぶっこぬいてLatestを置く
        $rel2 = "https://api.github.com/repos/tomarai/AUShipMod/releases/latest"
        $webs = Invoke-WebRequest $rel2 -UseBasicParsing
        $webs2 = ConvertFrom-Json $webs.Content
        $aus = $webs2.assets.browser_download_url
        Write-Log "AUShipMOD Latest DLL download start"
        Write-Log "$aus"
        if (!(Test-Path "$aupathm\BepInEx\plugins\")) {
            New-Item "$aupathm\BepInEx\plugins\" -Type Directory
        }
        Invoke-WebRequest $aus -Outfile "$aupathm\BepInEx\plugins\AUShipMod.dll" -UseBasicParsing
        Write-Log "AUShipMOD Latest DLL download done"
    }

    if($scid -eq "TOR Plus"){
        ###
        #Mod Original DLL削除
        if(test-path "$aupathm\TheOtherRoles"){
            robocopy "$aupathm\TheOtherRoles" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles" -recurse
        }
        Remove-item -Path "$aupathm\BepInEx\plugins\TheOtherRoles.dll"
        Write-Log 'Delete Original Mod DLL'
        #TOR+ DLLをDLして配置
        Write-Log "Download $scid DLL 開始"
        Write-Log $torplus
        Invoke-WebRequest $torplus -Outfile "$aupathm\BepInEx\plugins\TheOtherRoles.dll" -UseBasicParsing
        Write-Log "Download $scid DLL 完了"
    }elseif($scid -eq "TOR GM"){
        if(test-path "$aupathm\TheOtherRoles-GM.$torv"){
            robocopy "$aupathm\TheOtherRoles-GM.$torv" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles-GM.$torv" -recurse
        }
        if($torpv -eq "v3.4.1.2"){
            ###
            #Mod Original DLL削除
            Remove-item -Path "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll"
            Write-Log 'Delete Original Mod DLL'
            Write-Log $torgmdll
            $torgmdll = "https://github.com/yukinogatari/TheOtherRoles-GM/releases/download/$torpv/TheOtherRolesGM.dll"
            #TOR+ DLLをDLして配置
            Write-Log "Download $scid DLL 開始"
            Invoke-WebRequest $torgmdll -Outfile "$aupathm\BepInEx\plugins\TheOtherRolesGM.dll" -UseBasicParsing
            Write-Log "Download $scid DLL 完了"
        }
    }elseif($scid -eq "TOU-R"){
        if(test-path "$aupathm\ToU $torv"){
            robocopy "$aupathm\ToU $torv" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\ToU $torv" -recurse
        }
    }elseif($scid -eq "TOR"){
        if(test-path "$aupathm\TheOtherRoles"){
            robocopy "$aupathm\TheOtherRoles" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\TheOtherRoles" -recurse
        }
    }elseif($scid -eq "ER"){
        if(test-path "$aupathm\ExtremeRoles-$torv"){
            robocopy "$aupathm\ExtremeRoles-$torv" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\ExtremeRoles-$torv" -recurse
        }
    }elseif($scid -eq "NOS"){
        if(test-path "$aupathm\Nebula"){
            robocopy "$aupathm\Nebula" "$aupathm" /E /log+:$LogFileName >nul 2>&1
            Remove-Item "$aupathm\Nebula" -recurse
        }
        if (!(Test-Path "$aupathm\Language\")) {
            New-Item "$aupathm\Language\" -Type Directory
        }
        Write-Log "日本語 データ Download 開始"
        Invoke-WebRequest $langdata -Outfile "$aupathm\Language\Japanese.dat" -UseBasicParsing
        Write-Log "日本語 データ Download 完了"
}else{
    }

    #解凍チェック
    if (test-path "$aupathm\BepInEx\plugins"){
        Write-Log ("ZIP 解凍OK");
        Remove-item -Path "$aupathm\TheOtherRoles.zip"
        Write-Log ("DLしたZIPを削除");
    }else{
      Write-Log ("ZIP 解凍NG");
    }
    $Bar.Value = "5"

    if($shortcut -eq $true){
        ##Desktopにショートカットを配置する
        $scpath = [System.Environment]::GetFolderPath("Desktop")

        if(test-path "$scpath\Among Us Mod $scid.lnk"){
            Remove-item -Path "$scpath\Among Us Mod $scid.lnk"
            Write-Log '既存のMod用Shortcut削除'
        }

        # ショートカットを作る
        $WsShell = New-Object -ComObject WScript.Shell
        $sShortcut = $WsShell.CreateShortcut("$scpath\Among Us Mod $scid.lnk")
        $sShortcut.TargetPath = "$aupathm\Among Us.exe"
        $sShortcut.IconLocation = "$aupathm\Among Us.exe"
        $sShortcut.Save()

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

if($tio -eq $false){
    $Form2.Show()
}
$Bar.Value = "6"

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
            $Bar.Value = "7"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "AmongUsReplayInWindow"){
            $qureq = $true
            if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802){
            }else{
                if([System.Windows.Forms.MessageBox]::Show("必要な.Net 5 Frameworkがインストールされていません。インストールしますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -UseBasicParsing
                    .\dotnet-install.ps1
                    Remove-Item .\dotnet-install.ps1
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
                    if([System.Windows.Forms.MessageBox]::Show("既に存在するようです。上書き展開しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
            $Bar.Value = "8"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "AmongUsCapture"){
            $qureq = $true
            if((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 394802){
            }else{
                if([System.Windows.Forms.MessageBox]::Show("必要な.Net 5 Frameworkがインストールされていません。インストールしますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
                    Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -UseBasicParsing
                    .\dotnet-install.ps1
                    Remove-Item .\dotnet-install.ps1
                }else{
                    Write-Log "AmongUsCaptureの処理を中止します"
                    $qureq = $false
                }    

            }
            if($qureq){
                $aucap= (ConvertFrom-Json (Invoke-WebRequest "https://api.github.com/repos/automuteus/amonguscapture/releases/latest" -UseBasicParsing)).assets.browser_download_url
                $aucapfile = split-path $aucap[0] -Leaf 
                $aucapfn = $aucapfile.Substring(0, $aucapfile.LastIndexOf('.'))
                $md = [System.Environment]::GetFolderPath("MyDocuments")
                $aucapcheck = $true
                if(Test-Path $md\$aucapfn){
                    if([System.Windows.Forms.MessageBox]::Show("既に存在するようです。上書き展開しますか？", "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
            $Bar.Value = "9"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "VC Redist"){
            Write-Log "VC Redist Install start"
            $fpth = Join-Path $npl "\install.ps1"
            Invoke-WebRequest https://vcredist.com/install.ps1 -OutFile "$fpth" -UseBasicParsing
            if(test-path "$env:ProgramFiles\PowerShell\7"){
                if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                    Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth""" -Verb RunAs -Wait
                }
            }else{
                if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
                    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File ""$fpth""" -Verb RunAs -Wait
                }   
            }
            Remove-Item "$fpth"
            Write-Log "VC Redist Install ends"
        }elseif($CheckedBox.CheckedItems[$aa] -eq "PowerShell 7"){
            Write-Log "PS7 Install start"
            $pspth = Join-Path $npl "\PowerShell-7.2.1-win-x64.msi"
            Invoke-WebRequest https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi -OutFile "$pspth" -UseBasicParsing
            $arguments = @(
                      "/i"
                      "`"$pspth`""
                      "/passive"
            )
            Start-Process -FilePath msiexec.exe -Wait -PassThru -ArgumentList $arguments
            Or the preview version:

            Remove-Item $pspth
            Write-Log "PS7 Install ends"
        }else{
        }
    }
}

 
$Bar.Value = "9"

####################
#bat file auto update
####################
if(test-path "$npl\StartAmongUsModTORplusDeployScript.bat"){
    Invoke-WebRequest "https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/StartAmongUsModTORplusDeployScript.bat" -OutFile "$npl\StartAmongUsModTORplusDeployScript.bat" -UseBasicParsing
}
####################

$Bar.Value = "10"
$Form2.Close()

if($tio){
    if($startexewhendone -eq $true){
        Start-Process "$aupathm\Among Us.exe"   
    }else{
    }
}

Write-Log "-----------------------------------------------------------------"
Write-Log "MOD Installation Ends"
Write-Log "-----------------------------------------------------------------"

Start-Sleep -s 5

exit
