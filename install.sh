#!/bin/sh

if [ `id -u` -ne 0 ]
then
	echo "This script must be run as root"
	exit 1
fi

rm /usr/libexec/novpn -rf # remove old installation files

sh -xec '
mkdir -p /usr/libexec/novpn
mkdir -p /etc/resolv.conf.d
mkdir -p /etc/netns/novpn/resolv.conf.d
touch /etc/netns/novpn/resolv.conf
install -Dm755 ns-setup.sh /usr/libexec/novpn
install -Dm755 if-create.sh /usr/libexec/novpn
install -Dm755 resolvconf /usr/libexec/novpn
cc novpn-setuid.c -o /usr/bin/novpn
setcap CAP_SYS_ADMIN=ep /usr/bin/novpn'

if [ `ps -p1 -ocomm=` = "systemd" ] && [ "$1" != "no-systemd" ]
then
	sh -xec '
	install -Dm644 systemd/*.service /usr/lib/systemd/system
	systemctl enable novpn-keepalive
	systemctl restart novpn-keepalive
	systemctl enable novpn-namespace
	systemctl restart novpn-namespace'
else
	echo "
	Not using systemd. A service file for your init system needs to
	be created for running ns-setup.sh on boot."
fi
