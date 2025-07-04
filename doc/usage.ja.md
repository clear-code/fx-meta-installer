# メタインストーラの基本的な挙動について

## 動作環境

・Windows 10以降（Windows 10、Windows 11にて動作検証済み）

## 対応アプリケーション

・Mozilla Firefox
・Mozilla Thunderbird

## Mozillaアプリケーションの自動インストールの概要

* Mozillaアプリケーションについて、インストールされていない、またはインストール済みのバージョンが指定バージョンよりも古い場合、指定バージョンのMozillaアプリケーションを自動的にインストールする。
* Mozillaアプリケーションの自動インストールに使用するインストーラは、以下のいずれかの方法で提供できる。
  * 1. パッケージにインストーラを含める。
  * 2. 任意のパスに置いたファイルを利用する。
  * 3. Web上の任意のダウンロードURIから自動的にダウンロードさせる。
* クラッシュ報告機能の有効・無効、初期状態で無効にする検索プラグインを指定できる。
* Mozillaアプリケーションのサイレントインストール時の挙動をINIファイルで指定できる。

## 複数言語のリソースの同梱

メタインストーラは、特定言語向けのリソースを同梱できる。
インストール対象のリソースの言語は以下の順で識別する。

1. すでにインストール済みの対象Mozillaアプリケーションがあり、既定のユーザープロファイルがある場合、その `intl.locale.requested` で第一候補になっている言語を使用する。
2. 既定のユーザープロファイルが見付からないか、`intl.locale.requested` が未設定の場合、対象Mozillaアプリケーションのインストーラーの言語を使用する。
3. Mozillaアプリケーションがまだインストールされていない場合、システムの言語を使用する。
4. いずれの識別にも失敗した場合、`en-US`を使用する。

メタインストーラは、識別した言語に基づいて、同梱したリソースを以下の優先度で使用する。

1. 識別した言語に対応する `resources-(地域コードを含む言語コード)` （例：`resources-ja-JP`）内のファイル
2. 識別した言語に対応する `resources-(言語コード)` （例：`resources-ja`） 内のファイル
3. `resources` 内のファイル

## アドオンのインストールの概要

`resources`フォルダおよび`resources-*`フォルダ内に`*.xpi`ファイルを置くことで、全ユーザ向けにアドオンを
インストールできる。

## それ以外のファイルの自動配置

* `resources`フォルダおよび`resources-*`フォルダ内に特定の名前のファイルを置くと、所定の位置に自動的にインストールされる。
  * *.js, *.jsc   ：初期設定ファイルとして、%AppDir%\defaults\pref\ に
                    インストールされる。
  * *.cfg         ：AutoConfigファイルとして、%AppDir%\ にインストールされる。
  * override.ini  ：%AppDir%\ にインストールされる。
                    （Firefoxの場合は %AppDir%\browser にもインストールされる。）
  * *.properties  ：%AppDir%\ にインストールされる。（*.jsなどからの参照用）
  * distribution.ini, policies.json
                  ：%AppDir%\distribution\ にインストールされる。
  * bookmarks.html：新規プロファイルの初期ブックマークの内容として
                    %AppDir%\defaults\profile\ および
                    %AppDir%\browser\defaults\profile\ にインストールされる。
  * *.rdf         ：新規プロファイルの初期設定として
                    %AppDir%\defaults\profile\ および
                    %AppDir%\browser\defaults\profile\ にインストールされる。
  * *.xml         ：ThunderbirdのAutoConfiguration用設定ファイルとして
                    %AppDir%\isp\ にインストールされる。
  * *.jar         ：Mozillaアプリケーションの追加モジュールとして、
                    %AppDir%\chrome\ にインストールされる。
  * *.manifest    ：Mozillaアプリケーションの追加モジュールの定義ファイルとして、
                    %AppDir%\chrome\ にインストールされる。
  * *.css         ：%AppDir%\chrome\ にインストールされる。（globalChrome.css用）
  * *.ico         ：%AppDir%\chrome\icons\default\ および
                    %AppDir%\browser\chrome\icons\default\main-window.ico
                    にインストールされる。
  * *.cer, *.pem, *.crt, *.der,
    *.cer.override, *.pem.override, *.crt.override, *.der.override
                  ：%AppDir%\defaults\ にインストールされる。（certimporter用）
  * *.permissions ：%AppDir%\defaults\ にインストールされる。
  * *.xpt         ：%AppDir%\components\ にインストールされる。
  * *.dll         ：%AppDir%\plugins\ にインストールされる。
                    （Firefoxの場合は %AppDir%\browser\plugins にも
                      インストールされる。）
  * *.lnk         ：デスクトップ上にインストールされる。
  * *.reg         ：内容がそのまま実行環境のレジストリにインポートされる。
  * *.msi         ：配置はされず、サイレントインストールの形で実行される。
* これら以外の形式のファイルを配置するには、「ExtraFiles」での指定が必要。

ただし、fainstall.iniにおいて、ファイル名に対応するセクションを定義することで、
ファイルのインストール先をカスタマイズすることができる。
各[ファイル名]セクションでは以下のキーを指定できる。

* TargetLocation：（省略可能）
  ファイルのインストール先フォルダのパス。以下のプレースホルダを使用可能。
    %AppDir%  : Firefoxのインストール先フォルダ
    %AppData% : Windowsのアプリケーション情報保存先フォルダ
                （C:\Users\<username>\AppData\Roaming など）
    %Home%    : ユーザのホーム（C:\Users\<username> など）
  省略時は、上記のインストール先にインストールされる。

例えば「templates.xml」をThunderbirdのインストール先の
「\defaults\profile\quicktext\」以下に置きたいのであれば、
以下のように設定する。

```
[templates.xml]
TargetLocation=%AppDir%\defaults\profile\quicktext\
```

## ビルド方法

[README.md](../README.md)を参照。

### 環境設定

Windowsでのみ、メタインストーラの作成および署名に使用するツールの設定が必要となる。
これは config.bat で行う。

NSIS_PATH：
  NSISのインストール先パス。
SIGNTOOL_PATH：
  Microsoft Platform SDKのインストール先パス。
  （署名ツールのみ使用）

SIGN_PFX：
  コードサイニング証明書（*.pfx）が置かれているファイルパス。
  システムのファイルパスで指定。
  無指定またはファイルが存在しない場合、デジタル署名は行われない。
SIGN_PASSWORD：
  コードサイニング証明書を使用するためのパスワード。
SIGN_TIMESTAMP：
  コードサイニング証明書で署名を行うときのタイムスタンプサーバのURI。
SIGN_DESC：（省略可能）
  署名された内容の説明文。
SIGN_DESC_URL：（省略可能）
  署名された内容を説明するWebページのURI。

### 挙動の設定

fainstall.exeの挙動は、以下の2つのファイルにより制御する。

 * config.nsh（ビルド時にのみ使用）
 * fainstall.ini（ビルド後の実行時にのみ使用）

config.nshは、fainstall.exeのビルド時の設定と、一部の挙動の設定を行う。
メタインストーラを作成する場合は、基本的にこの設定ファイルのみを編集する。

config.iniは、fainstall.exeの挙動の設定と、Mozillaアプリケーションの
インストーラの挙動の一部の設定を行う。
fainstall.iniは、config.nshの内容に基づいてビルド時に自動生成される。
生成されたfainstall.iniの設定値を変更したり、設定を追加したりした場合は、
config.nshでの設定よりもfainstall.iniでの設定の方が優先的に適用される。
また、fainstall.iniでのみ設定できる設定項目もある。
よって、config.nshでは設定できない詳細な挙動を設定したい場合や、
再ビルドを行わずに設定を変えたい場合にのみ、fainstall.iniを直接編集
することが推奨される。

