<#
.SYNOPSIS
    Among Us Mod Auto Deploy Tool - Modern GUI Prototype (Airship Edition)
.DESCRIPTION
    本番環境のファイルを一切変更しない安全な GUI プレビュー・モックスクリプトです。
    WPF (XAML) を使用し、1つのウィンドウ内で設定 -> 進捗 -> 完了がシームレスに遷移します。
    Among Us "Airship" をイメージしたレッド＆ゴールド基調のデザインと、
    Windows のシステム設定（ライト／ダークモード）の自動検出および手動トグルに対応しています。
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconPath = Join-Path $scriptDir "AUMADS.ico"

# Windows システムのテーマ（ライト/ダーク）を検出
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

[xml]$xaml = @"
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

        <!-- ComboBox Dark Style -->
        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="{DynamicResource InputBg}"/>
            <Setter Property="Foreground" Value="{DynamicResource TextPrimary}"/>
            <Setter Property="BorderBrush" Value="{DynamicResource InputBorder}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8,6"/>
            <Setter Property="FontSize" Value="13"/>
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
                                <RadioButton x:Name="RbPlatformSteam" Content="Steam 版" IsChecked="True" Margin="0,0,16,0"/>
                                <RadioButton x:Name="RbPlatformEpic" Content="Epic Games 版" Margin="0,0,16,0"/>
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
                                <RadioButton x:Name="RbRecreate" Content="再作成する" IsChecked="True" Width="100"/>
                                <RadioButton x:Name="RbOverwrite" Content="上書きする" Width="100"/>
                                <RadioButton x:Name="RbNoRecreate" Content="再作成しない" Width="105"/>
                                <RadioButton x:Name="RbCleanInstall" Content="クリーンインストール" Width="145" Foreground="{DynamicResource TextAccentGold}"/>
                            </WrapPanel>

                            <!-- 起動 & ショートカット -->
                            <TextBlock Text="デスクトップショートカット" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                <RadioButton Content="作成する" IsChecked="True" Margin="0,0,14,0"/>
                                <RadioButton Content="作成しない"/>
                            </StackPanel>

                            <TextBlock Text="完了後の動作" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
                                <RadioButton Content="自動で起動する" Margin="0,0,14,0"/>
                                <RadioButton Content="起動しない" IsChecked="True"/>
                            </StackPanel>

                            <TextBlock Text="CPU Affinity (NOS向け最適化)" FontSize="12" Foreground="{DynamicResource TextSecondary}" Margin="0,0,0,4"/>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,12">
                                <RadioButton Content="CPU 0のみ" IsChecked="True" Margin="0,0,10,0"/>
                                <RadioButton Content="2コア" Margin="0,0,10,0"/>
                                <RadioButton Content="設定なし"/>
                            </StackPanel>

                            <Separator Background="{DynamicResource SeparatorBg}" Margin="0,0,0,10"/>

                            <!-- 追加ツール -->
                            <TextBlock Text="🔧 同時インストール Tool" FontSize="13" FontWeight="Bold" Foreground="{DynamicResource TextAccentGold}" Margin="0,0,8,0"/>
                            <WrapPanel>
                                <CheckBox Content="VC Redist" IsChecked="True" Width="135"/>
                                <CheckBox Content="BetterCrewLink" Width="135"/>
                                <CheckBox Content=".NET Framework" IsChecked="True" Width="135"/>
                                <CheckBox Content="AmongUsCapture" Width="135"/>
                                <CheckBox Content="Submerged" Width="135"/>
                                <CheckBox Content="カスタムサーバー情報追加" Width="160"/>
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
                    <TextBlock Text="Nebula on the Ship (NOS) の導入とショートカット作成が完了しました。" 
                               FontSize="13" Foreground="{DynamicResource TextSecondary}" HorizontalAlignment="Center" TextAlignment="Center" Margin="0,0,0,20"/>

                    <Border Background="{DynamicResource InputBg}" BorderBrush="{DynamicResource BorderCard}" BorderThickness="1" CornerRadius="8" Padding="16" Margin="0,0,0,24">
                        <StackPanel>
                            <TextBlock Text="📍 インストール場所:" FontSize="12" Foreground="{DynamicResource TextSecondary}"/>
                            <TextBlock Text="C:\Games\Among Us_NOS" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimary}" Margin="0,2,0,10"/>
                            
                            <TextBlock Text="🔗 デスクトップショートカット:" FontSize="12" Foreground="{DynamicResource TextSecondary}"/>
                            <TextBlock Text="Among Us - NOS (CPU Affinity: 0)" FontSize="13" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimary}" Margin="0,2,0,0"/>
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
"@

