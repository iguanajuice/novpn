#!/bin/sh

PHY_IFNAME="$1"

ip link add mvlan link $PHY_IFNAME netns novpn type macvlan || exit 0
ip --netns novpn link set mvlan up
