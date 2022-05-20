Param($Arg1,$Arg2,$Arg3) #modid,modpath,platform
#################################################################################################
#
# Among Us Mod Tech Support Script
#
$version = "1.0.2"
#
#################################################################################################

$npl = Get-Location

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
    Write-Output $(Get-Translate($Log)) | Out-File -FilePath $LogFileName -Encoding utf8 -Append
    # echo させるために出力したログを戻す
    Return $(Get-Translate($Log))
}
#################################################################################################
#Mod Selecter

if($null -ne $Arg1){
    $scid = $Arg1
}else{
    $scid = "TOR GMH"
}


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
Write-Log "$Arg1"
Write-Log "$Arg2"
Write-Log "$Arg3"

#Among Us Modded Path ：Steam Mod用フォルダ
$au_path_steam_mod = "C:\Program Files (x86)\Steam\steamapps\common\Among Us $scid Mod"
#Among Us Modded Path ：Steam Mod用フォルダ
$au_path_epic_mod = "C:\Program Files\Epic Games\AmongUs $scid Mod"

if($null -ne $Arg2){
    $aupathm = $Arg2   
    if($null -ne $Arg3){
        $platform = $Arg3
    }else{
        if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("PlatformはSteamですか?")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
            $platform = "Steam"
        }else{
            $platform = "Epic"
        }
    }
}elseif(Test-path "$au_path_steam_mod\Among Us.exe"){
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
        [System.Windows.Forms.MessageBox]::Show($(Get-Translate("Modが入っているAmongUsがインストールされているフォルダを選択してください")), "Among Us Mod Auto Deploy Tool")
        $spath = Get-FolderPathG
    }
    if($null -eq $spath){
        Write-Log "Failed $spath"
        pause
        Exit
    }
    if(test-path "$spath\Among Us.exe"){
        Write-Log "$spath にAmongUs Modのインストールパスを確認しました"
        if([System.Windows.Forms.MessageBox]::Show($(Get-Translate("PlatformはSteamですか？")), "Among Us Mod Auto Deploy Tool",4) -eq "Yes"){
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
Write-Log "Check Tree"
Write-Log "-----------------------------------------------------------------"
Write-Log "$aupathm"

#フォルダ/ファイル構成チェック
Set-Location $aupathm
tree /F | Out-File -FilePath $LogFileName -Encoding UTF8 -Append

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


if($Cult -eq "ja-JP"){
    #post API(Discord or Git issue)
    $chkenabled = ""
    $chkenabled = invoke-webrequest https://raw.githubusercontent.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/main/enabledebug.txt
    if($($chkenabled.Content).LastIndexOf("true") -gt 0){
        $dispost = $true
        If(Test-Path "C:\Temp\agreement.txt"){
            $agree = $true
            $usnm = Get-content "C:\Temp\agreement.txt" -Raw
        }
        Write-Log "Posting Debug Info is enabled globaly."
    }else{
        $dispost = $false
        Write-Log "Posting Debug Info is not enabled globaly.."
    }

    if($dispost){
        Write-Log "-----------------------------------------------------------------"
        Write-Log "Posting Data"
        Write-Log "-----------------------------------------------------------------"
        
        if(!($agree)){
            if([System.Windows.Forms.MessageBox]::Show("結果を健康ランドにPostしますか？`r`n`r`n投稿される情報は個人情報を含む場合がありますが、`r`n当方では何かあった場合の責任について一切感知しません。`r`nここで押した選択は記録され、今後同じ質問はされません。", "Among Us Mod Debug Bot",4) -eq "Yes"){
                $agree = $true
                #　インプットボックスの表示
                $usnm = [Microsoft.VisualBasic.Interaction]::InputBox("プレイヤー名を記載してください`r`nプレイヤー名が記載されていない場合は投稿をキャンセルします`r`nここで記載した名前は記録され、今後同じ質問はされません。", "Among Us Mod Debug Bot")
                if($usnm -eq ""){
                    return $LogFileName
                }    
                $usnm | Out-File -FilePath "C:\Temp\agreement.txt" -Encoding UTF8 -Append
            }
        }

        if($agree){
            $dishook = "https://discord.com/api/webhooks/975204305265102868/BzMgrQ8Ul15YVzpcL8P2BNTb21P-amVeROUAz7QQrSrUgbiLHzzo8Kc1AWTs9fM6unUF"

            #　アセンブリの読み込み
            [void][System.Reflection.Assembly]::Load("Microsoft.VisualBasic, Version=8.0.0.0, Culture=Neutral, PublicKeyToken=b03f5f7f11d50a3a")


            $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $headers.Add("content-type", "multipart/form-data")
            $headers.Add("Cookie", "__cfruid=6db5c6ada0d4c320afee521f14a55d58b856331f-1652577557; __dcfduid=0bf11ba09d7011ec8c31dac48d8e8976; __sdcfduid=0bf11ba09d7011ec8c31dac48d8e89764d55a8c8ef95cdfce9060d40f6b7bcde5325c65b689704f560aaa40f23128113")
            
            $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
            $multipartFile = $LogFileName
            $FileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
            $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $fileHeader.Name = "file"
            $fileHeader.FileName = "$LogFileName"
            $fileContent = [System.Net.Http.StreamContent]::new($FileStream)
            $fileContent.Headers.ContentDisposition = $fileHeader
            $multipartContent.Add($fileContent)
            
            $stringHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
            $stringHeader.Name = "payload_json"
            $stringContent = [System.Net.Http.StringContent]::new("{`"content`":`"$usnm posts info from debug mode.`"}")
            $stringContent.Headers.ContentDisposition = $stringHeader
            $multipartContent.Add($stringContent)
            
            $body = $multipartContent
            
            $response = (Invoke-RestMethod $dishook -Method 'POST' -Headers $headers -Body $body) | ConvertTo-Json  
            Write-Log $response 
        }
    }
}

Write-Log "-----------------------------------------------------------------"
Write-Log "Script Ends"
Write-Log "-----------------------------------------------------------------"

return $LogFileName

