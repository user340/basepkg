#!/bin/sh
. "./script/subroutine"

usage() {
	echo "usage: ./basepkg.sh operation"
	echo " Create packages operations"
	echo "    pkg        create packages"
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
	pkg)     make_BUILD_INFO base/openssl
	         make_COMMENT base/openssl
					 make_CONTENTS base/openssl
					 make_DESC base/openssl
					 make_PKG base/openssl
	         ;;
	*) usage ;;
esac
