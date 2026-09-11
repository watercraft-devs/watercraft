# Adding Versioning and Codename to the Build

One file holds the version and codename. Cleanup sources it. The git tag
reads from it. Nothing gets typed twice, so nothing can disagree.

---

## 1. Create the version file

Filename: `VERSION`
Found at root of Watercraft source control repository 

```sh
# Watercraft Linux release identity.
# Sourced by boatswain_cleanup.sh and by the release tagging process.

VERSION=0.1.0
CODENAME=Ketch
DISTRO_NAME="Watercraft"
DISTRO_ID=watercraft
```
This file gets sourced when you need the version info

---

## 2. VERSION gets sourced in `boatswain_cleanup.sh`

At the top of `boatswain_cleanup.sh`, we source the variables and then ensure the expected variables have values:

```sh
# Release identity lives in one place so the ISO, os-release and git tag
# can't drift apart.
. "$VERSION_FILE"

: "${VERSION:?VERSION not set in VERSION file}"
: "${CODENAME:?CODENAME not set in VERSION file}"
: "${DISTRO_NAME:?DISTRO_NAME not set in VERSION file}"
: "${DISTRO_ID:?DISTRO_ID not set in VERSION file}"

CODENAME_LC=$(echo "$CODENAME" | tr '[:upper:]' '[:lower:]')
```

---

## 3. Write os-release in `boatswain_cleanup.sh`

Write an `os-release` file with the sourced variable values 

```sh
hail "Branding"
cat > /etc/os-release <<EOF
NAME="$DISTRO_NAME"
VERSION="$VERSION ($CODENAME)"
VERSION_ID="$VERSION"
VERSION_CODENAME=$CODENAME_LC
ID=$DISTRO_ID
ID_LIKE=devuan
PRETTY_NAME="$DISTRO_NAME $VERSION ($CODENAME)"
EOF
```

`VERSION_CODENAME` is the machine-readable field — lowercase, no spaces.
That's what scripts match on. `VERSION` and `PRETTY_NAME` are for humans.

This is verifiable right after running `boatswain_cleanup.sh`:

```sh
cat /etc/os-release
lsb_release -a 2>/dev/null

#Should report the expected version and codename set in VERSION file
```

You can also run `lsb_release -a 2>/dev/null` on the installed system to make sure it propagated as well when testing and installation of a build.

---

## 4. Live Installer Boot Menu

`refractasnapshot` prompts for the distro name to be changed for the bootloader interactively. 
Since this is just for the live installer, it should be answered like this

```
Watercraft 0.1.0 (Ketch) Live Install
```
---

## 5. Tag the GIT release 

Before pushing the release, version it:

```sh
. ./VERSION
git tag -s "v$VERSION" -m "$DISTRO_NAME $VERSION ($CODENAME)"
git push origin "v$VERSION"
```

---

## Codename scope 

### Codenames are generational labels as of right now for Watercraft, not release pinning IDs.

- Codename: `Ketch` covers the span of `0.1.0` -> `1.0.0`.
    - The next codename (currently undetermined) will implicitly cover the `1.0.0` release.

- Version numbers identify specific releases, if you want to pin to them.

#### In the future we may employ per-suite codenames for more convenient pinning, but the work for that is not done.


