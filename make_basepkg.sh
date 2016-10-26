#!/bin/sh
#
# make_basepkg.sh
#   create system packages for NetBSD.
#   usage:
#     1. uncompression NetBSD sets in any directory.
#     2. copy this script to the directory.
#     3. run script
#          ./make_basepkg.sh <pkgname>
#        first, please run
#          ./make_basepkg.sh base
#     4. created tarball for pkg_add

# valiables

: ${SRC:=/usr/src}
: ${PKGSRC:=/usr/pkgsrc}
: ${PACKAGES:=./packages}
host="$(hostname)"
machine_arch="$(uname -m)"
opsys="$(uname)"
osversion="$(uname -r)"
pkgname="$(echo $1 | sed 's/\///')"
pkgtoolversion=""
prog="${0##*/}"
rcsid='$NetBSD: make_basepkg.sh,v 0.01 2016/10/19 15:36:22 enomoto Exp $'
utcdate="$(env TZ=UTC LOCALE=C date '+%Y-%m-%d %H:%M')"
user="${USER:-root}"

if [ -f ${PKGSRC}/pkgtools/pkg_install/files/lib/version.h ]; then
	pkgtoolversion="$(awk '/PKGTOOLS_VERSION/ {print $3}' \
	${PKGSRC}/pkgtools/pkg_install/files/lib/version.h)"
else
	pkgtoolversion="20160410"
fi

# functions

make_list(){
  echo "making $1 package contents list..."
	if [ ! -d list ]; then
		mkdir list
	fi	
	find $1 -type d | grep -v "mtree" | \
  grep -v "obsolete" | sed "s/^$1\///g" > list/dir.$1
	find $1 -type f | grep -v "mtree" | \
  grep -v "obsolete" | sed "s/^$1\///g" > list/file.$1
	if [ $1 != "base" ]; then
		grep -x -f list/dir.base list/dir.$1 > list/dir.$1.duplicate
		diff list/dir.$1 list/dir.$1.duplicate | \
		awk '$1 == "<" {print $2}' > list/dir.$1.tmp
		rm -f list/dir.$1.duplicate list/dir.$1
		mv list/dir.$1.tmp list/dir.$1
	fi	
}

make_BUILD_INFO(){
  echo "making $1 package build infomation..."
	echo "OPSYS=$opsys" > $1/+BUILD_INFO
	echo "OS_VERSION=$osversion" >> $1/+BUILD_INFO
	echo "OBJECT_FMT=ELF" >> $1/+BUILD_INFO
	echo "MACHINE_ARCH=$machine_arch" >> $1/+BUILD_INFO
	echo "MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}" >> $1/+BUILD_INFO
	echo "PKGTOOLS_VERSION=$pkgtoolversion" >> $1/+BUILD_INFO
}

make_COMMENT(){
  echo "making $1 package comment..."
	echo "System Package for $1" > $1/+COMMENT
}

make_CONTENTS(){
  echo "making $1 package contents from list..."
	echo "@name $1-`sh ${SRC}/sys/conf/osrelease.sh`" > $1/+CONTENTS
	echo "@comment Packaged at ${utcdate} UTC by ${user}@${host}" \
	>> $1/+CONTENTS
	echo "@comment Packaged using ${prog} ${rcsid}" >> $1/+CONTENTS
	echo "@cwd /" >> $1/+CONTENTS

	# directory
	cat list/dir.$1 | \
	awk '{print "@exec install -d -o root -g wheel -m 0755 %D"$1}' \
	>> $1/+CONTENTS

	# file
	cat list/file.$1 | grep -v '+[A-Z]' >> $1/+CONTENTS

	if [ $1 != "base" ]; then
		sed -i '5d' $1/+CONTENTS
	fi

}

make_DESC(){
  echo "making $1 package description..."
	echo "NetBSD base system" > $1/+DESC
	echo "" >> $1/+DESC
	echo "Homepage:" >> $1/+DESC
	echo "http://www.netbsd.org/" >> $1/+DESC
}

make_PKG(){
  echo "making $1 package using pkg_create..."
	pkg_create -l -U -B $1/+BUILD_INFO -c $1/+COMMENT \
	-d $1/+DESC -f $1/+CONTENTS $1 
  mv $1.tgz ./${PACKAGES}/$1.tgz
}

clean_plus_file(){
	if [ -f $1/+BUILD_INFO ]; then
		rm -f $1/+BUILD_INFO
	fi	
	if [ -f $1/+CONTENTS ]; then
		rm -f $1/+CONTENTS
	fi
	if [ -f $1/+COMMENT ]; then
		rm -f $1/+COMMENT
	fi
	if [ -f $1/+DESC ]; then
		rm -f $1/+DESC
	fi	
}

# main

clean_plus_file $pkgname
make_list $pkgname
make_BUILD_INFO $pkgname
make_COMMENT $pkgname
make_CONTENTS $pkgname
make_DESC $pkgname
make_PKG $pkgname
