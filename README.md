# novpn

Easy split-tunneling setup using network namespaces


## Dependencies

* `iproute2`
* `dhcpcd`
* a C compiler


## Installation

Run `./install.sh` for automatic setup. This will install the following files:


## Usage

### Running application or command

`novpn [command [args]]`

Example: `novpn flatpak run org.chromium.Chromium`

Running `novpn` with no arguments will spawn a new shell

### As a whitelist

To only allow certain programs to be tunneled, you'll need to run your VPN client
inside the namespace. In the following example, we'll use `wg-quick`:
```
sudo ip netns e novpn wg-quick up wg1.conf
```

Notice how we use `sudo ip` instead of `novpn`. This is because VPN connections
requires root, and `novpn` drops privileges upon entering the namespace

### As a blacklist

Simply connect your VPN as usual, everything running with `novpn` will not be tunneled
