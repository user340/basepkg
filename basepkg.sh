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

################################################################################
#
# POSIX undefined commands.
#     - hostname -- set or print name of current host system.
#     - mktemp -- make temporary file name.
#     - pkg_create -- a utility for creating software package distributions.
#
################################################################################

################################################################################
#
# The which(1) command is undefined in POSIX. So this process check the 
# which(1) command. If not exist in the system, define a function that same as 
# the which(1) command.
#
################################################################################
which which > /dev/null 2>&1 || {
    which()
    {
        ans=$(type "$1" 2>/dev/null) || exit $?
        case "$1" in
            */*) printf '%s\n' $1 ; exit ;;
        esac
        case "$ans" in
            */*) printf '%s\n' "/${ans#*/}"; exit ;;
        esac
        printf '%s\n' $1
    }
}

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
tmp_deps="/tmp/culldeps"
homepage="https://github.com/user340/basepkg"
mail_address="mail@e-yuuki.org"
toppid=$$

obj="/usr/obj"
packages="$PWD/packages"
category="base comp etc games man misc text"
kernel="GENERIC"
pkgdb="/var/db/basepkg"

################################################################################
#
# Output the error message to STDERR
#
################################################################################
err()
{
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')] $*" >&2
}

################################################################################
#
# Output abbort message. Then, kill the process and exit from it.
#
################################################################################
bomb()
{
    cat >&2 <<MESSAGE

ERROR: $@
*** PACKAGING ABORTED ***
MESSAGE
    kill $toppid
    exit 1
}

################################################################################
#
# The MACHINE_ARCH variable use MACHINE value as a reference.
#
################################################################################
getarch()
{
    local IFS
    local found=""
    local line
    
    IFS="$nl"
    for line in $valid_MACHINE_ARCH; do
        line="${line%%#*}"
        line="$( IFS=" $tab" ; echo $line )" # normalise white space
        case "$line " in
        " ")
            # skip blank lines or comment lines
            continue
            ;;
        *" ALIAS=$machine "*)
            # Found a line with a matching ALIAS=<alias>.
            found="$line"
            break
            ;;
        "MACHINE=$machine "*" NO_DEFAULT"*)
            # Found an explicit "NO_DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=$machine "*" DEFAULT"*)
            # Found an explicit "DEFAULT" for this MACHINE.
            found="$line"
            break
            ;;
        "MACHINE=$machine "*)
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
          for frag in $found; do
              case "$frag" in
              MACHINE=*|MACHINE_ARCH=*)
                  eval "$frag"
                  ;;
              esac
          done
          ;;
      *)
          bomb "Unknown target MACHINE: $machine"
          ;;
      esac
}

################################################################################
#
# Exit if the pair is not supported.
#
################################################################################
validatearch()
{
    local IFS
    local line
    local foundpair=false foundmachine=false foundarch=false

    case "$MACHINE_ARCH" in
    "")
        bomb "No MACHINE_ARCH provided"
        ;;
    esac

    IFS="$nl"
    for line in $valid_MACHINE_ARCH; do
        line="${line%%#*}" # ignore comments
        line="$( IFS=" $tab" ; echo $line )" # normalise white space
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
        bomb "Unknown target MACHINE: $MACHINE"
        ;;
    *:*:false)
        bomb "Unknown target MACHINE_ARCH: $MACHINE_ARCH"
        ;;
    *)
        bomb "MACHINE_ARCH '$MACHINE_ARCH' does not support MACHINE '$MACHINE'"
        ;;
    esac
}


