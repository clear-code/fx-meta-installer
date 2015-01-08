#!/bin/bash
# Copyright (C) 2015 ClearCode Inc.

script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
base_dir=$(dirname $script_dir)
project_root=${base_dir}/../

mkdir -p ${project_root}/resources
mkdir -p ${project_root}/installer-config

cp ${base_dir}/templates/Makefile ${project_root}
