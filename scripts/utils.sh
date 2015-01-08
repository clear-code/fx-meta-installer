#!/bin/bash
# Copyright (C) 2010-2011 ClearCode Inc.

black=30
red=31
green=32
yellow=33
blue=34
magenta=35
cyan=36
white=37
on_black=40
on_red=41
on_green=42
on_yellow=43
on_blue=44
on_magenta=45
on_cyan=46
on_white=47

colored() {
    color=$1
    shift
    echo -e "\033[1;${color}m$*\033[0m"
}

safely() {
    echo -n $(colored $blue "Executing: $*")
    echo $(colored $yellow " [$PWD]")
    LOG_FILE="/tmp/$(uuidgen)"
    REMOVE_LOG_FILE="rm -f ${LOG_FILE}"
    "$@" >${LOG_FILE} 2>&1
    result=$?

    cat ${LOG_FILE}

    if [ $result -ne 0 ]; then
        if [ $1 = "rm" ]; then
            echo $(colored $magenta " => Failed to remove file or directory. Proceed anyway.")
        elif [ $1 = "mkdir" ]; then
            echo $(colored $magenta " => Failed to create directory. Proceed anyway.")
        else
            echo $(colored $red " => Failed")
            echo $(colored $cyan $(cat ${LOG_FILE}))
            $REMOVE_LOG_FILE
            exit $result
        fi
    else
        echo $(colored $green " => Succeeded")
    fi

    $REMOVE_LOG_FILE

    echo

    return 0
}