################################################################################
#
# Output number of version of NetBSD. In default, number of version is drawn 
# from "/usr/obj/usr/include/sys/param.h". The osrelease() function not require 
# NetBSD source tree (/usr/src).
#
################################################################################
osrelease() {
    local option; option="$1"
    local define ver_tag rel_num comment_start NetBSD rel_text rest beta
    exec < "$destdir/$param"

    while
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
    set -- - $rel_text
    beta=${3#[0-9]}
    beta=${beta#[0-9]}
    shift 3
    IFS=' '
    set -- $rel_MM ${rel_mm#0}$beta "$@"
    case "$option" in
    -k)
        if [ ${rel_mm#0} = 99 ]; then
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
}

################################################################################
#
# Make category directory and organized files named "FILES".
#
################################################################################
split_category_from_lists()
{
    local i j
    local ad mi md shl module rescue rescue_ad rescue_machine stl
    for i in $category; do
        test -d "$workdir/$i" || mkdir -p "$workdir/$i"
        test -f "$workdir/$i/FILES" && rm -f "$workdir/$i/FILES"
        for j in $(ls $lists); do
            ad=""
            mi=""
            md=""
            module=""
            rescue=""
            rescue_ad=""
            rescue_machine=""
            shl=""
            stl=""
            test -f "$lists/$j/ad.$machine" && ad="$lists/$j/ad.$machine"
            test -f "$lists/$j/mi" && mi="$lists/$j/mi"
            test -f "$lists/$j/md.$machine" && md="$lists/$j/md.$machine"
            test -f "$lists/$j/module.mi" && module="$lists/$j/module.mi"
            test -f "$lists/$j/rescue.mi" && rescue="$lists/$j/rescue.mi"
            test -f "$lists/$j/rescue.ad.$machine" \
                && rescue_ad="$lists/$j/rescue.ad.$machine"
            test -f "$lists/$j/rescue.$machine" \
                && rescue_machine="$lists/$j/rescue.$machine"
            test -f "$lists/$j/shl.mi" && shl="$lists/$j/shl.mi"
            test -f "$lists/$j/stl.mi" && stl="$lists/$j/stl.mi"
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
                            gsub(/@MODULEDIR@/, "stand/'"$machine"'/'"$release_k"'/modules");
                            gsub(/@MACHINE@/, "'"$machine"'");
                            gsub(/@OSRELEASE@/, "'"$release_k"'");
                            print
                        }
                    }
                }' >> "$workdir/$i/FILES"
      done
    done
}

################################################################################
#
# Make directories referring to "FILES".
#
################################################################################
make_directories_of_package()
{
    local i
    for i in $category; do
        awk '{print $2}' "$workdir/$i/FILES" | sort | uniq \
        | xargs -n 1 -I % sh -c \
            "test -d $workdir/$i/% || mkdir $workdir/$i/%"
    done
}

################################################################################
#
# List each package's contents and write into "category/package/package.FILE".
#
################################################################################
make_contents_list()
{
    local i j
    for i in $category; do
        awk ' 
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
        }' "$workdir/$i/FILES" > "$workdir/$i/CATEGORIZED"
    done
    i=""
    for i in $category; do
        for j in $(ls "$workdir/$i" | grep '^[a-z]'); do
          awk '
          /^'"$j"'/ {
              for (i = 2; i <= NF; i++) {
                  print $i
              }
          }' "$workdir/$i/CATEGORIZED" > "$workdir/$i/$j/PLIST"
        done
    done
}

################################################################################
#
# Make "+BUILD_INFO" file.
#
################################################################################
make_BUILD_INFO()
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

################################################################################
#
# Calculate package's dependency.
#
################################################################################
culc_deps()
{
    grep -E "^$1" "$deps" > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        err "$1: Unknown package dependency."
        return 1
    fi
    awk '/^'"$1"'/{print $2}' "$deps" | while read -r depend; do
        test ! "$depend" && return 1
        echo "@pkgdep $depend>=$release" >> "$tmp_deps"
        test "$depend" = "base-sys-root" && return 0
        culc_deps $depend # Recursion.
    done
}

################################################################################
#
# Make "+CONTENTS" file.
#
################################################################################
make_CONTENTS()
{
    local TMPFILE=$(mktemp -q || bomb "$TMPFILE")
    local filename
    local setname=$(echo $1 | cut -d '/' -f 1 | sed 's/\./-/g')
    local pkgname=$(echo $1 | cut -d '/' -f 2 | sed 's/\./-/g')

    echo "@name $pkgname-$release" > "$workdir/$1/+CONTENTS"
    echo "@comment Packaged at $utcdate UTC by $user@$host" >> "$workdir/$1/+CONTENTS"

    test -f "$tmp_deps" && rm -f "$tmp_deps"
    culc_deps "$pkgname"
    test -f "$tmp_deps" && sort "$tmp_deps" | uniq >> "$workdir/$1/+CONTENTS"

    echo "@cwd /" >> "$workdir/$1/+CONTENTS"
    cat "$workdir/$1/PLIST" | while read -r i; do
        test $(file "$destdir/$i" | cut -d " " -f 2) = "symbolic" && continue
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
    done

    sort "$TMPFILE" >> "$workdir/$1/+CONTENTS"
    rm -f "$TMPFILE"
}

################################################################################
#
# Make "+DESC" and "+COMMENT" file.
#
################################################################################
make_DESC_and_COMMENT()
{
    local pkgname=$(echo $1 | cut -d '/' -f 2 | sed 's/\./-/g')

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$descrs" > "$workdir/$1/+DESC" || bomb "awk +DESC"

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$comments" > "$workdir/$1/+COMMENT" || bomb "awk +COMMENT"
}

