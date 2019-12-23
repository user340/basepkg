#!/bin/sh

SHUNIT2="/usr/pkg/bin/shunit2"

tab="	"
nl='
'

_bomb()
{
    printf "%s\\n" "$@"
    exit 1
}

_teardown_remove_given_file()
{
    rm -f "$1"
}