以下、各設定ファイルにおける各設定項目と設定キーの対応表を示す。

メタインストーラ自体の設定

| 設定項目＼設定ファイル             | config.nsh              | fainstall.ini                |
|-|-|-|
| サイレントインストールの設定       | PRODUCT_INSTALL_MODE    |                              |
| 長い名前                           | PRODUCT_FULL_NAME       |                              |
| 短い名前                           | PRODUCT_NAME            |                              |
| バージョン                         | PRODUCT_VERSION         | DisplayVersion               |
| 発表年                             | PRODUCT_YEAR            |                              |
| 配布者名                           | PRODUCT_PUBLISHER       |                              |
| 配布元のドメイン名                 | PRODUCT_DOMAIN          |                              |
| WebサイトのURI                     | PRODUCT_WEB_SITE        |                              |
| PRODUCT_WEB_SITEのアンカーテキスト | PRODUCT_WEB_LABEL       |                              |
| 表示言語                           | PRODUCT_LANGUAGE        |                              |
| 管理者権限を要求するかどうか       | REQUIRE_ADMIN           | RequireAdminPrivilege        |
| 管理者かどうかの判定用ディレクトリ | ADMIN_CHECK_DIR         | AdminPrivilegeCheckDirectory |
| 無効化するクライアント             | DISABLED_CLIENTS        | DisabledClients              |
| インストールするアドオン           | INSTALL_ADDONS          | Addons                       |
| 実行する他のインストーラ           | EXTRA_INSTALLERS        | Installers                   |
| 作成するショートカット             | EXTRA_SHORTCUTS         | Shortcuts                    |
| ピン留めされたショートカットの更新 | UPDATE_PINNED_SHORTCUTS | UpdatePinnedShortcuts        |
| 追加でインストールするファイル     | EXTRA_FILES             | ExtraFiles                   |
| 追加で設定するレジストリ情報       | EXTRA_REG_ENTRIES       | ExtraRegistryEntries         |
| 正常終了時メッセージ               | FINISH_MESSAGE          | FinishMessage                |
| 正常終了時タイトル                 | FINISH_TITLE            | FinishTitle                  |
| 再起動確認メッセージ               | CONFIRM_RESTART_MESSAGE | ConfirmRestartMessage        |
| 再起動確認タイトル                 | CONFIRM_RESTART_TITLE   | ConfirmRestartTitle          |
| MSIの実行モード                    | MSI_EXEC_WAIT_MODE      | MSIExecWaitMode              |
| MSIのログ出力                      | MSI_EXEC_LOGGING        | MSIExecLogging               |

Firefox/Thunderbirdのインストールに関する設定

| 設定項目＼設定ファイル             | config.nsh              | fainstall.ini                |
|----------------------------------------|-----------------------------------------|------------------------------------|
| サイレントインストールの設定           | APP_INSTALL_MODE                        |                                    |
| 時行ファイル名                         | APP_EXE                                 |                                    |
| レジストリキー                         | APP_KEY                                 |                                    |
| 対応する最小のバージョン               | APP_MIN_VERSION                         | AppMinVersion                      |
| 対応する最大のバージョン               | APP_MAX_VERSION                         | AppMaxVersion                      |
| 64bit版かどうか                        | APP_IS_64BIT                            | AppIs64bit                         |
| ESR版かどうか                          | APP_IS_ESR                              | AppIsESR                           |
| Developer Editionかどうか              | APP_IS_DEV_EDITION                      | AppIsDevEdition                    |
| 指定の配置先以外も許容するかどうか     | APP_USE_ACTUAL_INSTALL_DIR              | AppUseActualInstallDir             |
| ダウングレードの可否                   | APP_ALLOW_DOWNGRADE                     | AppAllowDowngrade                  |
| ダウングレード後のプロファイル流用可否 | APP_ALLOW_REUSE_PROFILE_AFTER_DOWNGRADE | AppAllowReuseProfileAfterDowngrade |
| インストーラの設置場所のパス           | APP_DOWNLOAD_PATH                       | AppDownloadPath                    |
| インストーラのダウンロード元URL        | APP_DOWNLOAD_URL                        | AppDownloadUrl                     |
| インストーラの検証用ハッシュ値         | APP_HASH                                | AppHash                            |
| 利用許諾書の設置場所のパス             | APP_EULA_PATH                           | AppEulaPath                        |
| 利用許諾書のダウンロード元URL          | APP_EULA_URL                            | AppEulaUrl                         |
| クラッシュ報告機能の有効化             | APP_ENABLE_CRASH_REPORT                 | AppEnableCrashReport               |
| 既定のクライアントに設定する           | DEFAULT_CLIENT                          | DefaultClient                      |
| Firefoxで有効化する検索エンジン        | FX_ENABLED_SEARCH_PLUGINS               | FxEnabledSearchPlugins             |
| Firefoxで無効化する検索エンジン        | FX_DISABLED_SEARCH_PLUGINS              | FxDisabledSearchPlugins            |
| インストール前のクリーンアップ対象     | APP_CLEANUP_DIRS                        | AppCleanupDirs                     |
| クリーンインストールの要求             | CLEAN_INSTALL                           | 以下の4つの設定により変化          |
| クリーンインストール要求メッセージ     | CLEAN_REQUIRED_MESSAGE                  | CleanInstallRequiredMessage        |
| クリーンインストール要求タイトル       | CLEAN_REQUIRED_TITLE                    | CleanInstallRequiredTitle          |
| クリーンインストール推奨メッセージ     | CLEAN_PREFERRED_MESSAGE                 | CleanInstallPreferredMessage       |
| クリーンインストール推奨タイトル       | CLEAN_PREFERRED_TITLE                   | CleanInstallPreferredTitle         |

## メタインストーラ自体の設定項目

### サイレントインストールの設定

*  config.nshでの設定キー   ：PRODUCT_INSTALL_MODE
* 説明                     ：対話モードとサイレントインストールモードを切り替
                             える。
* 取り得る値               ：以下のいずれか1つを選択。
  * "NORMAL"  : 対話モード。通常のウィザードを表示する。
  * "PASSIVE" : 準サイレントインストールモード。
                インストールの進行状況だけを表示する。
                アンインストール時のウィザードは表示しない。
  * "QUIET"   : 完全サイレントインストールモード。
                インストール時もアンインストール時もウィザードを表示しない。
* デフォルト値             ："NORMAL"

### 製品の長い名前

* config.nshでの設定キー   ：PRODUCT_FULL_NAME
* 説明                     ：対話モードのインストールウィザード、およびコント
                           ロールパネルからのアンインストール時に表示される、
                           この製品自体の名称。
* デフォルト値             ："Fx Meta Installer"

### 製品の短い名前

* config.nshでの設定キー   ：PRODUCT_NAME
* 説明                     ：レジストリキー名、最終的に生成されるexeファイル
                           の名前などで利用される、製品の内部名。半角英数字
                           のみの使用を推奨。
* デフォルト値             ："FxMetaInstaller"

### 製品のバージョン

* config.nshでの設定キー   ：PRODUCT_VERSION
* fainstall.iniでの設定キー：[fainstall] > DisplayVersion
* 説明                     ：製品のバージョン番号。"0.0.0.0" 形式で指定。
　                           fainstall.ini でバージョン番号を指定した場合、
　                           Windowsのコントロールパネルのアンインストール対象一覧に
　                           表示されるバージョン番号としてのみ反映される。
　                           （バイナリファイルのメタ情報にはPRODUCT_VERSIONの値が
　                             固定で埋め込まれているため、これは fainstall.ini では
　                             制御できない。）
* デフォルト値             ："0.0.0.0"

