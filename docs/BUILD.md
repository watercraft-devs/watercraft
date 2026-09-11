# Building Watercraft

## Knowledge Prerequisites
As of today, Watercraft builds are based on `refractainstaller` snapshots

Refracta is a tool that can back up your Devuan system into `ISO` file snapshots

It gives us a dated but convenient path to build Watercraft `ISO`s for version 0.1.0

Therefore, currently a Watercraft 0.1.0 image is a `refractasnapshot` of a fully configured Devuan system.

Through the development process we have determined that we will likely reserve refracta functionality for a snapshot distribution type tool that ships with Watercraft in the future.

Future releases won't be snapshots, they will be built and installed with a newly developed tool that gives us faster iteration times, improved UX, and full reproducibility for users. 


Watercraft is currently built using:

- a basic Devuan installation on a VM
- some Watercraft provisioning and cleanup scripts ran inside it
- a refractainstaller snapshot packed into a live `ISO`

## Lets get building

### Prerequisite Steps:
**Install `wget`**
```sh
sudo apt-get install wget
```

**`mkdir` and `cd` into your desired working directory**

example:

```
mkdir Watercraft-boatswain
cd Watercraft-boatswain
```


**We provide several helper scripts for this guide**
Copy them from your clone of the Github in the `boatswain` folder into your working directory:
```sh
cp WatercraftGithub/boatswain/*.sh .
```


**Get a copy of `Devuan netinstall` ISO**

```sh
wget https://files.devuan.org/devuan_excalibur/installer-iso/devuan_excalibur_6.1.1_amd64_netinstall.iso
```

**Install QEMU and OVMF (Virtual Machine and related software)**

```sh
sudo apt install qemu-system-x86 qemu-utils ovmf
```
**The Builder VM will consume 60 GIGABYTES!**

( It can technically be slightly less, however 60 gives comfortable headroom for `refractasnapshot` which needs 2x installed system size in free space ) 

Stick to 60GB minimum for reliable building

**Ensure you have ample space before proceeding with OS builds**

## Step 1. Builder / Boatswain VM

```sh
# create a builder / boatswain VM
qemu-img create -f qcow2 devuan-boatswain.qcow2 60G

#launch it
qemu-system-x86_64 -enable-kvm -m 8192 -smp 4 -vga virtio \
  -bios /usr/share/ovmf/OVMF.fd \
  -drive file=devuan-boatswain.qcow2,format=qcow2 \
  -cdrom devuan_excalibur_6.1.1_amd64_netinstall.iso -boot d \
  -netdev user,id=n0,hostfwd=tcp::2222-:22 \
  -device virtio-net,netdev=n0

#-netdev and -device options allow us to scp files to and from the build VM, very useful for source control and frictionless iteration
```


When installing the `builder` / `boatswain` system:

| Install Step  | Selection |
|---|---|
| Root password | set a short, trivial, easy to remember password, it will be replaced|
| User name | **boatswain** is our go-to default, can technically be anything though |
| Partitioning | guided, select **all files in one partition**  |
| Software selection | **Leave all default selections** change nothing, XFCE comes from here |
| Init system | **sysvinit** |

## Step 2.  Rigging the Gabbard

We keep a running script of `builder` / `boatswain` provisions in `boatswain/gabbard_rigging.sh`

It takes your default build system, and bootstraps it to be cleaned and snapshotted.

Has to be run at `sudo` level, can be run on builder account.

There is also `boatswain/boatswain_cleanup.sh` which cleans up remnants from the `build-time` session, including the builder account and any of its runtime artifacts.

There are a few ways to get these files to your build system, but the preferred way for fast iteration and smooth source control is `scp`.

We provide `boatswain/lighterman.sh` as a convenient `scp` helper script.
Make sure to read it before-hand if using, it's simple and modifiable but still very primitive because it assumes thing like the name of your builder account and the port your VM is on (assumes builder account is named `boatswain` and VM on port `2222`)

Otherwise `scp` works basically like this:


- `-P` defines the port of your VM (set when you launch it, we set it to 2222 above)
- `-r` defines the directory path that you want to send, here we have a `./rigging/` directory in the CWD full of the scripts we want to pass to the VM
- `boatswain@localhost:~/` is the destination, the format is `user@address:~/path/to/destination`
- here the username is `boatswain` the address is `localhost` since its a local VM, and the destination is just the HOME directory `~/`
- for example if you instead set the builder username as `builder` it would be `builder@localhost:~/`
```sh
scp -P 2222 -r ./rigging/  boatswain@localhost:~/
```

