#!/bin/bash
# Copyright (C) 2015 ClearCode Inc.

script_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
base_dir="$(dirname "$script_dir")"
project_root="${base_dir}/../"

add_blank_dir() {
    dir_path="${project_root}/$1"
    mkdir -p "${dir_path}" && touch "${dir_path}/.gitkeep"
}

add_blank_dir resources
add_blank_dir installer-config

cp "${base_dir}/templates/Makefile" "${project_root}"
