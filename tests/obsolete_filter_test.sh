#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

run_awk()
{
    local script="../lib/awk/obsolete_filter.awk"

    awk \
        -v category=test \
        -v moduledir=module \
        -v machine=amd64 \
        -v release_k=9.99.30 \
        -f $script
}

test_given_obsolete_package_pattern()
{
    local testcase="xxx	test-obsolete	testdata"
    local expected=""
    local result

    result="$(echo "$testcase" | run_awk)"

    assertEquals "$expected" "$result"
}

test_given_obsolete_labeled_package_pattern()
{
    local testcase="xxx	test-testing-package	obsolete"
    local expected=""
    local result

    result="$(echo "$testcase" | run_awk)"

    assertEquals "$expected" "$result"
}

test_valid_pattern()
{
    local testcase="
# comment
./@MODULEDIR@/aio	test-kernel-modules	kmod
./stand/@MACHINE@/@OSRELEASE@	test-kernel-modules	kmod
./stand/@MACHINE@/@OSRELEASE@	xxxx-kernel-modules	kmod"
    local expected="module/aio test-kernel-modules kmod
stand/amd64/9.99.30 test-kernel-modules kmod"
    local result

    result="$(echo "$testcase" | run_awk)"

    assertEquals "$expected" "$result"
}

. ./common.sh
. "$SHUNIT2"