### From your bare-metal development machine: Use `lighterman.sh` or raw `scp` to move necessary scripts onto your builder / boatswain VM
- `gabbard_rigging.sh`
- `boatswain_cleanup.sh`
- `add_sudo.sh` (optional/reccomended)
- `comandeer_sudo.sh` (optional/reccomended)
- `sync_rigging_local_boatswain.sh` (optional/reccomended)


`gabbard_rigging.sh` configures the builder VM with ALL the necessary things it may potentially need to construct a Watercraft ISO

`boatswain_cleanup.sh` ensures only the necessary components from the "gabbard" to go on the snapshot for the live installer, nothing else, creates a clean Watercraft vessel



### From your Builder / Boatswain VM: Get `sudo` access

Now we will add the Builder / Boatswain account to the sudoers group

We provide `boatswain/add_sudo.sh` as the core helper here

and 

`boatswain/comandeer_sudo.sh` as the high-level helper

`add_sudo.sh` has to be called from root
`comandeer_sudo.sh` can be called from your Builder / Boatswain account 

If you're using the `comandeer_sudo.sh` helper:
```sh
chmod +x comandeer_sudo.sh
./comandeer_sudo.sh
```
otherwise run it from scratch
```sh
su - root -c 'cd "$2" && bash add_sudo.sh "$1" ' -- sh "$USER" "$HOME"
```

### From your Builder / Boatswain VM: get exec perms and sync the rigging folder
If using the `sync_rigging_local_boatswain.sh` helper:
```sh
# you only need to run chmod +x the first time for exec perms of sync_rigging_local_boatswain.sh
chmod +x sync_rigging_local_boatswain.sh 
./sync_rigging_local_boatswain.sh
```
from scratch:
```sh
chmod +x rigging/*.sh
mkdir -p /root/build
sudo cp -r rigging /root/build/
```

### From your Builder / Boatswain VM: run the rigging script
should already be exec perm'd but if not just `chmod +x` it
```sh
# must run with sudo
sudo ./rigging/gabbard_rigging.sh
```
At this point, `liveuser` will have been created, and `~/rigging/` will be copied into the payload directory to be included in the final installed Watercraft system (for now every script  in `~/rigging/` will be shipped throughout for simplicity, in the future we can separate dev specific script)

### From your Builder / Boatswain VM: shutdown / poweroff
```sh
sudo poweroff
```

## Step 3. Snapshotting the successfully rigged Builder / Boatswain VM instance with QEMU

### From your bare-metal development machine:

Before running the cleanup script, we need a qcow2 (qemu vm disk format) snapshot of the current state.

This is a checkpoint you can use to iterate quickly in case the ISO install fails for some reason, or just for continuing development work from the last known good state in general.

To create the backup snapshot, you will need to run `PRE_CLEANUP_SNAPSHOT.sh`:

See: `boatswain/PRE_CLEANUP_SNAPSHOT.sh`

```sh
# chmod only needed if it's the first time you're executing it
chmod +x PRE_CLEANUP_SNAPSHOT.sh
./PRE_CLEANUP_SNAPSHOT.sh
```
this is what it does:
(if your VM disk name differs, just change the `DISK_NAME` variable to yours):
```sh
# very helpful to have as a helper script
DISK_NAME=devuan-boatswain
qemu-img snapshot -c pre-cleanup $HOME/$DISK_NAME.qcow2
qemu-img snapshot -l $HOME/$DISK_NAME.qcow2
```

to restore this snapshot you will need `POST_CLEANUP_RESTORE.sh`:

See: `boatswain/POST_CLEANUP_RESTORE.sh`

```sh
# chmod only needed if it's the first time you're executing it
chmod +x POST_CLEANUP_RESTORE.sh
# you can test restore from your snapshot here if you want, it should effectively no-op assuming you made no changes since snapshotting
./POST_CLEANUP_RESTORE.sh
```

`POST_CLEANUP_RESTORE.sh` automatically grabs your latest restore point according to the given VM disk name (if yours differs, just change the `DISK_NAME` variable to yours):

```sh
# this one is practically essential to have as a helper script

printf "\nTHIS WILL OVERWRITE YOUR CURRENT STATE ON THE DISTRO DEVELOPING VM, RESETS TO YOUR LATEST SNAPSHOT!!!\n\n\n"
read -p "PROCEED? : (y/n):  " restore_yn

DISK_NAME=devuan-boatswain
DISK="$HOME/$DISK_NAME".qcow2
TAG=$(qemu-img snapshot -l "$DISK" | awk 'NR>2 {print $2}' | tail -1)
LATEST=$(qemu-img snapshot -l "$DISK" | awk 'NR>2 {print $1}' | tail -1)
echo "RESTORING: $TAG #$LATEST"

if [[ "$restore_yn" == "y" ]]; then
        qemu-img snapshot -a "$LATEST" "$DISK"
else
        exit
fi
```
When you are ready to proceed, `qemu` back into your builder / boatswain VM instance:

