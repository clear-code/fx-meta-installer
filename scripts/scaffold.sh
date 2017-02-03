#!/bin/bash
# Copyright (C) 2015 ClearCode Inc.

script_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
base_dir="$(dirname "$script_dir")"
project_root="${base_dir}/../"
project_name="$1"

if [ "${project_name}" = "" ]; then
    echo "error: You must give project name via the first argument (like \"FxMetaInstaller\")" 1>&2
    exit 1
fi

add_blank_dir() {
    local dir_path="${project_root}/$1"
    mkdir -p "${dir_path}" && touch "${dir_path}/.gitkeep"
}

fill_palceholders() {
    local source_path="$1"
    local destination_dir="$2"
    local source_base_name="$(basename "${source_path}")"
    local destination_path="${destination_dir}/${source_base_name}"
    sed -e "s/@PROJECT_NAME@/${project_name}/g" "${source_path}" > "${destination_path}"
}

add_blank_dir resources
add_blank_dir installer-config

fill_palceholders "${base_dir}/templates/Makefile" "${project_root}"
fill_palceholders "${base_dir}/templates/installer-config/config.bat" "${project_root}"/installer-config
fill_palceholders "${base_dir}/templates/installer-config/config.nsh" "${project_root}"/installer-config
fill_palceholders "${base_dir}/templates/installer-config/fainstall.ini" "${project_root}"/installer-config
fill_palceholders "${base_dir}/templates/resources/Firefox-setup.ini" "${project_root}"/resources
