# AmongUs Mod Auto Deploy Script <br> AmongUs Mod自動導入スクリプト
<!-- wp:image {"id":410,"width":519,"height":386,"sizeSlug":"full","linkDestination":"none"} -->
<iframe width="560" height="315" src="https://www.youtube.com/embed/jdL7YCdV7qw" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><!-- /wp:image -->

<!-- wp:paragraph -->
<p>■TOR系 Mod入れるのが面倒なので作った自動化Script</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>MODとバージョンをリストから選択するとあとは良しなにしてくれるScript です</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>このScriptは 以下の環境用のものです<br>・tomarai様のTOR+ (<a rel="noreferrer noopener" href="https://github.com/tomarai/TheOtherRoles" target="_blank">tomarai/TheOtherRoles</a>)<br>・AUShipMod (<a rel="noreferrer noopener" href="https://github.com/tomarai/AUShipMod" target="_blank">tomarai/AUShipMod</a>)<br>・yukinogatari様のThe Other Roles: GM Edition (<a href="https://github.com/yukinogatari/TheOtherRoles-GM">yukinogatari/TheOtherRoles-GM</a>)<br>・haoming37様のThe Other Roles: GM Haoming Edition (<a href="https://github.com/haoming37/TheOtherRoles-GM-Haoming">haoming37/TheOtherRoles-GM-Haoming</a>)<br>・本家TOR (<a rel="noreferrer noopener" href="https://github.com/Eisbison/TheOtherRoles" target="_blank">Eisbison/TheOtherRoles</a>)<br>・Town of Us Reactivated (<a rel="noreferrer noopener" href="https://github.com/eDonnes124/Town-Of-Us-R" target="_blank">eDonnes124/Town-Of-Us-R</a>)<br>・Extreme Roles (<a rel="noreferrer noopener" href="https://github.com/yukieiji/ExtremeRoles" target="_blank">yukieiji/ExtremeRoles</a>)<br>・Extreme Roles with Extreme Skins (<a rel="noreferrer noopener" href="https://github.com/yukieiji/ExtremeRoles" target="_blank">yukieiji/ExtremeRoles</a>)<br>・Nebula on the Ship (<a rel="noreferrer noopener" href="https://github.com/Dolly1016/Nebula" target="_blank">Dolly1016/Nebula</a>)<br>・tomarai様のAUMod (<a rel="noreferrer noopener" href="https://github.com/tomarai/AUMod" target="_blank">tomarai/AUMod</a>)</p>
<!-- /wp:paragraph -->

<!-- wp:html -->
<p>本ScriptはAmongUs公式及び上記Mod作成者様とは無関係のScriptです</p>
<p><a href="https://disboard.org/ja/server/906600951924793444" target="_blank" rel="noreferrer noopener">本来はこのDiscordサーバー用に作ったツールです</a></p>
<!-- /wp:html -->

