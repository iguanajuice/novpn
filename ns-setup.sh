#!/bin/sh

PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`

mkdir -p /etc/netns/novpn
: > /etc/netns/novpn/resolv.conf

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

ip netns e novpn dhcpcd -4 --leasetime 1800 mvlan
