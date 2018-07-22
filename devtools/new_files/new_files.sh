#!/bin/sh

src="/usr/src"
lists="$src/distrib/sets/lists"
blists="../../sets/lists"
target="base comp etc games man misc modules tests text xbase xcomp xetc xfont xserver"
tmpfs="$(df -h | grep tmpfs | awk '{print $6}')"

for dir in $target; do
    ls "$lists/$dir" \
     | grep -v "CVS" \
     | xargs -I % cut -f 1 "$lists/$dir/"% \
     | grep -v "^#" \
     | sort > "$tmpfs/original_lists"
done

for bdir in $target; do
    ls "$blists/$dir" \
     | grep -v "CVS" \
     | xargs -I % cut -f 1 "$blists/$dir/"% \
     | grep -v "^#" \
     | sort > "$tmpfs/basepkg_lists"
done

diff -u "$tmpfs/original_lists" "$tmpfs/basepkg_lists"
