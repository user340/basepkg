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

libbasepkg="./lib"

. "$libbasepkg/Common"
. "$libbasepkg/Logging"
. "$libbasepkg/NetBSD"
. "$libbasepkg/Package"

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
log="$PWD/.basepkg.log"
obj="/usr/obj"
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
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        machine_arch="$2"
        shift
        ;;
    --category=*)
        category=$(_getopt "$1")
        ;;
    --category)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        category="$2"
        shift
        ;;
    --destdir=*)
        destdir=$(_getopt "$1")
        ;;
    --destdir)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        destdir="$2"
        shift
        ;;
    --machine=*)
        machine=$(_getopt "$1")
        ;;
    --machine)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        machine="$2"
        shift
        ;;
    --obj=*)
        obj=$(_getopt "$1")
        ;;
    --obj)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        obj="$2"
        shift
        ;;
    --releasedir=*)
        releasedir=$(_getopt "$1")
        ;;
    --releasedir)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        releasedir="$2"
        shift
        ;;
    --setsdir=*)
        setsdir=$(_getopt "$1")
        ;;
    --setsdir)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
        setsdir="$2"
        shift
        ;;
    --with-nbpkg-build-config=*)
        nbpkg_build_config=$(_getopt "$1")
        ;;
    --with-nbpkg-build-config)
        test -z "$2" && (_error "What is $1 parameter?" ; exit 1)
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
    _clean_packages
    _end_logging
    ;;
*)
    _usage
    ;;
esac
