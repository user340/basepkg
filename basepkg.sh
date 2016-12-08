#!/bin/sh
. "./script/subroutine"

usage() {
	echo "usage: ./basepkg.sh operation"
	echo " operations"
	echo "    clean      remove information files"
	echo "    extract    extract base binary"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi

case $1 in
	clean) clean_plus_file ;;
	extract) extract_base ;;
	*) usage ;;
esac
