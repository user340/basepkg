#!/bin/sh
#
# Copyright (c) 2001-2018 The NetBSD Foundation, Inc.
# Copyright (c) 2016, 2017, 2018 Yuuki Enomoto
# All rights reserved. 
#  
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met: 
#  
# * Redistributions of source code must retain the above copyright notice, 
#   this list of conditions and the following disclaimer.
#  
# * Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution. 
#  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#

#
# basepkg.sh --  Kernel program of NetBSD system package.
#
# It does the following works.
#     - Make packages of base in reference to /usr/obj (default).
#     - Make kernel packages in reference to 
#       /usr/obj/sys/<MACHINE>/compile (default).
#
# These are POSIX undefined command.
#     - hostname(1) -- set or print name of current host system.
#     - mktemp(1) -- make temporary file name.
#     - pkg_create(1) -- a utility for creating software package distributions.
#
# Please use ShellCheck (https://koalaman/shellcheck) for your code. 
#

###
# Global variables
#

# define new line and tab 
nl='
'
tab='		'

# From build.sh
valid_MACHINE_ARCH='
MACHINE=acorn26		MACHINE_ARCH=arm
MACHINE=acorn32		MACHINE_ARCH=arm
MACHINE=algor		MACHINE_ARCH=mips64el	ALIAS=algor64
MACHINE=algor		MACHINE_ARCH=mipsel	DEFAULT
MACHINE=alpha		MACHINE_ARCH=alpha
MACHINE=amd64		MACHINE_ARCH=x86_64
MACHINE=amiga		MACHINE_ARCH=m68k
MACHINE=amigappc	MACHINE_ARCH=powerpc
MACHINE=arc		MACHINE_ARCH=mips64el	ALIAS=arc64
MACHINE=arc		MACHINE_ARCH=mipsel	DEFAULT
MACHINE=atari		MACHINE_ARCH=m68k
MACHINE=bebox		MACHINE_ARCH=powerpc
MACHINE=cats		MACHINE_ARCH=arm	ALIAS=ocats
MACHINE=cats		MACHINE_ARCH=earmv4	ALIAS=ecats DEFAULT
MACHINE=cesfic		MACHINE_ARCH=m68k
MACHINE=cobalt		MACHINE_ARCH=mips64el	ALIAS=cobalt64
MACHINE=cobalt		MACHINE_ARCH=mipsel	DEFAULT
MACHINE=dreamcast	MACHINE_ARCH=sh3el
MACHINE=emips		MACHINE_ARCH=mipseb
MACHINE=epoc32		MACHINE_ARCH=arm
MACHINE=evbarm		MACHINE_ARCH=arm	ALIAS=evboarm-el
MACHINE=evbarm		MACHINE_ARCH=armeb	ALIAS=evboarm-eb
MACHINE=evbarm		MACHINE_ARCH=earm	ALIAS=evbearm-el DEFAULT
MACHINE=evbarm		MACHINE_ARCH=earmeb	ALIAS=evbearm-eb
MACHINE=evbarm		MACHINE_ARCH=earmhf	ALIAS=evbearmhf-el
MACHINE=evbarm		MACHINE_ARCH=earmhfeb	ALIAS=evbearmhf-eb
MACHINE=evbarm		MACHINE_ARCH=earmv4	ALIAS=evbearmv4-el
MACHINE=evbarm		MACHINE_ARCH=earmv4eb	ALIAS=evbearmv4-eb
MACHINE=evbarm		MACHINE_ARCH=earmv5	ALIAS=evbearmv5-el
MACHINE=evbarm		MACHINE_ARCH=earmv5eb	ALIAS=evbearmv5-eb
MACHINE=evbarm		MACHINE_ARCH=earmv6	ALIAS=evbearmv6-el
MACHINE=evbarm		MACHINE_ARCH=earmv6hf	ALIAS=evbearmv6hf-el
MACHINE=evbarm		MACHINE_ARCH=earmv6eb	ALIAS=evbearmv6-eb
MACHINE=evbarm		MACHINE_ARCH=earmv6hfeb	ALIAS=evbearmv6hf-eb
MACHINE=evbarm		MACHINE_ARCH=earmv7	ALIAS=evbearmv7-el
MACHINE=evbarm		MACHINE_ARCH=earmv7eb	ALIAS=evbearmv7-eb
MACHINE=evbarm		MACHINE_ARCH=earmv7hf	ALIAS=evbearmv7hf-el
MACHINE=evbarm		MACHINE_ARCH=earmv7hfeb	ALIAS=evbearmv7hf-eb
MACHINE=evbarm64	MACHINE_ARCH=aarch64	ALIAS=evbarm64-el DEFAULT
MACHINE=evbarm64	MACHINE_ARCH=aarch64eb	ALIAS=evbarm64-eb
MACHINE=evbcf		MACHINE_ARCH=coldfire
MACHINE=evbmips		MACHINE_ARCH=		NO_DEFAULT
MACHINE=evbmips		MACHINE_ARCH=mips64eb	ALIAS=evbmips64-eb
MACHINE=evbmips		MACHINE_ARCH=mips64el	ALIAS=evbmips64-el
MACHINE=evbmips		MACHINE_ARCH=mipseb	ALIAS=evbmips-eb
MACHINE=evbmips		MACHINE_ARCH=mipsel	ALIAS=evbmips-el
MACHINE=evbppc		MACHINE_ARCH=powerpc	DEFAULT
MACHINE=evbppc		MACHINE_ARCH=powerpc64	ALIAS=evbppc64
MACHINE=evbsh3		MACHINE_ARCH=		NO_DEFAULT
MACHINE=evbsh3		MACHINE_ARCH=sh3eb	ALIAS=evbsh3-eb
MACHINE=evbsh3		MACHINE_ARCH=sh3el	ALIAS=evbsh3-el
MACHINE=ews4800mips	MACHINE_ARCH=mipseb
MACHINE=hp300		MACHINE_ARCH=m68k
MACHINE=hppa		MACHINE_ARCH=hppa
MACHINE=hpcarm		MACHINE_ARCH=arm	ALIAS=hpcoarm
MACHINE=hpcarm		MACHINE_ARCH=earmv4	ALIAS=hpcearm DEFAULT
MACHINE=hpcmips		MACHINE_ARCH=mipsel
MACHINE=hpcsh		MACHINE_ARCH=sh3el
MACHINE=i386		MACHINE_ARCH=i386
MACHINE=ia64		MACHINE_ARCH=ia64
MACHINE=ibmnws		MACHINE_ARCH=powerpc
MACHINE=iyonix		MACHINE_ARCH=arm	ALIAS=oiyonix
MACHINE=iyonix		MACHINE_ARCH=earm	ALIAS=eiyonix DEFAULT
MACHINE=landisk		MACHINE_ARCH=sh3el
MACHINE=luna68k		MACHINE_ARCH=m68k
MACHINE=mac68k		MACHINE_ARCH=m68k
MACHINE=macppc		MACHINE_ARCH=powerpc	DEFAULT
MACHINE=macppc		MACHINE_ARCH=powerpc64	ALIAS=macppc64
MACHINE=mipsco		MACHINE_ARCH=mipseb
MACHINE=mmeye		MACHINE_ARCH=sh3eb
MACHINE=mvme68k		MACHINE_ARCH=m68k
MACHINE=mvmeppc		MACHINE_ARCH=powerpc
MACHINE=netwinder	MACHINE_ARCH=arm	ALIAS=onetwinder
MACHINE=netwinder	MACHINE_ARCH=earmv4	ALIAS=enetwinder DEFAULT
MACHINE=news68k		MACHINE_ARCH=m68k
MACHINE=newsmips	MACHINE_ARCH=mipseb
MACHINE=next68k		MACHINE_ARCH=m68k
MACHINE=ofppc		MACHINE_ARCH=powerpc	DEFAULT
MACHINE=ofppc		MACHINE_ARCH=powerpc64	ALIAS=ofppc64
MACHINE=or1k		MACHINE_ARCH=or1k
MACHINE=playstation2	MACHINE_ARCH=mipsel
MACHINE=pmax		MACHINE_ARCH=mips64el	ALIAS=pmax64
MACHINE=pmax		MACHINE_ARCH=mipsel	DEFAULT
MACHINE=prep		MACHINE_ARCH=powerpc
MACHINE=riscv		MACHINE_ARCH=riscv64	ALIAS=riscv64 DEFAULT
MACHINE=riscv		MACHINE_ARCH=riscv32	ALIAS=riscv32
MACHINE=rs6000		MACHINE_ARCH=powerpc
MACHINE=sandpoint	MACHINE_ARCH=powerpc
MACHINE=sbmips		MACHINE_ARCH=		NO_DEFAULT
MACHINE=sbmips		MACHINE_ARCH=mips64eb	ALIAS=sbmips64-eb
MACHINE=sbmips		MACHINE_ARCH=mips64el	ALIAS=sbmips64-el
MACHINE=sbmips		MACHINE_ARCH=mipseb	ALIAS=sbmips-eb
MACHINE=sbmips		MACHINE_ARCH=mipsel	ALIAS=sbmips-el
MACHINE=sgimips		MACHINE_ARCH=mips64eb	ALIAS=sgimips64
MACHINE=sgimips		MACHINE_ARCH=mipseb	DEFAULT
MACHINE=shark		MACHINE_ARCH=arm	ALIAS=oshark
MACHINE=shark		MACHINE_ARCH=earmv4	ALIAS=eshark DEFAULT
MACHINE=sparc		MACHINE_ARCH=sparc
MACHINE=sparc64		MACHINE_ARCH=sparc64
MACHINE=sun2		MACHINE_ARCH=m68000
MACHINE=sun3		MACHINE_ARCH=m68k
MACHINE=vax		MACHINE_ARCH=vax
MACHINE=x68k		MACHINE_ARCH=m68k
MACHINE=zaurus		MACHINE_ARCH=arm	ALIAS=ozaurus
MACHINE=zaurus		MACHINE_ARCH=earm	ALIAS=ezaurus DEFAULT
'

