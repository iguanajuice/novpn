#!/bin/sh

ip netns del novpn
ip netns add novpn

ip link del novpn
ip link add novpn type veth peer name host
ip link set host netns novpn

ip addr add 10.0.1.1/24 dev novpn
ip --netns novpn addr add 10.0.1.2/24 dev host

ip link set novpn up
ip --netns novpn link set lo up
ip --netns novpn link set host up

`dirname $0`/mvlan-create.sh

mkdir -p /etc/netns/novpn/resolv.conf.d
rm /etc/netns/novpn/resolv.conf.d/* 2>/dev/null
mkdir -p /run/novpn/dhcpcd
mkdir -p /run/novpn/systemd/resolve

novpn dhcpcd --leasetime 1800 mvlan
cp /etc/netns/novpn/resolv.conf /etc/netns/novpn/resolv.conf.d/tail
cp /etc/netns/novpn/resolv.conf /run/novpn/systemd/resolve/resolv.conf
cp /etc/netns/novpn/resolv.conf /run/novpn/systemd/resolve/stub-resolv.conf
