#!/bin/sh

while ! PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`
do sleep 0.1; done

mkdir -p /etc/netns/novpn/resolv.conf.d
rm /etc/netns/novpn/resolv.conf.d/* 2>/dev/null
[ -f /run/systemd/resolve/resolv.conf ] &&
RESOLV=/run/systemd/resolve || RESOLV=/etc
echo "$(grep -E '^\w' $RESOLV/resolv.conf)
nameserver 9.9.9.9
nameserver 149.112.112.112
nameserver 2620:fe::fe
nameserver 2620:fe::9" > /etc/netns/novpn/resolv.conf
cp /etc/netns/novpn/resolv.conf /etc/netns/novpn/resolv.conf.d/@base

ip netns del novpn
ip netns add novpn

ip link del novpn
ip link add novpn type veth peer name veth
ip link set veth netns novpn
ip link add mvlan link $PHY_IFNAME netns novpn type macvlan

ip addr add 10.0.1.1/24 dev novpn
ip --netns novpn addr add 10.0.1.2/24 dev veth

ip link set novpn up
ip --netns novpn link set lo up
ip --netns novpn link set veth up
ip --netns novpn link set mvlan up

ip netns exec novpn dhcpcd -4 --leasetime 1800 mvlan
