#!/bin/sh
. "./subroutine"
for i in base comp etc games kern-GENERIC man misc modules tests text
do
	test -d ./work/$i || mkdir ./work/$i
	tar zxf "$sets"/$i.tgz -C ./work/$i
done