### 製品の発表年

* config.nshでの設定キー   ：PRODUCT_YEAR
* 説明                     ：製品の発表年。
* デフォルト値             ："2012"

### 製品の製造・配布元

* config.nshでの設定キー   ：PRODUCT_PUBLISHER
* 説明                     ：製品の製造・配布元の表示名。
* デフォルト値             ："ClearCode Inc."

### 製品の製造・配布元のドメイン

* config.nshでの設定キー   ：PRODUCT_DOMAIN
* 説明                     ：製品の製造・配布元のドメイン名。
* デフォルト値             ："clear-code.com"

### 製品の製造・配布元のWebサイトのURL

* config.nshでの設定キー   ：PRODUCT_WEB_SITE
* 説明                     ：製品の製造・配布元のWebサイトのURI。
* デフォルト値             ："http://www.clear-code.com/"

### 製品の製造・配布元のWebサイトのURLに対するアンカーテキスト

* config.nshでの設定キー   ：PRODUCT_WEB_LABEL
* 説明                     ：対話モードのインストールウィザードに表示されるリ
                           ンク文字列。
* デフォルト値             ："Go to Clear Code Inc."

### インストールウィザードの表示言語
 
* config.nshでの設定キー   ：PRODUCT_LANGUAGE
* 説明                     ：インストールウィザードの言語。
* 取り得る値               ：以下のいずれか1つを選択。
    "Japanese"：日本語
    "English" ：英語
* デフォルト値             ："English"

### 管理者権限を要求するかどうか（省略可能）

* config.nshでの設定キー   ：REQUIRE_ADMIN
* fainstall.iniでの設定キー：[fainstall] > RequireAdminPrivilege
* 説明                     ：インストールに管理者権限を要求するかどうか。
　                           デスクトップ上へのショートカットのインストール
　                           のみを行うなど、管理者権限を必要としない場合は、
　                           明示的に「false」を指定する。
* 取り得る値               ：以下のいずれか1つを選択。
    "true" ：管理者権限を要求する。
    "false"：管理者権限を要求しない。
* デフォルト値             ："true"

### 管理者かどうかの判定用ディレクトリ（省略可能）

* config.nshでの設定キー   ：ADMIN_CHECK_DIR
* fainstall.iniでの設定キー：[fainstall] > AdminPrivilegeCheckDirectory
* 説明                     ：管理者権限の有無を事前に確認する必要がある場合
　                           に、管理者であるかどうかをチェックするために書
　                           き込みを試行するフォルダのパス。
                             ここで指定されたパスのフォルダに書き込み可能な
                             場合、管理者であると判定される。
                             省略時は、何も行わない（管理者権限で実行された
                             ものとみなす）。
* 取り得る値               ：ディレクトリのパス。
* デフォルト値             ：なし。

### 無効化するクライアント（省略可能）

* config.nshでの設定キー   ：DISABLED_CLIENTS
* fainstall.iniでの設定キー：[fainstall] > DisabledClients
* 説明                     ：詳細は「プログラムのアクセスと既定の設定」の変更」
　                           を参照。
* 取り得る値               ：レジストリキー。
* デフォルト値             ：なし。

### 正常終了時メッセージ

* config.nshでの設定キー   ：FINISH_MESSAGE
* fainstall.iniでの設定キー：[fainstlal] > FinishMessage
* 説明                     ：インストール処理が完了した後に表示するメッセージ
　                           ダイアログの内容。「\n」と書くとその位置で改行す
　                           る。
                             省略時は、メッセージダイアログ自体を表示しない。
* 取り得る値               ：文字列。
* デフォルト値             ：なし。

### 正常終了時メッセージのタイトル 

* config.nshでの設定キー   ：FINISH_TITLE
* fainstall.iniでの設定キー：[fainstlal] > FinishTitle
* 説明                     ：インストール処理が完了した後に表示するメッセージ
　                           ダイアログのタイトル。
                             省略時は、メタインストーラのアプリケーション名が
                             タイトルになる。
* 取り得る値               ：文字列。
* デフォルト値             ：メタインストーラのアプリケーション名。 

### 再起動確認メッセージ

* config.nshでの設定キー   ：CONFIRM_RESTART_MESSAGE
* fainstall.iniでの設定キー：[fainstlal] > ConfirmRestartMessage
* 説明                     ：正常終了メッセージの後に表示する、コンピュータの
　                           再起動を促すメッセージダイアログの内容。
　                           「\n」と書くとその位置で改行する。
　                           ダイアログはYes/No形式のボタンを伴って表示され、
　                           Yesが選択されるとコンピュータを即座に再起動する。
                             省略時は、メッセージダイアログ自体を表示しない。
* 取り得る値               ：文字列。
* デフォルト値             ：なし。

### 再起動確認メッセージのタイトル 

* config.nshでの設定キー   ：CONFIRM_RESTART_TITLE
* fainstall.iniでの設定キー：[fainstlal] > ConfirmRestartTitle
* 説明                     ：正常終了メッセージの後に表示する、コンピュータの
　                           再起動を促すメッセージダイアログのタイトル。
                             省略時は、メタインストーラのアプリケーション名が
                             タイトルになる。
* 取り得る値               ：文字列。
* デフォルト値             ：メタインストーラのアプリケーション名。 

### MSIの実行モード

* config.nshでの設定キー   ：MSI_EXEC_WAIT_MODE
* fainstall.iniでの設定キー：[fainstlal] > MSIExecWaitMode
* 説明                     ：MSI形式のインストーラの実行完了を待つ方法の選択。
　                           MSI形式のインストーラを複数含めた場合に、2つ目以降の
　                           インストーラが、他のMSI形式のインストーラのインストーラが
　                           実行中であるとして停止してしまう場合、この設定を
　                           切り替えることで現象を回避できる可能性がある。
* 取り得る値               ：以下のいずれか1つを選択。
   "0"または"ExecWaitJob" : ExecWaitJobを使用。
   "1"または"ExecWait"    : ExecWaitを使用。
   "2"または"nsExec::Exec": nsExec::Execを使用。
* デフォルト値             ：0

### MSIのログ出力

* config.nshでの設定キー   ：MSI_EXEC_LOGGING
* fainstall.iniでの設定キー：[fainstlal] > MSIExecLogging
* 説明                     ：MSI形式のインストーラの実行時に、fainstall.logと同じ位置に
　                           詳細なログを出力するかどうか。
* 取り得る値               ：以下のいずれか1つを選択。
    "true" : ログを出力する。
    "false": ログを出力しない。
* デフォルト値             ：false

### インストール対象のアドオン

* config.nshでの設定キー   ：INSTALL_ADDONS
* fainstall.iniでの設定キー：Addons
* 説明                     ：インストール対象のXPIファイル名のパイプ（|）区切
　                           りのリスト。
                             この値として記述されたXPIファイルが、記述された
                             順番に従ってインストールされる。
                             省略時は、resourcesフォルダおよびresources-*フォルダ
                             内にあるすべてのXPIファイルが順不同でインストールされる。
                             詳細は「同梱アドオンのインストール」を参照。
* 取り得る値               ：ファイル名のリスト。
* デフォルト値             ：なし。

### インストール対象の同梱アプリケーション

