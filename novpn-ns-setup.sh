#!/bin/sh

PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`
VL_IFNAME=veth

ip netns del novpn
ip netns add novpn

ip link add link $PHY_IFNAME $VL_IFNAME netns novpn type macvlan

ip -n novpn link set lo up
ip -n novpn link set $VL_IFNAME up

ip netns e novpn dhcpcd -4 --leasetime 3600 $VL_IFNAME -b
