#!/bin/sh
#
# Copyright (c) 2001-2019 The NetBSD Foundation, Inc.
# Copyright (c) 2016-2019 Yuuki Enomoto
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
# basepkg.sh --  Create NetBSD system packages.
#
# It works for the followings.
#     - Create base system packages in reference to /usr/obj (default).
#     - Create kernel packages in reference to
#       /usr/obj/sys/<MACHINE>/compile (default).
#
# These are POSIX undefined command.
#     - hostname(1) -- set or print name of current host system.
#     - mktemp(1) -- make temporary file name.
#     - pkg_create(1) -- a utility for creating software package distributions.
#
# Please use ShellCheck (https://koalaman/shellcheck) for your code.
#

###############################################################################
#
# {{{ Begin shell feature tests.
#
# We try to determine whether or not this script is being run under
# a shell that supports the features that we use.  If not, we try to
# re-exec the script under another shell.  If we can't find another
# suitable shell, then we print a message and exit.
#
# These code were imported from NetBSD's build.sh.
#
###############################################################################

errmsg=''		# error message, if not empty
shelltest=false		# if true, exit after testing the shell
re_exec_allowed=true	# if true, we may exec under another shell

# Parse special command line options in $1.  These special options are
# for internal use only, are not documented, and are not valid anywhere
# other than $1.
case "$1" in
"--shelltest")
    shelltest=true
    re_exec_allowed=false
    shift
    ;;
"--no-re-exec")
    re_exec_allowed=false
    shift
    ;;
esac

# Solaris /bin/sh, and other SVR4 shells, do not support "!".
# This is the first feature that we test, because subsequent
# tests use "!".
#
if test -z "$errmsg"; then
    if ( eval '! false' ) >/dev/null 2>&1 ; then
	:
    else
	errmsg='Shell does not support "!".'
    fi
fi

