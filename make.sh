#!/bin/sh
# Copyright (C) 2008-2009 ClearCode Inc.

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

mv fainstall.exe "./$installer_name-source/"
mv fainstall.ini "./$installer_name-source/"

run tar -c -f- -X _excludes.txt -C resources . | tar -x -C "./$installer_name-source/resources"
cp ./7z/pack.list "./$installer_name-source/"
cat ./7z/7zS.sfx ./7z/FxAddonInstaller.tag > "./$installer_name-source/fainstall.sfx"
cp ./7z/7zr.exe "./$installer_name-source/"
cp ./7z/pack.bat "./$installer_name-source/$installer_name.bat"
#cd "$installer_name-source"
#
#call "$installer_name.bat
#
#cd ..
