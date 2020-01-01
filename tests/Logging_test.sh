#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

_setup_logging()
{
    local log
    log="$(mktemp)"

    _logging "this is test string." > /dev/null

    echo "$log"
}

test_logging()
{
    local log
    log="$(_setup_logging)"

    assertEquals "this is test string." "$(cat "$log")"

    _teardown_remove_given_file "$log"
}

test_logfile_is_exists_and_is_a_regular_file()
{
    local log
    log="$(_setup_logging)"

    assertTrue "[ -f $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_is_exists_and_has_a_size_reater_than_zero()
{
    local log
    log="$(_setup_logging)"

    assertTrue "[ -s $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_is_eists_and_is_readable()
{
    local log
    log="$(_setup_logging)"

    assertTrue "[ -r $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_exists_and_is_writable()
{
    local log
    log="$(_setup_logging)"

    assertTrue "[ -w $log ]"

    _teardown_remove_given_file "$log"
}

_get_expected_by_begin_logging()
{
    local commandline="./basepkg.sh"
    local release="9.0"
    local machine="amd64"
    local machine_arch="x86_64"
    local opsys="NetBSD"
    local osversion="9.0"

    printf "===> basepkg.sh command: %s\\n===> basepkg.sh started: %s\\n===> NetBSD version:     %s\\n===> MACHINE:            %s\\n===> MACHINE_ARCH:       %s\\n===> Build platform:     %s %s %s" "$commandline" "$(date)" "$release" "$machine" "$machine_arch" "$opsys" "$osversion" "$(uname -m)"
}

test_begin_logging()
{
    local log
    local result
    local commandline="./basepkg.sh"
    local release="9.0"
    local machine="amd64"
    local machine_arch="x86_64"
    local opsys="NetBSD"
    local osversion="9.0"

    log="$(_setup_logging)"
    result="$(_begin_logging)"

    assertEquals "$(_get_expected_by_begin_logging)" "$result"
}

_get_expected_by_end_logging()
{
    local now

    now="$(date)"

    printf "===> basepkg.sh ended:   %s\\n===> Summary of log:\\nthis is test string.\\n     basepkg.sh ended:   %s\\n===> .\\n" "$now" "$now"
}

test_end_logging()
{
    local log
    local result

    log="$(_setup_logging)"
    result="$(_end_logging)"

    assertEquals "$(_get_expected_by_end_logging)" "$result"
}

. ./common.sh
. ../lib/Logging
. "$SHUNIT2"
