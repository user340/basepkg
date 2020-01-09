#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

awk_script="../lib/awk/obsolete_filter.awk"
run_awk="awk -v category=test -v moduledir=x -v machine=amd64 -v release_k=9.99.30 -f $awk_script"

test_given_obsolete_package_pattern()
{
    local testcase="xxx	test-obsolete	testdata"
    local expected=""
    local result

    result="$(echo "$testcase" | $run_awk)"

    assertEquals "$result" "$expected"
}

. ./common.sh
. "$SHUNIT2"
