#!/bin/bash
# Copyright (C) 2017-2018 ClearCode Inc.

set -e

URI="
https://nsis.sourceforge.io/mediawiki/images/3/3c/FindProc.zip
https://nsis.sourceforge.io/mediawiki/images/c/c9/Inetc.zip
https://nsis.sourceforge.io/mediawiki/images/d/d9/ZipDLL.zip
https://nsis.sourceforge.io/mediawiki/images/b/b3/CustomLicense.zip
https://nsis.sourceforge.io/mediawiki/images/5/55/Xml.zip
https://nsis.sourceforge.io/mediawiki/images/d/d7/Md5dll.zip
https://nsis.sourceforge.io/mediawiki/images/8/8f/UAC.zip
https://nsis.sourceforge.io/mediawiki/images/4/4a/AccessControl.zip
https://nsis.sourceforge.io/mediawiki/images/0/08/UserMgr.zip
https://nsis.sourceforge.io/mediawiki/images/d/d1/LogEx.zip
https://nsis.sourceforge.io/mediawiki/images/4/44/NSISArray.zip
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
    ls *.zip | sed -e 's/\.zip$//' | xargs -i unzip -u {}.zip -d {}
    find . -name "*.dll" | grep -v -i "unicode" | sudo xargs mv -t /usr/share/nsis/Plugins/
    find . -name "*.nsh" | sudo xargs mv -t /usr/share/nsis/Include/
fi

