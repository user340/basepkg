#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

test_load_config()
{
    CONFIG="../etc/basepkg.conf"

    _load_config

    assertEquals "0" "$?"
}

test_load_config_invalid_path_pattern()
{
    CONFIG="xxxxx"

    local result="$(_load_config)"
    local expected="$CONFIG not found"

    assertEquals "$result" "$expected"
}

test_value_is_available_by_load_config()
{
    CONFIG="../etc/basepkg.conf"

    _load_config

    test -n "$SRC"
    assertEquals "0" "$?"
    test -n "$OBJ"
    assertEquals "0" "$?"
    test -n "$LOG"
    assertEquals "0" "$?"
    test -n "$HOMEPAGE"
    assertEquals "0" "$?"
    test -n "$MAINTAINER"
    assertEquals "0" "$?"
    test -n "$CATEGORY"
    assertEquals "0" "$?"
    test -n "$PKGDB"
    assertEquals "0" "$?"

    test -n "$INVALID"
    assertEquals "1" "$?"
}

test_usage()
{
    local PROGNAME="basepkg"
    local OBJ="."
    local machine="amd64"
    local expected="Usage: $PROGNAME [--arch architecture] [--category category]
                  [--destdir destdir] [--machine machine] [--releasedir releasedir]
                  operation

 Operations:
    pkg                         Create packages.
    kern                        Create kernel package.
    clean                       Clean working directories.
    cleanpkg                    Clean package directories.

 Options:
    --arch                      Set machine_arch to architecture.
                                [Default: deduced from \"machine\"]
    --destdir                   Set destdir.
                                [Default: $OBJ/destdir.$machine]
    --machine                   Set machine type for MACHINE_ARCH.
                                [Default: result of \`uname -m\`]
    --releasedir                Set RELEASEDIR.
    -h | --help                 Show this message and exit."
    local result="$(_usage)"

    assertEquals "$expected" "$result"
}

test_getopt()
{
    local arg="--obj=/usr/obj"
    local expected="/usr/obj"
    local result="$(_getopt $arg)"

    assertEquals "$expected" "$result"
}

test_check_non_posix_commands()
{
    hostname()
    {
        :
    }
    mktemp(){
        : 
    }
    pkg_create(){
        :
    }
    pkg_admin(){
        :
    }
    _bomb_if_command_not_found()
    {
        command -v "$1" 2>&1 || return 1
    }

    _check_non_posix_commands

    assertEquals "0" "$?"
}

. ./common.sh
. ../lib/CommandLine
. "$SHUNIT2"
