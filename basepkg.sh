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
lists="${PWD}/lists"
bases="base comp debug etc games man misc modules tests text xbase xcomp xdebug xetc xfont xserver"

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
		if [ ! -d ./work/$i ]; then
			mkdir -p ./work/$i
		fi
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
		if [ ! -d ./$i ]; then
			mkdir -p ./$i
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
		 cd	./$i ;
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
	for j in $bases
	do
		for k in $j
		do
			grep "$k" ./.work/$j/lists | tr ' ' '\n' | \
			awk 'NR != 1{print $0}' > ./$j/$k/$k.list
		done
	done
}

##########################################################
# make_BUILD_INFO -- Output String For +BUILD_INFO
#
# Argument: <basename>/<pkgname> (Ex. base/base-sys-root)
##########################################################
make_BUILD_INFO(){
	echo "OPSYS=$opsys" > ./$1/+BUILD_INFO
	echo "OS_VERSION=$osversion" >> ./$1/+BUILD_INFO
	echo "OBJECT_FMT=ELF" >> ./$1/+BUILD_INFO
	echo "MACHINE_ARCH=$machine_arch" >> ./$1/+BUILD_INFO
	echo "MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}" >> ./$1/+BUILD_INFO
	echo "PKGTOOLS_VERSION=$pkgtoolversion" >> ./$1/+BUILD_INFO
}

###################################################
# make_COMMENT -- Output String For +COMMENT
#
# Argument: Packages Name (Ex. base/base-sys-root)
###################################################
make_COMMENT(){
	if [ ! -f ./$1/+COMMENT ]; then
		echo "System Package for $1" > ./$1/+COMMENT
	fi
}

###################################################
# make_CONTENTS -- Output String For +CONTENTS
#
# Argument: Packages Name (Ex. base/base-sys-root)
###################################################
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
	cat ./$1/$pkgname.list | while read i
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

#######################################
# make_DESC -- Output String For +DESC
#
# Argument: Packages Name
#######################################
make_DESC() {
	if [ ! -f ./$1/+DESC ]; then
		echo "NetBSD base system" > ./$1/+DESC
		echo "" >> ./$1/+DESC
		echo "Homepage:" >> ./$1/+DESC
		echo "http://www.netbsd.org/" >> ./$1/+DESC
	fi
}

########################################################
# make_PKG -- Create Package Tarball
#
# Argument: Packages Name
#
# XXX: If /var files packaging, pkg_create failed.
#      Need root privilege.
########################################################
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
	mv ./$pkgname.tgz ${PACKAGES}/$setname/$pkgname.tgz
}

############################################
# make_packages -- make_* Functions Wrapper
#                  Run It if make Packages
#
# Argument: None.
############################################
make_packages() {
	for i in $bases
	do
		for j in `ls ./$i`
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
	extract)
		extract_base
		;;
	*)
		usage
		;;
esac
