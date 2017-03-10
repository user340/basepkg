#!/bin/sh
# This script is temporary script.

machine=`uname -m`
category="base comp etc games man misc text"

for i in $category
do
	test -f $i-files || rm -f $i-files
	grep -E "$1-[a-z]+-[a-z]+" ./lists/$i/mi | sed 's/^\.\///' >> $1-files
	grep -E "$1-[a-z]+-[a-z]+" ./lists/$i/md.$machine | sed 's/^\.\///' >> $1-files
done