PWD="$(pwd)"
progname=${0##*/}
host="$(hostname)"
opsys="$(uname)"
osversion="$(uname -r)"
pkgtoolversion="$(pkg_create -V)"
utcdate="$(env TZ=UTC LOCALE=C date '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
param="usr/include/sys/param.h"
lists="$PWD/sets/lists"
comments="$PWD/sets/comments"
descrs="$PWD/sets/descrs"
deps="$PWD/sets/deps"
install_script="$PWD/sets/install"
deinstall_script="$PWD/sets/deinstall"
est="$PWD/sets/essentials"
tmp_deps="/tmp/culldeps"
homepage="https://github.com/user340/basepkg"
mail_address="uki@e-yuuki.org"
toppid=$$
results=".basepkg.log"

obj="/usr/obj"
packages="$PWD/packages"
category="base comp etc games man misc modules text xbase xcomp xetc xfont xserver"
pkgdb="/var/db/basepkg"

###
# Functions
#

#
# _err -- Output the error message with date.
#
# This function is used for ignorable error.
#
_err()
{
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $*"
}

#
# _bomb -- Output abbort message to standard error.
# Then, kill basepkg.sh's process and exit.
#
# This function is used for unignorable error.
#
_bomb()
{
    printf "ERROR: %s\\n *** PACKAGING ABORTED ***\\n" "$@"
    test -f "$results" && rm -f "$results"
    kill $toppid
    exit 1
}

#
# *** This function was copied from build.sh of NetBSD source tree. ***
#
# _getarch -- find the default MACHINE_ARCH for a MACHINE,
# or convert an alias to a MACHINE/MACHINE_ARCH pair.
#
# Saves the original value of MACHINE in makewrappermachine before
# alias processing.
#
# Sets MACHINE and MACHINE_ARCH if the input MACHINE value is
# recognised as an alias, or recognised as a machine that has a default
# MACHINE_ARCH (or that has only one possible MACHINE_ARCH).
#
# Leaves MACHINE and MACHINE_ARCH unchanged if MACHINE is recognised
# as being associated with multiple MACHINE_ARCH values with no default.
#
# Bombs if MACHINE is not recognised.
#
_getarch()
{
 (
    local found=""

    IFS="${nl}"
    makewrappermachine="${MACHINE}"
    for line in ${valid_MACHINE_ARCH}; do
        line="${line%%#*}" # ignore comments
        line="$( IFS=" ${tab}" ; echo $line )" # normalise white space
        case "${line} " in
        " ")
            # skip blank lines or comment lines
            continue
            ;;
        *" ALIAS=${MACHINE} "*)
            # Found a line with a matching ALIAS=<alias>.
            found="$line"
            break
            ;;
        "MACHINE=${MACHINE} "*" NO_DEFAULT"*)
            # Found an explicit "NO_DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=${MACHINE} "*" DEFAULT"*)
            # Found an explicit "DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=${MACHINE} "*)
            # Found a line for this MACHINE.  If it's the
            # first such line, then tentatively accept it.
            # If it's not the first matching line, then
            # remember that there was more than one match.
            case "$found" in
            '')    found="$line" ;;
            *)    found="MULTIPLE_MATCHES" ;;
            esac
            ;;
        esac
    done

    case "$found" in
    *NO_DEFAULT*|*MULTIPLE_MATCHES*)
        # MACHINE is OK, but MACHINE_ARCH is still unknown
        return
        ;;
    "MACHINE="*" MACHINE_ARCH="*)
        # Obey the MACHINE= and MACHINE_ARCH= parts of the line.
        IFS=" "
        for frag in ${found}; do
            case "$frag" in
            MACHINE=*|MACHINE_ARCH=*)
                eval "$frag"
                ;;
            esac
        done
        ;;
    *)
        bomb "Unknown target MACHINE: ${MACHINE}"
        ;;
    esac
 )
}

