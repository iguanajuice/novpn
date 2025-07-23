#!/bin/sh -x

ip link del novpn
ip netns del novpn
ip netns add novpn

$(dirname "$0")/if-create.sh

echo "nameserver 9.9.9.9" > /etc/netns/novpn/resolv.conf
mkdir -p /run/novpn/dhcpcd
mkdir -p /run/novpn/systemd/resolve

novpn dhcpcd -4 --leasetime 1800 eth0
