#!/bin/bash
# Copyright (C) 2011-2015 ClearCode Inc.

script_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
base_dir="$(dirname "$script_dir")"
project_root="${base_dir}/../"

source "${script_dir}/utils.sh"
addons="$@"

main() {
	safely rm -r "${base_dir}/resources"
	safely mkdir "${base_dir}/resources"

	for addon in $addons
	do
	    make_addon $addon
	done
}

make_addon() {
    (cd $1 &&
		safely make &&
		safely rm *_noupdate.xpi)

	result=$?
	if [ $result -ne 0 ]; then
	  exit $result
	else
	  safely mv $1/*.xpi "${base_dir}/resources/"
	  return 0
	fi
}

make_addon_noupdate() {
    (cd $1 &&
		safely make)

	result=$?
	if [ $result -ne 0 ]; then
	  exit $result
	else
	  safely mv $1/*_noupdate.xpi "${base_dir}/resources/"
	  return 0
	fi
}

main
