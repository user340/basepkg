#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

_setup_for_NetBSD_testing()
{
    uname()
    {
        echo "NetBSD"
    }
}

_setup_for_FreeBSD_testing()
{
    uname()
    {
        echo "FreeBSD"
    }
}

test_set_md5_sum_in_NetBSD()
{
    _setup_for_NetBSD_testing
    local expect="cksum -a md5"
    local result

    result="$(_set_md5_sum)"

    assertEquals "$expect" "$result"
}

test_set_sha512_sum_in_NetBSD()
{
    _setup_for_NetBSD_testing
    local expect="cksum -a sha512"
    local result

    result="$(_set_sha512_sum)"

    assertEquals "$expect" "$result"
}

test_set_md5_sum_in_FreeBSD()
{
    _setup_for_FreeBSD_testing
    local expect="md5"
    local result

    result="$(_set_md5_sum)"

    assertEquals "$expect" "$result"
}

test_set_sha512_sum_in_FreeBSD()
{
    _setup_for_FreeBSD_testing
    local expect="sha512"
    local result

    result="$(_set_sha512_sum)"

    assertEquals "$expect" "$result"
}

. ./common.sh
. ../lib/Command
. "$SHUNIT2"
