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
    local workdir="."
    local category="."
    local expect="././test-base-example
././test-obsolete
././test-package-example"
    local result

    result="$(_make_package_directories_of ".")"

    assertEquals "$expect" "$result"
}

. ./common.sh
. ../lib/Package
. "$SHUNIT2"