* config.nshでの設定キー   ：EXTRA_INSTALLERS
* fainstall.iniでの設定キー：Installers
* 説明                     ：resourcesフォルダまたはresources-*内に置いたインストーラの
　                           EXEファイル名のパイプ（|）区切りのリスト。
                             詳細は「その他の同梱アプリケーションのインストール」を参照。
                             省略時は、何も行わない。
* 取り得る値               ：ファイル名のリスト。
* デフォルト値             ：なし。

### インストール対象の追加のショートカット

* config.nshでの設定キー   ：EXTRA_SHORTCUTS
* fainstall.iniでの設定キー：Shortcuts
* 説明                     ：追加で作成するショートカット定義のリスト。
                             詳細は「ショートカットの作成」を参照。
* 取り得る値               ：ショートカット定義のセクション名のリスト。
* デフォルト値             ：なし。

### ピン留めされたショートカットの更新

* config.nshでの設定キー   ：UPDATE_PINNED_SHORTCUTS
* fainstall.iniでの設定キー：UpdatePinnedShortcuts
* 説明                     ：スタートメニューとタスクバー上に保存された
                             ショートカットの取り扱い。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：新しいショートカットで置き換える。
    "false" ：何もしない。
    "delete"：古いショートカットがあった場合は削除のみ行う。
* デフォルト値             ："false"

### 追加でインストールするファイル

* config.nshでの設定キー   ：EXTRA_FILES
* fainstall.iniでの設定キー：ExtraFiles
* 説明                     ：追加でインストールするファイルの定義のリスト。
                             詳細は「その他のファイルのインストール」を参照。
* 取り得る値               ：ファイルのインストール方法定義のセクション名のリスト。
* デフォルト値             ：なし。

### 追加で設定するレジストリ情報

* config.nshでの設定キー   ：EXTRA_REG_ENTRIES
* fainstall.iniでの設定キー：ExtraRegistryEntries
* 説明                     ：追加で設定するレジストリ情報の定義のリスト。
                             詳細は「任意のレジストリ情報の追加」を参照。
* 取り得る値               ：レジストリ情報の定義のセクション名のリスト。
* デフォルト値             ：なし。


## Mozillaアプリケーション（Firefox、Thunderbird）用の設定項目

### サイレントインストールの設定

* config.nshでの設定キー   ：APP_INSTALL_MODE
* 説明                     ：Mozillaアプリケーションのインストールを自動的に
　                           行うかどうか。
* 取り得る値               ：以下のいずれか1つを選択。
  * "NORMAL" : Mozillaアプリケーションのインストールウィザードを表示する。
  * "QUIET"  : Mozillaアプリケーションのインストーラ自身のインストール
               ウィザードを表示せず、APP_EULA_PATHまたはAPP_EULA_URLによって
               取得した利用許諾書への同意を以てサイレントインストールを行う。
  * "SKIP"   : Mozillaアプリケーションをインストールしない。
  * "EXTRACT" : インストーラをキックせず、ファイルを抽出・配置だけする。
* デフォルト値             ："QUIET"

### Mozillaアプリケーションの名称

* config.nshでの設定キー   ：APP_NAME
* 説明                     ：インストールするMozillaアプリケーションの名称。
* 取り得る値               ：以下のいずれか1つを選択。
    "Firefox"    ：Mozilla Firefox
    "Thunderbird"：Mozilla Thunderbird
* デフォルト値             ：なし。

### 実行ファイル名（省略可能）

* config.nshでの設定キー   ：APP_EXE
* 説明                     ：インストール済みのMozillaアプリケーションの実行
　                           ファイル名。アプリケーションのプロセスの自動終了
　                           などのために使われる。
                             省略時はAPP_NAMEから自動的に推測する。
* デフォルト値             ：APP_NAMEから自動的に推測する。

### レジストリキー（省略可能）

* config.nshでの設定キー   ：APP_KEY
* 説明                     ：インストール済みのMozillaアプリケーションに関す
　                           る情報を収集するレジストリのキー。省略時は
　                           APP_NAMEから自動的に推測する。アンインストール
　                           情報の記録などのために使われる。
                             省略時はAPP_NAMEから自動的に推測する。
* デフォルト値             ：APP_NAMEから自動的に推測する。

### 対応する最小のバージョン  

* config.nshでの設定キー   ：APP_MIN_VERSION
* fainstall.iniでの設定キー：[fainstall] > AppMinVersion
* 説明                     ：Mozillaアプリケーションの最小対応バージョン。
                             アプリケーションがまだインストールされていないか、
                             インストール済みであってもここで指定されたバー
                             ジョンより古い場合、アプリケーション自体の上書き
                             インストール（アップデート）を試みる。
* 取り得る値               ：3.5、4.0、10.0.2など。
* デフォルト値             ：なし。

### 対応する最大のバージョン  

* config.nshでの設定キー   ：APP_MAX_VERSION
* fainstall.iniでの設定キー：[fainstall] > AppMaxVersion
* 説明                     ：Mozillaアプリケーションの最大対応バージョン。
                             アプリケーションがまだインストールされていないか、
                             インストール済みであってもここで指定されたバー
                             ジョンより古い場合、アプリケーション自体の上書き
                             インストール（アップデート）を試みる。
                             逆に、アプリケーションのバージョン番号がここで
                             指定されたバージョンよりも新しい場合、インストー
                             ルを中断する。
* 取り得る値               ：3.5、4.0、10.0.2など。
                             アドオンの最大対応バージョン表記の「2.0.0.*」のよ
                             うなワイルドカードは利用できない。その場合は代わ
                             りとして「2.0.0.99」を用いる。
* デフォルト値             ：なし。

### 64bit版かどうか（省略可能）

* config.nshでの設定キー   ：APP_IS_64BIT
* fainstall.iniでの設定キー：[fainstall] > AppIs64bit
* 説明                     ：インストール対象のFirefoxが64bit版かどうかを示す。
* 取り得る値               ：
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：64bit版を使用。
    "false" ：32bit版を使用。
* デフォルト値             ：false

### ESR版かどうか（省略可能）

* config.nshでの設定キー   ：APP_IS_ESR
* fainstall.iniでの設定キー：[fainstall] > AppIsESR
* 説明                     ：インストール対象のFirefoxがESR版かどうかを示す。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：ESR版を使用。
    "false" ：通常リリース版、もしくはDeveloper Editionを使用。
* デフォルト値             ：false

### Developer Editionかどうか（省略可能）

* config.nshでの設定キー   ：APP_IS_DEV_EDITION
* fainstall.iniでの設定キー：[fainstall] > AppIsDevEdition
* 説明                     ：インストール対象のFirefoxがDeveloper Editionか
                             どうかを示す。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：Developer Editionを使用。
    "false" ：通常リリース版、もしくはESR版を使用。
* デフォルト値             ：false

### 指定の配置先以外も許容するかどうか（省略可能）

* config.nshでの設定キー   ：APP_USE_ACTUAL_INSTALL_DIR
* fainstall.iniでの設定キー：[fainstall] > AppUseActualInstallDir
* 説明                     ：Firefox/Thunderbirdがその環境において
                             Firefox/Thunderbird-setup.iniで指定された位置以外に
                             インストールされていた場合に、そのインストール先で
                             処理を継続するか、指定の配置先へのインストールを
                             強行するかを示す。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：既存のインストール先に上書きインストールする。
    "false" ：指定のインストール先にインストールする。
* デフォルト値             ：false

### ダウングレードの可否（省略可能）

