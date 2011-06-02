#!/bin/sh
# Copyright (C) 2008-2010 ClearCode Inc.

if [ ! -d ./resources ]
then
  mkdir resources
  cp _resources/*.sample resources/
fi


if [ ! -f ./config.bat ]
then
  exit
fi


installer_name=`grep 'INSTALLER_NAME=' config.bat | sed -r -e 's/[^=]+=|[ \t\r\n]+$//g'`
echo installer_name

rm fainstall.exe
rm fainstall.ini
rm "$installer_name.exe"

# build NSIS

cd nsis

inifile=../fainstall.ini

cat > $inifile << EOS
[fainstall]
AppDownloadPath=
AppDownloadUrl=
AppEulaPath=
AppEulaUrl=
AppHash=
AppInstallTalkback=true

EOS

for filename in ../resources/*.xpi
do
  echo reading $filename
  echo $filename | sed -r -e 's/.+\/([^\/]+)$/[\1]/' >> $inifile
  install_rdf=`unzip -p $filename install.rdf`
  echo AddonId=`echo $install_rdf | sed -r -e 's/.*em:id="([^"]+)".*(em:name|<em:targetApplication>).*/\1/'` >> $inifile
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

bash ./$installer_name.sh

cd ..

