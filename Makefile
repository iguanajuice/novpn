PREFIX := /usr

novpn: novpn.c

clean:
	rm -f novpn

uninstall:
	rm -f $(PREFIX)/libexec/novpn/ -r
	rm -f $(PREFIX)/bin/novpn

install: uninstall novpn
	mkdir -p $(PREFIX)/libexec/novpn/
	install -Dm755 scripts/* $(PREFIX)/libexec/novpn/
	install -Dm755 novpn $(PREFIX)/bin/
	setcap CAP_SYS_ADMIN=ep $(PREFIX)/bin/novpn

systemd_uninstall:
	systemctl disable --now novpn-namespace.service 2>/dev/null || :
	rm -f /usr/lib/systemd/system/novpn-namespace.service
	rm -f /usr/lib/systemd/system/novpn-pasta@.service
	rm -f /etc/systemd/system/novpn-pasta@*.service

systemd_install: systemd_uninstall
	install -Dm644 systemd/*.service /usr/lib/systemd/system/

.PHONY: systemd
systemd: systemd_install
	systemctl enable novpn-namespace
	systemctl restart novpn-namespace
