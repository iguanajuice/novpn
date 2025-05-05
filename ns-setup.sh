#!/bin/sh

PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`

mkdir -p /etc/netns/novpn/resolv.conf.d
echo 'nameserver 127.0.0.53
nameserver 9.9.9.9 149.112.112.112
nameserver 2620:fe::fe 2620:fe::9' > /etc/netns/novpn/resolv.conf
cp /etc/netns/novpn/resolv.conf /etc/netns/novpn/resolv.conf.d/@base

ip netns del novpn
ip netns add novpn

ip link del novpn
ip link add novpn type veth peer name veth
ip link set veth netns novpn
while ! ip link show dev mvlan
do ip link add mvlan link $PHY_IFNAME netns novpn type macvlan
done

ip addr add 10.0.1.1/24 dev novpn
ip --netns novpn addr add 10.0.1.2/24 dev veth

ip link set novpn up
ip --netns novpn link set lo up
ip --netns novpn link set veth up
ip --netns novpn link set mvlan up

ip netns e novpn dhcpcd -4 --leasetime 1800 mvlan
