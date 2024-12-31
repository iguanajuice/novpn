#!/bin/sh

PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`

ip netns del novpn
ip netns add novpn

ip link add veth-novpn type veth peer name veth
ip link set veth netns novpn

ip addr add 10.0.8.1/24 dev veth-novpn
ip addr add fc:0:0:8::1/64 dev veth-novpn
ip --netns novpn addr add 10.0.8.2/24 dev veth
ip --netns novpn addr add fc:0:0:8::2/64 dev veth

ip link set veth-novpn up
ip --netns novpn link set veth up

sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1

sed -i "s/^define wan = .*/define wan = $PHY_IFNAME/g" /usr/share/nftables/novpn.nft
nft -f /usr/share/nftables/novpn.nft

ip --netns novpn route add default via 10.0.8.1
ip --netns novpn route add default via fc:0:0:8::1
