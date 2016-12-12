#!/bin/sh
# For Development Script

misc_examples_list() {
	for i in amd apm asm atf dhcp disktab emul fstab ftpd getdate hostapd ipf isdn kerberos kyua-cli libsaslc lutok mount_portal openssl pf postfix pppd racoon rtadvd smbfs supfiles syslogd tmux
	do
		(cd ./work/misc/usr/share/examples ; find $i -type f | awk '{print "usr/share/examples/"$1}' > ~/src/basepkg/sets/misc/$i-example/$i-example.list)
	done
}

if [ $# != 1 ]; then
	echo "Argument?"
	exit 1
fi

case $1 in
	misc_examples_list) misc_examples_list
	                    ;;
	*) echo "not found"
	   exit 1
	   ;;
esac
