#!/bin/sh
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
# cmdlib.sh -- 
#
################################################################################

obj="/usr/obj"
destdir="$obj/destdir.amd64"
bindir="bin sbin usr/bin usr/sbin"
lists="../sets/lists"
deps="../sets/deps"
sett=".set"
pkgset=".pkgset"
awk_pkgset="pkgset.awk"
deplist=".deplist"

################################################################################
#
# Wrapper function of ldd. Output relation path of library name.  
#
# ** Output Example **
#     ./lib/libutil.so.7
#
################################################################################
fn_ldd()
{
    ldd -f "%p\n" "$1" | sed 's%^/%./%g' | tr '\n' ' '
}

################################################################################
#
# Output dependencies of program that on the given directory. The first field 
# shows relative program name. After the second fields shows libraries that 
# requried from program name of the first field. If target program is not ELF 
# file, after the second fields is empty.
#
# ** Output Example **
#     ./bin/ls ./lib/libutil.so.7 ./lib/libgcc_s.so.1 ./lib/libc.so.12
#
################################################################################
fn_depend()
{
 (
    for prog in "$1/"*; do
        printf "./%s/%s %s\n" \
            "$1" "$(basename "$prog")" "$(fn_ldd "$prog")"
    done
 )
}

################################################################################
#
# Output all set of command and libraries. It is wrapper of fn_depend().
#
################################################################################
fn_set_to()
{
 (
    cd "$destdir"
    
    for dir in $bindir; do
        # Write standard error to /dev/null.
        fn_depend "$dir" 2> /dev/null
    done
 ) > "$1"
}

################################################################################
#
# Output set of package name and required libraries. This is temporary output.  
#
# ** Output Example **
# base-util-root ./lib/libutil.so.7 ./lib/libgcc_s.so.1 ./lib/libc.so.12
# base-nis-root ./lib/libgcc_s.so.1 ./lib/libc.so.12
# base-util-root ./lib/libgcc_s.so.1 ./lib/libc.so.12
# base-util-root ./lib/libcrypt.so.1 ./lib/libgcc_s.so.1 ./lib/libc.so.12
#
################################################################################
fn_set_of_pkg_and_lib()
{
    while read -r cmd lib; do
        printf "%s %s\n" "$(grep -r "^$cmd" "$lists" | awk '{print $2}')" "$lib"
    done < "$sett"
}

################################################################################
#
# Calculate package's dependency.
#
################################################################################
culc_deps()
{
    grep "^$1" "$deps" > /dev/null 2>&1 || return 1 # unknown dependency.
    awk '/^'"$1"'/{print $2}' "$deps" | while read -r depend; do
        test ! "$depend" && return 1
        printf "$depend "
        test "$depend" = "base-sys-root" && return 0;
        culc_deps "$depend" # Recursion.
    done
}

fn_deplist()
{
 (
    for p in $(cut -d " " -f 1 "$pkgset"); do
        printf "%s %s\n" \
            "$p" "$(culc_deps "$p" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"
    done
 )
}

################################################################################
#
# Main
#
################################################################################

# 1. Output all set of commands and libraries.
test -f "$sett" || fn_set_to "$sett"

# 2. Output all set of packages and libraries.
test -f "$pkgset".tmp || fn_set_of_pkg_and_lib > "$pkgset".tmp 2> /dev/null

# 3. Remove overlap of package name and library name from "$pkgset.tmp".
#    Example, the following lines...
# 
#    base-util-root ./lib/libutil.so.7 ./lib/libgcc_s.so.1 ./lib/libc.so.12
#    base-util-root ./lib/libgcc_s.so.1 ./lib/libc.so.12
#    base-util-root ./lib/libcrypt.so.1 ./lib/libgcc_s.so.1 ./lib/libc.so.12
# 
#    are processed like this.
# 
#    base-util-root ./lib/libc.so.12 ./lib/libcrypt.so.1 ./lib/libgcc_s.so.1 ./libutil.so.7
test -f "$pkgset" || awk -f "$awk_pkgset" "$pkgset".tmp > "$pkgset"

# 4. Output all dependencies of package to "$deplist". 
test -f "$deplist" || fn_deplist > "$deplist"
