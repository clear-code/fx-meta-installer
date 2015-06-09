逆引きマニュアル


■Mozillaアプリケーション（FirefoxまたはThunderbird）の
　アップデート

・同梱のMozillaアプリケーションを新しいバージョンに入れ替えるには？
　→resourcesフォルダ内のアプリケーションのインストーラの実行ファイルを入れ替えて、
　　fainstall.ini の [fainstall] セクションに
　　------------
    AppMinVersion=<入れ替え後の新しいバージョン>
    AppMaxVersion=<入れ替え後の新しいバージョン>
　　------------
　　と記述する。
　　ESR版Firefoxをインストールする場合は、さらに以下を加える。
　　------------
　　AppIsESR=true
　　------------


■Mozillaアプリケーション（FirefoxまたはThunderbird）の
　インストールオプション

・Mozillaアプリケーションのインストール先を変えるには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　InstallDirectoryPath=<インストール先フォルダのフルパス>
　　------------
　　または
　　------------
　　InstallDirectoryName=<Program Files内に作成するフォルダ名>
　　------------
　　と記述する。

・デスクトップへのショートカットの作成を禁止するには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　DesktopShortcut=false
　　------------
　　と記述する。

・スタートメニューへの項目の追加を禁止するには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　StartMenuShortcuts=false
　　------------
　　と記述する。

・クイックランチへの項目の追加を禁止するには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　QuickLaunchShortcut=false
　　------------
　　と記述する。

・Mozilla Maintenance Serviceのインストールを禁止するには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　MaintenanceService=false
　　------------
　　と記述する。

・Talkback（障害報告ツール）のインストールを禁止するには？
　→fainstall.ini の [fainstall] セクションに
　　------------
　　AppInstallTalkback=false
　　------------
　　と記述する。


■Mozillaアプリケーション（FirefoxまたはThunderbird）の
　インストーラ

・共有フォルダやローカルの特定の場所に置いたインストーラから
　インストールを行うには？
　→fainstall.ini の [fainstall] セクションに
　　------------
　　AppDownloadPath=<インストーラのフルパス>
　　------------
　　と記述する。

・Web上に置かれたインストーラからインストールを行うには？
　→fainstall.ini の [fainstall] セクションに
　　------------
　　AppDownloadUrl=<インストーラのダウンロードURI>
　　AppHash=<ダウンロードされたファイルの正しいMD5ハッシュ>
　　------------
　　と記述する。


■デジタル署名、証明書

・生成されるメタインストーラのファイルにデジタル署名を付けるには？
　→バッチファイルに以下の指定を行う。
　　SIGNTOOL_PATH ：Microsoft Platform SDKのインストール先パス。
　　SIGN_PFX      ：コードサイニング証明書（*.pfx）のファイルパス。
　　SIGN_PASSWORD ：証明書を使用するためのパスワード。
　　SIGN_TIMESTAMP：タイムスタンプサーバのURI。
　　SIGN_DESC     ：署名された内容の説明文。（省略可）
　　SIGN_DESC_URL ：署名された内容を説明するWebページのURI。（省略可）

・インストール直後からSSL証明書やルート証明書をインポート済みの状態に
　しておくには？
　→SSL証明書（Base64形式テキストファイル）を *.cer という名前で
　　resourcesフォルダ以下に置く。
　　（certimporterの利用を前提とする）


■ブックマーク

・インストール直後の初期状態のブックマークの内容を変更するには？
　→resourcesフォルダ内にbookmarks.htmlを置く。
　  （実際にFirefoxでブックマークを編集してエクスポートした物を使うと良い）


■ヘルパーアプリケーション

・特定の形式のファイルをダウンロードする際の挙動をカスタマイズするには？
　→resourcesフォルダ内に編集済みのmimeTypes.rdfを置く。


■アドオン

・任意のアドオンをインストール対象に加えるには
　→resourcesフォルダへアドオンのxpiファイルを追加する。
　→以下の内容をfainstall.iniに追記する
  ----------
  [<addon identifier>.xpi]
  AddonId=<addon identifier>
  ----------

　<addon identifier> はxpiをzipにするなどして解凍した後、
　install.rdfのem:idの値を見ることで確かめられる。

・インストール先を「extensions」以下にして、普通のアドオンとして
　見えるようにするには？
　→fainstall.iniで各アドオンのセクションに
　　「TargetLocation=%AppDir%/browser/extensions」の指定を加える。例：
　　> [force-addon-status.xpi]
　　> AddonId=force-addon-status@clear-code.com
　　> TargetLocation=%AppDir%/browser/extensions
　　その上で、MCD用設定ファイルなどを使い以下の設定を適用し、
　　初回起動時の警告を表示しないようにする。
　　> defaultPref("extensions.autoDisableScopes", 11);

   ・TergetLocationについての注意
   → Firefoxでは
   > TargetLocation=%AppDir%/browser/extensions
   → Thunderbirdでは
   > TargetLocation=%AppDir%/extensions
   となる事に注意が必要。

   ・パス区切り文字について
   → 「\」または「/」の両方が使えるが、
   Shift-JIS⇄UTF-8間での文字化けを防ぐために「/」を使う方が良い。

■検索エンジン

・インストール直後の初期状態で特定の検索エンジンだけを有効にするには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　FxEnabledSearchPlugins=<有効にしたい検索エンジンの
　　ファイル名のリスト（スペース区切りまたはカンマ区切り）>
　　------------
　　と記述する。

・インストール直後の初期状態で特定の検索エンジンだけを無効化するには？
　→resourcesフォルダ内に<アプリケーション名>-setup.iniを作成して
　　[Install] セクションに
　　------------
　　FxDisabledSearchPlugins=<無効化したい検索エンジンの
　　ファイル名のリスト（スペース区切りまたはカンマ区切り）>
　　------------
　　と記述する。


■設定移行ウィザードの無効化

・初回起動時の設定移行ウィザードを無効化するには？
　→以下の内容のoverride.iniをresourcesフォルダ内に作成する。
　　------------
　　[XRE]
    EnableProfileMigrator=false
　　------------
