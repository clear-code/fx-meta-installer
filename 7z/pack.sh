#!/bin/sh
# Copyright (C) 2008-2009 ClearCode Inc.

installer_name=${0##*/}
installer_name=${installer_name%.sh}

rm "packed.7z"
rm "$installer_name.exe"

7z a -t7z packed.7z @pack.list -mx=9 -xr!*.svn -xr!*.sample

cat ./fainstall.sfx ./packed.7z > "$installer_name.exe"

rm "packed.7z"

