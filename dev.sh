#!/bin/sh
# For Development Script

misc_examples_list() {
	for i in amd apm asm atf dhcp disktab emul fstab ftpd getdate hostapd ipf isdn kerberos kyua-cli libsaslc lutok mount_portal openssl pf postfix pppd racoon rtadvd smbfs supfiles syslogd tmux
	do
		(cd ./work/misc/usr/share/examples ; find $i -type f | awk '{print "usr/share/examples/"$1}' > ~/src/basepkg/sets/misc/$i-example/$i-example.list)
	done
}

man_info_list() {
	find ./work/man/usr/share/info -type f | sed 's/^\.\/work\/man\///g' > ./sets/man/info/info.list
}

man_htmls() {
	for i in html1 html3lua html4 html5 html7 html8 html9lua
	do
		find ./work/man/usr/share/man/$i -type f | sed 's/^\.\/work\/man\///g' > ./sets/man/$i/$i.list
	done
}

man_mans() {
	for i in man1 man3lua man4 man5 man7 man8 man9lua
	do
		find ./work/man/usr/share/man/$i -type f | sed 's/^\.\/work\/man\///g' > ./sets/man/$i/$i.list
	done
}

if [ $# != 1 ]; then
	echo "Argument?"
	exit 1
fi

case $1 in
	misc_examples_list) misc_examples_list
	                    ;;
	man_info_list) man_info_list
	               ;;
	man_htmls) man_htmls
						 ;;
	man_mans) man_mans
					  ;;
	*) echo "not found"
	   exit 1
	   ;;
esac