replace_cmdstr()
{
    sed -e "s%@GROUPADD@%$(which groupadd)%g" \
        -e "s%@USERADD@%$(which useradd)%" \
        -e "s%@SH@%$(which sh)%" \
        -e "s%@PREFIX@%/%" \
        -e "s%@AWK@%$(which awk)%" \
        -e "s%@BASENAME@%$(which basename)%" \
        -e "s%@CAT@%$(which cat)%" \
        -e "s%@CHGRP@%$(which chgrp)%" \
        -e "s%@CHMOD@%$(which chmod)%" \
        -e "s%@CHOWN@%$(which chown)%" \
        -e "s%@CMP@%$(which cmp)%" \
        -e "s%@CP@%$(which cp)%" \
        -e "s%@DIRNAME@%$(which dirname)%" \
        -e "s%@ECHO@%echo%" \
        -e "s%@EGREP@%$(which egrep)%" \
        -e "s%@EXPR@%$(which expr)%" \
        -e "s%@FALSE@%$(which false)%" \
        -e "s%@FIND@%$(which find)%" \
        -e "s%@GREP@%$(which grep)%" \
        -e "s%@GTAR@%$(which gtar)%" \
        -e "s%@HEAD@%$(which head)%" \
        -e "s%@ID@%$(which id)%" \
        -e "s%@LINKFARM@%$(which linkfarm)%" \
        -e "s%@LN@%$(which ln)%" \
        -e "s%@LOCALBASE@%$(which localbase)%" \
        -e "s%@LS@%$(which ls)%" \
        -e "s%@MKDIR@%$(which mkdir) -p%" \
        -e "s%@MV@%$(which mv)%" \
        -e "s%@PKGBASE@%/%" \
        -e "s%@RM@%$(which  rm)%" \
        -e "s%@RMDIR@%$(which rmdir)%" \
        -e "s%@SED@%$(which sed)%" \
        -e "s%@SETENV@%$(which setenv)%" \
        -e "s%@ECHO_N@%echo -n%" \
        -e "s%@PKG_ADMIN@%$(which pkg_admin)%" \
        -e "s%@PKG_INFO@%$(which pkg_info)%" \
        -e "s%@PWD_CMD@%pwd%" \
        -e "s%@SORT@%$(which sort)%" \
        -e "s%@SU@%$(which su)%" \
        -e "s%@TEST@%test%" \
        -e "s%@TOUCH@%$(which touch)%" \
        -e "s%@TR@%$(which tr)%" \
        -e "s%@TRUE@%$(which true)%" \
        -e "s%@XARGS@%$(which xargs)%" \
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
        -e "s%@PERL5@%$(which perl)%" $1 || bomb "failed sed"
}

################################################################################
#
# Make "+INSTALL" file. The role of "+INSTALL" is defining absolute path of 
# file, permission, owner and group.
#
################################################################################
make_INSTALL()
{
    local mode_user_group=""

    test -f "$workdir/$1/+INSTALL" && rm -f "$workdir/$1/+INSTALL"
    replace_cmdstr $install_script > "$workdir/$1/+INSTALL"

    test -f "$workdir/$1/+CONTENTS" || bomb "+CONTENTS not found."
    grep -v -e "^@" "$workdir/$1/+CONTENTS" | while read -r file; do
        test $(file "$file" | cut -d " " -f 2) = "symbolic" && continue
        if [ $(echo "$file" | cut -d "/" -f 1) = "etc" ]; then
            test -f "$destdir/$file" && \
                mode_user_group=$(
                    grep -e "^\./$file " $destdir/etc/mtree/set.etc \
                    | cut -d " " -f 3 -f 4 -f 5 \
                    | xargs -n 1 -I % expr x% : "x[^=]*=\\(.*\\)" \
                    | tr '\n' ' '
                )
            echo "# FILE: /$file c $file $mode_user_group" \
                >> "$workdir/$1/+INSTALL"
        fi
    done
}

make_DEINSTALL()
{
    test -f "$workdir/$1/+DEINSTALL" && rm -f "$workdir/$1/+DEINSTALL"
    replace_cmdstr "$deinstall_script" > "$workdir/$1/+DEINSTALL"
}

output_base_dir () 
{
   if [ "X$MACHINE_ARCH" != "X$MACHINE" ];then
     echo "$packages/$release/$MACHINE-$MACHINE_ARCH"
   else
     echo "$packages/$release/$MACHINE"
   fi
}

################################################################################
#
# "pkg_create" command wrapper. Package moved to ${packages}/All directory.
#
################################################################################
do_pkg_create()
{
    local pkgname=$(echo $1 | cut -d '/' -f 2 | sed 's/\./-/g')

    pkg_create -v -l -U \
        -B "$workdir/$1/+BUILD_INFO" \
        -I "/" \
        -i "$workdir/$1/+INSTALL" \
        -K "$pkgdb" \
        -k "$workdir/$1/+DEINSTALL" \
        -p "$destdir" \
        -c "$workdir/$1/+COMMENT" \
        -d "$workdir/$1/+DESC" \
        -f "$workdir/$1/+CONTENTS" \
        "$pkgname" || bomb "$1: pkg_create"

    local _basedir=$(output_base_dir)
    test -d "$_basedir" || mkdir -p "$_basedir"
    mv "./$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
}

