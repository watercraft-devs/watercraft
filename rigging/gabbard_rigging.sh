#!/bin/bash

# gabbard_rigging.sh
#
# turns a minimal Devuan install into a snapshot builder system
#
# NOTE: it's necessary to have your build system be a clean isolated VM instance
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!! RUN THIS IN AN ISOLATED VM INSTANCE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#
# BUILD TIME and PAYLOAD are different sets of packages and subsequent scripts
#
# during BUILD TIME aka Distro Development Time keep to the SMALLEST POSSIBLE packages:
#
# this is because we don't want to ship any BLOAT
#
# ESPECIALLY not in the LIVE DISK
#
# anything installed to the dev environment or packaged into BUILD TIME will be passed 
# into the live disk AND the later install (so only mandatory items go here)
#
# we have several provisioning scripts, most of them will be ran after a successful install
# this keeps the OS configurable and keeps the install process focused on the basic install that we require
#
# PAYLOAD is the provisioning scripts and other things we will ship with the Distribution, these
# scripts largely give the user prompts to customize what they want installed on their specific system
# includes:
#  - all provisioning scripts
#  - third party repositories 
#  - etc...
#  
# anything that is not mandatory in the base image, is provided as a provisioning script of some sort as a PAYLOAD item.
# that way once the installation is completed and the user boots in, 
# they can easily configure and install exactly the packages they want using convenient (AND SECURE) helpers
# (consider that most package managers have failed because packages are a-uniform in shipping shape)
# (therefore helpers that carefully address each individual package are less likely to be as fragile as managers)
#
#
#
# (the point of the packages or desktop configurations that get installed by default right now in `provisions.sh` is to flavor the distribution towards the founder-group's development needs for all software projects in general, any package can be removed by the end-user once booted into their installed system making everything fully customizable at the end of the day)
#
# (gabbard_rigging.sh (this file) will ship some Watercraft specific artifacts like wallpapers, the name of the os, things like that. These artifacts can technically be modified/removed by end users, but will likely persist for most systems because that's the default installation behavior)
#
#
#
set  -euo pipefail


printf "gabbard_rigging.sh is meant to be ran in an ISOLATED VM INSTANCE ONLY\n\n"

printf "This is to programatically ensure that distro builds are completely free of any unwanted packages\n\n"

printf "MAKE SURE YOU ARE RUNNING IN AN ISOLATED VM INSTANCE DEDICATED TO WATERCRAFT DISTRO BUILDING\n\n"

read -p "Are you in an isolated VM instance? (y/n): " vmyn

if [[ "$vmyn" == "y" ]]; then
	printf "VM CONFIRMED, RIGGING THE GABBARD"
else
	printf "ISOLATED VM INSTANCE CAN BE CREATED WITH BASIC DEVUAN INSTALLATION AND QEMU"
	exit
fi


LIVE_USER="${LIVE_USER:-liveuser}"
PAYLOAD_SRC="${PAYLOAD_SRC:-./rigging}"
PAYLOAD_DST="/usr/local/share/rigging"

###

[ "$(id -u)" -eq 0 ] || { printf "\n!!RUN AS ROOT / SUDO!!\n" >&2; exit 1; }


###




for old in live liveuser; do
	[ "$old" = "$LIVE_USER" ] && continue
	id "$old" >/dev/null 2>&1 && { pkill -u "$old" 2>/dev/null; deluser --remove-home "$old"; }
	rm -f "/etc/sudoers.d/${old}-nopasswd"
done

mkdir -p /etc/live
sed -i '/^LIVE_USERNAME=/d' /etc/live/config.conf 2>/dev/null || true
echo "LIVE_USERNAME=\"$LIVE_USER\"" >> /etc/live/config.conf 


# hail: basically a formatted alias for echo or printf, use it to announce stuff
hail() {
        if [ -x /usr/bin/pad_cpp ]; then
                printf "\n%s\n" "$(/usr/bin/pad_cpp "$*" 64 = c)"
        else
                printf "\n%s\n" "$*"
        fi
}


