#!/bin/sh

while ! PHY_IFNAME=`ip route | grep '^default' | grep -oP '(?<=dev )[^\s]+'`
do sleep 0.1; done

ip link add mvlan link $PHY_IFNAME netns novpn type macvlan || exit 0
ip --netns novpn link set mvlan up
