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
# diff_all.sh -- Output all difference between basepkg's lists and original 
#                lists into standard output.
#
################################################################################

_check_new_list()
{
    ls "$original_lists/$1" | grep -v "CVS" > "$org.$1"
    ls "$basepkg_lists/$1"  > "$bpkg.$1"
    diff -u "$bpkg.$1" "$org.$1"
}

_do_diff()
{
    ls "$basepkg_lists/$1" \
    | xargs -I % -n 1 diff -u "$basepkg_lists/$1/"% "$original_lists/$1/"%
}

tmpfs="/var/shm"
org="$tmpfs/org.txt"
bpkg="$tmpfs/bpkg.txt"

basepkg_lists="../sets/lists"
original_lists="/usr/src/distrib/sets/lists"

categories="base comp debug etc games man misc modules tests text xbase xcomp xdebug xetc xfont xserver"

for i in $categories; do
    _check_new_list "$i"
done

for j in $categories; do
    _do_diff "$j"
done
