#!/usr/bin/env sh
#
# Copyright (c) 2016,2017 Yuuki Enomoto  
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
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE  
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR  
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER  
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,  
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

# POSIX Utilities
AWK="/usr/bin/awk"
BASENAME="/usr/bin/basename"
CAT="/bin/cat"
CHGRP="/bin/chgrp"
CHMOD="/bin/chmod"
CHOWN="/sbin/chown"
CKSUM="/usr/bin/cksum" 
CP="/bin/cp"
CUT="/usr/bin/cut"
DATE="/bin/date"
ECHO="/bin/echo"
ENV="/usr/bin/env"
EXPR="/bin/expr"
FILE="/usr/bin/file"
FIND="/usr/bin/find"
GREP="/usr/bin/grep"
KILL="/bin/kill"
LS="/bin/ls"
MKDIR="/bin/mkdir"
MOUNT="/sbin/mount"
MV="/bin/mv"
PRINTF="/usr/bin/printf"
PWD_CMD="/bin/pwd"
RM="/bin/rm"
RMDIR="/bin/rmdir"
SED="/usr/bin/sed"
SH="/bin/sh"
SORT="/usr/bin/sort"
TEST="/bin/test"
TOUCH="/usr/bin/touch"
TR="/usr/bin/tr"
UMOUNT="/sbin/umount"
UNAME="/usr/bin/uname"
UNIQ="/usr/bin/uniq"
XARGS="/usr/bin/xargs"

# Non-POSIX Utilities
DISKLABEL="/sbin/disklabel"
HOSTNAME="/bin/hostname"
INSTALL="/usr/bin/install"
INSTALLBOOT="/usr/sbin/installboot"
MAKEFS="/usr/sbin/makefs"
MKTEMP="/usr/bin/mktemp"
STAT="/usr/bin/stat"
PKG_ADD="/usr/pkg/sbin/pkg_add"
PKG_CREATE="/usr/pkg/sbin/pkg_create"
PKG_DELETE="/usr/pkg/sbin/pkg_delete"
PKG_INFO="/usr/pkg/sbin/pkg_info"

nl='
'
tab='		'

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
MACHINE=evbarm64	MACHINE_ARCH=aarch64	ALIAS=evbarm64-el
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
MACHINE=playstation2	MACHINE_ARCH=mipsel
MACHINE=pmax		MACHINE_ARCH=mips64el	ALIAS=pmax64
MACHINE=pmax		MACHINE_ARCH=mipsel	DEFAULT
MACHINE=prep		MACHINE_ARCH=powerpc
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

PWD="$(${PWD_CMD})"
progname=${0##*/}
host="$(${HOSTNAME})"
opsys="$(${UNAME})"
osversion="$(${UNAME} -r)"
pkgtoolversion="$(${PKG_ADD} -V)"
utcdate="$(${ENV} TZ=UTC LOCALE=C ${DATE} '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
param="usr/include/sys/param.h"
lists="${PWD}/sets/lists"
comments="${PWD}/sets/comments"
descrs="${PWD}/sets/descrs"
deps="${PWD}/sets/deps"
install_script="${PWD}/sets/install"
deinstall_script="${PWD}/sets/deinstall"
tmp_deps="/tmp/culldeps"
homepage="https://github.com/user340/basepkg"
mail_address="mail@e-yuuki.org"
toppid=$$

obj="/usr/obj"
packages="${PWD}/packages"
category="base comp etc games man misc text"
kernel="GENERIC"
pkgdb="/var/db/basepkg"
tmpdir="${PWD}/tmp"

#
# Output error message to STDERR
#
err()
{
    ${ECHO} "[$(${DATE} +'%Y-%m-%dT%H:%M:%S')] $@" >&2
}

#
# Output abbort message. Kill and exit.
#
bomb()
{
    ${CAT} >&2 <<MESSAGE

ERROR: $@
*** PACKAGING ABORTED ***
MESSAGE
    ${KILL} ${toppid}
    exit 1
}

#
# Set MACHINE_ARCH variable by MACHINE value.
#
getarch()
{
    local IFS
    local found=""
    local line
    
    IFS="${nl}"
    makewrappermachine="${machine}"
    for line in ${valid_MACHINE_ARCH}; do
        line="${line%%#*}"
        line="$( IFS=" ${tab}" ; ${ECHO} $line )" # normalise white space
        case "${line} " in
        " ")
            # skip blank lines or comment lines
            continue
            ;;
        *" ALIAS=${machine} "*)
            # Found a line with a matching ALIAS=<alias>.
            found="$line"
            break
            ;;
        "MACHINE=${machine} "*" NO_DEFAULT"*)
            # Found an explicit "NO_DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=${machine} "*" DEFAULT"*)
            # Found an explicit "DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=${machine} "*)
            # Found a line for this MACHINE.  If it's the
            # first such line, then tentatively accept it.
            # If it's not the first matching line, then
            # remember that there was more than one match.
            case "$found" in
            '')  found="$line" ;;
            *)  found="MULTIPLE_MATCHES" ;;
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
          bomb "Unknown target MACHINE: ${machine}"
          ;;
      esac
}

