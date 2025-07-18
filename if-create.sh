#!/bin/sh -x

IF_XNS=xlo # name of interface used for cross-namespace localhost networking
XNS_PFX4=172.17.0
XNS_PFX6=fd17
ADDR_MAC=$(cat /etc/novpn.mac) 2>/dev/null

ip link add novpn type veth peer name $IF_XNS
ip link set $IF_XNS netns novpn

ip addr add $XNS_PFX4.1/24 dev novpn
ip addr add $XNS_PFX6::1/64 dev novpn
ip --netns novpn addr add $XNS_PFX4.2/24 dev $IF_XNS
ip --netns novpn addr add $XNS_PFX6::2/64 dev $IF_XNS

ip link set novpn up
ip --netns novpn link set lo up
ip --netns novpn link set $IF_XNS up

while ! IF_PHY=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`
do sleep 0.5; done

ip link add eth0 link $IF_PHY $ADDR_MAC netns novpn type macvlan || exit 0
[ $ADDR_MAC ] || ip --netns novpn -j link show dev eth0 | jq -r '"addr \(.[].address)"' > /etc/novpn.mac
ip --netns novpn link set eth0 up
