#!/bin/sh
#
# Copyright (c) 2017,2018 Yuuki Enomoto 
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
# checkdep.sh -- Print information of lacking package. It is developer script. 
#                It is not necessary for general user.
#
################################################################################

################################################################################
#
# Check dependency of given package. It is a recursive function. Example, 
# file that descripts the following dependency.
#
#     A B
#     B C
#     C D
#
# "fn_deps A" prints the following output.
#
#     B C D
#
################################################################################
fn_deps()
{
    grep "^$1" "$deps" > /dev/null 2>&1 || return 1 # unknown dependency.
    awk '/^'"$1"'/{print $2}' "$deps" | while read -r dep; do
        test ! "$dep" && return 1
        test "$dep" = "base-sys-root" \
            && { printf "%s " "$dep"; return 0; }
        printf "%s " "$dep"
        fn_deps "$dep" # Recursion.
    done
}

################################################################################
#
# Print binary name that packaged in given package.
#
################################################################################
fn_get_bin()
{
    grep -h "$1" "$info"/* \
    | grep -E '^\./bin|^\./usr/bin|^\./sbin|^\./usr/sbin' \
    | cut -f 1 \
    | sed "s%^\.%$destdir%"
}

################################################################################
#
# Run ldd to return value from fn_get_bin().
#
################################################################################
fn_ldd()
{
 (
    fn_get_bin "$1" | while read -r prog; do
        test -f "$prog" \
            && ldd -f "%p\n" "$prog" 2> /dev/null \
               | sed 's%^/%./%g' | tr '\n' ' '
    done
 ) | tr ' ' '\n' | sort | uniq | tr '\n' ' '
}

################################################################################
#
# Wrapper of fn_ldd()
#
################################################################################
fn_all_ldd()
{
 (
    for i in $1; do
        fn_ldd "$i"
    done
 )
}

################################################################################
#
# Print necessary package name that packaged necessary shared libraries.
#
################################################################################
fn_print_necessary_pkg()
{
 (
    for i in $libs; do
        printf "%s\n" \
        "$(grep -h -r "$i" "$lists"/* \
            | grep -v "debug" \
            | awk '{print $2}' \
            | sort | uniq)"
    done
 ) | sort | uniq | tr '\n' ' '
}

################################################################################
#
# Print package name that is wanting in given package.
#
################################################################################
fn_print_lacking_pkg()
{
 (
    for i in $necessary; do
        for j in $depend; do
            ok="false"
            test "$i" = "$j" && ok="true"
        done
        test "$ok" = "false" \
            && printf "[Warn] %s dependent %s\n" "$1" "$i"
    done
 )
}

################################################################################
#
# Main
#
################################################################################

obj="/usr/obj"
destdir="$obj/destdir.amd64"
sets="../sets"
lists="$sets/lists"
deps="$sets/deps"
info="$lists/$(printf "%s" "$1" | cut -d "-" -f 1)"

# 1. Get dependency infomation
depend=$(fn_deps "$1" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

# 2. Get libraries that required.
libs=$(fn_all_ldd "$1 $depend")

# 3. Get necessary package information.
necessary=$(fn_print_necessary_pkg)

# 4. Print lacking package. Please edit basepkg/sets/deps.
fn_print_lacking_pkg "$1"
