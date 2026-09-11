#!/bin/bash
# cleanup.sh
#
# Run immediately before snapshotting, from a root console - not from a
# session belonging to the account being deleted.
#
#DISTRO_NAME='Watercraft Linux' 
#DISTRO_ID=watercraft 





BUILD_ACCOUNT=boatswain

set -euo pipefail

#: "${DISTRO_NAME:?set DISTRO_NAME}"
#: "${DISTRO_ID:?set DISTRO_ID}"


#DISTRO_VERSION="${DISTRO_VERSION:-0.0.1}"

# Source version info
VERSION_FILE="/root/build/rigging/VERSION" #VERSION and this file should always be located in same dir anyway...
[ -f "$VERSION_FILE" ] || { printf "VERSION file not found at $VERSION_FILE" >&2; exit 1; }
. "$VERSION_FILE"
: "${VERSION:?VERSION not set in VERSION file}"
: "${CODENAME:?CODENAME not set in VERSION file}"
: "${DISTRO_NAME:?DISTRO_NAME not set in VERSION file}"
: "${DISTRO_ID:?DISTRO_ID not set in VERSION file}"

CODENAME_LC=$(echo "$CODENAME" | tr '[:upper:]' '[:lower:]')





BUILD_ACCOUNT="${BUILD_ACCOUNT:-boatswain}"

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }

hail() {
        if [ -x /usr/bin/pad_cpp ]; then
                printf "\n%s\n" "$(/usr/bin/pad_cpp "$*" 64 = c)"
        else
                printf "\n%s\n" "$*"
        fi
}


hail "Branding"
# Refracta reads DISTRO from here for the boot menu, as do neofetch,
# lsb_release and most tooling.
cat > /etc/os-release <<EOF
NAME="$DISTRO_NAME"
VERSION="$VERSION ($CODENAME)"
VERSION_ID="$VERSION"
VERSION_CODENAME=$CODENAME_LC
ID=$DISTRO_ID
ID_LIKE=devuan
PRETTY_NAME="$DISTRO_NAME $VERSION ($CODENAME)"
EOF

sed -i 's|^GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR=`( . /etc/os-release \&\& echo ${PRETTY_NAME} )`|' /etc/default/grub
grep GRUB_DISTRIBUTOR /etc/default/grub

LIVE_USER="liveuser"
hail "Remove build account"
if [ -n "$BUILD_ACCOUNT" ] && id "$BUILD_ACCOUNT" >/dev/null 2>&1; then
  [ "$BUILD_ACCOUNT" != "$(logname 2>/dev/null || true)" ] || \
    { echo "Refusing to delete the account you're logged in as." >&2; exit 1; }
  deluser --remove-home "$BUILD_ACCOUNT"
  adduser --disabled-password --gecos "Live Session" --uid 1000 "$LIVE_USER"
  adduser "$LIVE_USER" sudo
  passwd -d "$LIVE_USER"
fi


hail "Credentials and history"
rm -rf /root/.bash_history /root/.ssh /root/.gnupg
find /home -maxdepth 2 \( -name .bash_history -o -name .ssh -o -name .gnupg \) \
  -exec rm -rf {} + 2>/dev/null || true

# Regenerate per-machine rather than shipping one identity to everyone.
rm -f /etc/ssh/ssh_host_*
truncate -s 0 /etc/machine-id

# DELETE AND LOCK THE BUILDER'S PASSWORD RENDERING IT UNUSABLE FOR ROOT EXECUTIONS IN THE POTENTIAL CHANCE THAT
# THE USER FAILS TO CHANGE THE ROOT PASSWORD AT INSTALL TIME
passwd -d root
passwd -l root
# (refracta specific pitfall)


hail "Package manifest"
dpkg --get-selections > /root/installed-packages.txt

apt clean


# Dumpster 
# # Could maybe use as a last-in-line space to ensure .sh and other files from build that might be in 
# # /root/build/rigging -> /usr/local/share/rigging that we want ignored get deleted if found here
# for now passing through those scripts is not harmful, it's just not entirely necessary 
# most will never or shouldn't use many of those scripts, most will use a select few scripts most likely
# whether the bulk pack or the slim pack is standard is yet to be determined
# Make sure broken stuff from old build states is incinerated before resnapshotting
rm -f /etc/firstboot-done
rm -f /home/liveuser/.config/.launchers-trusted
rm -f /usr/bin/pad_cpp
rm -f /usr/local/bin/pad_cpp
hail "Watercraft refracta build ready!"
hail "Reboot, then: refractasnapshot -d"
