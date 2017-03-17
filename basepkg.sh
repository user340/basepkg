#!/usr/bin/env sh

SRC="/usr/src"
PACKAGES="./packages"
host="$(hostname)"
machine="$(uname -m)"
machine_arch="$(uname -p)"
opsys="$(uname)"
osversion="$(uname -r)"
pkgtoolversion="$(pkg_add -V)"
prog="${0##*/}"
rcsid='$NetBSD: make_basepkg.sh,v 0.01 2016/10/19 15:36:22 uki Exp $'
utcdate="$(env TZ=UTC LOCALE=C date '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
sets="/usr/obj/releasedir/${machine}/binary/sets"
database="${PWD}/database"
lists="${database}/lists"
comments="${database}/comments"
descrs="${database}/descrs"
deps="${database}/deps"
category="base comp etc games man misc text"
progname=${0##*/}

# "extract" option using following function.
extract_base_binaries() {
	for i in `ls ${sets} | grep 'tgz$' | sed 's/\.tgz//g'`
	do
		if [ ! -d ./work/${i} ]; then
			mkdir -p ./work/${i}
		fi
		tar zxvf ${sets}/${i}.tgz -C ./work/${i}
	done
}

# "dir" option using following functions.
split_category_from_lists() {
	for i in ${category}
	do
		if [ ! -d ./${i} ]; then
			mkdir ./${i}
		fi
		if [ -f ./${i}/FILES ]; then
			rm -f ./${i}/FILES
		fi
		for j in `ls ${lists}`
		do
			grep -E "${i}-[a-z]+-[a-z]+" ${lists}/${j}/mi | \
			awk '$3 !~ /obsolete/ {print}' | \
			sed -e 's/^\.\///' -e '/^#/d' >> ./${i}/FILES
	
			if [ -f ${lists}/${j}/md.${machine} ]; then
				grep -E "${i}-[a-z]+-[a-z]+" ${lists}/${j}/md.${machine} | \
				awk '$3 !~ /obsolete/ {print}' | \
				sed -e 's/^\.\///' -e '/^#/d' >> ./${i}/FILES
			fi
		done
	done
}

make_directories_of_package() {
	for i in ${category}
	do
		awk '{print $2}' ./${i}/FILES | sort | uniq | \
		xargs -n 1 -I % mkdir ./${i}/%
	done
}

# "list" option using following function.
make_contents_list() {
	for i in ${category}
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
		}' ${i}/FILES > ./${i}/CATEGORIZED
	done
	for i in ${category}
	do
		for j in `ls ./${i} | grep '^[a-z]'`
		do
			grep "${j}" ./${i}/CATEGORIZED | tr ' ' '\n' | \
			awk 'NR != 1{print $0}' | sort | \
			grep -v -E "x${i}-[a-z]+-[a-z]+" > ./${i}/${j}/${j}.FILES
		done
	done
}

# "pkg" option using following functions.
make_BUILD_INFO(){
	cat > ./$1/+BUILD_INFO << _BUILD_INFO_
OPSYS=${opsys}
OS_VERSION=${osversion}
OBJECT_FMT=ELF
MACHINE_ARCH=${machine_arch}
MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}
PKGTOOLS_VERSION=${pkgtoolversion}
_BUILD_INFO_
}

make_CONTENTS() {
	if [ -f ./$1/tmp.list ]; then
		rm -f ./$1/tmp.list
	fi
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	echo "@name ${pkgname}-`sh ${SRC}/sys/conf/osrelease.sh`" > ./$1/+CONTENTS
	echo "@comment Packaged at ${utcdate} UTC by ${user}@${host}" \
	>> ./$1/+CONTENTS
	echo "@comment Packaged using ${prog} ${rcsid}" >> ./$1/+CONTENTS
	echo "@cwd /" >> ./$1/+CONTENTS
	cat ./$1/${pkgname}.FILES | while read i
	do
		filetype=`file ./work/$setname/${i} | awk '{print $2}'`
		if [ ${filetype} = directory ]; then
			filename=`echo ${i} | sed 's%\/%\\\/%g'`
			awk '$1 ~ /^\.\/'"${filename}"'$/{print $0}' ./work/${setname}/etc/mtree/set.${setname} | \
			sed 's%^\.\/%%' | \
			awk '{print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1}' >> ./$1/tmp.list
		elif [ ${filetype} = cannot ]; then
			continue
		else
			echo ${i} >> ./$1/tmp.list
		fi
	done
	if [ ! -f ./$1/tmp.list ]; then
		return 1
	fi
	sort ./$1/tmp.list >> ./$1/+CONTENTS
}

