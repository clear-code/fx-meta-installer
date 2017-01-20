#!/bin/bash
# Copyright (C) 2014 ClearCode Inc.
# ================================================================
# Fx Meta Installer (easy edition)
#
# このスクリプトは、メタインストーラのファイル群と組み合わせて
# 使用します。
#
# 使用方法:
#  1. メタインストーラのファイル群（fainstall.ini、resources
#     など）をインストール対象のLinux環境にコピーする。
#     例えば /tmp/FxMetaInstaller-source など。
#
#       % scp -r fileserver:/shared/FxMetaInstaller-source /tmp/
#
#  2. このスクリプトをメタインストーラのディレクトリ
#     （fainstall.ini があるディレクトリ）に設置する。
#     例えば /tmp/FxMetaInstaller-source/fainstall.sh など。
#
#       % scp fainstall.sh /tmp/FxMetaInstaller-source/
#
#  3. 2.でスクリプトをコピーした先のディレクトリに cd する。
#
#       % cd /tmp/FxMetaInstaller-source
#
#  4. 2.でコピーした fainstall.sh を管理者権限で実行する。
#
#       % sudo ./fainstall.sh
#
#
# 注意事項:
#  * このスクリプトの実行時には、以下のコマンドが必要です。
#
#    - bash
#    - unzip
#
#  * 未知の環境で実行する場合、事前にテスト実行して、実行予定の
#    コマンドが正しいかどうかを確認してください。
#    以下のように環境変数「DRY_RUN」に「yes」を指定すると、
#    テスト実行モードになります：
#
#      % env DRY_RUN=yes ./fainstall.sh
#
#  * メタインストーラのファイル構成によっては、インストール対象の
#    アプリケーション名を明示する必要があります。例えばFirefoxを
#    対象にする場合は以下のようにします：
#
#      % ./fainstall.sh firefox
#
# ================================================================

echo "Fx Meta Installer (easy edition)"

# ================================================================
# Initialize self
# ================================================================

fainstall_ini="$PWD/fainstall.ini"

resources="$PWD"
if [ -d "$PWD/resources" ]; then resources="$PWD/resources"; fi

application="$1"
if [ -f "$resources/Firefox-setup.ini" -o -f "$resources/Firefox-setup.exe" ]
then
  application="firefox"
fi
if [ -f "$resources/Thunderbird-setup.ini" -o -f "$resources/Thunderbird-setup.exe" ]
then
  application="thunderbird"
fi
application=$(echo "$application" | tr "[A-Z]" "[a-z]")


if [ "$1" = "--help" -o "$application" = "" ]
then
  echo ""
  echo "Usage:"
  echo "  ./fainstall.sh APPNAME"
  echo ""
  echo "Put this file to the directory which includes \"fainstall.ini\" and run."
  echo ""
  echo "The argument APPNAME is the target application."
  echo "Possible values:"
  echo " - \"firefox\""
  echo " - \"thunderbird\""
  echo ""
  echo "You can test this script without actual installations, by:"
  echo "  env DRY_RUN=yes ./fainstall.sh APPNAME"
  exit 0
fi


# DRY_RUN=no

try_run() {
  if [ "$DRY_RUN" = "yes" ]
  then
    echo "> Run: $*"
  else
    $*
  fi
}

case $(uname) in
  Darwin|*BSD) sed="sed -E" ;;
  *)           sed="sed -r" ;;
esac


# ================================================================
# Check required commands
# ================================================================

if ! type unzip > /dev/null
then
  echo "ERROR: Required command \"unzip\" is not available."
  exit 1
fi


# ================================================================
# Initialize variables
# ================================================================

detect_application_dir() {
  local application=$1
  possible_application_dirs="/usr/lib64/$application /usr/lib/$application"
  for location in $possible_application_dirs
  do
    if [ -d "$location" -a -f "$location/$application" ]
    then
      echo "$location"
      return 0
    fi
  done
  echo ""
  return 0
}
application_dir=$(detect_application_dir "$application")

echo "Target Application: $application"
echo "Target Location:    $application_dir"
echo ""

if [ "$application_dir" = "" ]
then
  echo "ERROR: The target location is not found."
  exit 1
fi

if [ ! -d "$application_dir" ]
then
  echo "ERROR: The target location does not exist."
  exit 1
fi

log_file="$PWD/fainstall.$(date +%Y-%m-%d.%H-%M-%S).log"




# ================================================================
# Installation
# ================================================================


# Enable/disable crash report (not implemented)

# Update existing shortcuts (not implemented)

# Set default client / disable client (not implemented)

# Install custom profiles (not implemented)


# ================================================================
# Install additional files
# ================================================================

install_files() {
  local target_location=$1
  local files=$2
  local option=$3

  find $resources -name "$files" | while read file
  do
    if [ -f "$file" ]
    then
      if [ ! -d "$target_location" -a "$option" = "create" ]
      then
        echo "Creating directory: $target_location"
        try_run mkdir -p "$target_location"
        try_run chown root:root "$target_location"
        try_run chmod 755 "$target_location"
        echo "$target_location" >> "$log_file"
      fi

      if [ ! -d "$target_location" ]; then return 0; fi

      echo "Installing file: $file => $target_location/"
      try_run cp "$file" "$target_location/"
      installed_file="$target_location/$(basename "$file")"
      try_run chown root:root "$installed_file"
      try_run chmod 644 "$installed_file"
      echo "$installed_file" >> "$log_file"
    fi
  done
}

install_files "$application_dir" "*.cfg"
install_files "$application_dir" "*.properties"
install_files "$application_dir" "override.ini"

