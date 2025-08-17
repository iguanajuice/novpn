#!/bin/sh -x

ip netns del novpn
ip netns add novpn

ip --netns novpn link set lo up

rm /etc/netns/novpn/ -rf 2>/dev/null
mkdir -p /etc/netns/novpn/
echo "nameserver 9.9.9.9" > /etc/netns/novpn/resolv.conf
mkdir -p /run/novpn/dhcpcd/
mkdir -p /run/novpn/systemd/resolve/
echo "nameserver 9.9.9.9" > /run/novpn/systemd/resolve/stub-resolv.conf
