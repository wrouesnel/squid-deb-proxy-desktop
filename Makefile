#!/usr/bin/make

all:
	echo "nothing to do"

install:
	# dir
	install -d -m 755 $(DESTDIR)/etc/squid-deb-proxy-desktop
	install -d -m 755 $(DESTDIR)/etc/apt/apt.conf.d
	install -d -m 755 $(DESTDIR)/usr/share/squid-deb-proxy-desktop-client/
	# files
	install -m 644 squid-deb-proxy-desktop.conf $(DESTDIR)/etc/squid-deb-proxy-desktop/
	install -m 644 allowed-networks-src.acl $(DESTDIR)/etc/squid-deb-proxy-desktop/
	install -m 644 discovered-peers.conf $(DESTDIR)/etc/squid-deb-proxy-desktop/
	install -m 644 repository-files.acl $(DESTDIR)/etc/squid-deb-proxy-desktop/
	# client
	install -m 755 apt-avahi-discover $(DESTDIR)/usr/share/squid-deb-proxy-desktop-client/
	install -m 644 30autoproxy $(DESTDIR)/etc/apt/apt.conf.d