# Does the shell support functions?
#
if test -z "$errmsg"; then
    if ! (
	eval 'somefunction() { : ; }'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support functions.'
    fi
fi

# Does the shell support the "local" keyword for variables in functions?
#
# Local variables are not required by SUSv3, but some scripts run during
# the NetBSD build use them.
#
# ksh93 fails this test; it uses an incompatible syntax involving the
# keywords 'function' and 'typeset'.
#
if test -z "$errmsg"; then
    if ! (
	eval 'f() { local v=2; }; v=1; f && test x"$v" = x"1"'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support the "local" keyword in functions.'
    fi
fi

# Does the shell support ${var%suffix}, ${var#prefix}, and their variants?
#
# We don't bother testing for ${var+value}, ${var-value}, or their variants,
# since shells without those are sure to fail other tests too.
#
if test -z "$errmsg"; then
    if ! (
	eval 'var=a/b/c ;
	      test x"${var#*/};${var##*/};${var%/*};${var%%/*}" = \
		   x"b/c;c;a/b;a" ;'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support "${var%suffix}" or "${var#prefix}".'
    fi
fi

# Does the shell support IFS?
#
# zsh in normal mode (as opposed to "emulate sh" mode) fails this test.
#
if test -z "$errmsg"; then
    if ! (
	eval 'IFS=: ; v=":a b::c" ; set -- $v ; IFS=+ ;
		test x"$#;$1,$2,$3,$4;$*" = x"4;,a b,,c;+a b++c"'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support IFS word splitting.'
    fi
fi

# Does the shell support ${1+"$@"}?
#
# Some versions of zsh fail this test, even in "emulate sh" mode.
#
if test -z "$errmsg"; then
    if ! (
	eval 'set -- "a a a" "b b b"; set -- ${1+"$@"};
	      test x"$#;$1;$2" = x"2;a a a;b b b";'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support ${1+"$@"}.'
    fi
fi

# Does the shell support $(...) command substitution?
#
if test -z "$errmsg"; then
    if ! (
	eval 'var=$(echo abc); test x"$var" = x"abc"'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support "$(...)" command substitution.'
    fi
fi

# Does the shell support $(...) command substitution with
# unbalanced parentheses?
#
# Some shells known to fail this test are:  NetBSD /bin/ksh (as of 2009-12),
# bash-3.1, pdksh-5.2.14, zsh-4.2.7 in "emulate sh" mode.
#
if test -z "$errmsg"; then
    if ! (
	eval 'var=$(case x in x) echo abc;; esac); test x"$var" = x"abc"'
	) >/dev/null 2>&1
    then
	# XXX: This test is ignored because so many shells fail it; instead,
	#      the NetBSD build avoids using the problematic construct.
	: ignore 'Shell does not support "$(...)" with unbalanced ")".'
    fi
fi

# Does the shell support getopts or getopt?
#
if test -z "$errmsg"; then
    if ! (
	eval 'type getopts || type getopt'
	) >/dev/null 2>&1
    then
	errmsg='Shell does not support getopts or getopt.'
    fi
fi

#
# If shelltest is true, exit now, reporting whether or not the shell is good.
#
if $shelltest; then
    if test -n "$errmsg"; then
	echo >&2 "$0: $errmsg"
	exit 1
    else
	exit 0
    fi
fi

#
# If the shell was bad, try to exec a better shell, or report an error.
#
# Loops are broken by passing an extra "--no-re-exec" flag to the new
# instance of this script.
#
if test -n "$errmsg"; then
    if $re_exec_allowed; then
	for othershell in \
	    "${HOST_SH}" /usr/xpg4/bin/sh ksh ksh88 mksh pdksh dash bash
	    # NOTE: some shells known not to work are:
	    # any shell using csh syntax;
	    # Solaris /bin/sh (missing many modern features);
	    # ksh93 (incompatible syntax for local variables);
	    # zsh (many differences, unless run in compatibility mode).
	do
	    test -n "$othershell" || continue
	    if eval 'type "$othershell"' >/dev/null 2>&1 \
		&& "$othershell" "$0" --shelltest >/dev/null 2>&1
	    then
		cat <<EOF
$0: $errmsg
$0: Retrying under $othershell
EOF
		HOST_SH="$othershell"
		export HOST_SH
		exec $othershell "$0" --no-re-exec "$@" # avoid ${1+"$@"}
	    fi
	    # If HOST_SH was set, but failed the test above,
	    # then give up without trying any other shells.
	    test x"${othershell}" = x"${HOST_SH}" && break
	done
    fi

    #
    # If we get here, then the shell is bad, and we either could not
    # find a replacement, or were not allowed to try a replacement.
    #
    cat <<EOF
$0: $errmsg

The NetBSD build system requires a shell that supports modern POSIX
features, as well as the "local" keyword in functions (which is a
widely-implemented but non-standardised feature).

Please re-run this script under a suitable shell.  For example:

	/path/to/suitable/shell $0 ...

The above command will usually enable build.sh to automatically set
HOST_SH=/path/to/suitable/shell, but if that fails, then you may also
need to explicitly set the HOST_SH environment variable, as follows:

	HOST_SH=/path/to/suitable/shell
	export HOST_SH
	\${HOST_SH} $0 ...
EOF
    exit 1
fi

###############################################################################
#
# }}} End shell feature tests.
#
###############################################################################

###############################################################################
#
# Functions
#
###############################################################################

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
    _remove_if_exists "$log"
    kill $toppid
    exit 1
}

_bomb_if_command_not_found()
{
    command -v "$1" > /dev/null 2>&1 || _bomb "$1 not found."
}

_bomb_if_not_found()
{
    test -f "$1" || _bomb "$1 not found"
}

_mkdir_if_not_exists()
{
    test -d "$1" || mkdir -p "$1"
}

_remove_if_exists()
{
    test -f "$1" && rm -f "$1"
}

_remove_directory_if_exists_and_writable()
{
    test -w "$1" && rm -fr "$1"
}

_logging()
{
    printf "%s\\n" "$@" | tee -a "$log"
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
    found=""

    IFS="$nl"
    for line in $valid_MACHINE_ARCH; do
        line="${line%%#*}" # ignore comments
        # Don't quote this $line
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
            '') found="$line" ;;
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
                # Here is difference point from original.
                # Original source code calls "eval" but we decided to call
                # "echo" because we want to print "frag" value to
                # standard output.
                echo "$frag"
                ;;
            esac
        done
        ;;
    *)
        _bomb "Unknown target MACHINE: $machine"
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
    case "$machine_arch" in
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
    local option="$1"

    exec < "$destdir/$param"

    # In this function, "comment_start" and "NetBSD" are unreferenced variables.
    while
        # shellcheck disable=SC2034
        read -r define ver_tag rel_num comment_start NetBSD rel_text rest; do
        [ "$define" = "#define" ] || continue;
        [ "$ver_tag" = "__NetBSD_Version__" ] || continue
        break
    done
    local rel_num=${rel_num%??}
    local rel_MMmm=${rel_num%????}
    local rel_MM=${rel_MMmm%??}
    local rel_mm=${rel_MMmm#$rel_MM}
    local IFS=.
    # shellcheck disable=SC2086
    set -- - $rel_text
    local beta=${3#[0-9]}
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
}

_print_if_file_exists()
{
    test -f "$1" && printf "%s" "$1"
}

#
# _split_category -- Make category directory and organized files named "FILES".
#
_split_category()
{
 (
    _logging "===> _split_category()"

    local moduledir="stand/$machine/$release_k/modules"

    for i in $category; do
        local category_dir="$lists/$i"

        _mkdir_if_not_exists "$workdir/$i"
        _remove_if_exists "$workdir/$i/FILES"

        ad="$(_print_if_file_exists "$category_dir/ad.$machine")"
        mi="$(_print_if_file_exists "$category_dir/mi")"
        md="$(_print_if_file_exists "$category_dir/md.$machine")"
        module="$(_print_if_file_exists "$category_dir/module.mi")"
        rescue="$(_print_if_file_exists "$category_dir/rescue.mi")"
        rescue_ad="$(_print_if_file_exists "$category_dir/rescue.ad.$machine")"
        rescue_machine="$(_print_if_file_exists "$category_dir/rescue.$machine")"
        shl="$(_print_if_file_exists "$category_dir/shl.mi")"
        stl="$(_print_if_file_exists "$category_dir/stl.mi")"

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
                # Ignore package with obsolete tags.
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
 )
}

_make_package_directories()
{
    _logging "===> _make_package_directories()"
    for i in $category; do
        awk '{print $2}' "$workdir/$i/FILES" | sort -u \
        | xargs -n 1 -I % sh -c "test -d $workdir/$i/% || mkdir $workdir/$i/%"
    done
}

_generate_PLIST()
{
    _logging "===> _generate_PLIST()"
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
}

_generate_BUILD_INFO()
{
    local package="$workdir/$1"

    cat > "$package/+BUILD_INFO" << _BUILD_INFO_
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
        _sep="[[:space:]]"
        _release=$(grep "^${depend}$_sep" $nbpkg_build_list_all    |
                   awk '{print $2}'                                |
                   tail -1                                         )
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

_generate_CONTENTS()
{
    local TMPFILE=$(mktemp -q || _bomb "$TMPFILE")
    local setname="${1%/*}" # E.g. "base/base-sys-root" --> "base"
    local pkgname="${1#*/}" # E.g. "base/base-sys-root" --> "base-sys-root"
    local prefix="/"
    if [ "$setname" = "etc" ]; then
        prefix="/var/tmp/basepkg"
    fi
    local package="$workdir/$1"

    echo "@name $pkgname-$release" > "$package/+CONTENTS"
    echo "@comment Packaged at $utcdate UTC by $user@$host" >> "$package/+CONTENTS"

    _remove_if_exists "$tmp_deps"
    _mk_depend "$pkgname"
    test -f "$tmp_deps" && sort -u "$tmp_deps" >> "$package/+CONTENTS"

    echo "@cwd $prefix" >> "$package/+CONTENTS"
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
    done < "$package/PLIST"

    sort "$TMPFILE" >> "$package/+CONTENTS"
    rm -f "$TMPFILE"
}

_generate_SIZE_PKG()
{
    local package="$workdir/$1"

    # Sum of file size.
    grep -v '^@' < "$package/+CONTENTS" \
        | xargs -I % ls -l "$destdir/"% \
        | awk '{sum+=$5} END{print sum}' \
        > "$package/+SIZE_PKG.tmp"

    # Sum of directory size.
    grep -c '^@exec install -d -o root -g wheel -m' < "$package/+CONTENTS" \
        | xargs -I % expr % \* 512 \
        >> "$package/+SIZE_PKG.tmp"

    # Sum of file and directory size.
    awk '{sum+=$1} END{print sum}' < "$package/+SIZE_PKG.tmp" \
        > "$package/+SIZE_PKG"

    rm -f "$package/+SIZE_PKG.tmp"
}

_generate_SIZE_ALL()
{
    local package="$workdir/$1"

    grep '^@pkgdep' "$package/+CONTENTS" \
        | cut -d " " -f 2 \
        | cut -d ">=" -f 1 \
        | xargs -I % find "$workdir" -type d -name % \
        | xargs -I % cat %/+SIZE_PKG \
        | awk '{sum+=$1} END{print sum}' \
        > "$package/+SIZE_ALL.tmp"

    cat "$package/+SIZE_PKG" "$package/+SIZE_ALL.tmp" \
        | awk '{sum+=$1}END{print sum}' \
        > "$package/+SIZE_ALL"

    rm -f "$package/+SIZE_ALL.tmp"
}

_generate_DESC_and_COMMENT()
{
    local pkgname="${1#*/}"
    local package="$workdir/$1"

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$descrs" > "$package/+DESC" || _bomb "awk +DESC"

    awk '
    /^'"$pkgname"'/ {
        for (i = 2; i <= NF; i++) {
            if (i == NF)
                printf $i"\n"
            else
                printf $i" "
        }
    }' "$comments" > "$package/+COMMENT" || _bomb "awk +COMMENT"
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
        -e "s%@CHOWN@%/sbin/chown%" \
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

_generate_INSTALL()
{
    local package="$workdir/$1"
    local user_group_mode=""
    local _mode=""
    local _user=""
    local _group=""

    _remove_if_exists "$package/+INSTALL"
    _replace_cmdstr "$install_script" > "$package/+INSTALL"
    _bomb_if_not_found "$package/+CONTENTS"

    # For +FILES routine which is conained in sets/install script.
    grep -v -e "^@" "$package/+CONTENTS" | while read -r file; do
        test "$(file "$obj/$file" | cut -d " " -f 2)" = "symbolic" && continue
        if [ "${file%%/*}" = "etc" ]; then
            if [ -f "$destdir/$file" ]; then
                user_group_mode=$(grep -e "^\\./$file " "$destdir/etc/mtree/set.etc" \
                                    | cut -d " " -f 3 -f 4 -f 5 \
                                    | xargs -n 1 -I % expr x% : "x[^=]*=\\(.*\\)" \
                                    | tr '\n' ' '
                                )
                _mode=$(echo "$user_group_mode" | cut -d " " -f 3)
                _user=$(echo "$user_group_mode" | cut -d " " -f 1)
                _group=$(echo "$user_group_mode" | cut -d " " -f 2)
            fi
            echo "# FILE: /$file c $file $_mode $_user $_group" \
                >> "$package/+INSTALL"
        fi
    done
}

_generate_DEINSTALL()
{
    _replace_cmdstr "$deinstall_script" > "$workdir/$1/+DEINSTALL"
}

_generate_PRESERVE()
{
    local essential_path=""

    while read -r essential_pkg; do
        essential_path=$(find "$workdir" -name "$essential_pkg" -type d)
        printf "%s-%s" "$essential_pkg" "$release" > "$essential_path/+PRESERVE"
    done < "$essential"
}

#
# _put_basedir -- Change directory name depending on
# same $machine and $machine_arch or not.
#
_put_basedir()
{
   if [ "X$machine_arch" != "X$machine" ]; then
     echo "$packages/$release/$machine-$machine_arch"
   else
     echo "$packages/$release/$machine"
   fi
}

#
# _do_pkg_create -- "pkg_create" command wrapper.
#
# Package moved to ${packages}/All directory.
#
_do_pkg_create()
{
    local setname="${1%/*}" # E.g. "base/base-sys-root" --> "base"
    local pkgname="${1#*/}" # E.g. "base/base-sys-root" --> "base-sys-root"
    local option="-v -l -U
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
    local package="$workdir/$1"

    test -f "$package/+PRESERVE" && option="$option -n $package/+PRESERVE"

    if [ "$setname" = "etc" ]; then
        option="$option -I /var/tmp/basepkg"
    else
        option="$option -I /"
    fi

    # shellcheck disable=SC2086
    pkg_create $option "$pkgname" || _bomb "$1: pkg_create"

    local _basedir=$(_put_basedir)
    _mkdir_if_not_exists "$_basedir"
    mv "./$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
}

_mk_checksum()
{
    find ./*.tgz -exec cksum -a md5 {} \; > MD5
    find ./*.tgz -exec cksum -a sha512 {} \; > SHA512
}

_find_package_directory()
{
    find "$workdir" -type d -name '*-*-*' | sed "s|$workdir/||g"
}

_is_nbpkg_daily_build()
{
    [ "X$nbpkg_build_config" != "X" ] && [ "X$nbpkg_build_target" = "Xdaily" ]
}

_make_all_packages()
{
    _logging "===> _make_all_packages()"
    _find_package_directory | while read -r pkg; do
        _generate_BUILD_INFO "$pkg"
        _generate_CONTENTS "$pkg"
        _generate_SIZE_PKG "$pkg"
        _generate_DESC_and_COMMENT "$pkg"
        _generate_INSTALL "$pkg"
        _generate_DEINSTALL "$pkg"
    done

    # XXX EXTENSION: build least packages specified by nbpkg-build
    if _is_nbpkg_daily_build; then
        _find_package_directory | egrep -f $nbpkg_build_list_filter
    else
        _find_package_directory
    fi | while read -r pkg; do
        _generate_SIZE_ALL "$pkg"
        _do_pkg_create "$pkg"
    done

    local _basedir=$(_put_basedir)
    cd "$_basedir" && _mk_checksum
}

#
# _mk_kernel_package -- Make kernel package.
#
# Now, information of meta-data is not write to another files such as
# ./sets/comments. Because the packaged file is only kernel binary named
# "netbsd". If add the kernel package's information to files that under the
# ./sets directory, This function will be deleted.
#
_mk_kernel_package()
{
    local category="base"
    local pkgname="base-kernel-$1"

    if [ ! -f "$obj/sys/arch/$machine/compile/$1/netbsd" ]; then
        _err "$1/netbsd not found."
        return 1
    fi

    _mkdir_if_not_exists "$workdir/$category/$pkgname"

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
    _mkdir_if_not_exists "$_basedir"
    mv "$PWD/$pkgname.tgz" "$_basedir/$pkgname-$release.tgz"
}

_make_all_kernel_packages()
{
    # XXX: A number of kernel packages can install to the system.
    _logging "===> _make_all_kernel_packages()"
    # shellcheck disable=SC2086
    # shellcheck disable=SC2012
    ls $kernobj | while read -r kernel_name; do
        _mk_kernel_package "$kernel_name"
    done
}

#
# _clean_workdir -- Clean working directories.
#
_clean_workdir()
{
    printf "_clean_workdir()\\n"
    _remove_directory_if_exists_and_writable "$workdir"
}

#
# _clean_pkg -- Clean packages.
#
_clean_pkg()
{
    printf "_clean_pkg()\\n"
    _remove_directory_if_exists_and_writable "$packages"
}

#
# _usage -- Show usage to standard output.
#
_usage()
{
    cat <<_usage_

Usage: $progname [--arch architecture] [--category category]
                  [--destdir destdir] [--machine machine] [--obj obj_dir]
                  [--releasedir releasedir] [--setsdir setsdir]
                  [--with-nbpkg-build-config config] [--enable-nbpkg-build]
                  operation

 Operations:
    pkg                         Create packages.
    kern                        Create kernel package.
    clean                       Clean working directories.
    cleanpkg                    Clean package directories.

 Options:
    --arch                      Set machine_arch to architecture.
                                [Default: deduced from "machine"]
    --category                  Set category.
                                [Default: "base comp etc games man misc text"]
    --destdir                   Set destdir.
                                [Default: $obj/destdir.$machine]
    --machine                   Set machine type for MACHINE_ARCH.
                                [Default: result of \`uname -m\`]
    --obj                       Set obj to NetBSD binaries.
                                [Default: /usr/obj]
    --releasedir                Set releasedir.
    --setsdir                   Set setsdir that contains meta informations.
    --with-nbpkg-buld-config    WIP (Don't use it unless you are developer.)
    --enable-nbpkg-build        WIP (Don't use it unless you are developer.)
    -h | --help                 Show this message and exit.

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
# _begin_logging -- Print log messages to standard output and log file.
#
# This function is called when beginning basepkg.sh's process.
#
_begin_logging()
{
    _logging "===> basepkg.sh command: $commandline"
    _logging "===> basepkg.sh started: $(date)"
    _logging "===> NetBSD version:     $release"
    _logging "===> MACHINE:            $machine"
    _logging "===> MACHINE_ARCH:       $machine_arch"
    _logging "===> Build platform:     $opsys $osversion $(uname -m)"
}

#
# _end_logging -- Print log messages to standard output and log file.
#
# This function is called when ending basepkg.sh's process.
#
_end_logging()
{
    _logging "===> basepkg.sh ended:   $(date)"
    printf "===> Summary of log:\\n"
    sed -e "s/^===>/    /g" "$log"
    printf "===> .\\n"
    rm -f "$log"
}

###############################################################################
#
# Global variables
#
###############################################################################

# define new line and tab
nl='
'
tab='	'

#
# Imported from build.sh
# valid_MACHINE_ARCH -- A multi-line string, listing all valid
# MACHINE/MACHINE_ARCH pairs.
#
# Each line contains a MACHINE and MACHINE_ARCH value, an optional ALIAS
# which may be used to refer to the MACHINE/MACHINE_ARCH pair, and an
# optional DEFAULT or NO_DEFAULT keyword.
#
# When a MACHINE corresponds to multiple possible values of
# MACHINE_ARCH, then this table should list all allowed combinations.
# If the MACHINE is associated with a default MACHINE_ARCH (to be
# used when the user specifies the MACHINE but fails to specify the
# MACHINE_ARCH), then one of the lines should have the "DEFAULT"
# keyword.  If there is no default MACHINE_ARCH for a particular
# MACHINE, then there should be a line with the "NO_DEFAULT" keyword,
# and with a blank MACHINE_ARCH.
#
path_to_valid_MACHINE_ARCH="./lib/valid_MACHINE_ARCH"
_bomb_if_not_found "$path_to_valid_MACHINE_ARCH"
. "$path_to_valid_MACHINE_ARCH" # we can refer $valid_MACHINE_ARCH

PWD="$(pwd)"
progname=${0##*/}
host="$(hostname)"
opsys="$(uname)"
osversion="$(uname -r)"
pkgtoolversion="$(pkg_create -V)"
utcdate="$(env TZ=UTC LOCALE=C date '+%Y-%m-%d %H:%M')"
user="${USER:-root}"
param="usr/include/sys/param.h"
tmp_deps="/tmp/culldeps"
homepage="https://github.com/user340/basepkg"
mail_address="uki@e-yuuki.org"
toppid=$$
log="$PWD/.basepkg.log"
obj="/usr/obj"
packages="$PWD/packages"
category="base comp etc games man misc modules text xbase xcomp xetc xfont xserver"
pkgdb="/var/db/basepkg"

###############################################################################
#
# Begin main process.
#
###############################################################################

[ $# = 0 ] && _usage

machine="$(uname -m)" # Firstly, set machine hardware name for _getarch().
machine_arch=""
commandline="$0 $*"

# extension modules
nbpkg_build_enable=0
nbpkg_build_config=""

#
# Parsing long option process. In this process, we don't use getopt(1) and
# getopts for the following reasons.
#     - One character option (-a, -m, ...) is difficult to understand.
#     - The getopt(1) have difference between GNU and BSD.
#
while [ $# -gt 0 ]; do
    case $1 in
    --arch=*)
        machine_arch=$(_getopt "$1")
        ;;
    --arch)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        machine_arch="$2"
        shift
        ;;
    --category=*)
        category=$(_getopt "$1")
        ;;
    --category)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        category="$2"
        shift
        ;;
    --destdir=*)
        destdir=$(_getopt "$1")
        ;;
    --destdir)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        destdir="$2"
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
    --obj=*)
        obj=$(_getopt "$1")
        ;;
    --obj)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        obj="$2"
        shift
        ;;
    --releasedir=*)
        releasedir=$(_getopt "$1")
        ;;
    --releasedir)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        releasedir="$2"
        shift
        ;;
    --setsdir=*)
        setsdir=$(_getopt "$1")
        ;;
    --setsdir)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        setsdir="$2"
        shift
        ;;
    --with-nbpkg-build-config=*)
        nbpkg_build_config=$(_getopt "$1")
        ;;
    --with-nbpkg-build-config)
        test -z "$2" && (_err "What is $1 parameter?" ; exit 1)
        nbpkg_build_config="$2"
        shift
        ;;
    --enable-nbpkg-build)
        nbpkg_build_enable=1;
        ;;
    -h|--help)
        _usage
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

