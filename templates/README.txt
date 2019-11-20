# How to create installer package

1. Copy all files under a local storage of your Windows PC.
   You cannot create an installer package when files are placed on a location with a UNC path like `\\hostname\...`.
2. Download Firefox's full installer from https://releases.mozilla.org （e.g. https://releases.mozilla.org/pub/firefox/releases/%VERSION%%ESR_SUFFIX%/win%BINARY_BITS%/en-US/Firefox%20Setup%20%VERSION%%ESR_SUFFIX%.exe ) and put it under the `resources` directory.
   Please note that you must use an installer matching to definitions of `AppMinVersion`/`AppMaxVersion`, `AppIs64bit`, and `AppIsESR` in the `fainstall.ini`.
3. Run `%INSTALLER_NAME%.bat`.
4. Distribute built `%INSTALLER_NAME%-(version).exe` to client PCs and run at there.


# インストーラーの作成手順

1. 全ての構成ファイルをWindows PCのローカルストレージ上に置きます。
   `\\hostname\...` のようなUNCパスで表される位置にファイルがあるとインストーラーを作成できませんので注意して下さい。
2. Firefoxのフルインストーラを https://releases.mozilla.org からダウンロードし（例： https://releases.mozilla.org/pub/firefox/releases/%VERSION%%ESR_SUFFIX%/win%BINARY_BITS%/ja/Firefox%20Setup%20%VERSION%%ESR_SUFFIX%.exe ）、`resources` ディレクトリ内に置きます。
   `fainstall.ini` に記載された情報（`AppMinVersion`/`AppMaxVersion`、`AppIs64bit`、`AppIsESR`）に合致するインストーラを使う必要がある事に注意して下さい。
3. `%INSTALLER_NAME%.bat` を実行します。
4. 作成された `%INSTALLER_NAME%-(バージョン).exe` をクライアントPCに配布して実行します。