* config.nshでの設定キー   ：APP_ALLOW_DOWNGRADE
* fainstall.iniでの設定キー：[fainstall] > AppAllowDowngurade
* 説明                     ：APP_MAX_VERSIONよりも新しいバージョンがインス
　                           トールされている場合において、Mozillaアプリケー
　                           ション自体の上書きインストール（ダウングレード）
　                           を試みるかどうか。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：既存バージョンより古いバージョンでの上書きインストールを許容する。
    "false" ：既存バージョンより古いバージョンでの上書きインストールを禁止する。
* デフォルト値             ：false

### ダウングレード後のプロファイル流用可否（省略可能）

* config.nshでの設定キー   ：APP_ALLOW_REUSE_PROFILE_AFTER_DOWNGRADE
* fainstall.iniでの設定キー：[fainstall] > AppAllowReuseProfileAfterDowngrade
* 説明                     ：より新しいバージョンのFirefox向けに移行済みの
　                           ユーザープロファイルを、古いバージョンのFirefoxでも
　                           使用することを許容するかどうか。
* 取り得る値               ：以下のいずれか1つを選択。
    "true"  ：ダウングレード後のプロファイルの流用を許可する。
    "false" ：ダウングレード後のプロファイルの流用を禁止する。
* デフォルト値             ：false

### インストーラの設置場所のパス（省略可能）

* config.nshでの設定キー   ：APP_DOWNLOAD_PATH
* fainstall.iniでの設定キー：[fainstall] > AppDownloadPath
* 説明                     ：resourcesおよびresources-*以下にインストーラが
                             同梱されていない場合に使用するインストーラを、
                             システムのファイルパスで指定する。
                             無指定、またはファイルが見つからない場合、
                             APP_DOWNLOAD_URLからのダウンロードを試みる。
* 取り得る値               ：ファイル共有サーバ上のパスまたはローカルのファイ
　                           ルパス。
* デフォルト値             ：なし。

### インストーラのダウンロード元URL（省略可能）

* config.nshでの設定キー   ：APP_DOWNLOAD_URL
* fainstall.iniでの設定キー：[fainstall] > AppDownloadUrl
* 説明                     ：resourcesおよびresources-*以下にインストーラが
                             同梱されておらず、APP_DOWNLOAD_PATHが無指定または
                             ファイルが見つからない場合に、このURLからMozilla
                             アプリケーションのインストーラのダウンロードを試行する。
                             ダウンロードに失敗した場合は、インストールを中断する。
* 取り得る値               ：URL。
* デフォルト値             ：なし。

### インストーラの検証用ハッシュ値（省略可能）

* config.nshでの設定キー   ：APP_HASH
* fainstall.iniでの設定キー：[fainstall] > AppHash
* 説明                     ：APP_DOWNLOAD_URLからダウンロードしたファイルが
　                           正しいものであるかどうかを検証するためのハッシュ
　                           値。
　                           無指定の場合、検証を省略する。
* 取り得る値               ：MD5ハッシュ文字列。
* デフォルト値             ：なし。

### 利用許諾書の設置場所のパス（省略可能）

* config.nshでの設定キー   ：APP_EULA_PATH
* fainstall.iniでの設定キー：[fainstall] > AppEulaPath
* 説明                     ：APP_INSTALL_MODEが"QUIET"の時に表示するMozillaア
　                           プリケーションの利用許諾書（テキストファイル）が、
　                           resourcesおよびresources-*以下にCOPYING.txtとして
　                           同梱されていない場合に使用するファイルを、システムの
　                           ファイルパスで指定する。
                             無指定、またはファイルがそのパスに存在しない場合、
                             APP_EULA_URLからのダウンロードを試みる。
                             サイレントインストールモードでは無視される。
* 取り得る値               ：ファイル共有サーバ上のパスまたはローカルのファイ
　                           ルパス。
* デフォルト値             ：なし。

### 利用許諾書のダウンロード元URL（省略可能）

* config.nshでの設定キー   ：APP_EULA_URL
* fainstall.iniでの設定キー：[fainstall] > AppEulaUrl
* 説明                     ：resourcesおよびresources-*以下にCOPYING.txtが同梱
                             されておらず、
                             APP_EULA_PATHが無指定またはファイルが見つからな
                             い場合に、このURLから利用許諾書のダウンロードを
                             試行する。
                             ダウンロードに失敗した場合は、インストールを中断
                             する。
* 取り得る値               ：URL。
* デフォルト値             ：なし。
### Firefoxで有効化する検索エンジン（省略可能）

* config.nshでの設定キー   ：FX_ENABLED_SEARCH_PLUGINS
* fainstall.iniでの設定キー：[fainstall] > FxEnabledSearchPlugins
* 説明                     ：Firefoxの検索バーで、初期状態で有効にする検索エ
　                           ンジンのファイル名の、半角スペース区切りのリスト。
                             無指定または「*」を指定した場合、すべての検索エン
                             ジンを有効にする。
                             検索エンジンのファイル名を列挙した場合、列挙され
                             なかった検索エンジンは無効化される。
                             ※インストール済み（ユーザプロファイル作成済み）
                             　のFirefoxに対して検索エンジンの変更を行うと、
                             　Firefoxが起動不可能になる場合がある。
                             　新規インストール時のみの利用を強く推奨する。
* 取り得る値               ：GoogleとYahooのみを有効化する場合の例。
　                           "google-jp.xml yahoo-jp.xml"
* デフォルト値             ："*"

### Firefoxで無効化する検索エンジン（省略可能）

* config.nshでの設定キー   ：FX_DISABLED_SEARCH_PLUGINS
* fainstall.iniでの設定キー：[fainstall] > FxDisabledSearchPlugins
* 説明                     ：Firefoxの検索バーで、初期状態で無効にする検索エ
　                           ンジンのファイル名のリスト。
                             無指定の場合、すべての検索エンジンを有効にする。
                             「*」を指定した場合、すべての検索エンジンを無効
                             にする。
                             検索エンジンのファイル名を列挙した場合、列挙され
                             た検索エンジンを無効にする。
                             FX_ENABLED_SEARCH_PLUGINSと併用した場合、
                           　FX_ENABLED_SEARCH_PLUGINSを適用した後に
                           　FX_DISABLED_SEARCH_PLUGINSが適用される。
                             ※インストール済み（ユーザプロファイル作成済み）
                             　のFirefoxに対して検索エンジンの変更を行うと、
                             　Firefoxが起動不可能になる場合がある。
                             　新規インストール時のみの利用を強く推奨する。
* 取り得る値               ：Googleを無効化する場合の例。
　                           "google-jp.xml"
* デフォルト値             ：""
### インストール前のクリーンアップ対象 （省略可能）

* config.nshでの設定キー   ：APP_CLEANUP_DIRS
* fainstall.iniでの設定キー：[fainstall] > AppCleanupDirs
* 説明                     ：インストール処理を始める前にアンインストールするMozillaアプリケーションのインストール先パスのリスト（「|」区切り）。
                             無指定の場合、何もしない。
* 取り得る値               ：C:\Program Files\Mozilla Firefox|C:\Program Files\Nightly
* デフォルト値             ：""
### クリーンインストールの要求（省略可能）

* config.nshでの設定キー   ：CLEAN_INSTALL
* fainstall.iniでの設定キー：なし。ただし、
                             [fainstall] > CleanInstallRequiredMessage
                             [fainstall] > CleanInstallRequiredTitle
                             [fainstall] > CleanInstallPreferredMessage
                             [fainstall] > CleanInstallPreferredTitle
                             の影響を受ける。
