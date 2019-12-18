#!/bin/sh

SHUNIT2="/usr/pkg/bin/shunit2"

tab="	"
nl='
'

_bomb()
{
    printf "%s\\n" "$@"
}
