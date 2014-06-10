#!/bin/bash
# Copyright (C) 2014 ClearCode Inc.

echo "Fx Meta Installer (easy edition)"

if [ "$1" = "--help" ]
then
  echo ""
  echo "Usage:"
  echo "  ./fainstall.sh APPNAME"
  echo ""
  echo "The argument APPNAME is the target application."
  echo "Possible values:"
  echo " - \"firefox\" (default)"
  echo " - \"thunderbird\""
  exit 0
fi


DRY_RUN=yes

try_run() {
  if [ "$DRY_RUN" = "yes" ]
  then
    echo "> Run: $@"
  else
    exec "$@"
  fi
}



# ================================================================
# Initialize variables
# ================================================================

application="$1"

if [ "$application" = "" ]; then application="firefox"; fi
application=$(echo "$application" | tr "[A-Z]" "[a-z]")

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


resources="."
if [ -d "./resources" ]; then resources="./resources"; fi

fainstall_ini="./fainstall.ini"



# ================================================================
# Installation
# ================================================================


# Enable/disable crash report

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
      fi

      if [ ! -d "$target_location" ]; then return 0; fi

      echo "Installing: $file => $target_location/"
      try_run cp "$file" "$target_location/"
      installed_file="$target_location/$(basename "$file")"
      try_run chown root:root "$installed_file"
      try_run chmod 644 "$installed_file"
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




# Install shortcuts (not implemented)

# Run extra installers (not implemented)

# Install search plugins (not implemented)

## Install searchplugins => appdir/browser/searchplugins/ or appdir/searchplugins/ (not implemented)

## Disable searchplugins (not implemented)