* 説明                     ：FirefoxまたはThunderbirdのプロファイルが既に存在
　                           する場合に、インストールを中断するかどうか。
　                           既存の環境を破壊する恐れがあり、既存の環境を維持
　                           することを最重要視する場合に使用する。
* 取り得る値               ：以下のいずれか1つを選択。
    "PREFERRED" : プロファイルが既に存在する場合はインストールを継続するか
                  どうかユーザに確認を求める。ユーザが中断を選択した場合は
                  インストールを中断する。
    "REQUIRED"  : プロファイルが既に存在する場合はインストールを問答無用で
                  中断する。
    それ以外    : 特に何もしない。
* デフォルト値             ：なし。

### クリーンインストール要求メッセージ （省略可能）

* config.nshでの設定キー   ：CLEAN_REQUIRED_MESSAGE
* fainstall.iniでの設定キー：CleanInstallRequiredMessage
* 説明                     ：CLEAN_INSTALL = "REQUIRED" の時に表示するメッセー
　                           ジダイアログの内容。
　                           省略時は、既定のメッセージを表示する。
                             CLEAN_INSTALLがconfig.nshで定義されていない場合
                             でも、このエントリがfainstall.iniにある場合は
                             CLEAN_INSTALL = "REQUIRED" と指定したものとして
                             扱う。
* 取り得る値               ：文字列。
* デフォルト値             ：なし。

### クリーンインストール要求メッセージのタイトル（省略可能）

* config.nshでの設定キー   ：CLEAN_REQUIRED_TITLE
* fainstall.iniでの設定キー：CleanInstallRequiredTitle
* 説明                     ：CLEAN_INSTALL = "REQUIRED" の時に表示するメッセー
　                           ジダイアログのタイトル。
                             省略時は、メタインストーラのアプリケーション名が
                             タイトルになる。
* 取り得る値               ：文字列。
* デフォルト値             ：メタインストーラのアプリケーション名。 
### クリーンインストール推奨メッセージ（省略可能）

* config.nshでの設定キー   ：CLEAN_PREFERRED_MESSAGE
* fainstall.iniでの設定キー：CleanInstallPreferredMessage
* 説明                     ：CLEAN_INSTALL = "PREFERRED" の時に表示するメッセー
　                           ジダイアログの内容。
　                           省略時は、既定のメッセージを表示する。
                             CLEAN_INSTALLがconfig.nshで定義されていない場合
                             でも、このエントリがfainstall.iniにある場合は
                             CLEAN_INSTALL = "PREFERRED" と指定したものとして
                             扱う。
* 取り得る値               ：文字列。
* デフォルト値             ：なし。

### クリーンインストール推奨メッセージのタイトル（省略可能）

* config.nshでの設定キー   ：CLEAN_PREFERRED_TITLE
* fainstall.iniでの設定キー：CleanInstallPreferredTitle
* 説明                     ：CLEAN_INSTALL = "PREFERRED" の時に表示するメッセー
　                           ジダイアログのタイトル。
                             省略時は、メタインストーラのアプリケーション名が
* 取り得る値               ：文字列。
* デフォルト値             ：メタインストーラのアプリケーション名。 

### クラッシュ報告機能の有効化（省略可能）

* config.nshでの設定キー   ：APP_ENABLE_CRASH_REPORT
* fainstall.iniでの設定キー：[fainstall] > AppEnableCrashReport
* 説明                     ：Mozillaアプリケーションをサイレントインストール
　                           する場合に、クラッシュ報告機能を有効にするかどう
　                           か。
* 取り得る値               ：以下のいずれか1つを選択。
    "true" ：クラッシュ報告機能を有効にする。
    "false"：クラッシュ報告機能を無効にする。
* デフォルト値             ："false"

### 既定のクライアントに設定する（省略可能）

* config.nshでの設定キー   ：DEFAULT_CLIENT
* fainstall.iniでの設定キー：[fainstall] > DefaultClient
* 説明                     ：Mozillaアプリケーションを既定のクライアントに
　                           設定するかどうか。
　                           詳細は「Firefoxをコンピュータの既定のブラウザに
　                           設定する/設定しない」を参照。
* 取り得る値               ：レジストリキー。
* デフォルト値             ：なし。


### Mozillaアプリケーションのインストーラの同梱

メタインストーラにMozillaアプリケーションのインストーラを含める場合、
インストーラをresourcesフォルダまたはresources-*フォルダに置く。

メタインストーラは、アプリケーション名（FirefoxまたはThunderbird）と
「setup」の文字列を大文字小文字の違いを問わず両方とも名前に含む実行ファイルを、
Mozillaアプリケーションのインストーラとして自動認識する。
例えば以下のファイル名はすべて有効である。

 * Firefox Setup 32.0.exe
 * Thunderbird Setup 31.1.exe
 * Firefox-setup.exe
 * setup-thunderbird-ja.exe

ファイルをresourcesフォルダおよびresources-*フォルダに含めなかった場合、メタインストーラは設定に従って、
ネットワーク経由でのファイルの取得を試みる。

### MozillaアプリケーションのEULAの同梱

メタインストーラを対話モードでビルドし、かつ、Mozillaアプリケーションを
サイレントインストールする設定にすると、resourcesフォルダまたはresources-*フォルダ内に置かれた
<Mozillaアプリケーション名>-EULA.txt（テキストファイル）の内容が、
インストールウィザードにおいて利用許諾書として表示される。

ファイルをresourcesフォルダまたはresources-*フォルダに含めなかった場合、メタインストーラは設定に従って、
ネットワーク経由でのファイルの取得を試みる。

### COPYING.txt

メタインストーラを対話モードでビルドすると、resourcesフォルダまたはresources-*フォルダ内に置かれた
COPYING.txt（テキストファイル）の内容が、インストールウィザードにおいて
利用許諾書として表示される。

### 同梱アドオンのインストール

resourcesフォルダおよびresources-*フォルダ内に置かれたXPIファイルは、自動的にインストールの対象として
認識される。
インストールするファイルを限定したい場合や、インストールする順番を指定したい
場合には、fainstall.iniの[fainstall]セクションのAddonsにパイプ（|）区切りで
XPIファイルの名前を列挙する。

fainstall.iniにおいて、XPIファイル名に対応するセクションを定義することで、
アドオンのインストール先などの詳細をカスタマイズすることができる。
各[XPIファイル名]セクションでは以下のキーを指定できる。

* AddonId：（省略可能）
  アドオンの内部ID。アドオンのインストール先フォルダに、このID文字列の
  名前でフォルダが作成され、その中にXPIファイルの内容が展開される。
  省略時は
  「<アドオンのファイル名から拡張子を除いた部分>@<PRODUCT_DOMAINの値>」
  として扱われる。
  正しい内部IDを指定ないとアドオンのアンインストールに失敗するので注意。
* TargetLocation：（省略可能）
  * アドオンのインストール先フォルダのパス。以下のプレースホルダを使用可能。
    * %AppDir%  : Firefoxのインストール先フォルダ
    * %AppData% : Windowsのアプリケーション情報保存先フォルダ
                （C:\Users\<username>\AppData\Roaming など）
    * %Home%    : ユーザのホーム（C:\Users\<username> など）
  * 省略時は、Firefox 10よりも前のバージョンでは「%AppDir%\extensions」、
  Firefox 10以降のバージョンでは「%AppDir%\distribution\bundles」として
  扱われる。
* Uninstall：（省略可能）
  * メタインストーラのアンインストール時にアドオンをアンインストールするかどうか。
  trueを指定すると、アドオンもアンインストールする。
  falseを指定すると、アドオンはそのまま残る。
  省略時はtrue。
