#!/bin/sh
. "./script/subroutine"

usage() {
	echo "usage: ./basepkg.sh operation"
	echo " Create packages operations"
	echo ""
	echo " Other operations"
	echo "    baseroot   create base root hierachy"
	echo "    clean      remove information files"
	echo "    extract    extract base binary"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi

case $1 in
	baseroot) make_dirtree > ./sets/base/root/root.list ;;
	clean) clean_plus_file ;;
	extract) extract_base ;;
	*) usage ;;
esac
