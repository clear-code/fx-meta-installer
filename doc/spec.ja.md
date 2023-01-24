 1. Firefoxが起動しているかどうかをチェック。
    起動している場合は「Firefoxを終了してから実行してください」のような
    エラーメッセージを出して終了。
 2. ウィザードを表示。「XXXのインストールを開始します」的な
    メッセージを表示。
 3. レジストリを見て、Firefoxがインストールされているかどうかを
    チェック。インストールされている場合は 9. へジャンプ。
 4. Mozilla JapanサイトからFirefoxのインストーラをダウンロード。
    ダウンロード元は以下のURL。（バージョン番号はインストーラ用
    iniファイルで指定し、バージョン固定とする）
    http://download.mozilla.org/?product=firefox-2.0.0.11&os=win&lang=ja
 5. ダウンロードに失敗した場合は「ダウンロードに失敗しました。
    インターネットに接続されていることを確認してからやり直して
    ください。」のようなエラーメッセージを出して終了。
 6. ダウンロードされたインストーラのexeファイルを実行。
 7. Firefoxのインストーラが終了したことを検知。
 8. Firefoxが正常にインストールされなかった場合は「Firefoxが
    インストールされませんでした。XXXのインストールを中断します。
    XXXの利用にはFirefoxのインストールが必要です。もう一度
    インストールをやり直してください。」のようなエラーメッセージを
    出して終了。
 9. レジストリからFirefoxのインストール先一覧を取得。
10. 取得したFirefoxインストール先のextensionsフォルダに
    アドオンのファイルをコピー。（xpiではダメかも。ここで展開するか、
    展開済みのものをインストーラに入れておく？）
11. コピーしたアドオンのファイルについてアンインストール情報を登録。
    （Firefox自体についてはFirefoxのインストーラに任せる）
12. 4. 〜 7. で新規にFirefoxをインストールした場合、
    「今すぐFirefoxを起動する」チェックボックスを有効にする。
    既にFirefoxが入っていて、複数のインストール先が検出された場合、
    チェックボックス自体を出さないか無効にするという風にしたい。
13. 12. でチェックが入っていた場合、Firefoxを起動。
14. インストーラ終了。


Firefoxのインストールプロセスを完全に自動化する場合、5. と 6. 、
6. と 7. の間にそれぞれ以下の処理を入れることになると思われます。


 5.1. EULA表示。
 5.2. Firefoxのインストール先を指定。（標準/自分で指定）
 5.3. 5.2. でカスタムインストールを選択された場合、同時に
      インストールするアドオンを選択。（DOM Inspector、Talkback）
 5.4. 選択の結果をテンポラリファイルに保存。


 6.1. インストーラに添付された自動インストールアプリケーションを実行。
 6.2. 自動インストールアプリケーションが 5.4. で作成されたファイルを
      読み込む。
 6.3. 6.2. で読み込んだ内容に基づいて、自動インストール
      アプリケーションがFirefoxインストーラのダイアログを自動操作。
      最後の「Firefoxを今すぐ起動」のチェックだけは常にOFFにする。
 6.4. 自動インストールアプリケーション終了。


まずインストールプロセスの完全自動化を行わない方で開発を進めて、
その後様子を見て完全自動化プロセスを追加実装する
というのが良いのではないかと思っています。