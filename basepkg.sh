#!/bin/sh

############
# Valiables
############
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
lists="${SRC}/distrib/sets/lists"

if [ -f ${PKGSRC}/pkgtools/pkg_install/files/lib/version.h ]; then
	pkgtoolversion="$(awk '/PKGTOOLS_VERSION/ {print $3}' \
	${PKGSRC}/pkgtools/pkg_install/files/lib/version.h)"
else
	pkgtoolversion="20160410"
fi

###########################################
# extract_base -- Extract Base Binary Sets
#
# Argument: None.
###########################################
extract_base() {
	for i in `ls $sets | grep 'tgz$' | sed 's/\.tgz//g'`
	do
		test -d ./work/$i || mkdir -p ./work/$i
		tar zxvf $sets/$i.tgz -C ./work/$i
	done
}

################################################
# make_pkgdir -- create packages name directory
#
# Argument: None.
################################################
make_pkgdir() {
	listfile=""
	for i in `ls $lists | grep -v '^[A-Z]'`
	do
		if [ ! -d ./sets/$i ]; then
			mkdir -p ./sets/$i
		fi
		if [ ! -f $lists/$i/mi ]; then
			continue
		fi
		if [ -f $lists/$i/md.$machine ]; then
			listfile="$lists/$i/md.$machine $lists/$i/mi"
		else
			listfile="$lists/$i/mi"
		fi
		( 
		 cd	./sets/$i ;
		 cat $listfile | awk '$1 !~ /^#/{print $1 " " $2}' | sort -k2 | \
		 awk '{print $2}' | uniq | awk '$1 !~ /^-/{print $0}' | sed 's/\./-/g' | xargs mkdir
		)
	done
}

###################################
# make_list -- Make Packages Lists
#
# Argument: None.
###################################
make_list() {
	listfile=""
	if [ ! -d ./.work ]; then
		mkdir .work
	fi
	for i in `ls $lists | grep -v '^[A-Z]'`
	do
		if [ ! -d ./.work/$i ]; then
			mkdir ./.work/$i
		fi
		if [ -f $lists/$i/md.$machine ]; then
			listfile="$lists/$i/md.$machine $lists/$i/mi"
		else
			listfile="$lists/$i/mi"
		fi
		cat $listfile | awk '$1 !~ /^#/{print $1 " " $2}' | \
		sort -k2 | sed 's/^\.\///g'	| \
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
		}' > ./.work/$i/lists
	done
	for j in `ls ./sets`
	do
		for k in `ls ./sets/$j`
		do
			grep "$k" ./.work/$j/lists | tr ' ' '\n' | \
			awk 'NR != 1{print $0}' > ./sets/$j/$k/$k.list
		done
	done
}

##########################################################
# make_BUILD_INFO -- Output String For +BUILD_INFO
#
# Argument: <basename>/<pkgname> (Ex. base/base-sys-root)
##########################################################
make_BUILD_INFO(){
	echo "OPSYS=$opsys" > ./sets/$1/+BUILD_INFO
	echo "OS_VERSION=$osversion" >> ./sets/$1/+BUILD_INFO
	echo "OBJECT_FMT=ELF" >> ./sets/$1/+BUILD_INFO
	echo "MACHINE_ARCH=$machine_arch" >> ./sets/$1/+BUILD_INFO
	echo "MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}" >> ./sets/$1/+BUILD_INFO
	echo "PKGTOOLS_VERSION=$pkgtoolversion" >> ./sets/$1/+BUILD_INFO
}

###################################################
# make_COMMENT -- Output String For +COMMENT
#
# Argument: Packages Name (Ex. base/base-sys-root)
###################################################
make_COMMENT(){
	echo "System Package for $1" > ./sets/$1/+COMMENT
}

