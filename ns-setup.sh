#!/bin/sh -x

ip link del novpn
ip netns del novpn
ip netns add novpn

$(dirname "$0")/if-create.sh

: > /etc/netns/novpn/resolv.conf
mkdir -p /etc/netns/novpn/resolv.conf.d
rm /etc/netns/novpn/resolv.conf.d/* 2>/dev/null
mkdir -p /run/novpn/dhcpcd
mkdir -p /run/novpn/systemd/resolve

novpn dhcpcd -4 --leasetime 1800 eth0

cp /etc/netns/novpn/resolv.conf /etc/netns/novpn/resolv.conf.d/tail
cp /etc/netns/novpn/resolv.conf /run/novpn/systemd/resolve/resolv.conf
cp /etc/netns/novpn/resolv.conf /run/novpn/systemd/resolve/stub-resolv.conf
