#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

FILES="./FILES"

run_awk()
{
    local script="../lib/awk/categorizing_files_into_package.awk"

    awk -f "$script" "$@"
}

test_categorizing_files_into_package()
{
    local expected="test-package-example ./sbin/example ./bin/example
test-obsolete ./bin/obsolete
test-base-example ./etc/test"
    local result

    result="$(run_awk "$FILES")"

    assertEquals "$expected" "$result"
}

. ./common.sh
. "$SHUNIT2"