#
# Exit if the pair is not supported.
#
validatearch()
{
    local IFS
    local line
    local foundpair=false foundmachine=false foundarch=false

    case "${MACHINE_ARCH}" in
    "")
        bomb "No MACHINE_ARCH provided"
        ;;
    esac

    IFS="${nl}"
    for line in ${valid_MACHINE_ARCH}; do
        line="${line%%#*}" # ignore comments
        line="$( IFS=" ${tab}" ; ${ECHO} $line )" # normalise white space
        case "${line} " in
        " ")
            # skip blank lines or comment lines
            continue
            ;;
        "MACHINE=${MACHINE} MACHINE_ARCH=${MACHINE_ARCH} "*)
            foundpair=true
            ;;
        "MACHINE=${MACHINE} "*)
            foundmachine=true
            ;;
        *"MACHINE_ARCH=${MACHINE_ARCH} "*)
            foundarch=true
            ;;
        esac
    done

    case "${foundpair}:${foundmachine}:${foundarch}" in
    true:*)
        : OK
        ;;
    *:false:*)
        bomb "Unknown target MACHINE: ${MACHINE}"
        ;;
    *:*:false)
        bomb "Unknown target MACHINE_ARCH: ${MACHINE_ARCH}"
        ;;
    *)
        bomb "MACHINE_ARCH '${MACHINE_ARCH}' does not support MACHINE '${MACHINE}'"
        ;;
    esac
}


