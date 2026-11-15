#!/bin/bash

# dark-lantern-dns by Watercraft
#
# toggle encrypted DNS without systemd
# this version hardcodes Quad9 over TLS via Unbound
#
#




set -e 

UNBOUND_CONF=/etc/unbound/unbound.conf.d/dark-lantern-dot.conf
NM_CONF=/etc/NetworkManager/conf.d/90-dark-lantern-dns.conf
BACKUP=/etc/resolv.conf.backup-pre-dark-lantern


restore_resolv_conf() {
	if [ -e "$BACKUP" ] || [ -L "$BACKUP"  ]; then
		rm -f /etc/resolv.conf
		mv "$BACKUP" /etc/resolv.conf
	fi
}


enable_dark_lantern() {
	[ "$(id -u)" -eq 0 ] || { echo "Needs sudo or run as root." >&2; exit 1;  }
	apt-get install -y unbound ca-certificates 

	cat > "$UNBOUND_CONF" << 'EOF'
server:
    interface: 127.0.0.1
    so-sndbuf: 0
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt

forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 9.9.9.9@853#dns.quad9.net
    forward-addr: 149.112.112.112@853#dns.quad9.net
EOF
	unbound-checkconf
	invoke-rc.d unbound restart

	printf '[main]\ndns=none\n' > "$NM_CONF"
	if [ ! -e "$BACKUP" ] && [ ! -L "$BACKUP" ]; then
		cp -P /etc/resolv.conf "$BACKUP"
	fi
	rm -f /etc/resolv.conf
	echo 'nameserver 127.0.0.1' > /etc/resov.conf
	invoke-rc.d network-manager reload || true

	if getent hosts deb.devuan.org > /dev/null; then
		printf "\n\n\nDark Lantern: [Cloud9] Encrypted DNS enabled.\n\n\n"
	else
		printf "Dark Lantern: failed to enable encrypred DNS (port 853 may be blocked). Reverting to backup DNS settings\n\n\n"
		disable_dark_lantern 
		exit 1
	fi
}

disable_dark_lantern() {
	[ "$(id -u)" -eq 0 ] || { echo "Needs sudo or run as root." >&2; exit 1;  }
	rm -f "$UNBOUND_CONF" "$NM_CONF"
	restore_resolv_conf
	invoke-rc.d unbound restart || true
	invoke-rc.d network-manager reload || true
	printf "\nDark Lantern: Disabled DNS Encryption Configuration\n"
}

dark-lantern-status() {
	if [ -e "$UNBOUND_CONF" ] && grep -qx 'nameserver 127.0.0.1' /etc/resolv.conf; then
        	echo "enabled"
    	else
        	echo "disabled"
    	fi
}

case "$1" in
	enable) enable_dark_lantern ;;
	disable) disable_dark_lantern ;;
	status) dark-lantern-status ;;
	*) printf "\nUsage: $0 {enable|disable|status}\n\n" >&2; exit 2 ;;
esac

