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
	for i in base comp etc games kern-GENERIC man misc modules tests text
	do
		test -d ./work/$i || mkdir -p ./work/$i
		tar zxvf $sets/$i.tgz -C ./work/$i
	done
}

####################################################
# create_root_list -- Create Packages Root Hierachy
#
# Argument: Any Sets Name.
####################################################
create_root_list() {
	for i in $@
	do
		test -d ./work/$i || (echo "./work/$i not found." ; exit 1)
		test -d ./sets/$i/root || mkdir -p ./sets/$i/root
		cat ./work/$i/etc/mtree/set.$i | mtree -C | grep "type=dir" | sed 's/^\.\///g' | \
		awk '{print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1 }' \
		>> ./sets/$i/root/root.list
	done
}

###################################################
# make_BUILD_INFO -- Output String For +BUILD_INFO
#
# Argument: Set/Packages Name (ex. base/openssl)
###################################################
make_BUILD_INFO(){
	echo "making $1 package build infomation..."
	echo "OPSYS=$opsys" > ./sets/$1/+BUILD_INFO
	echo "OS_VERSION=$osversion" >> ./sets/$1/+BUILD_INFO
	echo "OBJECT_FMT=ELF" >> ./sets/$1/+BUILD_INFO
	echo "MACHINE_ARCH=$machine_arch" >> ./sets/$1/+BUILD_INFO
	echo "MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}" >> ./sets/$1/+BUILD_INFO
	echo "PKGTOOLS_VERSION=$pkgtoolversion" >> ./sets/$1/+BUILD_INFO
}

#############################################
# make_COMMENT -- Output String For +COMMENT
#
# Argument: Packages Name
#############################################
make_COMMENT(){
	echo "making $1 package comment..."
	echo "System Package for $1" > ./sets/$1/+COMMENT
}

###############################################
# make_CONTENTS -- Output String For +CONTENTS
#
# Argument: Packages Name
###############################################
make_CONTENTS(){
	set_name=`echo $1 | awk 'BEGIN{FS="/"} {print $1}'`
	pkg_name=`echo $1 | awk 'BEGIN{FS="/"} {print $2}'`
	echo "making $1 package contents from list..."
	echo "@name $set_name-$pkg_name-`sh ${SRC}/sys/conf/osrelease.sh`" > sets/$1/+CONTENTS
	echo "@comment Packaged at ${utcdate} UTC by ${user}@${host}" >> ./sets/$1/+CONTENTS
	echo "@comment Packaged using ${prog} ${rcsid}" >> ./sets/$1/+CONTENTS
	echo "@cwd /" >> ./sets/$1/+CONTENTS
	cat ./sets/$1/$pkg_name.list | grep -v '+[A-Z]' >> ./sets/$1/+CONTENTS
}

#######################################
# make_DESC -- Output String For +DESC
#
# Argument: Packages Name
#######################################
make_DESC(){
	echo "making $1 package description..."
	echo "NetBSD base system" > sets/$1/+DESC
	echo "" >> sets/$1/+DESC
	echo "Homepage:" >> sets/$1/+DESC
	echo "http://www.netbsd.org/" >> sets/$1/+DESC
}

#####################################
# make_PKG -- Create Package Tarball
#
# Argument: Packages Name
#####################################
make_PKG(){
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}'`
 	echo "making $1 package using pkg_create..."
 	pkg_create -l -U -B sets/$1/+BUILD_INFO -c sets/$1/+COMMENT \
 	-d sets/$1/+DESC -f sets/$1/+CONTENTS -I / -p ${PWD}/work/$setname $setname-$pkgname
 	mv ./$setname-$pkgname.tgz ${PACKAGES}/$setname-$pkgname.tgz
}

################################################
# make_pkgdir -- create packages name directory
#
# Argument: None.
################################################
make_pkgdir() {
	for i in `ls $lists | grep -v '^[A-Z]'`
	do
		if [ ! -d ./sets/$i ]; then
			mkdir ./sets/$i
		fi
		if [ ! -f $lists/$i/mi ]; then
			continue
		fi
		( 
		 cd  ./sets/$i ;
		 awk '$1 !~ /^#/{print $1 " " $2}' $lists/$i/mi | sort -k2 | \
		 awk '{print $2}' | uniq | awk '$1 !~ /^-/{print $0}' | xargs mkdir
		)
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
	echo "    pkg        create packages"
	echo ""
	echo " Other operations"
	echo "    root   create root hierachy"
	echo "    clean      remove information files"
	echo "    extract    extract base binary"
	exit 1
}

if [ $# != 1 ]; then
	usage
fi

###############
# MAIN PROCESS
###############
case $1 in
	root) create_root_list base comp etc games man misc modules tests text
	      ;;
	pkgdir) make_pkgdir
			;;
	clean) clean_plus_file ;;
	extract) extract_base ;;
	pkg)     make_BUILD_INFO
	         make_COMMENT
					 make_CONTENTS
					 make_DESC
					 make_PKG
	         ;;
	test)		 test_func ;;
	*) usage ;;
esac