<!-- wp:paragraph -->
<p>■[推奨]<br>最新のPowershell（<a rel="noreferrer noopener" href="https://github.com/PowerShell/PowerShell/releases/tag/v7.2.2" target="_blank">公式HP</a>）（入れないと動かないとかは多分ないハズ）</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>初回動作時や動作不良の際はクリーンインストール推奨です</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■Download<br><a href="https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/StartAmongUsModTORplusDeployScript.bat" target="_blank" rel="noreferrer noopener">https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/StartAmongUsModTORplusDeployScript.bat</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>ZIP<br><a href="https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongUs-Mod-Auto-Deploy-Script.zip" target="_blank" rel="noreferrer noopener">https://github.com/Maximilian2022/AmongUs-Mod-Auto-Deploy-Script/releases/download/latest/AmongUs-Mod-Auto-Deploy-Script.zip</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■[導入手順] <br>1. このBatを動作させる <br>2. InstallするModを選択する<br>3. MODのバージョンを選択する（v3.3.2.2+、等) <br><br>■[このScriptでやってること] <br>０．Script ps1をDLして実行<br><br>１．Steam/Epicの自動判定機能（両方ある場合はSteamが先に判定されます）<br>       インストールパスがカスタムされてるときにフォルダ選択画面を出すよ <br><br>２．オリジナルフォルダをバックアップする<br>　　すでにバックアップ済みの場合はスキップされる<br><br>３．オリジナルフォルダをコピーしてMod用フォルダの作成<br>　　作成される場所はオリジナルフォルダと同じ階層です<br>　　（すでに作られてたら消して作り直すかユーザー確認する） <br><br>４．ZIPをDLしてMod用フォルダに解凍 <br><br>５．必要に応じて元のMod DLLを削除してTOR+のDLLをDL <br><br>６．DesktopにMod適用したAmongUsへのShortcutを作成するか、<br>　　作成したMod入りフォルダをExplorerで表示して終了（ユーザー選択）<br><br>７．選択したツールの展開<br>　・BetterCrewLinkを選択するとLatestをDLしてインストールする。<br>　　<a rel="noreferrer noopener" href="https://github.com/OhMyGuus/BetterCrewLink" target="_blank">https://github.com/OhMyGuus/BetterCrewLink</a><br>　・AmongUsReplayInWindowを選択するとLatestをDLしてDocumentsに展開する<br>　　<a rel="noreferrer noopener" href="https://github.com/sawa90/AmongUsReplayInWindow" target="_blank">https://github.com/sawa90/AmongUsReplayInWindow</a><br>　・AmongUsCaptureを選択するとLatestをDLしてDocumentsに展開する<br>　　<a rel="noreferrer noopener" href="https://github.com/automuteus/amonguscapture" target="_blank">https://github.com/automuteus/amonguscapture</a><br>　・VC Redist(Modの動作に必要)<br>　・Powershell 7</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>■Q&amp;A <br>Q. セキュリティソフトが止めてきます<br>A. でしょうね<br>　 真面目に話すと長いけど、Windows Defenderでも止められることがあるよ<br>　 詳細情報を押して実行ボタンを押せば、動くよ<br>　 自己責任でどうぞ<br><br>Q. batでcurl.exeでエラーが出てます<br>A. Windows 10が古い可能性があります<br>　Win10 1803以降、Win11でないと稼働しません<br><br>Q. Modを入れて起動すると画面が真っ黒になります <br>A. Mod Fileが壊れているか、失敗しています<br>　Scriptを再実行してみてください<br>　やり直しても変わらないときは、まず<strong>クリーンインストール</strong>しましょう<br><br>Q. 手順通りやってもModの起動に失敗したり、固まったりします <br>A. 以下のような場合、BepinExの初動が正しく動いていない可能性があります<br>　Scriptを再実行してみましょう<br>　・BepinExのフォルダにCacheフォルダができていない場合、<br>　・TheOtherHatsが初期状態のままの場合<br>　（多分NW系のエラーの可能性もあるので、時間置くのも大事です）<br><br>Q. EPIC版でも使えますか？<br>A. 使えるようになりました　　</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>■Credit<br>Special Thanks <br><a href="https://qiita.com/Kosen-amai/items/7b2339d7de8223ab77c4" target="_blank" rel="noreferrer noopener">https://qiita.com/Kosen-amai/items/7b2339d7de8223ab77c4</a><br><a href="https://letspowershell.blogspot.com/2015/07/powershell_29.html" target="_blank" rel="noreferrer noopener">https://letspowershell.blogspot.com/2015/07/powershell_29.html</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■動作Screenshot</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Batを起動すると、このような画面になります<br>BatはメインのPS1をDLして起動するためだけに使用されます</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":413,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://blog.kit-a.net/wp-content/uploads/2022/01/image-1024x329.png" alt="" class="wp-image-413"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>インストールしたいModを選択すると、Githubからバージョン一覧をGetして表示します<br>ここ都度取りに行ってるので数十回レベルでガチャガチャ返るとGithub側からNG食らうかも<br>都度GithubにAPIで取りに行ってるので、特別な操作が必要なバージョンがリリースされていなければ、このスクリプトをバージョンアップしなくても、最新のMod入りを作成することが可能です</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":415,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://blog.kit-a.net/wp-content/uploads/2022/01/image-1-1024x327.png" alt="" class="wp-image-415"/></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>選択したバージョンのModを構築します<br>AmongUs のデフォルトパスの中身は触れません<br>デフォルトはバニラのままおいといて、コピー元として扱い、コピー先にModを展開します</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":416,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://blog.kit-a.net/wp-content/uploads/2022/01/image-2-1024x398.png" alt="" class="wp-image-416"/></figure>
<!-- /wp:image -->
