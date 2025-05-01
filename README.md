# novpn

Easy split tunneling setup using network namespaces!


## Dependencies

* `iproute2`
* `dhcpcd`
* a C compiler


## Installation

Clone the repo and run `./install.sh` for an automated setup.


## Usage

### Running an application or command

`novpn [command [args]]`

Example: `novpn flatpak run org.chromium.Chromium`

Running `novpn` with no arguments will spawn a new shell.

### As a whitelist

To only allow certain programs to be tunneled, you'll need to run your VPN client
inside the namespace. In the following example, we'll use `wg-quick`:
```
novpn sudo wg-quick up ~/wg1.conf
```

### As a blacklist

Simply run your VPN normally; any traffic inside the namespace should not be tunneled.
