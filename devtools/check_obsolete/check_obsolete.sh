#!/bin/sh

src="/usr/src"
lists="$src/distrib/sets/lists"
target="base comp etc games man misc modules tests text xbase xcomp xetc xfont xserver"

for dir in $target; do
    ls "$lists/$dir" \
     | grep -v "CVS" \
     | xargs -I % grep 'obsolete' "$lists/$dir/"%
done
