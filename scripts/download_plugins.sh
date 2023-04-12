#!/bin/bash
# Copyright (C) 2017-2023 ClearCode Inc.

set -e

URI="
https://nsis.sourceforge.io/mediawiki/images/3/3c/FindProc.zip
https://github.com/DigitalMediaServer/NSIS-INetC-plugin/releases/download/v1.0.5.7/InetC.zip
https://nsis.sourceforge.io/mediawiki/images/d/d9/ZipDLL.zip
https://nsis.sourceforge.io/mediawiki/images/b/b3/CustomLicense.zip
https://nsis.sourceforge.io/mediawiki/images/5/55/Xml.zip
https://nsis.sourceforge.io/mediawiki/images/d/d7/Md5dll.zip
https://nsis.sourceforge.io/mediawiki/images/8/8f/UAC.zip
https://nsis.sourceforge.io/mediawiki/images/4/4a/AccessControl.zip
https://nsis.sourceforge.io/mediawiki/images/0/08/UserMgr.zip
https://nsis.sourceforge.io/mediawiki/images/d/d1/LogEx.zip
https://nsis.sourceforge.io/mediawiki/images/9/97/NsArray.zip
"

mkdir -p plugins

for url in $URI; do
    zip=$(basename $url)
    if [ ! -f plugins/$zip ]; then
	wget --quiet $url -O plugins/$zip
    fi
done
if [ "$1" = "install" ]; then
    cd plugins
    ls *.zip | sed -e 's/\.zip$//' | xargs -I{} unzip -u {}.zip -d {}
    find . -name "*.dll" | grep -E -v -i "ansi|x64" | sudo xargs mv -n -t /usr/share/nsis/Plugins/x86-unicode/
    find . -name "*.dll" | grep -E -v -i "unicode|x64" | sudo xargs mv -n -t /usr/share/nsis/Plugins/x86-ansi/
    find . -name "*.dll" | grep -E -v -i "x86|i386" | sudo xargs mv -n -t /usr/share/nsis/Plugins/amd64-unicode/
    find . -name "*.nsh" | sudo xargs mv -t /usr/share/nsis/Include/
fi