#
# *** This function was copied from build.sh of NetBSD source tree. ***
# *** Orifinal function name is "validatearch".                     ***
#
# _validate_arch() -- check that the MACHINE/MACHINE_ARCH pair is supported.
#
# Bombs if the pair is not supported.
#
_validate_arch()
{
 (
    foundpair=false foundmachine=false foundarch=false

    # MACHINE_ARCH may not be assigned, but catch at "case ... in"
    # shellcheck disable=SC2153
    case "$MACHINE_ARCH" in
    "")
        _bomb "No MACHINE_ARCH provided"
        ;;
    esac

    IFS="$nl"
    for line in $valid_MACHINE_ARCH; do
        line="${line%%#*}" # ignore comments
        # shellcheck disable=SC2086
        line="$( IFS=" $tab" ; echo $line )" # normalise white space
        # $MACHINE may not be assigned, but catch at "case ... in".
        # shellcheck disable=SC2153
        case "$line " in
        " ")
            # skip blank lines or comment lines
            continue
            ;;
        "MACHINE=$MACHINE MACHINE_ARCH=$MACHINE_ARCH "*)
            foundpair=true
            ;;
        "MACHINE=$MACHINE "*)
            foundmachine=true
            ;;
        *"MACHINE_ARCH=$MACHINE_ARCH "*)
            foundarch=true
            ;;
        esac
    done

    case "$foundpair:$foundmachine:$foundarch" in
    true:*)
        : OK
        ;;
    *:false:*)
        _bomb "Unknown target MACHINE: $MACHINE"
        ;;
    *:*:false)
        _bomb "Unknown target MACHINE_ARCH: $MACHINE_ARCH"
        ;;
    *)
        _bomb "MACHINE_ARCH '$MACHINE_ARCH' does not support MACHINE '$MACHINE'"
        ;;
    esac
 )
}


