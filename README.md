# novpn

Easy split tunneling setup using network namespaces!


## Dependencies

* `iproute2`
* `dhcpcd`
* a C compiler


## Installation

1. Clone the repo
2. Run `sudo make install`
3. If using systemd, also run `sudo make systemd`


## Usage

### Heads up for Flatpak apps

Flatpak apps need `flatpak-session-helper` for handling the access of host /etc files by app containers.

If you use `novpn` on a Flatpak app before `flatpak-sesion-helper` is running,
the application will use the wrong resolv.conf file, resulting in DNS issues.

To fix this, add `/usr/libexec/flatpak-session-helper` to your autostart.

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
