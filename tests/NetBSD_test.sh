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

test_validate_arch_takes_no_machine_architecture()
{
    local machine_arch=""
    local result="$(_validate_arch)"

    assertEquals "No MACHINE_ARCH provided" "$result"
}

test_validate_arch()
{
    local MACHINE="amd64"
    local MACHINE_ARCH="x86_64"
    local machine_arch="x86_64"
    local result="$(_validate_arch)"

    assertEquals "" "$result"
}

test_foundarch_is_false_in_validate_arch()
{
    local MACHINE="amd64"
    local MACHINE_ARCH="xxxxx"
    local machine_arch="x86_64"
    local result="$(_validate_arch)"

    assertEquals "Unknown target MACHINE_ARCH: xxxxx" "$result"
}

test_foundmachine_is_false_in_validate_arch()
{
    local MACHINE="xxxxx"
    local MACHINE_ARCH="x86_64"
    local machine_arch="x86_64"
    local result="$(_validate_arch)"

    assertEquals "Unknown target MACHINE: xxxxx" "$result"
}

test_foundpair_is_false_in_validate_arch()
{
    local MACHINE="amd64"
    local MACHINE_ARCH="i386"
    local machine_arch="x86_64"
    local result="$(_validate_arch)"

    assertEquals "MACHINE_ARCH '$MACHINE_ARCH' does not support MACHINE '$MACHINE'" "$result"
}

_setup_param()
{
    local tmp="$(mktemp)"

    case "$1" in
    "stable")
        echo "#define	__NetBSD_Version__	801000000	/* NetBSD 8.1_STABLE */" > "$tmp"
        ;;
    "current")
        echo  "#define	__NetBSD_Version__	999002500	/* NetBSD 9.99.25 */" > "$tmp"
        ;;
    *)
        ;;
    esac

    echo "$tmp"
}

_teardown_param()
{
    rm -f "$1"
}

test_osrelease_to_current()
{
    local destdir="/"
    local param="$(_setup_param "current")"
    local result="$(_osrelease)"

    assertEquals "9.99.25" "$result"

    _teardown_param "$param"
}

test_osrelease_with_k_to_current()
{
    local destdir="/"
    local param="$(_setup_param "current")"
    local result="$(_osrelease -k)"

    assertEquals "9.99.25" "$result"

    _teardown_param "$param"
}

test_osrelease_to_stable()
{
    local destdir="/"
    local param="$(_setup_param "stable")"
    local result="$(_osrelease)"

    assertEquals "8.1_STABLE" "$result"

    _teardown_param "$param"
}

test_osrelease_with_k_to_stable()
{
    local destdir="/"
    local param="$(_setup_param "stable")"
    local result="$(_osrelease -k)"

    assertEquals "8.1" "$result"

    _teardown_param "$param"
}

. ./common.sh
. ../lib/valid_MACHINE_ARCH
. ../lib/NetBSD
. "$SHUNIT2"
