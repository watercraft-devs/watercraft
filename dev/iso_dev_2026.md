# ISO Development Notes - 2026

These are notes of EVERY RELEVANT THING that we stumbled on creating ISOs in the year 2026
It may expand to several different files as we venture onward, as it's already getting to be much.
This will include development with refractainstaller and our own custom installer too in the future.
It also includes things about quirks when installing on hardware.

NOTE: at the time of writing, we are only using `refracta` to build our liveusb ISO files.

We have a roadmap for creating a more modern liveusb creation tool/protocol, that will be executed as soon as possible.

For now refracta gets the job done and is tested working, it's just not very ergonomic and we would like to improve the UX of the installation experience, it's also not too big of a job maintaining the refracta option while some people want to use it (it has good features for snapshotting/restoring etc...).

## Refracta

### The following appear as upstream bugs, we introduce our own workarounds for them in Watercraft. 

#### `grub-install`
- runs with no options unless `media_opt` is set
- installer calls `chroot /target grub-install ${efi_name_opt} ${media_opt}` when neither variable is assigned to yet
- variables originate from `/etc/refractainstaller.conf` where `media_opt` ships commented out
- resulting `grub-install` only writes the `grubx64.efi` file but not the `BOOTX64.EFI` file
- causes failure to boot on firmware without persistent NVRAM, installer doesn't properly report any of this
- **SOLUTION**: set `media_opt="--force-extra-removable"` in `/etc/refractainstaller.conf`

##### Solution implemented in `gabbard_rigging.sh`:

```sh
sed -i \
    's|^#*media_opt=.*|media_opt="--force-extra-removable"|' \
    /etc/refractainstaller.conf
grep -n '^media_opt' /etc/refractainstaller.conf
```
---
#### `cleanup-install.sh`
- **Ships non-executable**
- post-install hook tries to run it but skips it because the read write access is `-rw-r--r--`
- setting `run_postinstall="yes"` is needed but doesn't suffice due to the script being non-executable.
- it also hardcodes the installer launcher / desktop icon name
    - if you change the name at all it will never function

##### Solution implemented in `gabbard_rigging.sh`:

```sh
sed -i 's|refractainstaller\.desktop|install-system.desktop|' \
  /usr/lib/refractainstaller/post-install/cleanup-install.sh
chmod +x /usr/lib/refractainstaller/post-install/cleanup-install.sh
```
---
#### user renaming
- forces the user to be UID 1000
- any other account will cause `usermod -l` to fail with a usage dump and exit 2
- means we have to remove builder account before snapshots, or else nothing will work
    - we keep our own builder VM snapshots at every single iteration because of this
    - it's a workaround, ideally we don't have to do that forever

##### Solution implemented in `boatswain_cleanup.sh`:
```sh
if [ -n "$BUILD_ACCOUNT" ] && id "$BUILD_ACCOUNT" >/dev/null 2>&1; then
    [ "$BUILD_ACCOUNT" != "$(logname 2>/dev/null || true)" ] || \
        { 
            printf 'Refusing to delete your current account.\n' >&2; 
            exit 1; 
        }
    deluser --remove-home "$BUILD_ACCOUNT"
fi

# hopefully it's obvious but this has to be run from root, 
# not the account that will be deleted...

adduser --disabled-password --gecos "Live Session" --uid 1000 "$LIVE_USER"
adduser "$LIVE_USER" sudo
passwd -d "$LIVE_USER"
```
---
#### password changing 
- It asks if you want to rename the primary user, if you press `Enter` for `no` it skips password changing entirely
- It also fails to rewrite the autologin for the display-manager
    - Leaves you with a broken account you can't log into

##### Solution Unimplemented
Only real solution is changing the primary user name every time.
The **TRAP** here is pressing the `Enter` key carelessly (super likely occurrence).
Which isn't going to be suitable going forward hence our initiation towards a new upcoming live installer made by Watercraft devs..

---
#### GUI installer - locales 
- bug reproducible by selecting all locales
- working path is leaving default locale selection **untouched**
- a killed GUI here leaves a `debconf lock` that blocks the installer until a `reboot`
- `pkill` doesn't sufficiently restart it

