=== コンパイル手順

* NSISをインストール．
  http://nsis.sourceforge.net/Main_Page

* FindProcDLLプラグインをインストール．
  http://nsis.sourceforge.net/FindProcDLL_plug-in
  *.dllをNSISインストール先のPluginsフォルダに移動

* InetLoadプラグインをインストール．
  http://nsis.sourceforge.net/InetLoad_plug-in
  *.dllをNSISインストール先のPluginsフォルダに移動

* ZipDLLプラグインをインストール．
  http://nsis.sourceforge.net/ZipDLL_plug-in
  *.dllをNSISインストール先のPluginsフォルダに移動
  *.nshをNSISインストール先のIncludeフォルダに移動

* CustomLicenseプラグインをインストール．
  http://nsis.sourceforge.net/CustomLicense_plug-in
  Plugin\*.dllをNSISインストール先のPluginsフォルダに移動

* XMLプラグインをインストール．
  http://nsis.sourceforge.net/XML_plug-in
  Plugin\*.dllをNSISインストール先のPluginsフォルダに移動
  Include\*.nshをNSISインストール先のIncludeフォルダに移動

* MD5プラグインをインストール．
  http://nsis.sourceforge.net/MD5_plugin
  *.dllをNSISインストール先のPluginsフォルダに移動

// * Cryptoプラグインをインストール．
//  http://nsis.sourceforge.net/Crypto_plug-in
//  cryptoplg11.zipを展開し、インストーラを実行

* UACプラグインをインストール．
  http://nsis.sourceforge.net/UAC_plug-in
  Release/*.dllをNSISインストール先のPluginsフォルダに移動

* 7-Zipをインストール．
  http://www.7-zip.org/ja/

* addons以下にxpiを置く（複数可）．

* 以下のファイルをサンプルを元に適切に作成、内容を設定．
  config.bat
  config.nsh

* make.batを実行して、インストーラを生成

* たぶん完成


=== 注意事項

* いくつか恥ずかしい罠あり

* 7z内の7zSD.sfx/7zS.sfx（自己解凍書庫作成用のリソース）は
  http://www.7-zip.org/ja/download.html の
  「7z Library, SFXs for installers, Plugin for FAR Manager」
  とあるファイルの中に含まれている。
  更新する場合は、新しい7zSD.sfx/7zS.sfxで上書きした後、IconReset
  （ http://www.geocities.jp/iconsetjp/ ）などの実行ファイルの
  アイコンリソースを差し替えられるツールを用いて、内蔵のアイコン
  リソースをnsis内のfainstall.icoまたはこれと同等の物に差し替える。
