#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

test_usage()
{
    local PROGNAME="basepkg"
    local OBJ="."
    local machine="amd64"
    local expected="Usage: $PROGNAME [--arch architecture] [--category category]
                  [--destdir destdir] [--machine machine] [--obj objdir]
                  [--releasedir releasedir] [--src srcdir]
                  [--with-nbpkg-build-config config] [--enable-nbpkg-build]
                  operation

 Operations:
    pkg                         Create packages.
    kern                        Create kernel package.
    clean                       Clean working directories.
    cleanpkg                    Clean package directories.

 Options:
    --arch                      Set machine_arch to architecture.
                                [Default: deduced from \"machine\"]
    --category                  Set category.
                                [Default: \"base comp etc games man misc text\"]
    --destdir                   Set destdir.
                                [Default: $OBJ/destdir.$machine]
    --machine                   Set machine type for MACHINE_ARCH.
                                [Default: result of \`uname -m\`]
    --obj                       Set obj to NetBSD binaries.
                                [Default: /usr/obj]
    --releasedir                Set RELEASEDIR.
    --src                       Set NetBSD source directory.
                                [Default: /usr/src]
    --with-nbpkg-buld-config    WIP (Don't use it unless you are developer.)
    --enable-nbpkg-build        WIP (Don't use it unless you are developer.)
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