##### Solution Unimplemented
With no solution in sight for refracta, we will defer the "fix" to the upcoming Watercraft live installer

---
## live-config
### worked around currently, will be fixed without workaround
#### **Malformed /etc/sudoers.d/live on live boots**
- live kernel command carries an empty `username=` value 
- then `live-config` writes `ALL=(ALL) NOPASSWD: ALL` with no user field
- this causes `sudo` to print `syntax error` on every invocation
- `sudo` still functions normally behind the noise, but it's not an acceptable quirk

##### Workaround init script implemented in `gabbard_rigging.sh`:
```sh
cat > /etc/init.d/rm-live-sudoers <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          rm-live-sudoers
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Remove malformed live-config sudoers file
### END INIT INFO
rm -f /etc/sudoers.d/live
EOF
chmod +x /etc/init.d/rm-live-sudoers
update-rc.d rm-live-sudoers defaults
```

## Hazards of refracta's snapshot-based ISO builds

### `refractasnapshot` copies a **RUNNING SYSTEM**

#### **Everything written on to the builder's system during building gets shipped to end users!!!**

**This means we have to make scripts that delete leftovers that we don't want to ship, explicitly.**

If those scripts don't run, it's usually silent which was a huge annoyance during the development of 0.1.0 .

- **Don't** make marker files that say that the script ran, it's messy and unreliable.
- **Do** make idempotent scripts that run exactly when needed, check ahead that they really need to run to be extra clean.



**`/etc/skel` needs population before any account is created, or the created account doesn't inherit what you want it to.**

`XFCE` won't run a `.desktop` launcher until it sees a SHA-256 checksum in the per-user gvfs metadata.
It's written by `gio` into the user's session, so it should be done by a first-login hook.
Cannot just be shipped as a file in `/etc/skel`.

**`X11` credentials don't survive `sudo` by default**

`gparted` for example dies with "requires graphical environment" unless `DISPLAY` and `XAUTHORITY` are passed through.

A sudoers drop-in solves this.
##### Solution implemented in `gabbard_rigging`:
```sh
install -m 440 /dev/stdin /etc/sudoers.d/x11-forward <<'EOF'
Defaults env_keep += "DISPLAY XAUTHORITY"
EOF
visudo -c
# NOTE: sudo refuses to read drop ins with looser permissions than 440
```

**Stale `/home/work/myfs` produces corrupt ISO, doesn't boot**

If a refractasnapshot run is interrupted while `save_work="yes"` the next run repacks the old tree
The ISO will build but it will not boot, the `/home/work` directory must be cleared before trying to debug anything.

**SSH host key warning**

If you regenerate keys on the builder to move files around (expected builder behavior) they ship to end users.

This is obviously a huge red line that shouldn't be crossed, never share SSH keys or anything of the like to end users or anyone else for that matter.

The fix is programmatically removing the keys before snapshotting.

To move the ISO out after cleaning up keys, do it via `nbd mount` instead of scp.

##### Solution implemented in `boatswain_cleanup.sh`:

```sh
rm -rf /root/.bash_history /root/.ssh /root/.gnupg
find /home \
    -maxdepth 2 \( -name .bash_history -o -name .ssh -o -name .gnupg \) \
    -exec rm -rf {} + 2>/dev/null || true

# Regenerate per-machine rather than shipping one identity to everyone.
rm -f /etc/ssh/ssh_host_*
truncate -s 0 /etc/machine-id
```

## `qemu` VM software

### used to host the builder account and test live install ISOs

#### **`qemu-nbd -c` returns before a newly created partition node officially exists**

- causes `Can't lookup blockdev` error
- `udevadm settle` does not reliably help — it waits on already-queued events, and the scan may not have started


If the commands are run by hand, you won't experience the error.

That's because there's a gap before the first command finished blocking shell input.

In a bash script, they are executed one after another immediately causing the lookup error.

##### Solution 
1) Load the module with partition support, otherwise nodes never appear and waiting doesn't help:

