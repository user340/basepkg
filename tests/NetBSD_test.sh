#!/bin/sh

test_getarch_in_amd64()
{
    local machine="amd64"
    local result="$(_getarch)"
    local expect="MACHINE=$machine\nMACHINE_ARCH=x86_64"

    assertEquals "$(echo -e $expect)" "$result"
}

test_getarch_in_evbarm()
{
    local machine="evbarm"
    local result="$(_getarch)"
    local expect="MACHINE=$machine\nMACHINE_ARCH=earm"

    assertEquals "$(echo -e $expect)" "$result"
}

test_getarch_fail_pattern()
{
    local machine="xxxxxxx"
    local result="$(_getarch)"

    assertEquals "Unknown target MACHINE: $machine" "$result"
}

test_validate_arch_takes_no_machine_arch()
{
    local machine_arch=""
    local result="$(_validate_arch)"

    assertEquals "No MACHINE_ARCH provided" "$result"
}

. ./common.sh
. ../lib/valid_MACHINE_ARCH
. ../lib/NetBSD
. "$SHUNIT2"
