if [ `id -u` -ne 0 ]
then
	echo "This script must be run as root"
	exit 1
fi

sh -xec '
mkdir -p /usr/libexec/novpn
install -Dm755 ns-setup.sh /usr/libexec/novpn
install -Dm755 resolvconf /usr/libexec/novpn
cc novpn-setuid.c -o /usr/bin/novpn
setcap CAP_SYS_ADMIN=ep /usr/bin/novpn'

if [ `ps -p1 -ocomm=` = "systemd" ]
then
	sh -xec '
	install -Dm644 novpn-namespace.service /usr/lib/systemd/system
	systemctl enable --now novpn-namespace'
else
	echo "
	Not using systemd. A service file for your init system needs to
	be created for running /usr/libexec/novpn-ns-setup.sh on boot."
fi
