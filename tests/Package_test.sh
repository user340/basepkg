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
    local workdir="./testdata"
    # shellcheck disable=SC2034
    local category="."
    local expected="$workdir/$category/test-base-example
$workdir/$category/test-obsolete
$workdir/$category/test-package-example"
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

test_check_package_dependency_of_package_which_has_no_dependency()
{
    _error()
    {
        echo "$@"
    }

    local deps="/home/uki/src/cvs.NetBSD.org/src/distrib/sets/deps"
    local release="9.99.48"
    local expected="test-package-bin Unknown package dependency."
    local result

    result="$(_check_package_dependency_of "test-package-bin")"

    assertEquals "$expected" "$result"
}

test_ext_give_release_number_to()
{
    _ext_get_ident_number()
    {
        echo "20181101"
    }

    local expected="@pkgdep base-sys-root>=20181101"
    local result

    result="$(_ext_give_release_number_to "base-sys-root")"

    assertEquals "$expected" "$result"
}

test_invalid_pattern_ext_give_release_number_to()
{
    _ext_get_ident_number()
    {
        :
    }

    local expected=""
    local result

    result="$(_ext_give_release_number_to "base-sys-root")"

    assertEquals "$expected" "$result"
}

test_calculate_sum_of_file_size()
{
    _show_each_file_size_in_CONTENTS_of()
    {
        echo "$@"
    }

    local data="100
200
300
400"
    local expected="1000"
    local result

    result="$(_calculate_sum_of_file_size "$data")"

    assertEquals "$expected" "$result"
}

test_print_description()
{
    local descrs="./testdata/descrs"
    local expected="This is test package. Unavailable in upstream or production
environment. This description is multi line."
    local result

    result="$(_print_description "test-package-bin" "$descrs")"

    assertEquals "$expected" "$result"
}

test_replace_cmdstr()
{
    local testdata="./testdata/replace_cmd"
    local expected="/usr/sbin/groupadd
/usr/sbin/useradd
/bin/sh
/
/usr/bin/awk
/usr/bin/basename
/bin/cat
/bin/chgrp
/bin/chmod
/sbin/chown
/usr/bin/cmp
/bin/cp
/usr/bin/dirname
echo
/usr/bin/egrep
/bin/expr
/usr/bin/false
/usr/bin/find
/usr/bin/grep
/bin/tar
/usr/bin/head
/usr/bin/id
linkfarm
/bin/ln
localbase
/bin/ls
/bin/mkdir -p
/bin/mv
/
/bin/rm
/bin/rmdir
/usr/bin/sed
setenv
echo -n
pkg_admin
pkg_info
pwd
/usr/bin/sort
/usr/bin/su
test
/usr/bin/touch
/usr/bin/tr
/usr/bin/true
/usr/bin/xargs
/usr/X11R7
/etc
/etc
/etc

NO
YES
YES
NO


$(command -v perl)"

    local result

    result="$(_replace_cmdstr "$testdata")"

    assertEquals "$expected" "$result"
}

. ./common.sh
. ../lib/Package
. "$SHUNIT2"
