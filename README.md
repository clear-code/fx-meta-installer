# Fx Meta Installer

## Abstract

This installs Firefox or Thunderbird automatically and configure installed
instance as you like. This helps that you distribute customized Firefox or
Thunderbird to PCs in a specific organization.

To use this, you need to do following steps:

 1. Setup your environment to build NSIS binary.
 2. Prepare configuration files and resouces (addons, CSS files, etc.) to
    include the final installer package.
 3. Build the binary of Fx Meta Instlaler (fainstall) and the final installer
    package.

### Required Plugins

Fx Meta Installer is written as a NSIS script, and depends on these plugins.

 * [FindProcDLL](http://nsis.sourceforge.net/FindProcDLL_plug-in)
 * [InetLoad](http://nsis.sourceforge.net/InetLoad_plug-in)
 * [ZipDLL](http://nsis.sourceforge.net/ZipDLL_plug-in)
 * [CustomLicense](http://nsis.sourceforge.net/CustomLicense_plug-in)
 * [XML](http://nsis.sourceforge.net/XML_plug-in)
 * [MD5](http://nsis.sourceforge.net/MD5_plugin)
 * [UAC](http://nsis.sourceforge.net/UAC_plug-in)
 * [AccessControl](http://nsis.sourceforge.net/AccessControl_plug-in)
 * [UserMgr](http://nsis.sourceforge.net/UserMgr_plug-in)
 * [LogEx](http://nsis.sourceforge.net/LogEx_plug-in)

## How to build

### Setup to build NSIS binary

Fx Meta Installer is written as a NSIS script. You need to setup build
environments at first.

#### Windows

 1. Download the installer v2.46 and instlal it.
    See [NSIS wiki](http://nsis.sourceforge.net/Main_Page).
    (If you want to debug Fx Meta Installer with detailed logs, you should use
    the "advanced logging" build of the NSIS.
    See [Special Builds](http://nsis.sourceforge.net/Special_Builds).)
 2. Install plugins. Download zip files, decompress them,
    move "*.dll" files to "c:\Program Files\NSIS\Plugins\", and
    move "*.nsh" files to "c:\Program Files\NSIS\Include\".

#### Linux (Debian, Ubuntu)

 1. Install required packages "nsis", "pwgen" and "uuid-runtime".

        $ sudo apt-get install nsis pwgen uuid-runtime

 2. Install plugins. Download zip files, decompress them,
    move "*.dll" files to "/usr/share/nsis/Plugins/", and
    move "*.nsh" files to "/usr/share/nsis/Include".
    For example:

        $ ls *.zip | sed -e 's/\.zip$//' | xargs -i unzip {}.zip -d {}
        $ find . -name "*.dll" | grep -v -i "unicode" | sudo xargs mv -t /usr/share/nsis/Plugins/
        $ find . -name "*.nsh" | sudo xargs mv -t /usr/share/nsis/Include/

#### OS X (Homebrew)

 1. Install required a package "nsis".

        $ brew install makensis

 2. Install plugins. Download zip files, decompress them,
    move "*.dll" files to "/usr/local/share/nsis/Plugins/", and
    move "*.nsh" files to "/usr/local/share/nsis/Include".
    For example:

        $ unzip *.zip
        $ find . -name "*.dll" | grep -v -i "unicode" | xargs -J % mv % /usr/local/share/nsis/Plugins/
        $ find . -name "*.nsh" | xargs -J % mv % /usr/local/share/nsis/Include/

 3. install GNU origin commands.

        $ brew install gnu-tar coreutils

### Preparing configuration files and resources

 1. Copy "config.bat.sample" to "config.bat", and
    copy "config.nsh.sample" to "config.nsh".
 2. Modify both files as you like.
 3. Put .xpi, .css, .js, .cfg, .exe, and other resources to the directory
    "resources".

### Build the binary

 1. Run "make.bat" (Windows) or "make.sh" (Linux).
 2. Then, the kit to generate the final installer executable is saved as
    a new directory "FxMetaInstaller-source".
 3. Copy the directory "FxMetaInstaller-source" to a local disk of Windows
    environment.
 4. Confirm files in the "resources" directory and the "fainstall.ini".
    If there is no problem, run the batch file "FxMetaInstaller.bat".
    Then, the final installer executable "FxMetaInstaller.exe" is generated.

## Notes for developers

### About MSI (Microsoft Windows Installer)

MSI doesn't cover full features of NSIS, so we cannot convert Fx Meta
Installer from .exe to .msi. However, [you can run NSIS .exe files from
.msi.](http://wiki.team-mediaportal.com/1_MEDIAPORTAL_1/18_Contribute/6_Plugins/MPEMaker/How_to_include_an_NSIS_or_an_MSI_installer)

### How to change icons? / How to update 7-Zip self-extraction module?

This repository includes binaries of 7-Zip self extraction: 7zSD.sfx and
7zS.sfx. You can update them by following steps:

 1. Download new self extraction binaries (7zSD.sfx and 7zS.sfx).
    Go to the [download page in the 7-Zip project site](http://www.7-zip.org/download.html)
    and extract binaries.
 2. Replace old .sfx files with new one.
 3. Replace icon resources in those .sfx files with fainstal.ico, by
    [IconReset](http://www.geocities.jp/iconsetjp/) or similar tool.


## Legal notes

### 最終生成物のライセンス

Fx Meta Installerによって生成された、インストールを行うモジュール（fainstall.exe）は、無保証にて自由に利用できます。

fainstall.exeを含める形で作成した最終生成物の実行ファイル（以下、メタインストーラ）の使用および利用の許諾条件は、そのメタインストーラによってインストールされるソフトウェアの使用および利用の許諾条件に依存します。例えば、以下のような制限があり得ます。

 * 同梱したアドオンやプラグインの利用許諾条件として、非営利での利用が必須条件となっている場合、メタインストーラを有償で販売することはできません。
 * Firefoxを自動的にインストールするように設定した場合、メタインストーラを不特定多数に向けて無断で一般公開することはできません。一般公開のためにはMozillaの許諾を得る必要があります。詳しくは[法人向けFAQの「製品をカスタマイズして配布しても構わないのですか？」の項](http://www.mozilla.jp/business/faq/#sec-licensing)を参照して下さい。
   （なお、公式のFirefoxのバイナリではなく、Firefoxのロゴなどを含まない独自ビルドのバイナリであれば、この限りではありません。）