# Window Generation
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

if (Test-Path $iconPath) {
    $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create($iconPath)
}

# Element References
$ViewConfig = $window.FindName("ViewConfig")
$ViewProgress = $window.FindName("ViewProgress")
$ViewComplete = $window.FindName("ViewComplete")

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
$TxtPlatformBadge = $window.FindName("TxtPlatformBadge")

$CmbMod = $window.FindName("CmbMod")
$TxtModPath = $window.FindName("TxtModPath")

$ProgBar = $window.FindName("ProgBar")
$TxtProgressStatus = $window.FindName("TxtProgressStatus")
$TxtPercent = $window.FindName("TxtPercent")
$TxtLog = $window.FindName("TxtLog")
$ScrollLog = $window.FindName("ScrollLog")

# プラットフォームや MOD 変更時にパスとバッジを自動連動更新
function Update-GuiPaths() {
    $isSteam = $RbPlatformSteam.IsChecked
    $modCode = "NOS"
    if ($CmbMod.SelectedItem) {
        $raw = $CmbMod.SelectedItem.Content.ToString()
        $modCode = $raw.Split(":")[0].Trim()
    }
    
    if ($isSteam) {
        $TxtPlatformBadge.Text = "🟢 Steam 選択中 (v2026.9.29)"
        $TxtVanillaPath.Text = "C:\Program Files (x86)\Steam\steamapps\common\Among Us"
        if ($modCode -match "Install|Tool") {
            $TxtModPath.Text = "（一括インストール / ツールのみモード）"
        } else {
            $TxtModPath.Text = "C:\Program Files (x86)\Steam\steamapps\common\Among Us $modCode Mod"
        }
    } else {
        $TxtPlatformBadge.Text = "🟢 Epic 選択中 (v2026.9.29)"
        $TxtVanillaPath.Text = "C:\Program Files\Epic Games\AmongUs"
        if ($modCode -match "Install|Tool") {
            $TxtModPath.Text = "（一括インストール / ツールのみモード）"
        } else {
            $TxtModPath.Text = "C:\Program Files\Epic Games\Among Us $modCode Mod"
        }
    }
}

$RbPlatformSteam.Add_Checked({ Update-GuiPaths })
$RbPlatformEpic.Add_Checked({ Update-GuiPaths })
$CmbMod.Add_SelectionChanged({ Update-GuiPaths })

# -------------------------------------------------------------
# Airship Theme Definitions (Dark & Light)
# -------------------------------------------------------------
$script:isLightMode = $systemIsLight

function Set-AppTheme([bool]$isLight) {
    $conv = [System.Windows.Media.BrushConverter]::new()
    if ($isLight) {
        # Light Mode (Airship Daylight Cloud / Lounge)
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

        $BtnToggleTheme.Content = "☀️ ライト"
    } else {
        # Dark Mode (Airship Night Sky / Bridge Deck)
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

        $BtnToggleTheme.Content = "🌙 ダーク"
    }
}

# 初回テーマ適用（システム設定に基づく）
Set-AppTheme $script:isLightMode

# テーマ切替ボタンのイベント
$BtnToggleTheme.Add_Click({
    $script:isLightMode = -not $script:isLightMode
    Set-AppTheme $script:isLightMode
})

