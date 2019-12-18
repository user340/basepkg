#!/bin/sh

test_getarch_in_amd64()
{
    local machine="amd64"
    local frag="$(_getarch)"
    local expect="MACHINE=$machine\nMACHINE_ARCH=x86_64"

    assertEquals "$(echo -e $expect)" "$frag"
}

test_getarch_in_evbarm()
{
    local machine="evbarm"
    local frag="$(_getarch)"
    local expect="MACHINE=$machine\nMACHINE_ARCH=earm"

    assertEquals "$(echo -e $expect)" "$frag"
}

test_getarch_fail_pattern()
{
    local machine="xxxxxxx"
    local frag="$(_getarch)"

    assertEquals "Unknown target MACHINE: $machine" "$frag"
}

. ../lib/valid_MACHINE_ARCH
. ../lib/NetBSD
. "$SHUNIT2"
