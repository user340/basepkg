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
# Wrapper function of ldd. Output relation path of library name.
#
################################################################################
wrap_ldd()
{
    ldd -f "%p\n" "$1" | sed 's%^\/%%g' | tr '\n' ' '
}

output_dependencies()
{
 (
    for prog in "$1/"*; do
        printf "%s/%s, %s\n" \
            "$1" "$(basename "$prog")" "$(wrap_ldd "$prog")"
    done
 )
}

obj="/usr/obj"
destdir="$obj/destdir.amd64"
bindir="bin sbin usr/bin usr/sbin"

for dir in $bindir; do
    { cd "$destdir"; output_dependencies "$dir"; }
done
