#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

test_make_package_directory_of()
{
    _mkdir_if_not_exists()
    {
        echo "$1"
    }
    _logging()
    {
        :
    }
    # shellcheck disable=SC2034
    local workdir="."
    # shellcheck disable=SC2034
    local category="."
    local expected="././test-base-example
././test-obsolete
././test-package-example"
    local result

    result="$(_make_package_directories_of ".")"

    assertEquals "$expected" "$result"
}

test_make_package_directories()
{
    _logging()
    {
        echo "$@"
    }

    _make_package_directories_of()
    {
        echo "$@"
    }

    local category="base etc"
    local expected="===> _make_package_directories()
base
etc"
    local result

    result="$(_make_package_directories)"

    assertEquals "$expected" "$result"
}

test_generate_BUILD_INFO()
{
    local OPSYS="NetBSD"
    local OSVERSION="9.99.43"
    local machine_arch="x86_64"
    local PKGTOOLVERSION="20200101"
    local HOMEPAGE="https://github.com/user340/basepkg"
    local MAINTAINER="uki@127.0.0.1"

    local expected="OPSYS=$OPSYS
OS_VERSION=$OSVERSION
OBJECT_FMT=ELF
MACHINE_ARCH=$machine_arch
PKGTOOLS_VERSION=$PKGTOOLVERSION
HOMEPAGE=$HOMEPAGE
MAINTAINER=$MAINTAINER"
    local result

    result="$(_generate_BUILD_INFO)"

    assertEquals "$expected" "$result"
}

test_check_package_dependency_of()
{
    local deps="/home/uki/src/cvs.NetBSD.org/src/distrib/sets/deps"
    local release="9.99.48"
    local expected="@pkgdep base-sys-usr>=$release
@pkgdep base-sys-root>=$release"
    local result

    result="$(_check_package_dependency_of "base-c-bin")"

    assertEquals "$expected" "$result"
}

. ./common.sh
. ../lib/Package
. "$SHUNIT2"
