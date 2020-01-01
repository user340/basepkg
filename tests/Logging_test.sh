#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC1091
# shellcheck disable=SC2039

_setup_logging()
{
    local log="$(mktemp)"

    _logging "this is test string." > /dev/null

    echo "$log"
}

test_logging()
{
    local log="$(_setup_logging)"

    assertEquals "this is test string." "$(cat "$log")"

    _teardown_remove_given_file "$log"
}

test_logfile_is_exists_and_is_a_regular_file()
{
    local log="$(_setup_logging)"

    assertTrue "[ -f $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_is_exists_and_has_a_size_reater_than_zero()
{
    local log="$(_setup_logging)"

    assertTrue "[ -s $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_is_eists_and_is_readable()
{
    local log="$(_setup_logging)"

    assertTrue "[ -r $log ]"

    _teardown_remove_given_file "$log"
}

test_logfile_exists_and_is_writable()
{
    local log="$(_setup_logging)"

    assertTrue "[ -w $log ]"

    _teardown_remove_given_file "$log"
}

_get_expected()
{
    local now="$(date)"
    printf "===> basepkg.sh ended:   %s\\n===> Summary of log:\\nthis is test string.\\n     basepkg.sh ended:   %s\\n===> .\\n" "$now" "$now"
}

test_end_logging()
{
    local log="$(_setup_logging)"
    local result="$(_end_logging)"

    assertEquals "$(_get_expected)" "$result"
}

. ./common.sh
. ../lib/Logging
. "$SHUNIT2"