install_files "$application_dir/defaults" "*.cer"
install_files "$application_dir/defaults" "*.crt"
install_files "$application_dir/defaults" "*.pem"
install_files "$application_dir/defaults" "*.cer.override"
install_files "$application_dir/defaults" "*.crt.override"
install_files "$application_dir/defaults" "*.pem.override"

install_files "$application_dir/defaults/profile" "bookmarks.html" "create"
install_files "$application_dir/defaults/profile" "*.rdf" "create"

install_files "$application_dir/isp" "*.xml" "create"

install_files "$application_dir/defaults/pref" "*.js"
install_files "$application_dir/defaults/preferences" "*.js"

install_files "$application_dir/chrome" "*.css"
install_files "$application_dir/chrome" "*.jar"
install_files "$application_dir/chrome" "*.manifest"

install_files "$application_dir/components" "*.xpt"

## Install *.dll => appdir/plugins/ (not implemented)

install_files "$application_dir/distribution" "distribution.*" "create"

## for Firefox
install_files "$application_dir/browser" "override.ini"
install_files "$application_dir/browser/defaults/profile" "bookmarks.html"
install_files "$target_location/browser/defaults/profile" "*.rdf"
### Install *.dll => appdir/browser/plugins/ (not implemented)

## for Netscape
### Install installed-chrome.txt => appdir/ (not implemented)

## Install *.lnk => desktop/ (not implemented)


# ================================================================
# Install addons
# ================================================================

install_addon() {
  local file=$1

  local basename=$(basename "$file")
  local tmpdir="/tmp/$basename"

  rm -rf "$tmpdir"
  mkdir -p "$tmpdir"
  unzip "$file" -d "$tmpdir" > /dev/null

  local id=$(grep "em:id" "$tmpdir/install.rdf" | head -n 1 | \
               $sed -e "s/ *<[^>]+> *//g" \
                    -e "s/[^=]+= *\"([^\"]+)\"/\1/" \
                    -e "s/[^=]+= *'([^\"]+)'/\1/" | \
               tr -d "\r" | tr -d "\n")
  local target_location=$(get_addon_install_location "$file" "$id")

  echo "Installing addon: $basename => $target_location"

  try_run rm -rf "$target_location"
  try_run mkdir -p "$target_location"
  try_run mv "$tmpdir/*" "$target_location/"
  try_run chown -R root:root "$target_location"
  try_run find "$target_location" -type d -exec chmod 755 {} +
  try_run find "$target_location" -type f -exec chmod 644 {} +
  rm -rf "$tmpdir"
  echo "$target_location" >> "$log_file"
}

get_addon_install_location() {
  local file=$1
  local basename=$(basename "$1")
  local id=$2

  if [ -f "$fainstall_ini" ]
  then
    local id_from_ini=$(grep --after-context=5 "\[$basename\]" "$fainstall_ini" | \
                          grep "AddonId=" | head -n 1 | cut -d "=" -f 2 | \
                          tr -d "\r" | tr -d "\n")
    if [ "$id_from_ini" != "" ]
    then
      local id="$id_from_ini"
    fi

    local target_location=$(grep --after-context=5 "\[$basename\]" "$fainstall_ini" | \
                              grep "TargetLocation=" | head -n 1 | cut -d "=" -f 2 | \
                              $sed -e 's#\\#/#g' | tr -d "\r" | tr -d "\n" )
    local target_location=$(resolve_place_holders "$target_location")
    if [ "$target_location" != "" ]
    then
      echo "$target_location/$id"
      return 0
    fi
  fi

  echo "$application_dir/distribution/bundles/$id"
  return 0
}

resolve_place_holders() {
  echo "$1" | \
    $sed -e "s;\%AppData\%;$HOME;i" \
         -e "s;\%HomePath\%;$HOME;i" \
         -e "s;\%UserName\%;$USER;i" \
         -e "s;\%Tmp\%;/tmp;i" \
         -e "s;\%Temp\%;/tmp;i" \
         -e "s;\%ComputerName\%;$(cat /etc/hostname | tr -d "\n" | tr -d "\r");i" \
         -e "s;\%Home\%;$HOME;i" \
         -e "s;\%DeskTop\%;$HOME/Desktop;i" \
         -e "s;\%AppDir\%;$application_dir;i"
         # not implemented:
         # -e "s;\%HomeDrive\%;???;i" \
         # -e "s;\%SystemDrive\%;???;i" \
         # -e "s;\%SystemRoot\%;???;i" \
         # -e "s;\%WinDir\%;???;i" \
         # -e "s;\%ProgramFiles\%;???;i" \
         # -e "s;\%CommonProgramFiles\%;???;i" \
         # -e "s;\%AllUsersProfile\%;???;i" \
         # -e "s;\%SysDir\%;???;i" \
         # -e "s;\%ProgramFiles32\%;???;i" \
         # -e "s;\%ProgramFiles64\%;???;i" \
         # -e "s;\%CommonFiles\%;???;i" \
         # -e "s;\%CommonFiles32\%;???;i" \
         # -e "s;\%CommonFiles64\%;???;i" \
         # -e "s;\%StartMenu\%;???;i" \
         # -e "s;\%Programs\%;???;i" \
  return 0
}

find $resources -name "*.xpi" | while read file
do
  install_addon "$file"
done


# Install shortcuts (not implemented)

# Run extra installers (not implemented)

# Install search plugins (not implemented)

## Install searchplugins => appdir/browser/searchplugins/ or appdir/searchplugins/ (not implemented)

## Disable searchplugins (not implemented)


echo ""
echo "Done."
echo ""
echo "Installed fires and directories are listed in the file:"
echo ""
echo "  $log_file"
echo ""
echo "You can uninstall all installed files with:"
echo ""
echo "  cat $log_file | xargs rm -rf"
exit 0
