# Installing Watercraft Linux via Live Install ISO

prerequisites:

- `20 GB` **TESTED MINIMUM** of available hard-drive/SSD space (SSD is recommended), if this is a workstation you will want much more space
- `1 GB` of RAM **BARE MINIMUM** but `2 GB` is the **RECOMMENDED MINIMUM** amount, ideally have upwards of `16 GB` for a modern desktop system running lots of applications if you are configuring a workstation.
- make sure `Secure Boot` is **OFF** in your BIOS 
- get a copy of Watercraft live install ISO [README Download Section](../README.md#download)
- verify your ISO: [VERIFY_ISO.md](VERIFY_ISO.md)

## Step 1. Flash a USB device with the Live Install ISO 

Reccomended: Use a spare SSD with a usb adapter instead of a thumb drive, works well and is much faster and more reliable
use a dedicated SSD for flashing stuff ideally

### Flash the USB device with the ISO


**HELPER SCRIPT** If you don't want to run dd yourself like this (understandable) we have a helper script that makes the process extra careful and interactive from the CLI. Find it at `rigging/careful_dd.sh` in this repo.
`careful_dd.sh` **CURRENTLY ONLY WORKS IF YOU HAVE ONE USB DEVICE (the one you're dedicating for the iso flash) ATTACHED TO YOUR CURRENT SYSTEM, if not you MUST do it manually**:


1. run this command to see all USB devices plugged into your system:

    ```sh
    lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN | grep 'usb'
    ```

2. find your desired USB device and triple check that you know the listed one matches the desired one, if you only have one plugged in this step is basically nothing
    - the `NAME` output is what you need to hold on to, for this guide we will refer to it as `USB_NAME`, yours will look like `sdc` or something similar


    obviously, again, this USB device needs to be empty and dedicated for ISO flashing, if it's not put one in that is before proceeding.

3. run `dd` against the device to flash the ISO on to it:
    ```sh
    sudo dd if="        ISONAME     " of=/dev/USB_NAME bs=4M status=progress oflag=sync
    ```

Once finished, eject and remove the USB drive.

You can also try to use dedicated flashing software to do this, but only at your own risk, we won't recommend them here for unverifiability reasons and other concerns.



Live Install ISOs are provided with source control releases or from mirrors.

## Step 2. Live Installation Process

Power off the destination system that you want to install to

Plug the USB device into the most convenient direct-motherboard-connected USB port you have on your destination system
(Use USB 3.0 if you have it)

Boot the system up, if it's a dual boot you may have to select the USB drive as the priority boot device from BIOS

Once booted in, try out the live installation to see how it will run on the destination system if you'd like.

**Click the "Install to Hard Drive" Desktop Icon to start the actual installation process when you're ready to go.**

### tzdata 

- not strictly necessary to be accurate 
- may be important depending on applications you run or your own personal preferences

Simply fill out each screen as you like and press `Next` when done:

`Geographic area` -> `Time Zone`  

### locales

here **don't select ANYTHING** !

encountering consistent freezes when we do, and install works perfectly fine without it

Select nothing, press `Next` for both screens:

`Locales to be generated` -> `Default locale for the system environment`

### keyboard-configuraton

if you KNOW you need something specific here, feel free to configure it (probably doable post-install anyway)
otherwise just hit `next`, it will cover the vast majority of computer users 

### partitioning your system (DUAL BOOTERS BE CAREFUL HERE!)

If you're **NOT DUAL BOOTING** you should see a prompt like `There is no EFI partition. You will need to create one`

If you **ARE DUAL BOOTING** you will already have an EFI partition so it will say something slightly different, regardless **do not create another EFI Partition or erase your existing one**. You will still need to create a `linux-swap` partition and an `ext4` partition for the installed system to live on. Only follow those partition creation steps if you are dual booting.



- Select `2` to continue

Then another prompt to pick the partitioning tool, for this doc we're going with `GParted`

- Select `1` for `GParted`

### GParted System Partitioning Steps:

***this can vary but we will provide a version that should work for basic installations here***

***only do a custom installation that diverges from this one if you know EXACTLY what you are doing!***

**THIS INSTALL GUIDE ASSUMES A READY INSTALL DISK `/dev/sda` THAT HAS NOTHING ON IT AND CAN BE USED SAFELY FOR INSTALLATION**

**REMINDER**: If you **ARE DUAL BOOTING** you will already have an EFI partition so **do not create another EFI Partition or erase your existing one**. You will still need to create a `linux-swap` partition and an `ext4` partition for the installed system to live on. Only follow those partition creation steps if you are dual booting.

**IF YOU ARE INSTALLING A DUAL BOOT ON ONE DRIVE, TO FOLLOW THIS GUIDE YOU MUST HAVE NON-PARTITIONED STORAGE SPACE AVAILABLE. THAT SPACE CAN BE TREATED LIKE `/dev/sda` IN THIS EXAMPLE, DO NOT FOLLOW THE EFI BOOTLOADER PARTITION CREATION STEP BECAUSE YOUR DUAL BOOT ALREADY HAS ONE**

**IF YOU ARE INSTALLING A DUAL BOOT ON A NEW DRIVE, THE NEW EMPTY DRIVE CAN BE TREATED AS `/dev/sda` IS TREATED IN THIS GUIDE, AGAIN DO NOT FOLLOW THE EFI BOOTLOADER PARTITION CREATION STEP, YOUR DUAL BOOT ALREADY HAS ONE**


**DUAL BOOTERS USING THE SAME DRIVE FOR TWO INSTALLATIONS SKIP STEP 1!!!**
**DUAL BOOTERS WHO DO HAVE A DEDICATED NEW EMPTY DRIVE MAY NEED TO DO STEP 1 ON THAT DRIVE IF IT ISNT PARTITIONED YET**

1. Top Bar: `Device` -> `Create Partition Table` (make sure the correct disk is selected `/dev/sda/` here)
    - Select new partition table type: `gpt`
    - **REMINDER DUAL BOOTERS WHO ARE USING A SINGLE DRIVE FOR MULTIPLE INSTALLATIONS DON'T DO THIS AT ALL**
    - hit Apply
2. Icon-Button Bar: Click the first icon (Page with a star) `Create a new partition in the selected unallocated space` button

3. Create a new Partition Window:
- EFI System Partition (**DUAL BOOTERS DON'T DO THIS STEP! ONLY FOR MACHINES WITH NO BOOTLOADER YET!**)
    - New size (MiB): `512`
    - File system: `fat32`
    - REMINDER WARNING: DUAL BOOTERS DON'T DO THIS
    - Click `+ Add`
**DUAL BOOTERS MUST DIRECT THE INSTALLER TOWARDS THEIR EXISTING EFI / ESP-FLAGGED PARTITION LATER IN THE INSTALLATION** (`Final shell installer steps` -> `2.`)

Click the same icon to get back into the `Create a new Partition Window`

- Linux Swap Partition
    - New size (MiB): `16384` **Assumes 16GB of RAM on system**
        - respective RAM to MiB sizes: 
            - RAM: `64GB`, `32GB`, `16GB`, `8GB`, `4GB`, `2GB`, `1GB` 
            - MiB: `65536`,`32768`,`16384`,`8192`,`4096`,`2048`,`1024` 
    - File system: `linux-swap`
    - Click `+ Add`
    
Click the same icon to get back into the `Create a new Partition Window`


- Rest of the system
    - New Size: Whatever amount of space you want your Watercraft system to have, leave as is for it to take up the rest of your space. (Recommended minimum is 32GB, going below that is not guaranteed to work well for actual usage)
    - File system: `ext4` (should be default)
    - Click `+ Add`

4. Apply the operations by hitting the green checkmark in the Icon-Button bar

- Once finished, close the `Applying pending operations` window
**DUAL BOOTERS ARE DONE HERE, THEY CAN CLOSE GPARTED RIGHT NOW**
- If you are **NOT DUAL BOOTING** right-click the `fat32` filesystem partition we created (the first one, `/dev/sda1` in this example, the EFI partition
    - Select `Manage Flags` -> Select the `esp` checkbox
5. Close out of GParted

### Final shell installer steps

1. Hit `Enter` once out of GParted (it will prompt you to do so)
2. Enter the device name for the EFI partition to use
    - `/dev/sda1` in this example
3. Hit `Enter` to skip past the "Separate partition for /boot" prompt
4. For the installation of the operating system, give the device name that has the "Rest of the system" partiton allocated to it
    - `/dev/sda3` in this example
    - it will ask for filesystem type, choose `ext4` (assuming you're on ext4)
5. Answer whether you want the OS on an encrypted partition, for this guide we're just saying `2` for no to keep it simple
6. Hit `Enter` to skip past the "Separate partition for /home" prompt
7. Enter the device name for the linux-swap
    - `/dev/sda2`
8. Hit `Enter` to allow fstab to use UUID to ID filesystems
9. Modify the hostname to your new desired hostname
10. If you did everything properly up to here, enter `1` to proceed with the installation
11. When prompted `Disable auto-login?` hit `Enter` for `YES`
12. Enter `2` for Install bootloader and finish the installation
    - If it breaks here you most likely restarted the installer without rebooting
13. Configure your username for the new system, enter whatever you want it to be
    - same with user's real name, whatever you want
14. Change the password for your new system **MANDATORY** press `Enter` for `YES` and follow the instructions
    - Refracta annoyance: if you misspell the re-entry of your new password, the whole password process will fail
    - to fix it while you're still on the liveuser/liveusb installer system, open a terminal and do this:
    ```sh
        sudo chroot /target YOURNEWPASSWORDHERE USERNAMEHERE
    ```
    - to set password from the installed system do this: `passwd`

    **DO THIS IMMEDIATELY, VERY UNSAFE TO HAVE A PASSWORDLESS SYSTEM ACCOUNT**

15. On the next prompt, enter `2` for `Permit sudo for new user(and keep root account.)`
16. On the `Change root password?` prompt, press `ENTER` for YES
    - follow the instructions, change it to same as new system password or something else if you want
    - **IMPORTANT**: If you fail to change the root password here, your installed system will be left without a root password
    - If you want a root password, on the new system run `sudo -i` and then `passwd root` in a terminal once you're booted in


**If you make a critical mistake during the install configuration and need to restart, the best way is to restart the entire system**

**That's because the live disk is not persistent and full system restart will erase any memory holding bugged-data, running refractainstaller with the bugged data present can critically break your desired installation.**

**IMPORTANT NOTICE: If your installer shuts down before it prompts you to reset the system passwords (due to a bugged-data state)**

- this implies it already started writing to the partitions, meaning the partitions now contain a broken installation. 
- In this case you must wipe the partitions you created and start over from square one. 
    - **(Unfortunate but unavoidable with this series of state changes)**


## Step 3. Voyage onward with your newly installed Watercraft Linux System

1. Poweroff the live installer:
    - open a terminal and `sudo poweroff`
    - or click `liveuser` in the top right then select `Shut Down` from the options

2. Once powered off, remove Live Installer ISO USB device physically from your system.

3. Boot the system back on.
    - If you are dual booting and it boots into your other system, change the primary boot drive to the new Watercraft linux drive in your motherboard's BIOS
    - If the install fails to boot, please reference: [/docs/trouble_booting.md](/docs/trouble_booting.md) for remedies

4. Log In with the account user name and password you just made during installation
    - After this step if you don't have ethernet access, connect to your wifi network before trying to install anything to save yourself some potential headaches. Network gui tool is just to the right of your workspaces on the right side of the top-bar. 
5. Run some recommended/optional scripts that come with Watercraft:

#### The `.sh` files can be found in `/usr/local/share/rigging/`

run `cp -r /usr/local/share/rigging/ ~/` to have them all on your home folder

To run individual files, it's recommended to `cd` to the `rigging` folder and then you can execute them with the `./` prefix.
 

- `./fresh_install_ok.sh`
    - just displays your disks and usage and pings deb.devuan.org to check network connection
    - if it all looks good consider your install a success
- `sudo apt update && sudo apt upgrade -y`
    - only works if network is up (checked with `fresh_install_ok.sh` ping)
    - may be necessary depending on the package state
    - if provisioning scripts or other installations fail, it's likely because you need to upgrade with these commands
- `./provisions.sh`
    - this is the default biased configuration for Watercraft but it doesn't send `-y` to `apt` package install commands, leaves interaction up to system owner 
    - some essential things, such as tiling congfiguration, brave-browser, VLC, etc...  will happen automatically without any prompt here, just take notice of that
        - (if you really hate some of these things for whatever reason, you can always uninstall or unconfigure them afterwards)
    - installs some basic packages and vulkan GPU drivers (prompts you for AMD or Nvidia)
    - will ask if you want some custom shell commands used by Watercraft maintainers
    - configures window tiling for you automatically, will be home to other biased configurations in the future
- `./dev_provisions.sh`
    - 100% interactive won't install anything if you don't enter `y`
    - helps install stuff for building out Watercraft further / maintaining it 
    - also installs non-Watercraft-specific developer-packages relating to any other practical high-utility thing that many developers may want and/or need on their Linux system
    - genuinely open to a wide variety of possibilities for future inclusion here but only things that are practical and well utilized
- `./amusements.sh`
    - this is where packages that are largely and/or solely used for entertainment value get installed
    - things like `Spotify`, `Discord`, `cowsay`, `Project M`, etc...
    - obviously means this is also implicitly 100% interactive, none of this should be forced on anyone's system EVER
    - but it includes things many Linux users may want frictionless access to at the same time
    - things like `Discord` with sketchy unsigned binaries should use Flatpak for its sandboxing in this script


    
### **Otherwise your system is now ready to use however you want to.**

### **Customize and enjoy, submit feedback, bugs, improvements, or any other positive contributions.**

### **We welcome any developers who support our mission.**