#
# _osrelease -- Output version number of NetBSD.
#
# In default, version number is coded in "/usr/obj/usr/include/sys/param.h".
# This function is not requires NetBSD source tree (/usr/src).
#
_osrelease()
{
 (
    option="$1"
    exec < "$destdir/$param"

    # In this function, "comment_start" and "NetBSD" are unreferenced variables.
    while
        # shellcheck disable=SC2034
        read -r define ver_tag rel_num comment_start NetBSD rel_text rest; do
        [ "$define" = "#define" ] || continue;
        [ "$ver_tag" = "__NetBSD_Version__" ] || continue
        break
    done
    rel_num=${rel_num%??}
    rel_MMmm=${rel_num%????}
    rel_MM=${rel_MMmm%??}
    rel_mm=${rel_MMmm#$rel_MM}
    IFS=.
    # shellcheck disable=SC2086
    set -- - $rel_text
    beta=${3#[0-9]}
    beta=${beta#[0-9]}
    shift 3
    IFS=' '
    # shellcheck disable=SC2086
    set -- $rel_MM ${rel_mm#0}$beta "$@"
    case "$option" in
    -k)
        if [ "${rel_mm#0}" = 99 ]; then
            IFS=.
            echo "$*"
        else
            echo "${rel_MM}.${rel_mm#0}"
        fi
        ;;
    *)
        IFS=.
        echo "$*"
        ;;
    esac
 )
}

#
# _split_category -- Make category directory and organized files named "FILES".
#
_split_category()
{
 (
    printf "===> _split_category()\\n" | tee -a $results
    for i in $category; do
        test -d "$workdir/$i" || mkdir -p "$workdir/$i"
        test -f "$workdir/$i/FILES" && rm -f "$workdir/$i/FILES"
        for j in "$lists"/* ; do
            ad=""
            mi=""
            md=""
            module=""
            rescue=""
            rescue_ad=""
            rescue_machine=""
            shl=""
            stl=""
            test -f "$j/ad.$machine" && ad="$j/ad.$machine"
            test -f "$j/mi" && mi="$j/mi"
            test -f "$j/md.$machine" && md="$j/md.$machine"
            test -f "$j/module.mi" && module="$j/module.mi"
            test -f "$j/rescue.mi" && rescue="$j/rescue.mi"
            test -f "$j/rescue.ad.$machine" && rescue_ad="$j/rescue.ad.$machine"
            test -f "$j/rescue.$machine" \
                && rescue_machine="$j/rescue.$machine"
            test -f "$j/shl.mi" && shl="$j/shl.mi"
            test -f "$j/stl.mi" && stl="$j/stl.mi"
            moduledir="stand/$machine/$release_k/modules"
            # shellcheck disable=SC2086
            cat \
                $ad $mi $md $module $rescue $rescue_ad \
                $rescue_machine $shl $stl \
            | awk '
                ! /^\#/ {
                    #
                    # Ignore obsolete packages.
                    #
                    if ($2 == "'"$i-obsolete"'")
                        next
                    #
                    # Ignore pacakge with obsolete tags.
                    #
                    if ($3 ~ "obsolete")
                        next
                    if ($2 ~ "^'"$i"'") {
                        #
                        # Remove "./" characters.
                        #
                        $1 = substr($1, 3);
                        if ($1 != "") {
                            gsub(/@MODULEDIR@/, "'"$moduledir"'");
                            gsub(/@MACHINE@/, "'"$machine"'");
                            gsub(/@OSRELEASE@/, "'"$release_k"'");
                            print
                        }
                    }
                }' >> "$workdir/$i/FILES"
      done
    done
 )
}

#
# _mk_pkgtree -- Make package tree referring to "FILES".
#
_mk_pkgtree()
{
 (
    printf "===> _mk_pkgtree()\\n" | tee -a $results
    for i in $category; do
        awk '{print $2}' "$workdir/$i/FILES" | sort | uniq \
        | xargs -n 1 -I % sh -c \
            "test -d $workdir/$i/% || mkdir $workdir/$i/%"
    done
 )
}

#
# _mk_plist -- List each package's contents and write into
# "category/package/package.FILE".
#
_mk_plist()
{
 (
    printf "===> _mk_plist()\\n" | tee -a $results
    for i in $category; do
        awk ' 
        # $1 - file name
        # $2 - package name
        {
            if ($2 in lists)
                lists[$2] = $1 " " lists[$2]
            else
                lists[$2] = $1
        }
        END {
            for (pkg in lists)
                print pkg, lists[pkg]
        }' "$workdir/$i/FILES" > "$workdir/$i/CATEGORIZED"
    done
    i=""
    for i in $category; do
        for j in "$workdir/$i"/*; do
            test -d "$j" || continue
            awk '
            /^'"$(basename "$j")"'/ {
                for (i = 2; i <= NF; i++) {
                    print $i
                }
            }' "$workdir/$i/CATEGORIZED" > "$j/PLIST"
        done
    done
 )
}

#
# _BUILD_INFO -- Make "+BUILD_INFO" file.
#
_BUILD_INFO()
{
    cat > "$workdir/$1/+BUILD_INFO" << _BUILD_INFO_
OPSYS=$opsys
OS_VERSION=$osversion
OBJECT_FMT=ELF
MACHINE_ARCH=$machine_arch
PKGTOOLS_VERSION=$pkgtoolversion
HOMEPAGE=$homepage
MAINTAINER=$mail_address
_BUILD_INFO_
}

#
# _mk_depend -- Calculate package's dependency.
#
_mk_depend()
{
    grep "^$1" "$deps" > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        _err "$1 Unknown package dependency."
        return 1
    fi
    awk '/^'"$1"'/{print $2}' "$deps" | while read -r depend; do
        test ! "$depend" && return 1

	# XXX EXTENSION: check dependency generated by nbpkg-build.
	# XXX $nbpkg_build_list_all knows changes based on ident comparison
	# XXX where the format is such as "base-sys-root 8.0.20181101".
	if [ "X$nbpkg_build_config" != "X" ];then
	    local _sep _release
	        _sep="[[:space:]]"
	    _release=$(grep "^${depend}$_sep" $nbpkg_build_list_all	|
		       awk '{print $2}'					|
		       tail -1						)
	    if [ "X$_release" != "X" ];then
	        echo "@pkgdep $depend>=$_release"
	    fi
	else
	    echo "@pkgdep $depend>=$release"
	fi  >> "$tmp_deps"
        test "$depend" = "base-sys-root" && return 0
        _mk_depend "$depend" # Recursion.
    done
}

#
# _CONTENTS -- Make "+CONTENTS" file.
#
_CONTENTS()
{
 (
    TMPFILE=$(mktemp -q || _bomb "$TMPFILE")
    setname="${1%/*}" # E.g. "base/base-sys-root" --> "base"
    pkgname="${1#*/}" # E.g. "base/base-sys-root" --> "base-sys-root"
    prefix="/"
    test "$setname" = "etc" && prefix="/var/tmp/basepkg"

    echo "@name $pkgname-$release" > "$workdir/$1/+CONTENTS"
    echo "@comment Packaged at $utcdate UTC by $user@$host" >> "$workdir/$1/+CONTENTS"

    test -f "$tmp_deps" && rm -f "$tmp_deps"
    _mk_depend "$pkgname"
    test -f "$tmp_deps" && sort "$tmp_deps" | uniq >> "$workdir/$1/+CONTENTS"

    echo "@cwd $prefix" >> "$workdir/$1/+CONTENTS"
    while read -r i; do
        if [ -d "$destdir/$i" ]; then
            filename=$(echo "$i" | sed 's%\/%\\\/%g')
            awk '$1 ~ /^\.\/'"$filename"'$/{print $0}' "$destdir/etc/mtree/set.$setname" \
            | sed 's%^\.\/%%' \
            | awk '
            {
                print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1
            } ' >> "$TMPFILE"
        fi
        test -f "$destdir/$i" && echo "$i" >> "$TMPFILE"
    done < "$workdir/$1/PLIST"

    sort "$TMPFILE" >> "$workdir/$1/+CONTENTS"
    rm -f "$TMPFILE"
 )
}

#
# _SIZE_PKG -- Make "+SIZE_PKG" file.
#
_SIZE_PKG()
{
    # Sum of file size.
    grep -v '^@' < "$workdir/$1/+CONTENTS" \
        | xargs -I % ls -l "$destdir/"% \
        | awk '{sum+=$5} END{print sum}' \
        > "$workdir/$1/+SIZE_PKG.tmp"

    # Sum of directory size.
    grep -c '^@exec install -d -o root -g wheel -m' < "$workdir/$1/+CONTENTS" \
        | xargs -I % expr % \* 512 \
        >> "$workdir/$1/+SIZE_PKG.tmp"

    # Sum of file and directory size.
    awk '{sum+=$1} END{print sum}' < "$workdir/$1/+SIZE_PKG.tmp" \
        > "$workdir/$1/+SIZE_PKG"

    rm -f "$workdir/$1/+SIZE_PKG.tmp"
}

#
# _SIZE_ALL -- Make "+SIZE_PKG" file.
#
_SIZE_ALL()
{
    grep '^@pkgdep' "$workdir/$1/+CONTENTS" \
        | cut -d " " -f 2 \
        | cut -d ">=" -f 1 \
        | xargs -I % find "$workdir" -type d -name % \
        | xargs -I % cat %/+SIZE_PKG \
        | awk '{sum+=$1} END{print sum}' \
        > "$workdir/$1/+SIZE_ALL.tmp"

    cat "$workdir/$1/+SIZE_PKG" "$workdir/$1/+SIZE_ALL.tmp" \
        | awk '{sum+=$1}END{print sum}' \
        > "$workdir/$1/+SIZE_ALL"

    rm -f "$workdir/$1/+SIZE_ALL.tmp"
}

#
# _DESC_and_COMMENT -- Make "+DESC" and "+COMMENT" file.
#
_DESC_and_COMMENT()
{
 (
    pkgname="${1#*/}"

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$descrs" > "$workdir/$1/+DESC" || _bomb "awk +DESC"

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$comments" > "$workdir/$1/+COMMENT" || _bomb "awk +COMMENT"
 )
}

#
# _replace_cmdstr -- Replace temporary strings to absolute path of command in
# +INSTALL and +DEINSTALL.

# Packages made by basepkg are only for NetBSD.  For this reason, file path is
# almost hard coded.
#
_replace_cmdstr()
{
    sed -e "s%@GROUPADD@%/usr/sbin/groupadd%g" \
        -e "s%@USERADD@%/usr/sbin/useradd%" \
        -e "s%@SH@%/bin/sh%" \
        -e "s%@PREFIX@%/%" \
        -e "s%@AWK@%/usr/bin/awk%" \
        -e "s%@BASENAME@%/usr/bin/basename%" \
        -e "s%@CAT@%/bin/cat%" \
        -e "s%@CHGRP@%/bin/chgrp%" \
        -e "s%@CHMOD@%/bin/chmod%" \
        -e "s%@CHOWN@%/bin/chown%" \
        -e "s%@CMP@%/usr/bin/cmp%" \
        -e "s%@CP@%/bin/cp%" \
        -e "s%@DIRNAME@%/usr/bin/dirname%" \
        -e "s%@ECHO@%echo%" \
        -e "s%@EGREP@%/usr/bin/egrep%" \
        -e "s%@EXPR@%/bin/expr%" \
        -e "s%@FALSE@%/usr/bin/false%" \
        -e "s%@FIND@%/usr/bin/find%" \
        -e "s%@GREP@%/usr/bin/grep%" \
        -e "s%@GTAR@%/bin/tar%" \
        -e "s%@HEAD@%/usr/bin/head%" \
        -e "s%@ID@%/usr/bin/id%" \
        -e "s%@LINKFARM@%linkfarm%" \
        -e "s%@LN@%/bin/ln%" \
        -e "s%@LOCALBASE@%localbase%" \
        -e "s%@LS@%/bin/ls%" \
        -e "s%@MKDIR@%/bin/mkdir -p%" \
        -e "s%@MV@%/bin/mv%" \
        -e "s%@PKGBASE@%/%" \
        -e "s%@RM@%/bin/rm%" \
        -e "s%@RMDIR@%/bin/rmdir%" \
        -e "s%@SED@%/usr/bin/sed%" \
        -e "s%@SETENV@%setenv%" \
        -e "s%@ECHO_N@%echo -n%" \
        -e "s%@PKG_ADMIN@%pkg_admin%" \
        -e "s%@PKG_INFO@%pkg_info%" \
        -e "s%@PWD_CMD@%pwd%" \
        -e "s%@SORT@%/usr/bin/sort%" \
        -e "s%@SU@%/usr/bin/su%" \
        -e "s%@TEST@%test%" \
        -e "s%@TOUCH@%/usr/bin/touch%" \
        -e "s%@TR@%/usr/bin/tr%" \
        -e "s%@TRUE@%/usr/bin/true%" \
        -e "s%@XARGS@%/usr/bin/xargs%" \
        -e "s%@X11BASE@%/usr/X11R7%" \
        -e "s%@PKG_SYSCONFBASE@%/etc%" \
        -e "s%@PKG_SYSCONFBASEDIR@%/etc%" \
        -e "s%@PKG_SYSCONFDIR@%/etc%" \
        -e "s%@CONF_DEPENDS@%%" \
        -e "s%@PKG_CREATE_USERGROUP@%NO%" \
        -e "s%@PKG_CONFIG@%YES%" \
        -e "s%@PKG_CONFIG_PERMS@%YES%" \
        -e "s%@PKG_RCD_SCRIPTS@%NO%" \
        -e "s%@PKG_USER_HOME@%%" \
        -e "s%@PKG_USER_SHELL@%%" \
        -e "s%@PERL5@%$(command -v perl)%" "$1" || _bomb "failed sed"
}

#
# _INSTALL -- Make "+INSTALL" file. The role of "+INSTALL" is defining
# absolute path of file, permission, owner and group.
#
_INSTALL()
{
 (
    user_group_mode=""

    test -f "$workdir/$1/+INSTALL" && rm -f "$workdir/$1/+INSTALL"
    _replace_cmdstr "$install_script" > "$workdir/$1/+INSTALL"

    test -f "$workdir/$1/+CONTENTS" || _bomb "+CONTENTS not found."
    # For +FILES routine which is conained in sets/install script.
    grep -v -e "^@" "$workdir/$1/+CONTENTS" | while read -r file; do
        test "$(file "$obj/$file" | cut -d " " -f 2)" = "symbolic" && continue
        if [ "${file%%/*}" = "etc" ]; then
            if [ -f "$destdir/$file" ]; then
                user_group_mode=$(grep -e "^\\./$file " "$destdir/etc/mtree/set.etc" \
                                    | cut -d " " -f 3 -f 4 -f 5 \
                                    | xargs -n 1 -I % expr x% : "x[^=]*=\\(.*\\)" \
                                    | tr '\n' ' '
                                )
                mode=$(echo "$user_group_mode" | cut -d " " -f 3)
                user=$(echo "$user_group_mode" | cut -d " " -f 1)
                group=$(echo "$user_group_mode" | cut -d " " -f 2)
            fi
            echo "# FILE: /$file c $file $mode $user $group" \
                >> "$workdir/$1/+INSTALL"
        fi
    done
 )
}

#
# _DEINSTALL -- Make deinstall script for each packages.
#
_DEINSTALL()
{
    _replace_cmdstr "$deinstall_script" > "$workdir/$1/+DEINSTALL"
}

#
# _PRESERVE -- Make preserve-file.
#
_PRESERVE()
{
 (
    while read -r e_pkg; do
        e_path=$(find "$workdir" -name "$e_pkg" -type d)

        # For debug.
        #printf "%s-%s -> %s\n" "$e_pkg" "$release" "$e_path/+PRESERVE"

        test "$e_path" && printf "%s-%s" "$e_pkg" "$release" > "$e_path/+PRESERVE"
    done < "$est"
 )
}

#
# _put_basedir -- Change directory name depending on
# same $MACHINE and $MACHINE_ARCH or not.
#
_put_basedir() 
{
   if [ "X$MACHINE_ARCH" != "X$MACHINE" ]; then
     echo "$packages/$release/$MACHINE-$MACHINE_ARCH"
   else
     echo "$packages/$release/$MACHINE"
   fi
}

#
# _do_pkg_create -- "pkg_create" command wrapper.
#
# Package moved to ${packages}/All directory.
#
_do_pkg_create()
{
 (
    setname="${1%/*}" # E.g. "base/base-sys-root" --> "base"
    pkgname="${1#*/}" # E.g. "base/base-sys-root" --> "base-sys-root"

    option="-v -l -U 
    -B $workdir/$1/+BUILD_INFO
    -i $workdir/$1/+INSTALL
    -K $pkgdb
    -k $workdir/$1/+DEINSTALL
    -p $destdir
    -c $workdir/$1/+COMMENT
    -d $workdir/$1/+DESC
    -f $workdir/$1/+CONTENTS
    -s $workdir/$1/+SIZE_PKG
    -S $workdir/$1/+SIZE_ALL"

    test -f "$workdir/$1/+PRESERVE" && option="$option -n $workdir/$1/+PRESERVE"

    if [ "$setname" = "etc" ]; then
        option="$option -I /var/tmp/basepkg"
    else
        option="$option -I /"
    fi

    # shellcheck disable=SC2086
    pkg_create $option "$pkgname" || _bomb "$1: pkg_create"

    _basedir=$(_put_basedir)
    test -d "$_basedir" || mkdir -p "$_basedir"
    mv "./$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
 )
}

_mk_checksum()
{
    find ./*.tgz | xargs -I % cksum -a md5 % > MD5
    find ./*.tgz | xargs -I % cksum -a sha512 % > SHA512
}

#
# _mk_pkg -- Execute any functions and make MD5 and SHA512.
#
_mk_pkg()
{
 (
    printf "===> _mk_pkg()\\n" | tee -a $results
    find "$workdir" -type d -name '*-*-*' \
        | sed "s|$workdir/||g" \
        | while read -r pkg; do
            _BUILD_INFO "$pkg"
            _CONTENTS "$pkg"
            _SIZE_PKG "$pkg"
            _DESC_and_COMMENT "$pkg"
            _INSTALL "$pkg"
            _DEINSTALL "$pkg"
    done

    # XXX EXTENSION: build least packages specified by nbpgk-build
    if [ "X$nbpkg_build_config" != "X" ];then
	if [ "X$nbpkg_build_target" = "Xdaily" ];then
	   find "$workdir" -type d -name '*-*-*' 	|
	   egrep -f $nbpkg_build_list_filter
	else
	   find "$workdir" -type d -name '*-*-*'
	fi
    else
	find "$workdir" -type d -name '*-*-*'
    fi  | sed "s|$workdir/||g" \
        | while read -r pkg; do
            _SIZE_ALL "$pkg"
            _do_pkg_create "$pkg"
    done
    
    _basedir=$(_put_basedir)
    cd "$_basedir" && _mk_checksum
 )
}

#
# _mk_kpkg -- Make kernel package.
#
# Now, information of meta-data is not write to another files such as
# ./sets/comments. Because the packaged file is only kernel binary named
# "netbsd". If add the kernel package's information to files that under the
# ./sets directory, This function will be deleted.
#
_mk_kpkg()
{
 (
    category="base"
    pkgname="base-kernel-$1"

    if [ ! -f "$obj/sys/arch/$machine/compile/$1/netbsd" ]; then
        _err "$1/netbsd not found."
        return 1
    fi

    test -d "$workdir/$category/.$pkgname" || \
        mkdir -p "$workdir/$category/$pkgname"

    # Information of build environment.
    cat > "$workdir/$category/$pkgname/+BUILD_INFO" << _BUILD_INFO_
OPSYS=$opsys
OS_VERSION=$osversion
OBJECT_FMT=ELF
MACHINE_ARCH=$machine_arch
PKGTOOLS_VERSION=$pkgtoolversion
_BUILD_INFO_

    # Short description of package.
    cat > "$workdir/$category/$pkgname/+COMMENT" << _COMMENT_
NetBSD $1 Kernel
_COMMENT_

    # Description of package.
    cat > "$workdir/$category/$pkgname/+DESC" << _DESC_
NetBSD $1 Kernel
_DESC_

    # Package contents.
    cat > "$workdir/$category/$pkgname/+CONTENTS" << _CONTENTS_
@name $pkgname-$release
@comment Packaged at $utcdate UTC by $user@$host
@cwd / 
netbsd
_CONTENTS_

    # Size of kernel.
    du "$obj/sys/arch/$machine/compile/$1/netbsd" \
        | cut -f 1 \
        > "$workdir/$category/$pkgname/+SIZE_PKG"

    # XXX: Size all.
    cp "$workdir/$category/$pkgname/+SIZE_PKG" "$workdir/$category/$pkgname/+SIZE_ALL"

    pkg_create -v -l -U \
    -B "$workdir/$category/$pkgname/+BUILD_INFO" \
    -I "/" \
    -c "$workdir/$category/$pkgname/+COMMENT" \
    -d "$workdir/$category/$pkgname/+DESC" \
    -f "$workdir/$category/$pkgname/+CONTENTS" \
    -p "$obj/sys/arch/$machine/compile/$1" \
    -s "$workdir/$category/$pkgname/+SIZE_PKG" \
    -S "$workdir/$category/$pkgname/+SIZE_ALL" \
    -K "$pkgdb" "$pkgname" || _bomb "kernel: pkg_create"

    _basedir=$(_put_basedir)
    test -d "$_basedir" || mkdir -p "$_basedir"
    mv "$PWD/$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
 )
}

#
# _mk_all_kpkg -- Packaging all compiled kernels.
#
# XXX: A number of kernel packages can install to the system.
#
_mk_all_kpkg()
{
 (
    printf "===> _mk_all_kpkg()\\n" | tee -a $results
    # shellcheck disable=SC2086
    # shellcheck disable=SC2012
    ls $kernobj | while read -r kname; do
        _mk_kpkg "$kname"
    done
 )
}

#
# _clean_work -- Clean working directories.
#
_clean_work()
{
    printf "_clean_workdir()\\n"
    test -w "$workdir" && rm -fr "$workdir"
}

#
# _clean_pkg -- Clean packages.
#
_clean_pkg()
{
    printf "_clean_pkg()\\n"
    test -w "$packages" && rm -fr "$packages"
}

#
# _usage -- Show usage to standard output.
#
_usage()
{
    cat <<_usage_

Usage: $progname [--obj obj_dir] [--category category] [--machine machine] 
                 command

 Command:
    pkg                 Create packages.
    kern                Create kernel package.
    clean               Clean working directories.
    cleanpkg            Clean package directories.

 Options:
    --help              Show this message and exit.
    --obj               Set obj to NetBSD binaries.
                        [Default: $obj]
    --category          Set category.
                        [Default: "base comp etc games man misc text"]
    --machine           Set machine type for MACHINE_ARCH.
                        [Default: $machine]
_usage_
    exit 1
}

#
# _getopt -- Parsing options.
#
# Example:
#   --obj=/usr/obj
#         ^^^^^^^^^
#          take it
#
# In this example, it will return "/usr/obj".
#
_getopt()
{
    expr "x$1" : "x[^=]*=\\(.*\\)"
}

#
# _begin_msg -- Print log messages to standard output and log file.
#
# This function is called when beginning basepkg.sh's process.
#
_begin_msg()
{
    printf "===> basepkg.sh command: %s\\n" "$1" | tee -a $results
    printf "===> basepkg.sh started: %s\\n" "$2" | tee -a $results
    printf "===> NetBSD version:     %s\\n" "$release" | tee -a $results
    printf "===> MACHINE:            %s\\n" "$machine" | tee -a $results
    printf "===> MACHINE_ARCH:       %s\\n" "$machine_arch" | tee -a $results
    printf "===> Build platform:     %s %s %s\\n" "$opsys" "$osversion" "$(uname -m)" | tee -a $results
}

#
# _end_msg -- Print log messages to standard output and log file.
#
# This function is called when ending basepkg.sh's process.
#
_end_msg()
{
    printf "===> basepkg.sh ended:   %s\\n" "$1" | tee -a $results
    printf "===> Summary of results:\\n"
    sed -e 's/^===>/    /g' $results
    printf "===> .\\n"
    rm -f $results
}

###
# Begin main process.
#

machine="$(uname -m)" # Firstly, set machine hardware name for _getarch().
commandline="$0 $*"

# extension modules 
nbpkg_build_enable=0;
nbpkg_build_config=""

#
# Parsing long option process. In this process, not used getopt(1) and 
# getopts for the following reasons.
#     - One character option is difficult to understand.
#     - The getopt(1) have difference between GNU and BSD.
#
while [ $# -gt 0 ]; do
    case $1 in
    -h|--help)
        _usage
        ;;
    --obj)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        obj="$2"
        shift
        ;;
    --obj=*)
        obj=$(_getopt "$1")
        ;;
    --releasedir)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        releasedir="$2"
        shift
        ;;
    --releasedir=*)
        releasedir=$(_getopt "$1")
        ;;
    --destdir)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        destdir="$2"
        shift
        ;;
    --destdir=*)
        destdir=$(_getopt "$1")
        ;;
    --category=*)
        category=$(_getopt "$1")
        ;;
    --category)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        category="$2"
        shift
        ;;
    --machine=*)
        machine=$(_getopt "$1")
        ;;
    --machine)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        machine="$2"
        shift
        ;;
    --enable-nbpkg-build)
	nbpkg_build_enable=1;
        ;;
    --with-nbpkg-build-config=*)
        nbpkg_build_config=$(_getopt "$1")
        ;;
    --with-nbpkg-build-config)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        nbpkg_build_config="$2"
        shift
        ;;
    -|--)
        break
        ;;
    *)
        break
        ;;
    esac
    shift
done

#
# Initialization
#
set -u
umask 0022
export LC_ALL=C LANG=C

eval "$(_getarch)"
_validate_arch
destdir=${destdir:-"$obj/destdir.$MACHINE"}
releasedir=${releasedir:-.}
release="$(_osrelease -a)"
release_k="$(_osrelease -k)"
machine_arch=$MACHINE_ARCH
workdir="$releasedir/work/$release/$machine"
packages="$releasedir/packages"
kernobj="$obj/sys/arch/$machine/compile"
start=$(date)

# quirks: overwritten for "nbpkg-build" system
if [ "X$nbpkg_build_config" != "X" -a -f $nbpkg_build_config ];then
   . $nbpkg_build_config
   release=$nbpkg_build_id 	# e.g. 8.0.20181029
fi	


#
# least assertions
#
test -f "$install_script"  || _bomb "require $install_script"
test "X$release" != "X" || _bomb "cannot resolve \$release"

test $# -eq 0 && _usage
command -v hostname > /dev/null 2>&1 || _bomb "hostname(1) not found."
command -v mktemp > /dev/null 2>&1 || _bomb "mktemp(1) not found."
command -v pkg_create > /dev/null 2>&1 || _bomb "pkg_create(1) not found."

#
# operation
#
case $1 in
pkg)
    _begin_msg "$commandline" "$start"
    _split_category
    _mk_pkgtree
    _mk_plist
    _PRESERVE
    _mk_pkg
    _end_msg "$(date)" 
    ;;
kern)
    _begin_msg "$commandline" "$start"
    _mk_all_kpkg
    _end_msg "$(date)" 
    ;;
clean)
    _begin_msg "$commandline" "$start"
    _clean_work
    _end_msg "$(date)" 
    ;;
cleanpkg)
    _begin_msg "$commandline" "$start"
    _clean_pkg
    _end_msg "$(date)" 
    ;;
*)
    _usage
    ;;
esac

# Success.
exit 0