###################################################
# make_CONTENTS -- Output String For +CONTENTS
#
# Argument: Packages Name (Ex. base/base-sys-root)
###################################################
make_CONTENTS() {
	if [ -f ./sets/$1/tmp.list ]; then
		rm ./sets/$1/tmp.list
	fi
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	echo "@name $pkgname-`sh ${SRC}/sys/conf/osrelease.sh`" > sets/$1/+CONTENTS
	echo "@comment Packaged at ${utcdate} UTC by ${user}@${host}" >> ./sets/$1/+CONTENTS
	echo "@comment Packaged using ${prog} ${rcsid}" >> ./sets/$1/+CONTENTS
	echo "@cwd /" >> ./sets/$1/+CONTENTS
	# XXX: This package may be empty package
	cat ./sets/$1/$pkgname.list | while read i
	do
		filetype=`file ./work/$setname/$i | awk '{print $2}'`
		if [ $filetype = directory ]; then
			filename=`echo $i | sed 's%\/%\\\/%g'`
			awk '$1 ~ /^\.\/'"${filename}"'$/{print $0}' ./work/$setname/etc/mtree/set.$setname | \
			sed 's%^\.\/%%' | \
			awk '{print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1}' >> ./sets/$1/tmp.list
		elif [ $filetype = cannot ]; then
			continue
		else
			echo $i >> ./sets/$1/tmp.list
		fi
	done
	if [ ! -f ./sets/$1/tmp.list ]; then
		return 1
	fi
	sort ./sets/$1/tmp.list >> ./sets/$1/+CONTENTS
}

#######################################
# make_DESC -- Output String For +DESC
#
# Argument: Packages Name
#######################################
make_DESC(){
	echo "NetBSD base system" > sets/$1/+DESC
	echo "" >> sets/$1/+DESC
	echo "Homepage:" >> sets/$1/+DESC
	echo "http://www.netbsd.org/" >> sets/$1/+DESC
}

########################################################
# make_PKG -- Create Package Tarball
#
# Argument: Packages Name
#
# XXX: If /var files packaging, pkg_create failed.
#      Need root privilege.
# XXX: If packages name include ".", pkg_create failed.
#      Example: tests-usr.bin-debug packages
########################################################
make_PKG(){
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	pkg_create -l -U -B sets/$1/+BUILD_INFO -c sets/$1/+COMMENT \
	-d sets/$1/+DESC -f sets/$1/+CONTENTS -I / -p ${PWD}/work/$setname $pkgname
	if [ $? != 0 ]; then
		return $?
	fi
	if [ ! -d ${PACKAGES} ]; then
	  mkdir ${PACKAGES}
	fi
	if [ ! -d ${PACKAGES}/$setname ]; then
	  mkdir -p ${PACKAGES}/$setname
	fi
	mv ./$pkgname.tgz ${PACKAGES}/$setname/$pkgname.tgz
}

############################################
# make_packages -- make_* Functions Wrapper
#                  Run It if make Packages
#
# Argument: None.
############################################
make_packages() {
	for i in `ls ./sets`
	do
		for j in `ls ./sets/$i`
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

######################################################
# clean_plus_file -- Remove Packages Information File
#
# Argument: None.
######################################################
clean_plus_file(){
	find ./sets -name '\+[A-Z]*' | xargs rm -f
}

########################################
# usage -- Print How to Use This Script
#
# Argument: None.
########################################
usage() {
	echo "usage: ./basepkg.sh operation"
	echo " Create packages operations"
	echo "   extract   extract base binary"
	echo "   dir       create packages directory"
	echo "   list      create packages list"
	echo "   pkg       create packages"
	echo ""
	echo " Other operations"
	echo "   clean     remove information files"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi

###############
# MAIN PROCESS
###############
case $1 in
	dir) 
		make_pkgdir
		;;
	pkg)		 
		make_packages
		;;
	list)
		make_list
		;;
	clean)
		clean_plus_file
		;;
	extract)
		extract_base
		;;
	root)
		make_rootpriv_testspackages
		make_rootpriv_etcspackages
		;;
	*)
		usage
		;;
esac