* Overwrite：（省略可能）
  * すでに前のバージョンのアドオンがインストールされている場合に、古いファイルに
  新しいファイルを上書きするかどうか。
  trueを指定すると、ファイルを上書きする。
  falseを指定すると、既存のファイルをそのまま使う（新しいファイルは使用されない）。
  省略時はtrue。

### ネイティブマニフェストのインストール

アドオンにマニフェストファイルが付属している場合は、`<アドオン名>.<マニフェスト種別>`
というファイル名でresourcesフォルダまたはresources-*フォルダに配置する。すると、インストーラが自動的に
マニフェストの存在を検知し、それぞれのマニフェストを適切な箇所に配置する。

例えば、マネージドストレージを利用する場合は次のようにファイルを配置する：

    resources/
    ├── auto_confirm-0.6.xpi
    └── auto_confirm-0.6.xpi.ManagedStorage

なお、現在サポートしているマニフェスト種別は"ManagedStorage"のみ。

### その他の同梱アプリケーションのインストール

fainstall.iniの[fainstall]セクションのInstallersにパイプ（|）区切りで記述され
た各インストーラ名に対応するセクションを定義することで、EXE形式の
インストーラを起動することができる。

各[インストーラ名]セクションでは以下のキーを指定できる。

Name：（省略可能）
  インストーラのファイル名。省略時はセクション名をそのままファイル名と見なす。
Options：（省略可能）
  インストーラの起動オプション。

例えば「-S」オプションによってサイレントインストールを行うプラグイン
「myplugin1.exe」と「myplugin2.exe」をインストールする場合は、以下の通り。

```
[fainstall]
Installers=myplugin1 myplugin2

[myplugin1]
Name=myplugin1.exe
Options=-S

[myplugin2]
Name=myplugin2.exe
Options=-S
```

### その他のファイルのインストール

fainstall.iniの[fainstall]セクションのExtraFilesにパイプ（|）区切りで
記述されたファイル名に対応するセクションを定義することで、任意の形式の
ファイルを指定したパスにインストールすることができる。(メタインストー
ラが通常インストールすることを想定していない形式のファイルをやむを得ず
インストールしなければならない場合に使用。)

各[ファイル名]セクションでは以下のキーを指定できる。

TargetLocation：（省略不可）
  インストール先のディレクトリ名。

例えば「proxy.pac」をdefaults以下にインストールする場合は、以下の通り。

```
[fainstall]
ExtraFiles=proxy.pac

[proxy.pac]
TargetLocation=%AppDir%/defaults/
```

### 任意のレジストリ情報の追加

fainstall.iniの[fainstall]セクションのExtraRegistryEntriesにパイプ（|）
区切りで記述されたセクション名に対応するセクションを定義することで、任
意のレジストリ情報を追加することができる。(メタインストーラが通常書き込
むことを想定していないレジストリ上の値をやむを得ず書き込まなければなら
ない場合に使用。)

各セクションでは以下のキーを指定できる。

Root:
  書き込み先のメインキー。
  KHCU, HKEY_CURRENT_USER, HKLM, HKEY_LOCAL_MACHINE のいずれか。
  省略時の初期値はHKLM。
Path:（省略不可）
  書き込み先のキーのパス。
DefaultStringData:（DefaultDwordDataとは併用不可）
  既定の値に文字列型として書き込むデータ。
DefaultDwordData:（DefaultStringDataとは併用不可）
  既定の値にDWORD型として書き込むデータ（「0x」から始まる16進数表記）。
StringValueN/StringDataN:
  文字列型の値として設定する値の名前とデータ。
  Nは0から始まる連番。
DwordValueN/DwordDataN:
  DWORD型の値として設定する値の名前とデータ（「0x」から始まる16進数表記）。
  Nは0から始まる連番。

例えばIE用コンテキストメニュー拡張を登録する場合は、以下の通り。

```
[fainstall]
ExtraRegistryEntries=IEContextMenu

[IEContextMenu]
Root=HKCU
Path=Software\Microsoft\Internet Explorer\MenuExt\FireFoxで開く
DefaultStringData=C:\Program Files (x86)\Mozilla Firefox\distribution\OpenFirefox.htm
DwordValue0=Contexts
DwordData0=0x00000033
```

### ショートカットの作成

fainstall.iniの[fainstall]セクションのShortcutsにパイプ（|）区切りで記述され
た各ショートカット名に対応するセクションを定義することで、任意の内容のショート
カットを自動的に生成することができる。

各[ショートカット名]セクションでは以下のキーを指定できる。

* Name：ショートカット名
* Path：
  * ショートカットのリンク先実行ファイルのパス。以下のプレースホルダを使用可能。
    * %AppDir%  : Firefoxのインストール先フォルダ
    * %AppData% : Windowsのアプリケーション情報保存先フォルダ
                （C:\Users\<username>\AppData\Roaming など）
    * %Home%    : ユーザのホーム（C:\Users\<username> など）
* Options：（省略可能）
  * 追加の起動オプション。以下のプレースホルダを使用可能。
    * %AppDir%    : Firefoxのインストール先フォルダ
    * %Home%      : ユーザのホーム（C:\Users\<username> など）
    * %Desktop%   : デスクトップ（C:\Users\<username>\Desktop など）
    * %StartMenu% : スタートメニュー直下
    * %Programs%  : スタートメニュー内の「すべてのプログラム」
    * %StartUp%   : スタートメニュー内の「スタートアップ」
* IconPath：（省略可能）
  * ショートカットのアイコンファイルのパス。
  * 省略時はPath（リンク先実行ファイルのパス）と同じ値が指定されたものとして扱う。
  * 以下のプレースホルダを使用可能。
    * %AppDir%  : Firefoxのインストール先フォルダ
    * %AppData% : Windowsのアプリケーション情報保存先フォルダ
                （C:\Users\<username>\AppData\Roaming など）
    * %Home%    : ユーザのホーム（C:\Users\<username> など）
* IconIndex：（省略可能）
  Pathで示されたファイルにアイコンが複数含まれている場合に、ショートカットの
  アイコンとして使うアイコンの番号を示す。
* TargetUser：（省略可能）
  * ショートカットの作成先ユーザ。以下のいずれかを指定可能。
    * current : 現在のユーザ
    * all     : All Users（パブリック）
* TargetLocation：（省略可能）
  * ショートカットの作成先フォルダのパス。以下のプレースホルダを使用可能。
    * %AppDir%    : Firefoxのインストール先フォルダ
    * %AppData%   : Windowsのアプリケーション情報保存先フォルダ
                  （C:\Users\<username>\AppData\Roaming など）
    * %Home%      : ユーザのホーム（C:\Users\<username> など）
    * %Desktop%   : デスクトップ（C:\Users\<username>\Desktop など）
    * %StartMenu% : スタートメニュー直下
    * %Programs%  : スタートメニュー内の「すべてのプログラム」
    * %StartUp%   : スタートメニュー内の「スタートアップ」
  省略時は「%Desktop%」として扱われる。

例えば、All Users（パブリック）のデスクトップ上にFirefoxのプロファイルマネージャを
起動するショートカットを作成する場合は、以下の通り記述する。
（※非ASCII文字を使う場合、ファイルの文字エンコーディングはShift_JISもしくはUTF-8で保存する必要がある。）

```
[fainstall]
Shortcuts=profile-manager

[profile-manager]
Name=プロファイルマネージャ
Path=%AppDir%\firefox.exe
Options=-p
TargetUser=all
TargetLocation=%Desktop%
```