if [ -z "$machine_arch" ]; then
    eval "$(_getarch)"
    machine_arch=$MACHINE_ARCH
    _validate_arch
fi
destdir=${destdir:-"$obj/destdir.$machine"}
releasedir=${releasedir:-.}
release="$(_osrelease -a)"
release_k="$(_osrelease -k)"
setsdir="$PWD/sets"
lists="$setsdir/lists"
comments="$setsdir/comments"
descrs="$setsdir/descrs"
deps="$setsdir/deps"
install_script="$setsdir/install"
deinstall_script="$setsdir/deinstall"
essential="$setsdir/essentials"
workdir="$releasedir/work/$release/$machine"
packages="$releasedir/packages"
kernobj="$obj/sys/arch/$machine/compile"
start=$(date)

# quirks: overwritten for "nbpkg-build" system
if [ "X$nbpkg_build_config" != "X" ] && [ -f "$nbpkg_build_config" ]; then
   . "$nbpkg_build_config"
   release="$nbpkg_build_id" # e.g. 8.0.20181029
fi

#
# least assertions
#
_bomb_if_not_found "$install_script"
test "X$release" != "X" || _bomb "cannot resolve \$release"

test $# -eq 0 && _usage
for cmd in hostname mktemp pkg_create; do
    _bomb_if_command_not_found "$cmd"
done

#
# operation
#
case $1 in
pkg)
    _begin_logging
    _split_category
    _make_package_directories
    _generate_PLIST
    _generate_PRESERVE
    _make_all_packages
    _end_logging
    ;;
kern)
    _begin_logging
    _make_all_kernel_packages
    _end_logging
    ;;
clean)
    _begin_logging
    _clean_workdir
    _end_logging
    ;;
cleanpkg)
    _begin_logging
    _clean_pkg
    _end_logging
    ;;
*)
    _usage
    ;;
esac