See: `boatswain/qemu_boatswain.sh` helper script in this repo.
```
# another helpful script to have
DISK_NAME=devuan-boatswain
qemu-system-x86_64 \
    -enable-kvm -m 8192 \
    -smp 4 -vga virtio   \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file=$HOME/$DISK_NAME.qcow2,format=qcow2 \
    -netdev user,id=n0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=n0
```


## Step 4. Builder / Boatswain Cleanup 

### Produce a clean Watercraft vessel

Cleanup must happen in a **ROOT SHELL** on your Builder / Boatswain VM Instance: 

For `qemu` to get to a `root shell` it's a process: 

1. hit these keys at the same time: `Ctrl`+`Alt`+`2`
2. you will be in the `qemu console` from there you can use the `sendkey` command:
    -   type `sendkey ctrl-alt-f1` and then hit enter, if it returns an error check your format
3. hit these keys at the same time: `Ctrl`+`Alt`+`1` to go back to the main VM screen, it will now be in the root shell login prompt screen
4. where it says `login: ` type:  `root` and hit enter, for password enter the password you set for your builder / boatswain VM account

You are now finally in the root shell!

from here you can locate `~/build/rigging/`

quickly ensure every `.sh` file in there is executable

this can probably be done at an earlier step too

```sh
chmod +x ~/build/rigging/*.sh
```

the main one we need is `boatswain_cleanup.sh` but making them all executable is good practice for future cases

### From a **ROOT SHELL** on your Builder / Boatswain VM Instance: Run `boatswain_cleanup.sh` to produce the live install ISO
```sh
./build/rigging/boatswain_cleanup.sh
```
As soon as the VM is powered off or rebooted, we now have a clean Watercraft vessel


## Step 5. Snapshot the System with Refracta 
### Weigh Anchor

### **From your Builder / Boatswain VM:**

Once you are back in your rebooted system, get back into the `root shell` using the instructions from the top of `Step 4`

From the `root shell` run a refracta snapshot:

```sh
refractasnapshot -d
```

It's output will land in `/home/snapshot`

Boatswain can now depart with the vessel

Do a final shutdown of the builder / boatswain VM
```sh
sudo poweroff
```


## Step 6. Extract the Watercraft ISO 

### **From your bare-metal development machine:**


### First, mount the VM instance:


See: `boatswain/alongside_boatswain.sh` in this repo.

```sh
./alongside_boatswain.sh
```
it does this:
```sh
# loads the network block device, allows it to scan for VM partitions
sudo modprobe nbd max_part=8
# set disk name here if yours is different
DISK_NAME=devuan-boatswain
# qemu pre-mount command
sudo qemu-nbd -c /dev/nbd0 $HOME/$DISK_NAME.qcow2
# wait for it to be available
# qemu-nbd -c returns BEFORE the kernel has scanned the partition table
# so assuming /dev/nbd0p2 "exists" here will break the script
for i in $(seq 20); do
  [ -b /dev/nbd0p2 ] && break
  sleep 0.25
done
[ -b /dev/nbd0p2 ] || { echo "nbd0p2 never appeared" >&2; exit 1; }
# make a mount dir for your VM instance
mkdir -p /mnt/vm/
# finally mount the VM accordingly
sudo mount /dev/nbd0p2 /mnt/vm/
```

### Next, extract the snapshot you made.

- If you made more than one snapshot for some reason, you will have to differentiate between them yourself for now.

- It's best practice to only make one snapshot after running `boatswain_cleanup.sh`
- If you made a mistake or encountered some error, it's best to just overwrite the ISO with the following steps (you must have a restore point available):
    1. `sudo poweroff` the VM.
    2. Run `POST_CLEANUP_RESTORE.sh` with the VM powered off. 
    3. Run the cleanup script again `boatswain_cleanup.sh`(from root shell as always).
    4. Then run `refractasnapshot -d` again, but only do it **once** per cleanup.

assuming you only have one snapshot as expected you can do:
```sh
sudo cp /mnt/vm/home/snapshot/*.iso .
```
again otherwise target your specific snapshot (not recommended)

### Now unmount the VM

See: `boatswain/sheeroff_boatswain.sh`

