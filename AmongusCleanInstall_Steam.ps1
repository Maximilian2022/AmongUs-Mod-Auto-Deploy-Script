#################################################################################################
#
# Among Us Clean Install Script
#
$version = "1.0.0"
#
#################################################################################################
# Log用Function
#################################################################################################
# ログの出力先
$LogPath = "C:\Temp"
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
    Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append
    # echo させるために出力したログを戻す
    Return $Log
}
#################################################################################################

Write-Log "Running With Powershell Version $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Log "                                                                 "
Write-Log "-----------------------------------------------------------------"
Write-Log "                                                                 "
Write-Log "                  AmongUs Clean Install Script                   "
Write-Log "                                                   Version: $version"
Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Starts"
Write-Log "-----------------------------------------------------------------"

$steampth = "C:\Program Files (x86)\Steam\Steam.exe"
if (Test-Path $steampth){
    Write-Log "Steam Application is found on $steampth"
}else{
    Write-Log "Steam Application is not on default location"
    Param(
        [Parameter()]
        [String] $FilePath
      )     
      # $FilePath が設定されていない、又はファイルが存在しない
      if([string]::IsNullOrEmpty($steampth) -Or (Test-Path -LiteralPath $steampth -PathType Leaf) -eq $false) {
          [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")    
          $dialog = New-Object System.Windows.Forms.OpenFileDialog
          $dialog.Filter = "EXE ファイル(*.EXE)|*.EXE"
          $dialog.InitialDirectory = "C:\"
          $dialog.Title = "Steam.exe ファイルを選択してください"
      
          # キャンセルを押された時は処理を止める
          if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::NG){
              exit 1
          }
      
          # 選択したファイルパスを $FilePath に設定
          $steampth = $dialog.FileName
      }
}


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
    }else{
        #デフォルトパスになかったら、ウインドウを出してユーザー選択させる
        Write-Log "デフォルトフォルダにAmongUsを見つけることに失敗しました"      
        Write-Log "フォルダをユーザーに選択するようダイアログを出します"      
        [System.Windows.Forms.MessageBox]::Show("Modが入っていないAmongUsがインストールされているフォルダを選択してください", "Among Us Clean Install Tool")
        $spath = Get-FolderPathG
    }
    if($null -eq $spath){
        Write-Log "Failed $spath"
        pause
        Exit
    }
    if(test-path "$spath\Among Us.exe"){
        Write-Log "$spath にAmongUsのインストールパスを確認しました"
    }else{
        Write-Log "$spath にAmongUsのインストールが確認できませんでした"
    }
}

Write-Log "Delete AmongUs First"
if([System.Windows.Forms.MessageBox]::Show("クリーンインストールのために選択したFolderは削除されます`n続行しますか？", "Among Us Clean Install Tool",4) -eq "Yes"){
}else{
    Write-Log "処理を中止します"
    exit
}
Remove-Item -Path $spath -Recurse -Force

Write-Log "Validate AmongUs"
Start-Process $steampth -argument "+app_start_validation 945360"

Write-Log "-----------------------------------------------------------------"
Write-Log "Clean Installation Ends"
Write-Log "-----------------------------------------------------------------"
