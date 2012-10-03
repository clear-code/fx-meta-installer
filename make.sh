#!/bin/bash
# Copyright (C) 2008-2012 ClearCode Inc.

if [ ! -d ./resources ]
then
  mkdir resources
  cp _resources/*.sample resources/
fi


if [ ! -f ./config.bat ]
then
  cp ./config.bat.sample ./config.bat
fi

if [ ! -f ./config.nsh ]
then
  cp ./config.nsh.sample ./config.nsh
fi

sed='sed -r -e'

installer_name=`grep 'INSTALLER_NAME=' config.bat | $sed 's/[^=]+=|[ \t\r\n]+$//g'`
echo installer_name

rm fainstall.exe
rm fainstall.ini
rm "$installer_name.exe"

# build NSIS

cd nsis

inifile=../fainstall.ini

read_config() {
  cat ../config.nsh | grep -v -E "^;" | grep $1 | cut -d '"' -f 2
}

cat > $inifile << EOS
[fainstall]
AppMaxVersion=$(read_config "APP_MAX_VERSION")
AppMinVersion=$(read_config "APP_MIN_VERSION")
AppDownloadPath=$(read_config "APP_DOWNLOAD_PATH")
AppDownloadUrl=$(read_config "APP_DOWNLOAD_URL")
AppEulaPath=$(read_config "APP_EULA_PATH")
AppEulaUrl=$(read_config "APP_EULA_URL")
AppHash=$(read_config "APP_HASH")
AppEnableCrashReport=true

EOS

for filename in ../resources/*.xpi
do
  echo reading $filename
  echo $filename | $sed 's/.+\/([^\/]+)$/[\1]/' >> $inifile
  install_rdf=`unzip -p $filename install.rdf`
  echo AddonId=`echo $install_rdf | $sed 's/.*em:id="([^"]+)".*(em:name|<em:targetApplication>).*/\1/'` >> $inifile
  echo '' >> $inifile
done

makensis fainstall.nsi
cd ..


# create package sources

rm -r "$installer_name-source"
mkdir "$installer_name-source"
mkdir "$installer_name-source/resources"

mv fainstall.exe "./$installer_name-source/"
mv fainstall.ini "./$installer_name-source/"

tar -c -f- --exclude-vcs -C resources . | tar -x -C "./$installer_name-source/resources"
cp ./7z/pack.list "./$installer_name-source/"
cat ./7z/7zS.sfx ./7z/FxAddonInstaller.tag > "./$installer_name-source/fainstall.sfx"
cp ./7z/7zr.exe "./$installer_name-source/"
cp ./7z/pack.bat "./$installer_name-source/$installer_name.bat"
cp ./7z/pack.sh "./$installer_name-source/$installer_name.sh"
cd "$installer_name-source"

# bash ./$installer_name.sh

cd ..