```sh
./sheeroff_boatswain.sh
```
much simpler, it does this:
```sh
sudo umount /mnt/vm
sudo qemu-nbd -d /dev/nbd0
```
##  Step 7. Live Installer Testing / Trial

### **From your bare-metal development machine:**


Create another qemu qcow2 image, we will assume it's called `test-install` for this guide
It will consume **20 GB** !
```sh
# Create the image
qemu-img create -f qcow2 test-install.qcow2 20G
```

Now we will boot the new `test-install` image with the `ISO` that we just extracted, it's a Watercraft live installer.

**This command again assumes you only have one snapshot in the CWD, if that's not the case manually specify it for now**
```sh
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -vga virtio \
  -bios /usr/share/ovmf/OVMF.fd \
  -drive file=test-install.qcow2,format=qcow2 \
  -cdrom snapshot-*.iso -boot d
```
When you boot into the `live install` system, start checking to ensure some important things are working and/or present:

1. Boot menu shows distro name `Watercraft` or `Watercraft Linux` plainly with no version stuff for the time being
2. `live install` system has autologin working, logs you into `liveuser` account on fresh boot-in with 0 interactivity
3. Both the `Install to Hard Drive` (`refractainstaller`) and `Partition Disk` (`gparted`) desktop icons / shortcuts are working 
    - ideally with no trust dialog although that may not be working yet 
    - bare minimum that theyre there with the right icons and they open and function
4. `sudo` commands need no password, (sortof validated by running the desktop icon check, `Install to Hard drive` runs `sudo refractainstaller`)

If all of this is working, proceed to installing the system on the new `test-install` VM image.

## Step 8. Test-Install on the new VM Watercraft Live Install Disk

### **On the VM Test-Install Live-Installer:**


Click on the `Install to Hard Drive` Desktop shortcut

---
### 8.1. Go through the tzdata setup
---
Just keep the defaults for a basic test

- just keep clicking `next`...

Once you get to Keyboard model

- same thing, click `next` for every page **until it gets to just the terminal prompt.**

It will say `There is no EFI partition. You will need to create one`.

- press `2` and hit `enter` to continue.

---
### 8.2. Partition the Test-Installation
---
It will give you some choices for partitioning, for this guide we will choose `gparted` but if you feel more comfortable with gdisk or something else you can technically use that for this part just fine



- press `1` and hit `enter`, gparted should open.

- You will see your unallocated 20GB there

- Select `Device` from the top menu bar and click `Create Partition Table...`

- Where it says `Select new partition table type:` click the dropdown selector and choose `gpt` then hit `Apply`

- Next, click the leftmost icon or select `Partition` from the top menu bar and click the first option: `New`

Partition 1
In the `Create new Partition` window that opens up

- change the `New size (MiB):` field to `512`
- change the `File system` field to `fat32`
Then click `Add`

Repeat for the next two partitions with these settings:

Partition 2:

- change the `New size (MiB):` field to `2048`
- change the `File system` field to `linux-swap`
Then click `Add`

Partition 3:

- don't change the `New size (MiB):` field, just partition the remainder of the VM space
- the `File system` field should be default set to `ext4` leave it like that
Click `Add`

Once these 3 partitions are in place, click the green checkmark to `Apply All Operations`

or select `Edit` from the top menu bar and then click `Apply All Operations`

Once that's finished it should say `All operations successfully completed`

- `Close` that `Applying pending operations` window.

- `Right-Click` the first partition once the main screen is fully loaded, then select `Manage Flags`.

- From the list of flags, select `esp` then close that window and wait for gparted to fully settle.

Now you can close out of gparted

The installer should now say `Press 1 to return to partitioning a disk or press ENTER to proceed`

- Hit `Enter`

---
### 8.3. Device Configuration
---
The Installer prompt should say `Enter the device name for the EFI partition to use`

- type `/dev/sda1` and hit `Enter`

The next prompt should ask about a separate /boot partition, just hit `Enter`

The following prompt should say `Which partition would you like to use for the installation of the operating system?`

- type `/dev/sda3` and hit `Enter`

Then it will give a list of filesystem choices

- choose `ext4` by pressing `4` and hitting `Enter`

After that it will ask `Do you want the operating system on an encrypted partition?`

- select `no` by hitting `2` and pressing `Enter`

It will ask you `If you created a separate partition for /home?`

- select `no` by hitting `Enter` with the input left blank

Next it will ask for a swap file partition

- type `/dev/sda2` and hit `Enter`

It will now ask `Would you like fstab to use the UUID to identify filesystems?`

- hit `Enter` for `yes`

---
### 8.4. VM Test-Install User Configuration and Installation
---
The Installer should now prompt you with:

