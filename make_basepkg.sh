#!/bin/sh
. "./subroutine"
pkgname="$(echo $1 | sed 's/\///')"
clean_plus_file $pkgname
make_list $pkgname
make_BUILD_INFO $pkgname
make_COMMENT $pkgname
make_CONTENTS $pkgname
make_DESC $pkgname
make_PKG $pkgname