###

hail "INSTALLING BUILD-TIME PACKAGES"
chmod +x ./dev_provisions.sh
./dev_provisions.sh --refracta 

sudo apt install -y --no-install-recommends \
	gparted gdisk dosfstools

###

hail "PAYLOADS / PROVISION SCRIPTS"

mkdir -p "$PAYLOAD_DST"
if [ -d "$PAYLOAD_SRC" ]; then
	cp -r "$PAYLOAD_SRC"/* "$PAYLOAD_DST"/
	chmod +x "$PAYLOAD_DST"/*.sh 2>/dev/null || true
else
	echo "No $PAYLOAD_SRC directory - drop your scripts there and re-run."
fi

###

cat > "$PAYLOAD_DST/README" << 'EOF'

This directory contains configurable user system provisioning scripts.

Ran optionally after a successful base installation.

Can contain 3rd party, unverifiable, or taste-dependant choices.

Anything that should be a deliberate customization by the end user
EOF


###


hail "PASSING X11 CREDS THROUGH SUDO"

#this step fixes a few legacy bugs with refracta installer and GUI behavior

install -m 440 /dev/stdin /etc/sudoers.d/x11-forward <<'EOF'
Defaults env_keep += "DISPLAY XAUTHORITY"
EOF
visudo -c

###

hail "ADDING DESKTOP LAUNCHERS TO /etc/skel"
mkdir -p /etc/skel/Desktop

cat > /etc/skel/Desktop/install-system.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install to Hard Drive
Exec=sudo refractainstaller
Icon=system-software-install
Terminal=true
EOF
 
cat > /etc/skel/Desktop/partition-disks.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Partition Editor
Exec=sudo /usr/sbin/gparted
Icon=gparted
Terminal=true
EOF
 
chmod +x /etc/skel/Desktop/*.desktop
 
###

hail "FIRST LOGIN DESKTOP TRUST AUTORUN"

cat > /usr/local/bin/trust-desktop-launchers <<'EOF'
#!/bin/bash
for f in "$HOME"/Desktop/*.desktop; do
  [ -e "$f" ] || continue
  chmod +x "$f"
  gio set -t string "$f" metadata::xfce-exe-checksum \
    "$(sha256sum "$f" | awk '{print $1}')" 2>/dev/null || true
done
EOF
chmod +x /usr/local/bin/trust-desktop-launchers
 
mkdir -p /etc/skel/.config/autostart
cat > /etc/skel/.config/autostart/trust-launchers.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Trust desktop launchers
Exec=/usr/local/bin/trust-desktop-launchers
NoDisplay=true
EOF

hail "Setup Live Disk Account: $LIVE_USER"

id "$LIVE_USER" >/dev/null 2>&1 || \
#	adduser --disabled-password --gecos "Live Session" "$LIVE_USER"
#adduser "$LIVE_USER" sudo

install -m 440 /dev/stdin /etc/sudoers.d/live-nopasswd <<EOF
$LIVE_USER ALL=(ALL) NOPASSWD: ALL
EOF
visudo -c

hail "Autologin"

sed -i "s/^#*\s*default_user.*/default_user        $LIVE_USER/" /etc/slim.conf
sed -i 's/^#*\s*auto_login.*/auto_login          yes/' /etc/slim.conf

printf "AUTOLOGIN CHECK: \n\n"

grep -E 'default_user|auto_login' /etc/slim.conf



#passwd -d "$LIVE_USER"

hail "FIXING 'live-config' SUDOERS ARTIFACT" #TODO change required start to $all if first try doesnt work
cat > /etc/init.d/rm-live-sudoers <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          rm-live-sudoers
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Remove stale live-config sudoers file
### END INIT INFO
rm -f /etc/sudoers.d/live
EOF
chmod +x /etc/init.d/rm-live-sudoers
update-rc.d rm-live-sudoers defaults

