#!/bin/bash
# Copyright (C) 2010-2015 ClearCode Inc.

script_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
base_dir="$(dirname "$script_dir")"
project_root="${base_dir}/../"

source "${script_dir}/utils.sh"
base_name="$1"
package_name="${base_name}-source"
dist_dir="${project_root}/dist/"
addons=${@:2}

case $(uname) in
  Darwin|*BSD) cp="gcp" ;;
  *)           cp="cp" ;;
esac

main() {
        safely rm -rf "${base_dir}/resources"
        safely mkdir "${base_dir}/resources"

        safely rm -rf "${dist_dir}/${package_name}"
        safely mkdir "${dist_dir}"

        safely "${script_dir}/make_addons.sh" $addons
        make_installer

        safely rm -rf "${base_dir}/resources"
        safely mkdir "${base_dir}/resources"
}

rm_emacs_swap_file() {
    find . -name "*~" -type f -print0 | xargs -0 rm
}

make_installer() {
    (cd "${base_dir}/../installer-config" &&
        safely $cp -t "${base_dir}/" *.*)
    (cd "${base_dir}/../resources" &&
        $cp -t "${base_dir}/resources/" *.*)

    (cd "${base_dir}" &&
        safely ./make.sh &&
        safely cd "${package_name}" &&
        safely rm -f fainstall.ini &&
        safely rm -f "./resources/*.sample" &&
        rm_emacs_swap_file)

    safely $cp "${base_dir}/../installer-config/fainstall.ini" "${base_dir}/${package_name}/"
    safely mv "${base_dir}/${package_name}" "${dist_dir}"
    safely rm "${dist_dir}/${package_name}/${base_name}.exe"
}

main
