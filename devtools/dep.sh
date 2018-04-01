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

#
# This script written for update syspkg's dependency file. 
# It is temporal script for basepkg developer.
#
test -f ../log || { printf "../log: No Such File\n"; exit 1; }

awk '{print $2}' ../log | sed 's/:$//g' | while read -r pkg; do
    head=$(printf "%s" "$pkg" | cut -d "-" -f 1)
    middle="$(printf "%s" "$pkg" | cut -d "-" -f 2)"
    tail=$(printf "%s" "$pkg" | cut -d "-" -f 3)
    case "$tail" in
        "root") printf "%s base-sys-root\n" "$pkg" ;;
        "piclib" | "proflib" | "usr" | "etc" | "rc" | "defaults" | "bin" | "debug" | "shlib" | "lib") printf "%s base-sys-usr\n" "$pkg" ;;
        "locale") printf "%s base-locale-share\n" "$pkg" ;;
        "share" | "examples") printf "%s base-sys-share\n" "$pkg" ;;
        "htmlman" | "catman" | "man") printf "%s base-man-share\n" "$pkg" ;;
        "doc") printf "%s %s-share\n" "$pkg" "$head-$middle" ;;
        "lintlib") printf "%s base-c-usr\n" "$pkg" ;;
        *) ;;
    esac
done