#
# Output version of NetBSD source set.
#
osrelease() {
    local option; option="$1"
    local define ver_tag rel_num comment_start NetBSD rel_text rest beta
    exec < ${destdir}/${param}

    while
        read define ver_tag rel_num comment_start NetBSD rel_text rest; do
        [ "${define}" = "#define" ] || continue;
        [ "${ver_tag}" = "__NetBSD_Version__" ] || continue
        break
    done
    rel_num=${rel_num%??}
    rel_MMmm=${rel_num%????}
    rel_MM=${rel_MMmm%??}
    rel_mm=${rel_MMmm#${rel_MM}}
    IFS=.
    set -- - ${rel_text}
    beta=${3#[0-9]}
    beta=${beta#[0-9]}
    shift 3
    IFS=' '
    set -- ${rel_MM} ${rel_mm#0}${beta} $*
    case "${option}" in
    -k)
        if [ ${rel_mm#0} = 99 ]; then
            IFS=.
            ${ECHO} "$*"
        else
            ${ECHO} "${rel_MM}.${rel_mm#0}"
        fi
        ;;
    *)
        IFS=.
        ${ECHO} "$*"
        ;;
    esac
}

#
# Make category directory and organized files named "FILES".
#
split_category_from_lists()
{
    local i j
    local ad mi md shl module rescue rescue_ad rescue_machine stl
    for i in ${category}; do
        ${TEST} -d ${workdir}/${i} || ${MKDIR} -p ${workdir}/${i}
        ${TEST} -f ${workdir}/${i}/FILES && ${RM} -f ${workdir}/${i}/FILES
        for j in $(${LS} ${lists}); do
            ad=""
            mi=""
            md=""
            module=""
            rescue=""
            rescue_ad=""
            rescue_machine=""
            shl=""
            stl=""
            ${TEST} -f ${lists}/${j}/ad.${machine} && ad="${lists}/${j}/ad.${machine}"
            ${TEST} -f ${lists}/${j}/mi && mi="${lists}/${j}/mi"
            ${TEST} -f ${lists}/${j}/md.${machine} && md="${lists}/${j}/md.${machine}"
            ${TEST} -f ${lists}/${j}/module.mi && module="${lists}/${j}/module.mi"
            ${TEST} -f ${lists}/${j}/rescue.mi && rescue="${lists}/${j}/rescue.mi"
            ${TEST} -f ${lists}/${j}/rescue.ad.${machine} \
                && rescue_ad="${lists}/${j}/rescue.ad.${machine}"
            ${TEST} -f ${lists}/${j}/rescue.${machine} \
                && rescue_machine="${lists}/${j}/rescue.${machine}"
            ${TEST} -f ${lists}/${j}/shl.mi && shl="${lists}/${j}/shl.mi"
            ${TEST} -f ${lists}/${j}/stl.mi && stl="${lists}/${j}/stl.mi"
            ${CAT} \
                ${ad} ${mi} ${md} ${module} ${rescue} ${rescue_ad} \
                ${rescue_machine} ${shl} ${stl} \
            | ${AWK} '
             ! /^\#/ {
                 #
                 # Ignore obsolete packages.
                 #
                 if ($2 == "'"${i}-obsolete"'")
                     next
                 #
                 # Ignore pacakge with obsolete tags.
                 #
                 if ($3 ~ "obsolete")
                     next
                 if ($2 ~ "^'"${i}"'") {
                     #
                     # Remove "./" characters.
                     #
                     $1 = substr($1, 3);
                     if ($1 != "") {
                         gsub(/@MODULEDIR@/, "stand/'"${machine}"'/'"${release_k}"'/modules");
                         gsub(/@MACHINE@/, "'"${machine}"'");
                         gsub(/@OSRELEASE@/, "'"${release_k}"'");
                         print
                     }
                 }
             }' \
            >> ${workdir}/${i}/FILES
      done
    done
}

#
# Make directories referring to "FILES".
#
make_directories_of_package()
{
    local i
    for i in ${category}; do
        ${AWK} '{print $2}' ${workdir}/${i}/FILES | ${SORT} | ${UNIQ} \
        | ${XARGS} -n 1 -I % ${SH} -c \
            "${TEST} -d ${workdir}/${i}/% || ${MKDIR} ${workdir}/${i}/%"
    done
}

#
# List each package's contents and write into "category/package/package.FILE".
#
make_contents_list()
{
    local i j
    for i in ${category}; do
        ${AWK} ' 
        # $1 - file name
        # $2 - package name
        $2 ~ /\./ {
            gsub(/\./, "-", $2)
        }
        {
            if ($2 in lists)
                lists[$2] = $1 " " lists[$2]
            else
                lists[$2] = $1
        }
        END {
            for (pkg in lists)
                print pkg, lists[pkg]
        }' ${workdir}/${i}/FILES > ${workdir}/${i}/CATEGORIZED
    done
    i=""
    for i in ${category}; do
        for j in `${LS} ${workdir}/${i} | ${GREP} '^[a-z]'`; do
          ${AWK} '
          /^'"${j}"'/ {
              for (i = 2; i <= NF; i++) {
                  print $i
              }
          }' ${workdir}/${i}/CATEGORIZED > ${workdir}/${i}/${j}/PLIST
        done
    done
}

#
# Make "+BUILD_INFO" file.
#
make_BUILD_INFO()
{
    ${CAT} > ${workdir}/$1/+BUILD_INFO << _BUILD_INFO_
OPSYS=${opsys}
OS_VERSION=${osversion}
OBJECT_FMT=ELF
MACHINE_ARCH=${machine_arch}
PKGTOOLS_VERSION=${pkgtoolversion}
HOMEPAGE=${homepage}
MAINTAINER=${mail_address}
_BUILD_INFO_
}

#
# Calculate package's dependency.
#
culc_deps()
{
    ${GREP} -E "^$1" ${deps} > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        err "$1: Unknown package dependency."
        return 1
    fi
    ${AWK} '/^'"$1"'/{print $2}' ${deps} | while read depend; do
        ${TEST} ! "${depend}" && return 1
        ${ECHO} "@pkgdep ${depend}>=${release}" >> ${tmp_deps}
        ${TEST} "${depend}" = "base-sys-root" && return 0
        culc_deps ${depend} # Recursion.
    done
}

#
# Make "+CONTENTS" file.
#
make_CONTENTS()
{
    local TMPFILE=`${MKTEMP} -q || bomb "${TMPFILE}"`
    local filename
    local setname=`${ECHO} $1 | ${CUT} -d '/' -f 1 | ${SED} 's/\./-/g'`
    local pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`

    ${ECHO} "@name ${pkgname}-${release}" > ${workdir}/$1/+CONTENTS
    ${ECHO} "@comment Packaged at ${utcdate} UTC by ${user}@${host}" >> ${workdir}/$1/+CONTENTS

    ${TEST} -f ${tmp_deps} && ${RM} -f ${tmp_deps}
    culc_deps ${pkgname}
    ${TEST} -f ${tmp_deps} && ${SORT} ${tmp_deps} | ${UNIQ} >> ${workdir}/$1/+CONTENTS

    ${ECHO} "@cwd /" >> ${workdir}/$1/+CONTENTS
    ${CAT} ${workdir}/$1/PLIST | while read i; do
        ${TEST} $(${FILE} ${destdir}/${i} | ${CUT} -d " " -f 2) = "symbolic" && continue
        if [ -d ${destdir}/${i} ]; then
            filename=$(${ECHO} ${i} | ${SED} 's%\/%\\\/%g')
            ${AWK} '$1 ~ /^\.\/'"${filename}"'$/{print $0}' ${destdir}/etc/mtree/set.${setname} \
            | ${SED} 's%^\.\/%%' \
            | ${AWK} '
            {
                print "@exec install -d -o root -g wheel -m "substr($5, 6) " "$1
            } ' >> ${TMPFILE}
        fi
        ${TEST} -f ${destdir}/${i} && ${ECHO} ${i} >> ${TMPFILE}
    done

    ${SORT} ${TMPFILE} >> ${workdir}/$1/+CONTENTS
    ${RM} -f ${TMPFILE}
}

#
# Make "+DESC" and "+COMMENT" file.
#
make_DESC_and_COMMENT()
{
    local pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`

    ${AWK} '
    /^'"${pkgname}"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' ${descrs} > ${workdir}/$1/+DESC || bomb "${AWK} +DESC"

    ${AWK} '
    /^'"${pkgname}"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' ${comments} > ${workdir}/$1/+COMMENT || bomb "${AWK} +COMMENT"
}

_which()
{
    ans=$(type "$1" 2>/dev/null) || exit $?
    case "$1" in
        */*) ${PRINTF} '%s\n' $1 ; exit ;;
    esac
    case "$ans" in
        */*) ${PRINTF} '%s\n' "/${ans#*/}"; exit ;;
    esac
    ${PRINTF} '%s\n' $1
}

replace_cmdstr()
{
    ${SED} -e "s%@GROUPADD@%`_which groupadd`%g" \
           -e "s%@USERADD@%`_which useradd`%" \
           -e "s%@SH@%`_which sh`%" \
           -e "s%@PREFIX@%/%" \
           -e "s%@AWK@%`_which awk`%" \
           -e "s%@BASENAME@%`_which basename`%" \
           -e "s%@CAT@%`_which cat`%" \
           -e "s%@CHGRP@%`_which chgrp`%" \
           -e "s%@CHMOD@%`_which chmod`%" \
           -e "s%@CHOWN@%`_which chown`%" \
           -e "s%@CMP@%`_which cmp`%" \
           -e "s%@CP@%`_which cp`%" \
           -e "s%@DIRNAME@%`_which dirname`%" \
           -e "s%@ECHO@%echo%" \
           -e "s%@EGREP@%`_which egrep`%" \
           -e "s%@EXPR@%`_which expr`%" \
           -e "s%@FALSE@%`_which false`%" \
           -e "s%@FIND@%`_which find`%" \
           -e "s%@GREP@%`_which grep`%" \
           -e "s%@GTAR@%`_which gtar`%" \
           -e "s%@HEAD@%`_which head`%" \
           -e "s%@ID@%`_which id`%" \
           -e "s%@LINKFARM@%`_which linkfarm`%" \
           -e "s%@LN@%`_which ln`%" \
           -e "s%@LOCALBASE@%`_which localbase`%" \
           -e "s%@LS@%`_which ls`%" \
           -e "s%@MKDIR@%`_which mkdir` -p%" \
           -e "s%@MV@%`_which mv`%" \
           -e "s%@PKGBASE@%/%" \
           -e "s%@RM@%`_which  rm`%" \
           -e "s%@RMDIR@%`_which rmdir`%" \
           -e "s%@SED@%`_which sed`%" \
           -e "s%@SETENV@%`_which setenv`%" \
           -e "s%@ECHO_N@%echo -n%" \
           -e "s%@PKG_ADMIN@%`_which pkg_admin`%" \
           -e "s%@PKG_INFO@%`_which pkg_info`%" \
           -e "s%@PWD_CMD@%pwd%" \
           -e "s%@SORT@%`_which sort`%" \
           -e "s%@SU@%`_which su`%" \
           -e "s%@TEST@%test%" \
           -e "s%@TOUCH@%`_which touch`%" \
           -e "s%@TR@%`_which tr`%" \
           -e "s%@TRUE@%`_which true`%" \
           -e "s%@XARGS@%`_which xargs`%" \
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
           -e "s%@PERL5@%`_which perl`%" $1 || bomb "failed sed"
}

#
# Make "+INSTALL" file.
# Role of "+INSTALL" is defining absolute path of file, 
# permission, owner and group.
#
make_INSTALL()
{
    local mode_user_group=""

    ${TEST} -f ${workdir}/$1/+INSTALL && ${RM} -f ${workdir}/$1/+INSTALL
    replace_cmdstr ${install_script} > ${workdir}/$1/+INSTALL

    ${TEST} -f ${workdir}/$1/+CONTENTS || bomb "+CONTENTS not found."
    ${GREP} -v -e "^@" ${workdir}/$1/+CONTENTS | while read file; do
        ${TEST} $(${FILE} ${file} | ${CUT} -d " " -f 2) = "symbolic" && continue
        if [ $(${ECHO} ${file} | ${CUT} -d "/" -f 1) = "etc" ]; then
            ${TEST} -f ${destdir}/${file} && \
                mode_user_group=$(
                    ${GREP} -e "^\./${file} " ${destdir}/etc/mtree/set.etc \
                    | ${CUT} -d " " -f 3 -f 4 -f 5 \
                    | ${XARGS} -n 1 -I % ${EXPR} x% : "x[^=]*=\\(.*\\)" \
                    | ${TR} '\n' ' '
                )
            ${ECHO} "# FILE: /${file} c ${file} ${mode_user_group}" \
                >> ${workdir}/$1/+INSTALL
        fi
    done
}

make_DEINSTALL()
{
    ${TEST} -f ${workdir}/$1/+DEINSTALL && ${RM} -f ${workdir}/$1/+DEINSTALL
    replace_cmdstr ${deinstall_script} > ${workdir}/$1/+DEINSTALL
}

#
# "pkg_create" command wrapper.
# Package moved to ${packages}/All directory.
#
do_pkg_create()
{
    local pkgname=`${ECHO} $1 | ${CUT} -d '/' -f 2 | ${SED} 's/\./-/g'`

    ${PKG_CREATE} -v -l -U \
        -B ${workdir}/$1/+BUILD_INFO \
        -I "/" \
        -i ${workdir}/$1/+INSTALL \
        -K ${pkgdb} \
        -k ${workdir}/$1/+DEINSTALL \
        -p ${destdir} \
        -c ${workdir}/$1/+COMMENT \
        -d ${workdir}/$1/+DESC \
        -f ${workdir}/$1/+CONTENTS \
        ${pkgname} || bomb "$1: ${PKG_CREATE}"

    ${TEST} -d ${packages}/${release}/${machine} \
        || ${MKDIR} -p ${packages}/${release}/${machine}

    ${MV} ./${pkgname}.tgz \
        ${packages}/${release}/${machine}/${pkgname}-${release}.tgz
}

#
# Execute any functions and make MD5 and SHA512.
#
make_packages()
{
    local i j
    local pkgs

    for i in ${category}; do
        for j in `${LS} ${workdir}/${i} | ${GREP} -E '^[a-z]+'`; do
            make_BUILD_INFO "${i}/${j}"
            make_CONTENTS "${i}/${j}"
            make_DESC_and_COMMENT "${i}/${j}"
            make_INSTALL "${i}/${j}"
            make_DEINSTALL "${i}/${j}"
            do_pkg_create "${i}/${j}"
        done
    done
    pkgs="$(
        ${FIND} ${packages} -type f \
        \! -name MD5 \! -name *SUM \! -name SHA512 2>/dev/null
    )"
    if [ -n "${pkgs}" ]; then
        ${CKSUM} -a md5 ${pkgs} > ${packages}/${release}/${machine}/MD5
        ${CKSUM} -a sha512 ${pkgs} > ${packages}/${release}/${machine}/SHA512
    fi
}

#
# Make kernel package.
#
make_kernel_package()
{
    local category="base"
    local pkgname="base-kernel-${kernel}"

    ${TEST} -d ${workdir}/${category}/.${pkgname} \
        || ${MKDIR} -p ${workdir}/${category}/${pkgname}

    # Information of build environment.
    ${CAT} > ${workdir}/${category}/${pkgname}/+BUILD_INFO << _BUILD_INFO_
OPSYS=${opsys}
OS_VERSION=${osversion}
OBJECT_FMT=ELF
MACHINE_ARCH=${machine_arch}
PKGTOOLS_VERSION=${pkgtoolversion}
_BUILD_INFO_

    # Short description of package.
    ${CAT} > ${workdir}/${category}/${pkgname}/+COMMENT << _COMMENT_
NetBSD Kernel
_COMMENT_

    # Description of package.
    ${CAT} > ${workdir}/${category}/${pkgname}/+DESC << _DESC_
NetBSD Kernel
_DESC_

    # Package contents.
    ${CAT} > ${workdir}/${category}/${pkgname}/+CONTENTS << _CONTENTS_
@name ${pkgname}-${release}
@comment Packaged at ${utcdate} UTC by ${user}@${host}
@cwd / 
netbsd
_CONTENTS_

    ${PKG_CREATE} -v -l -U \
    -B ${workdir}/${category}/${pkgname}/+BUILD_INFO \
    -I "/" \
    -c ${workdir}/${category}/${pkgname}/+COMMENT \
    -d ${workdir}/${category}/${pkgname}/+DESC \
    -f ${workdir}/${category}/${pkgname}/+CONTENTS \
    -p ${obj}/sys/arch/${machine}/compile/${kernel} \
    -K ${pkgdb} ${pkgname} || bomb "kernel: ${PKG_CREATE}"

    ${TEST} -d ${packages}/${release}/${machine} \
        || ${MKDIR} -p ${packages}/${release}/${machine}

    ${MV} ./${pkgname}.tgz \
        ${packages}/${release}/${machine}/${pkgname}-${release}.tgz
}

#
# Show usage.
#
usage()
{
    ${CAT} <<_usage_

Usage: ${progname} [--obj obj_dir] [--category category] operation

 Operation:
    pkg                 Create packages.
    kern                Create kernel package.

 Options:
    --help              Show this message and exit.
    --obj               Set obj to NetBSD binaries.
                        [Default: ${obj}]
    --category          Set category.
                        [Default: "base comp etc games man misc text"]
    --machine           Set machine type for MACHINE_ARCH.
                        [Default: ${machine}]
    --kernel            Set kernel type.
                        [Default: GENERIC]
_usage_
    exit 1
}

#
# --obj=/usr/obj
#       ^^^^^^^^^
#        take it
# return -> /usr/obj
#
get_optarg()
{
    ${EXPR} "x$1" : "x[^=]*=\\(.*\\)"
}

# Main

machine="$(${UNAME} -m)"

# parse long-options
while [ $# -gt 0 ]; do
    case $1 in
    -h|--help)
        usage
        ;;
    --obj)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        obj=$2
        shift
        ;;
    --obj=*)
        obj=$(get_optarg "$1")
        ;;
    --releasedir)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        releasedir=$2
        shift
        ;;
    --releasedir=*)
        releasedir=$(get_optarg "$1")
        ;;
    --destdir)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        destdir=$2
        shift
        ;;
    --destdir=*)
        destdir=$(get_optarg "$1")
        ;;
    --category=*)
        category=$(get_optarg "$1")
        ;;
    --category)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        category="$2"
        shift
        ;;
    --machine=*)
        machine=$(get_optarg "$1")
        ;;
    --machine)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        machine="$2"
        shift
        ;;
    --kernel=*)
        kernel=$(get_optarg "$1")
        ;;
    --kernel)
        ${TEST} -z $2 && (err "What is $1 parameter?" ; exit 1)
        kernel="$2"
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

# Initialization
set -u
umask 0022
export LC_ALL=C LANG=C

getarch
validatearch
destdir=${destdir:-"${obj}/destdir.${MACHINE}"}
releasedir=${releasedir:-.}
release="$(osrelease -a)"
release_k="$(osrelease -k)"
machine_arch=${MACHINE_ARCH}
moduledir="stand/${machine}/${release}/modules"
workdir="${releasedir}/work/${release}/${machine}"
kerneldir="${obj}/sys/arch/${machine}/compile"
packages="${releasedir}/packages"

# least assertions
${TEST} -f "sets/install"  || bomb "require ./sets/"
${TEST} "X$release" != "X" || bomb "cannot resolve \$release"

${TEST} $# -eq 0 && usage

# operation
case $1 in
pkg)
    split_category_from_lists
    make_directories_of_package
    make_contents_list
    make_packages
    ;;
kern)
    make_kernel_package
    ;;
*)
    usage
    ;;
esac

exit 0
