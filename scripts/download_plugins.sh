#!/bin/bash
# Copyright (C) 2017 ClearCode Inc.

set -e

URI="
http://nsis.sourceforge.net/mediawiki/images/3/3c/FindProc.zip
http://nsis.sourceforge.net/mediawiki/images/b/b4/InetLoad.zip
http://nsis.sourceforge.net/mediawiki/images/d/d9/ZipDLL.zip
http://nsis.sourceforge.net/mediawiki/images/b/b3/CustomLicense.zip
http://nsis.sourceforge.net/mediawiki/images/5/55/Xml.zip
http://nsis.sourceforge.net/mediawiki/images/d/d7/Md5dll.zip
http://nsis.sourceforge.net/mediawiki/images/8/8f/UAC.zip
http://nsis.sourceforge.net/mediawiki/images/4/4a/AccessControl.zip
http://nsis.sourceforge.net/mediawiki/images/0/08/UserMgr.zip
http://nsis.sourceforge.net/mediawiki/images/d/d1/LogEx.zip
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

