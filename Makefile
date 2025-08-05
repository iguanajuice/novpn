PREFIX := /usr

novpn: novpn.c

clean:
	rm -f novpn

uninstall:
	rm $(PREFIX)/libexec/novpn/ -rf
	rm -f $(PREFIX)/bin/novpn

install: uninstall novpn
	mkdir -p $(PREFIX)/libexec/novpn/
	install -Dm755 ns-setup.sh $(PREFIX)/libexec/novpn/
	install -Dm755 if-create.sh $(PREFIX)/libexec/novpn/
	install -Dm755 resolvconf $(PREFIX)/libexec/novpn/
	install -Dm755 novpn $(PREFIX)/bin/
	setcap CAP_SYS_ADMIN=ep $(PREFIX)/bin/novpn

systemd_uninstall:
	rm /usr/lib/systemd/system/novpn-namespace.service
	rm /usr/lib/systemd/system/novpn-keepalive.service
	rm /usr/lib/systemd/system/novpn-dhcpcd.service

systemd_install: systemd_uninstall
	install -Dm644 systemd/*.service /usr/lib/systemd/system/

.PHONY: systemd
systemd: systemd_install
	systemctl enable novpn-keepalive
	systemctl enable novpn-namespace
	systemctl enable novpn-dhcpcd
	systemctl restart novpn-namespace
	systemctl restart novpn-dhcpcd
