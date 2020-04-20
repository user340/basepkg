#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

_setup_logging()
{
    local log
    LOG="$(mktemp)"

    _logging "this is test string." > /dev/null

    echo "$LOG"
}

test_logging()
{
    local log
    LOG="$(_setup_logging)"

    assertEquals "this is test string." "$(cat "$LOG")"

    _teardown_remove_given_file "$LOG"
}

test_logfile_is_exists_and_is_a_regular_file()
{
    local log
    LOG="$(_setup_logging)"

    assertTrue "[ -f $LOG ]"

    _teardown_remove_given_file "$LOG"
}

test_logfile_is_exists_and_has_a_size_reater_than_zero()
{
    local log
    LOG="$(_setup_logging)"

    assertTrue "[ -s $LOG ]"

    _teardown_remove_given_file "$LOG"
}

test_logfile_is_eists_and_is_readable()
{
    local log
    LOG="$(_setup_logging)"

    assertTrue "[ -r $LOG ]"

    _teardown_remove_given_file "$LOG"
}

test_logfile_exists_and_is_writable()
{
    local log
    LOG="$(_setup_logging)"

    assertTrue "[ -w $LOG ]"

    _teardown_remove_given_file "$LOG"
}

_get_expected_by_begin_logging()
{
    local COMMANDLINE="./basepkg"
    local RELEASE="9.0"
    local machine="amd64"
    local machine_arch="x86_64"
    local OPSYS="NetBSD"
    local OSVERSION="9.0"

    printf "===> basepkg command: %s\\n===> basepkg started: %s\\n===> NetBSD version:     %s\\n===> MACHINE:            %s\\n===> MACHINE_ARCH:       %s\\n===> Build platform:     %s %s %s" "$COMMANDLINE" "$(date)" "$RELEASE" "$machine" "$machine_arch" "$OPSYS" "$OSVERSION" "$(uname -m)"
}

test_begin_logging()
{
    local log
    local result
    local COMMANDLINE="./basepkg"
    local RELEASE="9.0"
    local machine="amd64"
    local machine_arch="x86_64"
    local OPSYS="NetBSD"
    local OSVERSION="9.0"

    LOG="$(_setup_logging)"
    result="$(_begin_logging)"

    assertEquals "$(_get_expected_by_begin_logging)" "$result"
}

_get_expected_by_end_logging()
{
    local now

    now="$(date)"

    printf "===> basepkg ended:   %s\\n===> Summary of log:\\nthis is test string.\\n     basepkg ended:   %s\\n===> .\\n" "$now" "$now"
}

test_end_logging()
{
    local log
    local result

    LOG="$(_setup_logging)"
    result="$(_end_logging)"

    assertEquals "$(_get_expected_by_end_logging)" "$result"
}

. ./common.sh
. ../lib/Logging
. "$SHUNIT2"