make_DESC_and_COMMENT() {
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	grep ${pkgname} ${descrs} | sed -e "s/${pkgname} //" > ./$1/+DESC
	grep ${pkgname} ${comments} | sed -e "s/${pkgname} //" > ./$1/+COMMENT
}

make_PKG() {
	setname=`echo $1 | awk 'BEGIN{FS="/"} {print $1}' | sed 's/\./-/g'`
	pkgname=`echo $1 | awk 'BEGIN{FS="/"} {print $2}' | sed 's/\./-/g'`
	pkg_create -l -U -B $1/+BUILD_INFO -c $1/+COMMENT \
	-d $1/+DESC -f $1/+CONTENTS -I / -p ${PWD}/work/${setname} ${pkgname}
	if [ $? != 0 ]; then
		return $?
	fi
	if [ ! -d ${PACKAGES} ]; then
	  mkdir ${PACKAGES}
	fi
	if [ ! -d ${PACKAGES}/${setname} ]; then
	  mkdir -p ${PACKAGES}/${setname}
	fi
	mv ./${pkgname}.tgz \
	${PACKAGES}/${setname}/${pkgname}-`sh ${SRC}/sys/conf/osrelease.sh`.tgz
}

make_packages() {
	for i in ${category}
	do
		for j in `ls ./${i} | grep -E '^[a-z]+'`
		do
			echo "Package ${i}/${j} Creating..."
			make_BUILD_INFO ${i}/${j}
			make_CONTENTS ${i}/${j}
			make_DESC_and_COMMENT ${i}/${j}
			make_PKG ${i}/${j}
		done
	done
}

# "clean" option using following functions.
clean_packages() {
	rm -fr ${PACKAGES}
}

clean_categories() {
	for i in ${category}
	do
		rm -fr ${i}
	done
}

# self-explanatorily :-)
usage() {
	cat <<_usage_

Usage: ${progname} [--sets sets] [--src src] [--pkgsrc pkgsrc]
                   [--pkg packages]
                  operation

 Operation:
    extract     Extract base binary.
    dir         Create packages directory.
    list        Create packages list.
    pkg         Create packages.
    all         Running dir,list,pkg options.
    clean       Remove all packages and created directories.

 Options:
    -h | --help Show this message and exit.
    --sets      Set sets to extract tarballs.
                [Default: /usr/obj/releasedir/${machine}/binary/sets]
    --src       Set SRC to NetBSD source directory.
                [Default: /usr/src]
    --pkg       Set packages root directory; sets a PACKAGES pattern.
                [Default: ./packages]

_usage_
	exit 1
}

# parse long-options
for OPT in $@
do
	case ${OPT} in
		'-h'|'--help' )
			usage
			;;
		'--sets' )
			if [ -z $2 ]; then
				echo "What is $1 parameter?" 1>&2
				exit 1
			fi
			sets=$2
			shift
			shift
			;;
		'--src' )
			if [ -z $2 ]; then
				echo "What is $1 parameter?" 1>&2
				exit 1
			fi
			SRC=$2
			shift
			shift
			;;
		'--pkg' )
			if [ -z $2 ]; then
				echo "What is $1 parameter?" 1>&2
				exit 1
			fi
			PACKAGES=$2
			shift
			shift
			;;
		'-'|'--' )
			shift
			break
			;;
		* )
			break
			;;
	esac
done

# operation
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
	all)
		split_category_from_lists
		make_directories_of_package
		make_contents_list
		make_packages
		;;
	clean)
		clean_packages
		clean_categories
		;;
	*)
		usage
		;;
esac
