if [ `id -u` -ne 0 ]
then
	echo "This script must be run as root"
	exit 1
fi

sh -xec '
install -Dm755 novpn-ns-setup.sh /usr/libexec
install -Dm644 novpn.nft /usr/share/nftables
cc novpn-setuid.c -o /usr/bin/novpn
chmod u+s /usr/bin/novpn'

if [ `ps -p1 -ocomm=` = "systemd" ]
then
	sh -xec '
	install -D novpn-namespace.service /etc/systemd/system
	systemctl enable --now novpn-namespace'
else
	echo "
	Not using systemd. A service file for your init system needs to
	be created for running /usr/libexec/novpn-ns-setup.sh on boot."
fi