################################################################################
#
# Execute any functions and make MD5 and SHA512.
#
################################################################################
make_packages()
{
    local i j
    local pkgs

    for i in $category; do
        for j in $(ls "$workdir/$i" | grep -E '^[a-z]+'); do
            make_BUILD_INFO "$i/$j"
            make_CONTENTS "$i/$j"
            make_DESC_and_COMMENT "$i/$j"
            make_INSTALL "$i/$j"
            make_DEINSTALL "$i/$j"
            do_pkg_create "$i/$j"
        done
    done
    pkgs="$(
        find $packages -type f \
        \! -name MD5 \! -name *SUM \! -name SHA512 2>/dev/null
    )"

    local _basedir=$(output_base_dir)
    if [ -n "$pkgs" ]; then
        cksum -a    md5 $pkgs > "$_basedir/MD5"
        cksum -a sha512 $pkgs > "$_basedir/SHA512"
    fi
}

################################################################################
#
# Make kernel package.
#
################################################################################
make_kernel_package()
{
    local category="base"
    local pkgname="base-kernel-$kernel"

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
NetBSD Kernel
_COMMENT_

    # Description of package.
    cat > "$workdir/$category/$pkgname/+DESC" << _DESC_
NetBSD Kernel
_DESC_

    # Package contents.
    cat > "$workdir/$category/$pkgname/+CONTENTS" << _CONTENTS_
@name $pkgname-$release
@comment Packaged at $utcdate UTC by $user@$host
@cwd / 
netbsd
_CONTENTS_

    pkg_create -v -l -U \
    -B "$workdir/$category/$pkgname/+BUILD_INFO" \
    -I "/" \
    -c "$workdir/$category/$pkgname/+COMMENT" \
    -d "$workdir/$category/$pkgname/+DESC" \
    -f "$workdir/$category/$pkgname/+CONTENTS" \
    -p "$obj/sys/arch/$machine/compile/$kernel" \
    -K "$pkgdb" "$pkgname" || bomb "kernel: pkg_create"

    local _basedir=$(output_base_dir)
    test -d "$_basedir" || mkdir -p "$_basedir"
    mv "$PWD/$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
}

################################################################################
#
# Show usage to STDOUT.
#
################################################################################
usage()
{
    cat <<_usage_

Usage: $progname [--obj obj_dir] [--category category] operation

 Operation:
    pkg                 Create packages.
    kern                Create kernel package.

 Options:
    --help              Show this message and exit.
    --obj               Set obj to NetBSD binaries.
                        [Default: $obj]
    --category          Set category.
                        [Default: "base comp etc games man misc text"]
    --machine           Set machine type for MACHINE_ARCH.
                        [Default: $machine]
    --kernel            Set kernel type.
                        [Default: GENERIC]
_usage_
    exit 1
}

################################################################################
#
# --obj=/usr/obj
#       ^^^^^^^^^
#        take it
# return -> /usr/obj
#
################################################################################
get_optarg()
{
    expr "x$1" : "x[^=]*=\\(.*\\)"
}

################################################################################
#
# Start of main processes.
#
################################################################################

machine="$(uname -m)"

################################################################################
#
# Parse long-options
#
################################################################################
while [ $# -gt 0 ]; do
    case $1 in
    -h|--help)
        usage
        ;;
    --obj)
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
        obj=$2
        shift
        ;;
    --obj=*)
        obj=$(get_optarg "$1")
        ;;
    --releasedir)
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
        releasedir=$2
        shift
        ;;
    --releasedir=*)
        releasedir=$(get_optarg "$1")
        ;;
    --destdir)
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
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
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
        category="$2"
        shift
        ;;
    --machine=*)
        machine=$(get_optarg "$1")
        ;;
    --machine)
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
        machine="$2"
        shift
        ;;
    --kernel=*)
        kernel=$(get_optarg "$1")
        ;;
    --kernel)
        test -z $2 && (err "What is $1 parameter?" ; exit 1)
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

################################################################################
#
# Initialization
#
################################################################################
set -u
umask 0022
export LC_ALL=C LANG=C

getarch
validatearch
destdir=${destdir:-"$obj/destdir.$MACHINE"}
releasedir=${releasedir:-.}
release="$(osrelease -a)"
release_k="$(osrelease -k)"
machine_arch=$MACHINE_ARCH
workdir="$releasedir/work/$release/$machine"
packages="$releasedir/packages"

################################################################################
#
# least assertions
#
################################################################################
test -f "sets/install"  || bomb "require ./sets/"
test "X$release" != "X" || bomb "cannot resolve \$release"

test $# -eq 0 && usage

################################################################################
#
# operation
#
################################################################################
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