`The current hostname is boatswain. To change that, enter the new hostname here. To leave it unchanged, just press ENTER`

You don't HAVE to change it, but for good practice change it to something like `vmTestAccount` to ensure the account configuration is working, just remember exactly what you changed it to in order to test the install later.

- type your `New hostname` ie `vmTestAccount` and hit `Enter`

FINALLY it will ask `Proceed with the installation?`

- hit `1` and press `Enter` for `yes`

It may warn you about `/dev/sda3 contains an ext4 file system` already, just type `y` and hit `Enter`

**Now wait for the install to complete FULLY before doing anything else.**

---
### 8.5. End-of-Install configuration 
---
After a short while, the Installer will prompt you: `Disable auto-login?`

- hit `Enter` for yes

On the next prompt that starts with `The installed system is ready for chroot`

- Choose `Install bootloader and finish the installation` by hitting `2` and pressing `Enter`

The next prompt will say `The current primary user's name is liveuser...`

**DO NOT JUST HIT ENTER HERE WITHOUT TYPING ANYTHING IN**

If you hit enter `liveuser` will persist as the main account, it **HAS NO PASSWORD AND AUTO LOGS IN**!!!

In absolutely no circumstances should you allow a `liveuser` account to persist onto your actual hardware installation of any kind of Linux **EVER**. 

- Just enter in the same account name you created, for the guide we made `vmTestAccount`

- **type in the account name**, then hit `Enter`, do the same thing for `Enter the new user's real name`

Finally, it will ask `Change the new user's password?`

- press `Enter` for `yes`

- type in the password you want for the vmTestAccount, make it something memorable not too complex just remember it

Almost lastly, it will ask about changing `sudo` access, we want option `2`: `Permit sudo for new user (and keep root account.)`

- press `2` and hit `Enter`

Actually lastly, it will ask `Change root password?`

- Technically your call, but I just enter in the same password that I set for my new `vmTestAccount` that was just created

When you're ready to move on to the next step, shutdown the VM:

```sh
sudo poweroff

#if the VM stalls here just hit Enter once or twice on it
```

## Step 9. Test the New "Test-Install" Watercraft System

### **From your bare-metal development machine:**


Run the same command we used to load the `live install` except without the `-cdrom` option which will effectively simulate removing a `live-usb` from an actual system

```sh
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -vga virtio \
  -bios /usr/share/ovmf/OVMF.fd \
  -drive file=test-install.qcow2,format=qcow2 
```
### **Once inside the VM Test-Install Installed System:**


Booting in it should say `Watercraft Linux` as the boot entry

If you get some I/O error just wait it out

Once on the login screen, login with the credentials you made during installation.

For this guide it's `vmTestAccount` and whatever `password` you set.

Once logged in you should see:

- No install desktop icon shortcut, only Partition Editor (`gparted`)
- No remaining `NOPASSWD` sudoers file
- latest `/rigging/` folder in `/usr/local/share/rigging/` with expected `sh` scripts and other stuff inside it

At this point you can also test any remaining things you may want to test on this build before installing the ISO to a bare-metal system.

In the case where something failed or that you are working on a potential update, and need to go back and re-do your ISO building, just `sudo poweroff` the VM, delete the `test-install.qcow2` image and then run `./POST_CLEANUP_RESTORE.sh`, then you can boot into the builder VM and repeat from step 2. and/or apply your updates again


## Known Upstream Issues:

Workarounds were made to most of these in our install process but still worth reporting:

- **`grub-install` runs with empty options** unless `media_opt` is set in
  `/etc/refractainstaller.conf`. 
    - Default produces an install with no `EFI/BOOT/BOOTX64.EFI`
    - won't boot on firmware without persistent NVRAM. 
    - Set `media_opt="--force-extra-removable"`.
- **`cleanup-install.sh` ships non-executable**, so the post-install hook
  never runs even with `run_postinstall="yes"`.
- **The installer's rename step breaks if the live user isn't UID 1000.**
    - It greps `/etc/passwd` for `1000:1000` 
    - anything else leaves the variable empty and `usermod -l` fails with a usage dump.
- **live-config writes a malformed `/etc/sudoers.d/live`** when
  `username=` is empty on the kernel command line. Noisy but not fatal.
- **The GUI installer can hang on the locale dialog** circumstances not nailed down yet, 
    - a killed run leaves a debconf lock that blocks the text installer until
  reboot. 
    - `pkill` isn't sufficient. 
    - the `Install to Hard Drive` in our installer functions by calling `sudo refractainstaller` and the GUI works OK
    - pretty sure the broken circumstance is running outside of sudo  

