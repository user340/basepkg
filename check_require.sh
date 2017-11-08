#!/bin/sh

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
