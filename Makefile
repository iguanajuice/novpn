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

.PHONY: systemd
systemd:
	install -Dm644 systemd/*.service /usr/lib/systemd/system/
	systemctl enable novpn-keepalive
	systemctl enable novpn-namespace
	systemctl restart novpn-keepalive
	systemctl restart novpn-namespace
