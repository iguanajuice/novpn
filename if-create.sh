#!/bin/sh -x

IF_MVL=eth0 # "MAC virtual LAN" interface
IF_XNS=eth1 # "cross namespace" interface
ADDR_MAC=$(cat /etc/novpn.mac) 2>/dev/null

ip link add novpn type veth peer name $IF_XNS
ip link set $IF_XNS netns novpn

ip addr add 10.0.1.1/24 dev novpn
ip --netns novpn addr add 10.0.1.2/24 dev $IF_XNS

ip link set novpn up
ip --netns novpn link set lo up
ip --netns novpn link set $IF_XNS up

while ! IF_PHY=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`
do sleep 0.5; done

ip link add $IF_MVL link $IF_PHY $ADDR_MAC netns novpn type macvlan || exit 0
[ $ADDR_MAC ] || ip --netns novpn -j link show dev $IF_MVL | jq -r '"addr \(.[].address)"' > /etc/novpn.mac
ip --netns novpn link set $IF_MVL up