# LIGHTDM TODO make optional
#mkdir -p /etc/lightdm/lightdm.conf.d
#cat > /etc/lightdm/lightdm.conf.d/60-autologin.conf <<EOF
#[Seat:*]
#autologin-user=$LIVE_USER
#autologin-user-timeout=0
#EOF

hail "FIRST-BOOT CLEANUP SERVICE"
cat > /etc/init.d/firstboot-cleanup <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          firstboot-cleanup
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Remove live-session config on installed systems
### END INIT INFO

# Live boots carry boot=live; installed systems don't. Leave live media alone.
grep -qs 'boot=live' /proc/cmdline && exit 0
[ ! -e /etc/sudoers.d/liveuser-nopasswd ] && exit 0

if rm -f /etc/sudoers.d/liveuser-nopasswd && \
   sed -i 's/^auto_login.*/auto_login          no/' /etc/slim.conf && \
   grep -q '^auto_login *no' /etc/slim.conf; then
    update-rc.d -f firstboot-cleanup remove
    rm -f "$0"
fi
exit 0
EOF
chmod +x /etc/init.d/firstboot-cleanup
update-rc.d firstboot-cleanup defaults


hail "REFRACTAINSTALLER EFI FALLBACK"

sed -i 's|^#*media_opt=.*|media_opt="--force-extra-removable"|' /etc/refractainstaller.conf
grep -n '^media_opt' /etc/refractainstaller.conf

hail "Post-install icon cleanup"
sed -i 's|refractainstaller\.desktop|install-system.desktop|' \
  /usr/lib/refractainstaller/post-install/cleanup-install.sh
				# add skel and the installer desktop icon to refracta's cleanup script
sed -i '/^exit 0/i rm -f /target/etc/skel/Desktop/install-system.desktop' \
    /usr/lib/refractainstaller/post-install/cleanup-install.sh

chmod +x /usr/lib/refractainstaller/post-install/cleanup-install.sh


hail "Blacklist floppy driver"

printf 'blacklist floppy\n' > /etc/modprobe.d/blacklist-floppy.conf
update-initramfs -u

hail "Wireless firmware" #make this optional in future releases
apt install -y --no-install-recommends \
	firmware-mediatek \
	firmware-realtek \
	firmware-iwlwifi \
	firmware-atheros \
	firmware-brcm80211

hail "Themes"
install -Dm644 rigging/assets/WatercraftBackgroundCustom_DEFAULT.png \
    /usr/share/backgrounds/watercraft/default.png
install -Dm644 rigging/assets/WatercraftBackgroundCustom_KRAKEN.png \
    /usr/share/backgrounds/watercraft/kraken.png
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
cat > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string"
                    value="/usr/share/backgrounds/watercraft/default.png"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF
cat > /usr/local/bin/watercraft-wallpaper <<'EOF'
#!/bin/bash
BG=/usr/share/backgrounds/watercraft/default.png
[ -e "$HOME/release_the_kraken" ] && BG=/usr/share/backgrounds/watercraft/kraken.png

for out in $(xrandr --listmonitors | awk 'NR>1 {print $NF}'); do
	xfconf-query -c xfce4-desktop \
		-p "/backdrop/screen0/monitor$out/workspace0/last-image" \
		-n -t string -s "$BG" 2>/dev/null
	xfconf-query -c xfce4-desktop \
                -p "/backdrop/screen0/monitor$out/workspace0/image-style" \
                -n -t int -s 5 2>/dev/null
done
xfdesktop --reload 2>/dev/null

EOF
chmod +x /usr/local/bin/watercraft-wallpaper
mkdir -p /etc/skel/.config/autostart
cat > /etc/skel/.config/autostart/watercraft-wallpaper.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Watercraft wallpaper
Exec=/usr/local/bin/watercraft-wallpaper
NoDisplay=true
EOF




###########################################################################################################################

hail "DONE. Reboot and check that the desktop icons are functioning properly."
hail "Then run './boatswain_cleanup.sh'"





