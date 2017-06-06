#!/bin/bash
# Copyright (C) 2008-2016 ClearCode Inc.

if [ ! -d ./resources ]
then
  mkdir resources
  cp _resources/*.sample resources/
  cd resources
  for file in *.sample; do
    echo $file
    echo ${file%.sample}
    mv $file ${file%.sample};
  done
  cd ..
fi


if [ ! -f ./config.bat ]
then
  cp ./config.bat.sample ./config.bat
fi

if [ ! -f ./config.nsh ]
then
  cp ./config.nsh.sample ./config.nsh
fi

case $(uname) in
  Darwin|*BSD) sed="sed -E -e" ;;
  *)           sed="sed -r -e" ;;
esac

case $(uname) in
  Darwin|*BSD) tar="gtar" ;;
  *)           tar="tar" ;;
esac

product_name=`grep --binary-files=text 'PRODUCT_NAME' config.nsh | $sed 's/^[^"]*"//' | $sed 's/".*$\r?\n?//'`
echo $product_name

rm fainstall.exe
rm fainstall.ini
rm "$product_name.exe"
rm "$product_name-*.exe"

# build NSIS

cd nsis

inifile=../fainstall.ini

read_config() {
  cat ../config.nsh | grep -v -E "^;" | grep $1 | cut -d '"' -f 2
}

read_boolean_config() {
  found=$(cat ../config.nsh | grep -v -E "^;" | grep $1)
  if [ "$found" = "" ]
  then
    echo -n "false"
  else
    echo -n "true"
  fi
}

cat > $inifile << EOS
[fainstall]
AppMinVersion=$(read_config "APP_MIN_VERSION")
AppMaxVersion=$(read_config "APP_MAX_VERSION")
AppDownloadPath=$(read_config "APP_DOWNLOAD_PATH")
AppDownloadUrl=$(read_config "APP_DOWNLOAD_URL")
AppEulaPath=$(read_config "APP_EULA_PATH")
AppEulaUrl=$(read_config "APP_EULA_URL")
AppHash=$(read_config "APP_HASH")
AppEnableCrashReport=$(read_boolean_config "APP_ENABLE_CRASH_REPORT")
AppAllowDowngrade=$(read_boolean_config "APP_ALLOW_DOWNGRADE")
FinishTitle=$(read_config "FINISH_TITLE")
FinishMessage=$(read_config "FINISH_MESSAGE")
CleanInstallPreferredTitle=$(read_config "CLEAN_PREFERRED_TITLE")
CleanInstallPreferredMessage=$(read_config "CLEAN_PREFERRED_MESSAGE")
CleanInstallRequiredTitle=$(read_config "CLEAN_REQUIRED_TITLE")
CleanInstallRequiredMessage=$(read_config "CLEAN_REQUIRED_MESSAGE")
RequireAdminPrivilege=$(read_config "REQUIRE_ADMIN_PRIVILEGE$")
AdminPrivilegeCheckDirectory=$(read_config "ADMIN_PRIVILEGE_CHECK_DIR")
DefaultClient=$(read_config "DEFAULT_CLIENT$")
DisabledClients=$(read_config "DISABLED_CLIENTS")
Addons=<addon_files>
Installers=$(read_config "EXTRA_INSTALLERS")
Shortcuts=$(read_config "EXTRA_SHORTCUTS")
FxEnabledSearchPlugins=$(read_config "FX_ENABLED_SEARCH_PLUGINS")
FxDisabledSearchPlugins=$(read_config "FX_DISABLEd_SEARCH_PLUGINS")
;AppIsESR=true

EOS

addon_files=""
for filename in ../resources/*.xpi
do
  if [ -f $filename ]
  then
    echo reading $filename
    addon_file=$(echo $filename | $sed 's/.+\/([^\/]+)$/\1/')
    addon_files="$addon_files|$addon_file"
    echo "[$addon_file]" >> $inifile
    install_rdf=`unzip -p $filename install.rdf`
    addon_id=`echo $install_rdf | $sed "s%(em:id=['\"]|<em:id>)([^'\"<]+).*%\1\2%g" | $sed "s%.*(em:id=['\"]|<em:id>)%%"`
    echo "id = $addon_id"
    echo "AddonId=$addon_id" >> $inifile
    echo "TargetLocation=%AppDir%/browser/extensions" >> $inifile
    echo "Unpack=false" >> $inifile
    echo "" >> $inifile
  fi
done

addon_files=$(echo "$addon_files" | $sed 's/^\|//')

given_addon_files=$(read_config "INSTALL_ADDONS")
if [ -n "${given_addon_files}" ]
then
  addon_files=$given_addon_files
fi

$sed "s/<addon_files>/$addon_files/" -i $inifile


makensis fainstall.nsi
cd ..

if [ ! -f ./fainstall.exe ]
then
  echo -e "\033[1;31mFailed to build fainstall.exe!\033[0m"
  exit 1
fi


# create package sources

rm -r "$product_name-source"
mkdir "$product_name-source"
mkdir "$product_name-source/resources"

mv fainstall.exe "./$product_name-source/"
mv fainstall.ini "./$product_name-source/"

$tar -c -f- --exclude-vcs -C resources . | $tar -x -C "./$product_name-source/resources"
cp ./7z/pack.list "./$product_name-source/"
cat ./7z/7zS2.sfx.with-manifest ./7z/FxMetaInstaller.tag > "./$product_name-source/fainstall.sfx"
cp ./7z/7zr.exe "./$product_name-source/"
cp ./7z/pack.bat "./$product_name-source/$product_name.bat"
cp ./7z/pack.sh "./$product_name-source/$product_name.sh"
cp ./fainstall.sh "./$product_name-source/"
cd "$product_name-source"

# bash ./$product_name.sh

cd ..

echo -e "\033[1;32mSuccess\033[0m"