# Event: Start Deploy (Smooth View Transition in Single Window)
$BtnStartDeploy.Add_Click({
    $ViewConfig.Visibility = [System.Windows.Visibility]::Collapsed
    $ViewProgress.Visibility = [System.Windows.Visibility]::Visible
    $ViewComplete.Visibility = [System.Windows.Visibility]::Collapsed

    # 選択されたモードの判定
    $deployMode = "再作成する"
    if ($RbCleanInstall.IsChecked) {
        $deployMode = "クリーンインストール"
    } elseif ($RbOverwrite.IsChecked) {
        $deployMode = "上書きする"
    } elseif ($RbNoRecreate.IsChecked) {
        $deployMode = "再作成しない"
    }

    # Simulation Timer for Demonstration
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $script:step = 0

    $timer.Add_Tick({
        $script:step++
        switch ($script:step) {
            1 {
                $ProgBar.Value = 15
                $TxtPercent.Text = "15%"
                if ($deployMode -eq "クリーンインストール") {
                    $TxtProgressStatus.Text = "[1/4] Among Us バニラのクリーンインストール中..."
                    $TxtLog.Text += "`n[Step 1] クリーンインストールスクリプトを実行中..."
                } else {
                    $TxtProgressStatus.Text = "[1/4] Among Us バニラバックアップを作成中 (モード: $deployMode)..."
                    $TxtLog.Text += "`n[Step 1] バニラファイルのバックアップ中 (モード: $deployMode)..."
                }
                $ScrollLog.ScrollToEnd()
            }
            2 {
                $ProgBar.Value = 40
                $TxtPercent.Text = "40%"
                $TxtProgressStatus.Text = "[2/4] 最新版 Nebula on the Ship (v110) をダウンロード中..."
                $TxtLog.Text += "`n[Step 2] GitHub から最新リリースを取得中: NOS v110.zip"
                $ScrollLog.ScrollToEnd()
            }
            3 {
                $ProgBar.Value = 70
                $TxtPercent.Text = "70%"
                $TxtProgressStatus.Text = "[3/4] BepInEx および MOD ファイルを展開中..."
                $TxtLog.Text += "`n[Step 3] BepInEx/plugins/Nebula.dll を展開完了"
                $ScrollLog.ScrollToEnd()
            }
            4 {
                $ProgBar.Value = 90
                $TxtPercent.Text = "90%"
                $TxtProgressStatus.Text = "[4/4] ショートカット & CPU Affinity を設定中..."
                $TxtLog.Text += "`n[Step 4] デスクトップショートカット作成完了 (Affinity: CPU 0)"
                $ScrollLog.ScrollToEnd()
            }
            5 {
                $ProgBar.Value = 100
                $TxtPercent.Text = "100%"
                $TxtProgressStatus.Text = "デプロイ完了！"
                $TxtLog.Text += "`n[Done] 全処理が正常に終了しました。"
                $ScrollLog.ScrollToEnd()
                $timer.Stop()

                # 完了画面へ遷移
                Start-Sleep -Milliseconds 600
                $ViewProgress.Visibility = [System.Windows.Visibility]::Collapsed
                $ViewComplete.Visibility = [System.Windows.Visibility]::Visible
            }
        }
    })
    $timer.Start()
})

# Event: Cancel / Reset
$BtnCancel.Add_Click({
    $ViewProgress.Visibility = [System.Windows.Visibility]::Collapsed
    $ViewConfig.Visibility = [System.Windows.Visibility]::Visible
})

$BtnBackToConfig.Add_Click({
    $ViewComplete.Visibility = [System.Windows.Visibility]::Collapsed
    $ViewConfig.Visibility = [System.Windows.Visibility]::Visible
})

$BtnClose.Add_Click({
    $window.Close()
})

$BtnLaunchGame.Add_Click({
    [System.Windows.MessageBox]::Show("（モックデモ）Among Us が起動されます！", "起動通知", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
    $window.Close()
})

# Display Window
$window.ShowDialog() | Out-Null