``` sudo modprobe nbd max_part=8```

2) Poll for the device:
   
```sh
sudo qemu-nbd -c /dev/nbd0 /path/to/disk.qcow2

for i in $(seq 20); do
    [ -b /dev/nbd0p2 ] && break
    sleep 0.25
done
[ -b /dev/nbd0p2 ] || { printf 'nbd0p2 never appeared\n' >&2; exit 1; }

sudo mount /dev/nbd0p2 /mnt/vm
```

3) **Unmount FIRST** then disconnect:

```sh
sudo umount /mnt/vm
sudo qemu-nbd -d /dev/nbd0
# do this every time after pulling anything off the vm
```
Forgetting `qemu-nbd -d` at the end leaves your image locked, common pitfall.
Keeping these in scripts makes development smoother.

## Reports from installing on real hardware

**NVMe enumeration is unstable across boots**

If drives are saved as paths instead of UUID, and the enumeration changes, the bootloader will fail.

This is because `root` and `swap` can change actual path due to the NVMe instability.

`fstab` and `grub` will both be unable to see the correct drive, the enumeration will be pointing at the wrong path.

The resulting system gets dropped into `initramfs` and has to be manually reconfigured.

That's why it's essential to save the drives as UUIDs when refractainstaller prompts.

Check before rebooting a live install with:

```sh
cat /target/etc/fstab
grep -h 'linux\s' /target/boot/grub/grub.cfg | head -3
```

If they show paths instead of UUIDs, replace the paths with the respective UUID.

If you reboot before doing this fix, you will drop into `grub` and / or `initramfs` on attempt to boot depending on the circumstance.

`grub` will not have a usable prefix, you can add it manually with 

```sh
set prefix=(hdX,gptY)/boot/grub
insmod normal
normal
# it will start booting in
```
once in the system run `grub-install` to save it.

---
**NVRAM can fill up**

`efibootmgr -B` fails with "No space left on device"

mitigate by clearing dump variables:
`sudo rm -f /sys/firmware/efi/efivars/dump-*`

---
**Kernel headers need to be installed BEFORE Nvidia driver**

In our case without `linux-headers-amd64` DKMS cannot build the module, needs confirmation on other architectures probably.

Without the headers, the install blacklists nouveau but doesn't replace it so when you reboot you land in a `tty`.

---
**`primus-vk-nvidia` pulls in the deprecated Bumblebee**

It installs a Vulkan wrapper that shadows Nvidia ICD, outputs this when trying anything:
```
Can't open bumblebee display.
ICD libnv_vulkan_wrapper.so.1 doesn't support interface version
compatible with loader, skip this ICD
```

You only need `nvidia-driver` plus `nvidia-vulkan-icd` here, PRIME offload is built into these already.


---
**`nvidia-persistenced` fails during installation** 

Happens because module isn't loaded yet, leaves dpkg broken.

It's a `recommended` package for headless compute setups, not necessary for most desktop applications.

We avoid it with `--no-install-recommends`.

---
**Blacklist emulated floppy saves boot time**

QEMU presents an emulated floppy by default, and it can happen on many BIOSes as well. 

The Kernel attempts to read `fd0` for a non-negligible amount of time (~30 seconds) in the middle of booting if it's not blacklisted.

---
## Open Questions

- Desktop background and icons take 10+ seconds to load / display on the screen with GPU driver not installed yet
    - Suspected to be nouveau loading slowly
    - not confirmed across enough hardware boots yet

- Refracta has no reproducibility guarantees
    - Implicitly, snapshotted systems are not byte identical even if they structurally are the same system
    - Meaning identical rebuilds with no modifications cannot be verified against the original ISO release
    - As a solution we plan to move to a declarative build system in our upcoming Watercraft developed live installer

## Watercraft specific quirks

- Build scripts shipping in the ISO image rigging folder
    - generally ok, but for 0.1.0 they contain no guards, meaning users who run them carelessly might end up with a recoverable but annoying system situation
    - in all future releases, anything like this should either be filtered out of main releases or bare minimum given a script guard up front which would likely mitigate all the potential pitfalls here



