#!/bin/sh

: ${SRC:=/usr/src}
: ${OBJ:=/usr/obj}
: ${PKGSRC:=/usr/pkgsrc}
: ${PACKAGES:=./packages}
host="$(hostname)"
machine="$(uname -m)"
machine_arch="$(uname -p)"
opsys="$(uname)"
osversion="$(uname -r)"
pkgtoolversion=""
prog="${0##*/}"
rcsid='$NetBSD: make_basepkg.sh,v 0.01 2016/10/19 15:36:22 enomoto Exp $'
utcdate="$(env TZ=UTC LOCALE=C date '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
sets="${OBJ}/releasedir/${machine}/binary/sets"
lists="${PWD}/database/lists"
category="base comp etc games man misc text"

if [ -f ${PKGSRC}/pkgtools/pkg_install/files/lib/version.h ]; then
	pkgtoolversion="$(awk '/PKGTOOLS_VERSION/ {print $3}' \
	${PKGSRC}/pkgtools/pkg_install/files/lib/version.h)"
else
	pkgtoolversion="20160410"
fi

# "extract" option using following function.
extract_base_binaries() {
	for i in `ls $sets | grep 'tgz$' | sed 's/\.tgz//g'`
	do
		if [ ! -d ./work/$i ]; then
			mkdir -p ./work/$i
		fi
		tar zxvf $sets/$i.tgz -C ./work/$i
	done
}

# "dir" option using following functions.
split_category_from_lists() {
	for i in $category
	do
		if [ ! -d ./$i ]; then
			mkdir ./$i
		fi
		if [ -f ./$i/FILES ]; then
			rm -f ./$i/FILES
		fi
		for j in `ls $lists`
		do
			grep -E "$i-[a-z]+-[a-z]+" $lists/$j/mi | \
			sed -e 's/^\.\///' -e '/^#/d' >> ./$i/FILES
	
			test -f $lists/$j/md.$machine && grep -E "$i-[a-z]+-[a-z]+" \
			$lists/$j/md.$machine | sed -e 's/^\.\///' -e '/^#/d' \
			>> ./$i/FILES
		done
	done
}

make_directories_of_package() {
	for i in $category
	do
		awk '{print $2}' ./$i/FILES | sort | uniq | \
		xargs -n 1 -I % mkdir ./$i/%
	done
}

# "list" option using following function.
make_contents_list() {
	for i in $category
	do
		awk ' 
		# $1 - file name
		# $2 - package name
		$2 ~ /\./ {
			gsub(/\./, "-", $2)
		}
		{
			if($2 in lists)
				lists[$2] = $1 " " lists[$2]
			else
				lists[$2] = $1
		}
		END {
			for(pkg in lists)
				print pkg, lists[pkg]
		}' $i/FILES > ./$i/CATEGORIZED
	done
	for i in $category
	do
		for j in `ls ./$i | grep '^[a-z]'`
		do
			grep "$j" ./$i/CATEGORIZED | tr ' ' '\n' | \
			awk 'NR != 1{print $0}' | sort | \
			grep -v -E "x$i-[a-z]+-[a-z]+" > ./$i/$j/$j.FILES
		done
	done
}

# "pkg" option using following functions.
make_BUILD_INFO(){
	echo "OPSYS=$opsys" > ./$1/+BUILD_INFO
	echo "OS_VERSION=$osversion" >> ./$1/+BUILD_INFO
	echo "OBJECT_FMT=ELF" >> ./$1/+BUILD_INFO
	echo "MACHINE_ARCH=$machine_arch" >> ./$1/+BUILD_INFO
	echo "MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}" >> ./$1/+BUILD_INFO
	echo "PKGTOOLS_VERSION=$pkgtoolversion" >> ./$1/+BUILD_INFO
}

make_COMMENT(){
	if [ ! -f ./$1/+COMMENT ]; then
		echo "System Package for $1" > ./$1/+COMMENT
	fi
}

make_CONTENTS() {
	if [ -f ./$1/tmp.list ]; then
		rm -f ./$1/tmp.list
	fi
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	echo "@name $pkgname-`sh ${SRC}/sys/conf/osrelease.sh`" > ./$1/+CONTENTS
	echo "@comment Packaged at ${utcdate} UTC by ${user}@${host}" >> ./$1/+CONTENTS
	echo "@comment Packaged using ${prog} ${rcsid}" >> ./$1/+CONTENTS
	echo "@cwd /" >> ./$1/+CONTENTS
	# XXX: This package may be empty package
	cat ./$1/$pkgname.FILES | while read i
	do
		filetype=`file ./work/$setname/$i | awk '{print $2}'`
		if [ $filetype = directory ]; then
			filename=`echo $i | sed 's%\/%\\\/%g'`
			awk '$1 ~ /^\.\/'"${filename}"'$/{print $0}' ./work/$setname/etc/mtree/set.$setname | \
			sed 's%^\.\/%%' | \
			awk '{print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1}' >> ./$1/tmp.list
		elif [ $filetype = cannot ]; then
			continue
		else
			echo $i >> ./$1/tmp.list
		fi
	done
	if [ ! -f ./$1/tmp.list ]; then
		return 1
	fi
	sort ./$1/tmp.list >> ./$1/+CONTENTS
}

make_DESC() {
	if [ ! -f ./$1/+DESC ]; then
		echo "NetBSD base system" > ./$1/+DESC
		echo "" >> ./$1/+DESC
		echo "Homepage:" >> ./$1/+DESC
		echo "http://www.netbsd.org/" >> ./$1/+DESC
	fi
}

make_PKG() {
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	pkg_create -l -U -B $1/+BUILD_INFO -c $1/+COMMENT \
	-d $1/+DESC -f $1/+CONTENTS -I / -p ${PWD}/work/$setname $pkgname
	if [ $? != 0 ]; then
		return $?
	fi
	if [ ! -d ${PACKAGES} ]; then
	  mkdir ${PACKAGES}
	fi
	if [ ! -d ${PACKAGES}/$setname ]; then
	  mkdir -p ${PACKAGES}/$setname
	fi
	mv ./$pkgname.tgz ${PACKAGES}/$setname/$pkgname-$osversion.tgz
}

make_packages() {
	for i in $category
	do
		for j in `ls ./$i | grep -E '^[a-z]+'`
		do
			echo "Package $i/$j Creating..."
			make_BUILD_INFO $i/$j
			make_COMMENT $i/$j
			make_CONTENTS $i/$j
			make_DESC $i/$j
			make_PKG $i/$j
		done
	done
}

usage() {
	echo "usage: ./basepkg.sh <option>"
	echo " Options:"
	echo "   extract   extract base binary"
	echo "   dir       create packages directory"
	echo "   list      create packages list"
	echo "   pkg       create packages"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi

case $1 in
	extract)
		extract_base_binaries
		;;
	dir) 
		split_category_from_lists
		make_directories_of_package
		;;
	list)
		make_contents_list
		;;
	pkg)		 
		make_packages
		;;
	*)
		usage
		;;
esac