> **Warning**
> UTF-8の場合BOMつきだとメタインストーラーがFirefox-setup.iniやfainstall.iniの設定をただしく読み込めず、指定通りにショートカットが作成されない。

### Firefoxをコンピュータの既定のブラウザに設定する/設定しない

初期状態では、Firefoxのインストールが完了した後に、Firefoxが自動的にコンピュー
タの既定のブラウザとして設定される。この挙動は、config.nshの「DEFAULT_CLIENT」
またはfainstall.iniの[fainstall]セクション内の「DefaultClient」の値を変更する
ことで制御できる。

 * 現在のブラウザをそのままコンピュータの既定のブラウザとして使い続ける場合：
   設定を削除する、または値を空にする。
 * Firefoxをコンピュータの既定のブラウザに設定する場合： 設定値を「StartMenuInternet\FIREFOX.EXE」にする。
 * それ以外のブラウザをコンピュータの既定のブラウザに設定する場合： 設定値を以下の通り設定する。
   * Internet Explorer：StartMenuInternet\IEXPLORE.EXE
   * Opera            ：StartMenuInternet\Opera.exe
   * Google Chrome    ：StartMenuInternet\Google Chrome
   * Thunderbird      ：Mail\Mozilla Thunderbird

### 「プログラムのアクセスと既定の設定」の変更

Windows XP SP1以降の「プログラムのアクセスと既定の設定」（Windows Vistaの
「プログラムのアクセスとコンピュータの既定の設定」）において、「このプログラ
ムへのアクセスを有効にする」のチェック状態を変更する（チェックボックスをOFF
にし、プログラムへのアクセスを禁止する）ことができる。

この挙動は、config.nshの「DISABLED_CLIENTS」またはfainstall.iniの[fainstall]
セクション内の「DisabledClients」の値を変更することで制御できる。
チェックボックスをOFFにするクライアントに対応する以下のキー名を値として記入
すると、そのクライアントが無効化される。
複数のクライアントを無効化する場合は、キー名を「|（半角パイプ）」で区切って
記述する。

Firefox          ：StartMenuInternet\FIREFOX.EXE
Internet Explorer：StartMenuInternet\IEXPLORE.EXE
Opera            ：StartMenuInternet\Opera.exe
Google Chrome    ：StartMenuInternet\Google Chrome
Thunderbird      ：Mail\Mozilla Thunderbird

### 専用のユーザープロファイルのインストール

fainstall.iniに[profile]セクションを定義すると、インストール時に専用のユーザ
プロファイルを準備することができる。
また、profile.zipというファイルをresourcesフォルダまたはresources-*フォルダ内に配置することで、
その内容をプロファイルの初期状態の内容として利用できる。

[profile]セクションに設定できる情報：
Name：
  プロファイル名。
RootPath：
  プロファイルやプロファイル一覧のINIファイルが置かれるフォルダのパス。
  プレースホルダを使用可能。
  例えば "RootPath=%AppData%\Customized Firefox" と指定した場合、
  プロファイルは以下の位置に作られる。
  %AppData%\Customized Firefox\Profilex\(Name)

### Mozillaアプリケーションのサイレントインストールの挙動の変更

Mozillaアプリケーションをサイレントインストールする際の挙動は、resources
フォルダまたはresources-*フォルダ内に「Firefox-setup.ini」のような名前で置いた
「サイレントインストール用INIファイル」で変更できる。

メタインストーラは、アプリケーション名（FirefoxまたはThunderbird）と
「setup」の文字列を大文字小文字の違いを問わず両方とも名前に含むINIファイルを、
サイレントインストール用INIファイルファイルとして自動認識する。
例えば以下のファイル名はすべて有効である。

 * Firefox Setup 32.0.ini
 * Thunderbird Setup 31.1.ini
 * firefox-setup.ini
 * setup-thunderbird-ja.ini

サイレントインストール用INIファイルは、[Install]セクションで
以下の各キーを指定できる。

* InstallDirectoryName：（省略可能）
  通常、Firefoxは「C:\Program Files\Mozilla Firefox」または
  「C:\Program Files(x86)\Mozilla Firefox」（64bit版Windowsの場合）
  という位置にインストールされるが、この「Mozilla Firefox」部分を
  任意のフォルダ名に変更することができる。
  初期値は「Mozilla Firefox」。
* InstallDirectoryPath：（省略可能）
  Firefoxのインストール先フォルダをフルパスで指定する。
  初期値は無し。
  この指定は、InstallDirectoryNameが空の場合にのみ利用される。
  こちらの指定を優先させる場合、InstallDirectoryNameは明示的に
  空にする必要がある。
  例えば「C:\Firefox」にインストールさせる場合は以下のように記述する。
  > InstallDirectoryName=
  > InstallDirectoryPath=C:\Firefox
* ShortcutName：
  生成あるいは削除の対象とするショートカットの名称。
  （FirefoxおよびThunderbirdでは、ショートカット名は固定されており
  　この設定は機能しない）
* DesktopShortcut：（省略可能）
  デスクトップ上にショートカットを作成するかどうかを指定する。
  true：デスクトップに項目を追加する。
  false：デスクトップに項目を追加しない。
  省略時はtrueとして扱う。
  （FirefixおよびThunderbirdでは、ショートカット名は固定されている）
* StartMenuShortcuts：（省略可能）
  スタートメニューの「すべてのプログラム」内にショートカットを作成するか
  どうかを指定する。
  true：スタートメニューに項目を追加する。
  false：スタートメニューに項目を追加しない。
  省略時はtrueとして扱う。
  （FirefixおよびThunderbirdでは、ショートカット名は固定されている）
* StartMenuDirectoryName：
  スタートメニューの「すべてのプログラム」内に作成される、Firefoxの
  通常起動用のショートカットとセーフモード用のショートカットを格納する
  フォルダの名前を指定する。
  初期値は「Mozilla Firefox」。
  StartMenuShortcutsがfalseである場合は、削除対象とするサブメニューの
  名称として解釈する。
  （この指定はFirefox 3.6以前でのみ利用できる。Firefox 4以降ではスタート
  　メニューにショートカットのフォルダを作成しないようになったため、
  　この指定は単に無視される。）
* QuickLaunchShortcut：（省略可能）
  Windows Vista以前のWindowsにおいて、クイック起動のショートカットを
  作成するかどうかを指定する。
  true：クイックランチにショートカットを作成する。
  false：クイックランチにショートカットを作成しない。
  省略時はtrueとして扱う。
  （Windows 7以降ではクイック起動の機能自体が存在しなくなっているため、
  　指定は単に無視される。）
* QuickLaunchShortcutAllUsers：（省略可能）
  クイックランチへのショートカットの変更をすべてのユーザに適用するかどうか。
  true：全ユーザのクイックランチに適用する。
  false：現在のユーザのクイックランチにのみ適用する。
  省略時はfalseとして扱う。
* MaintenanceService：（省略可能）
  Mozilla Maintenance Serviceのインストールを行うかどうか。
  true：インストールする。
  false：インストールしない。
  省略時はtrueとして扱う。

クラッシュ報告機能の有効・無効、特定の検索プラグインのみの有効化・特定の
検索プラグインのみの無効化は、config.nshまたはfainstall.iniにて設定する。
これらについては「Mozillaアプリケーション（Firefox、Thunderbird）用の設定項目」
の項を参照。

DOM Inspectorのインストールの可否は設定できず、常にインストールしない。


