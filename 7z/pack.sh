#!/bin/sh
# Copyright (C) 2008-2014 ClearCode Inc.

installer_name=${0##*/}
installer_name=${installer_name%.sh}

rm "packed.7z"
rm "$installer_name.exe"

7z a -t7z packed.7z @pack.list -mx=9 -xr\!\*.svn -xr\!\*.sample

version=$(cat fainstall.ini | grep "DisplayVersion" | cut -d "=" -f 2)
if [ "$version" != "" ]
then
  installer_name="$installer_name-$version"
fi

cat ./fainstall.sfx ./packed.7z > "$installer_name.exe"

rm "packed.7z"

