# Watercraft (GNU + Linux)


## *Updated: 2026-11-1*

### A `Devuan`-based GNU + Linux Desktop 

Watercraft comes with convenient shell scripts, 
intended to assist with configuring entire development, workstation, and/or entertainment systems.

No build system forced onto users, no runtime beyond `bash`, no pre-generated config ambiguity, 
everything the scripts do are transparently presented to the end user.

(As of right now anyone can read the shell scripts front to back in an afternoon)

Built for unique use-cases, needs, and ideals: 

-  minimizing and/or eliminating dependence on decisions made by systemd, debian, ubuntu, gnome, etc...  
-  having a development system with a low surface area of complexity but also high stability
-  ensuring broad GPU driver support for both graphical development and entertainment usecases
-  having a pathway to high-customization + simplicity at all levels, remove gatekeeping from Linux system configuration
-  nurturing an environment that supports organic contributions to Linux operating systems, 
prioritizing BOTH end user freedom and convenience without making a false dichotomy between them (which leads to gatekeeping)

### IMPORTANT SECURITY UPDATE: NEW AS OF Oct 29 2026: CVE-2026-98432 affects the Linux kernel that ships with this Watercraft 0.1.1 ISO!
Check your kernel version:
```
uname -r
```
If it prints anything lower than: `6.12.113+deb13-amd64` you are vulnerable.
To patch the vulnerability simply upgrade your kernel with these commands:
```ssh
sudo apt update && sudo apt full-upgrade
```
Then reboot your system for it to take effect:
```
sudo reboot
```
Log in, then check afterwards that the correct kernel is being used:
```
uname -r
# Should print 6.12.113+deb13-amd64 as of Oct 29 2026
# Will be a higher kernel version in the future
```
If it prints the expected version `6.12.113+deb13-amd64` you are patched.

If it does not, you may need to run `sudo dpkg --configure -a` to fix an interrupted install.

After that, run `sudo reboot` again, after logging in check that the correct kernel is being used as directed above.

If it STILL shows the old version try to update grub, then reboot and check again:

```sh
sudo update-grub
sudo reboot
```
...log in...
```
uname -r
# Should print 6.12.113+deb13-amd64 as of Oct 29 2026
# Will be a higher kernel version in the future
```



**ATTENTION: version 0.1.0 has been officially superseded by 0.1.1 due build-time sudo rules persisting onto the installed system**

If you left the default name and your account is named `liveuser` will have passwordless root which is not secure for an actual installation.

The builder account persisting is also insecure as it does not have a secure password. 

If you are on `0.1.0` follow this mitigation:
```sh
# 0.1.0 left two sudo rules for the Live Install account 'liveuser' and builder account 'boatswain'
# If you built from scratch you have to change boatswain to your build account name
# this script grep matches the files by content and then removes them from sudoers.d
sudo grep -lE '^(boatswain|liveuser)[[:space:]]' /etc/sudoers.d/* | xargs -r sudo rm
sudo visudo -c
```

---
## System Requirements


### UEFI firmware 

- UEFI firmware is required
- Secure Boot must be disabled 

### Disk Space

- **20GB** *Bare Minimum (tested)*
- **32GB** *Comfortable Realistic Minimum*

### RAM

- **2GB** *Bare Minimum*
- **4GB** *Recommended Minimum*

### Compatible Platforms

- 64-bit x86 (amd64) 
    - Covers almost every Intel and AMD CPU from ~2006 to now

### Incompatible Platforms

- 32-bit x86 
    - Devuan is downstream of Debian Trixie dropping the i386 kernel and installer
    - i386 packages exist in the repositories but have no kernel to boot with
- ARM, RISC-V or PowerPC
    - Supported on Devuan through its own installer images
    - Watercraft inherits the Devuan amd64 install as of right now
    - Contributors are welcome to help do the work required to port Watercraft to more architectures
    - Lack of support is limited by ready access to specific hardware for testing and impact on iteration times with a small team
---
## GPG Fingerprint

```
2D77 384D 04C6 968E 1FBF  E957 6066 E450 9E00 ED74
```

This is the fingerprint of the key that signs Watercraft releases and commits. 

---
## Download
Download the release, gpg key, and checksum files here:
```
https://phosphene.xyz/releases/watercraft/ketch-0.1.1/
```

| File | Description | Link | 
|---|---|---|
| `watercraft-0.1.1-ketch-amd64.iso` | Watercraft 0.1.1 (Ketch) release ISO image | [watercraft-0.1.1-ketch-amd64.iso](https://phosphene.xyz/releases/watercraft/ketch-0.1.1/watercraft-0.1.1-ketch-amd64.iso) | 
| `SHA256SUMS` | checksum file | [SHA256SUMS](https://phosphene.xyz/releases/watercraft/ketch-0.1.1/SHA256SUMS)  |
| `SHA256SUMS.asc` | gpg signed checksum file | [SHA256SUMS.asc](https://phosphene.xyz/releases/watercraft/ketch-0.1.1/SHA256SUMS.asc) | 
| `watercraft-public.asc` | gpg key used to sign the release | [watercraft-public.asc](https://phosphene.xyz/releases/watercraft/ketch-0.1.1/watercraft-public.asc)  |

To download all of these files at once from the terminal:
```sh
wget -r -np -nH --cut-dirs=1 -R "index.html*" -e robots=off  https://phosphene.xyz/releases/watercraft/ketch-0.1.1/
```
This will copy them into directories `watercraft/ketch-0.1.1/` from whatever path you call them in, so if you do it from `~/` they will land in `~/watercraft/ketch-0.1.1/`

If you want to make your own directory and have them land in there directly, make that directory and `cd` to it, then just run the same thing with the `-nd` "no directories" flag added to the end:

```sh
wget -r -np -nH --cut-dirs=1 -R "index.html*" -e robots=off -nd https://phosphene.xyz/releases/watercraft/ketch-0.1.1/
```

### **Verify the integrity of your Watercraft ISO download by following the steps listed here: [VERIFY_ISO.md](docs/VERIFY_ISO.md)**


### **We strongly encourage every user to verify their Watercraft ISO before installation in order to prevent MITM attacks!**

#### NOTE: for building from source in 0.1.1

Watercraft 0.1.1 is built with `refractasnapshot` and `refractainstaller` tools.

These tools are dated and cause the build process to be more interactive / involved than should be necessary, therefore building from source is unfortunately not a recommended path yet. 

Long term we would like for it to be an easy option for any end user, we are fully reworking our build process to make it easier to build Watercraft from source and also make the ISO fully reproducible at the same time.

Right now the ISO that you reproduce will not be identical to the one in the release, because `refractasnapshot` captures build system artifacts (such as timestamps, package install order, inode layout, and any other accumulated state from the build system) which will never be the same from one build to the next.

If you are absolutely determined to build from source instead of just downloading a verifiable ISO release file, you can follow the process here: [BUILD.md](docs/BUILD.md)

---
## ISO Installation



( Remember to try out on a VM if you're skeptical )

NOTE: The Watercraft install is able to be done fully offline, however in order to accomplish this for laptops without ethernet we shipped common (non-free) wifi firmware with the installer. These firmware can be removed by the user in 0.1.1 post install only, in future versions we will make them totally optional due to their non-free categorization. 

see: [docs/INSTALL.md](docs/INSTALL.md) for more specific instructions

General Install Instructions:

- Boot the system with the ISO
  - On VM just target the ISO
  - On baremetal flash the ISO to a USB device and boot from it via bios
- Should autologin as liveuser, with Installer and Partition Editor (gparted) shortcuts on the desktop 
- If you know exactly how your system should look, pre-partition it with the Partition Editor (gparted or a tui one of your choice)
- Otherwise the Installer will prompt you to do so when it needs it at the beginning of the install (works fine)
- Click the Installer shortcut (calls `sudo refractainstaller`) and follow the instructions
- `refractainstaller` is a dated tool that doesn't capture the entire instllation process in a GUI, a major part of it is in the terminal and is prone to bugs or glitches (we have a roadmap towards repurposing it for a better use-case while also developing a more modern ISO generating tool for main Watercraft releases)
- the install guide is highly recommended to reduce confusion

---
## Distro Lineage

```
Debian -> Devuan -> Watercraft
```

### Debian -  The 'Grandfather' of Watercraft

- Debian is the source of most packages we inherit
- Many are unmodified between there and here because most packages are agnostic to the init system, window manager, etc... 
- However for relevant packages, Debian's `Trixie` release is tracked by Devuan's `Excalibur` release

### Devuan -  The 'Direct Parent' of Watercraft

- Devuan is what allows us to inherit init-freedom since their core work is removing systemd dependency 
(we are eternally grateful)
- They accomplish init-freedom by dependency patching the packages they track from Debian, and applying any other init related component replacements necessary
- this allows all of OUR (Watercraft's) packages to come from `deb.devuan.org`

---
## What it is and what it's not

### Watercraft IS
- Devuan Excalibur base, pinned to the codename rather than `stable` branch
- sysvinit system: as a distribution-wide-stance, Watercraft is fundamentally opposed to systemd or anything that functions similarly to systemd as an option for an init system. The reasons as to why shall be divulged officially here: [why_no_systemd.md](why_no_systemd.md).

- XFCE on X11
    - this is subject to change with advancements in XLibre or other similar projects
    - users should be able to configure any windowing systems or display systems that they want assuming those systems are coherent with the rest of the OS

    - (but for the time being, users should assume XFCE on X11 will provide the most stability here and only proceed elsewhere if they are willing to blaze their own trail, or even better contribute any needed support back to the Watercraft distribution.)
    - not chosen for preference, chosen for boring functionality and stability

- (As of right now) everything above the base install is just a shell script
- Ships with a `liveISO`/`liveUSB` installer
    - allows you to test the OS before installing it on your hardware
    - based on refractainstaller (don't expect anything too shiny, don't give to your grandma quite yet)
    - Potential Contributors Please Note: 
        - The live iso process can still use lots of polishing
        - It was a large venture to get it to the PoC state it's in right now
        - Check [dev/iso_dev_2026.md](dev/iso_dev_2026.md) for a more detailed list of the things we encountered when fixing stuff up,
don't hesitate to comment and contribute things based on your knowledge of the underlying infrastructure
- Meant to stay entirely fixated on minimizing instability by targeting system design choices that are deemed frivolous or otherwise unacceptable and circumventing them as much as possible

### Watercraft IS NOT
- Watercraft IS NOT a stability guarantee (for now...)
    - currently, we just track stock Devuan repositories
    - pinning to `Excalibur` implies you won't be moved to a new release until you choose to
    - we have the goal to provide a fully verified/validated package set that can provide more guarantees for end users
but this is NOT the current state, so please do not assume we will accomplish it until it happens
- Watercraft IS NOT externally audited whatsoever (as of 2026-08-09)
    - I am the only author right now. 
    - You are as always implored to read everything before you run it on your system. 
    - Critically Important: 
        - if you are doing experimental development work, ALWAYS do such things in a contained VM. 
        - Normal users who are skeptical are also implored to use in a VM before feeling comfortable to do a bare metal install
- Watercraft IS NOT a "one-size-fits-all" distro
    - This is an opinionated setup meant for like-minded developers and users, some things are very up for discussion others aren't
    - Contributions are judged based on merit and the steps towards our symbiotic goals of user-freedom and pragmatic development environments for all



Watercraft IS ONLY meant to stick to the core GOAL (not immediate guarantee) of stability, stick to what works and never clobber the user experience 

---    
## Some Reasons Watercraft Exists 

Beyond needing my own development machine configured the way I want

- Non-systemd Linux needs MORE maintainers, and we don't want Devuan's small but mighty team to be swamped with all the work

- Supporting resistance to **any upstream-mandated language rewrites** of core-utils or otherwise, whether the language be Rust or anything else that is unstandard to Linux historically

- Display server transitions are genuinely breaking the Linux user-experience, and that is obviously bad.
    - X11 is the protocol server default that nearly everything still targets, for good reason
    - Xorg is simply X11's reference implementation, and has maintenance concerns
    - XLibre is a fork of Xorg (we are surveying it openly in the case it becomes more dependable)
    - Wayland is an entirely different protocol with a different set of gaps to fill
    - Regardless of which of these protocols ends up "winning" with Linux users long-term, 
moving in between them while minimizing the breakage of user experience is an obvious goal that people who want to see Linux succeed should have
    - We will put lots of effort into filling the cracks in the display server pavement, not only for others but so our own systems stay functional

---
## Governance Related Information


- The motivations for supporting resistance to any upstream-mandated language rewrites are derived from expressions of concern from grass-roots Linux-user community members that Watercraft maintainers share sentiment with or outright agree with.

- Decisions about Linux core system component changes/updates/upgrades etc... will be gauged against community sentiment (expressions of concern or support) prior to any discussion of their potential merit upon inclusion into this distribution, with executive decisions being ultimately made by Watercraft maintainers (just the reality of the situation, not technically a policy).
    - Changes to core system components are rightfully controversial, they can break people's systems easily.

- All discussions about Linux core system component changes/updates/upgrades etc... will be held **PUBLICLY** and promoted for engagement **AMONGST COMMUNITY MEMBERS**. 

---
## Related Work

### systemd-entanglement Audit Harness 
(github link soon...)

- In early development, separate repository
- Measures depth of dependency from Debian source packages on systemd
- Emits a structured dataset of findings, doesn't provide patches/solutions (just an observational layer)
- All findings are ID'd according to a taxonomy and recorded, including clean passes
- Proposing fixes is later work, to be done programmatically based on the inputs generated in this audit layer 
- Not Devuan-bound, any non-systemd project can inherit from this theoretically making it agnostic to the overall project

---
## Structure
```
rigging/            payload - scripts shipped to installed system, 
totally optional, never ran at build time

boatswain/          build-time - builder VM setup scripts, 
to build the distro from source you can install a fresh clean Devuan system 
and then run the appropriate scripts (exact build steps TODO)

docs/               documentation for the build process, known issues, etc...
```

Key Distinctions:

- Build-time: 
    - the minimal set to boot a desktop, partition a disk, run the installer, produce snapshots, things of that nature
    - doesn't include anything unrelated to the bare necessities of developing and building for the next Watercraft release

- Payload:
    - All the optional scripts that you can install as a feature or flavor of the Watercraft operating system package
    - Just the scripts you need for executing these custom configurations are simply copied into the install, they are NEVER ran forcefully
    - More convenient scripts will be optimized and delivered as they are developed
    - Intended to deliver only what the user wants and expects on their system, heavily interactive to prevent any unwanted installations
    - We keep in mind that if this system is to be installed on a wide variety of machine-setups, its core should be agnostic to what its ultimate user-configured use case can be

IMPORTANT:

- Any item that cannot be cryptographically verified according to existing standards is PROHIBITED from shipping in the base image

---
## Building from Source
see: [docs/BUILD.md](docs/BUILD.md)

Watercraft 0.1.1 is built with `refractasnapshot` and `refractainstaller` tools.

These tools are dated and cause the build process to be more interactive / involved than should be necessary, therefore building from source is unfortunately not a recommended path yet.

Long term we would like for it to be an easy option for any end user, we are fully reworking our build process to make it easier to build Watercraft from source and also make the ISO reproducable when doing so.

Right now the ISO that you reproduce will not be identical to the one in the release, because `refractasnapshot` captures artifacts such as timestamps which will never be the same from one build to the next.

basically you install a clean Devuan system (IN A VM CONTAINER!!!) run the necessary scripts, go through the clean and snapshot process, and then TEST the iso you made on a separate VM partition before considering it a good build. afterwards you can install on bare-metal.

---
## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

- Everyone who is of the same goals as stated above is more than welcome to contribute to this project
- People who represent themselves as being directly opposed to the goals of this project for whatever reason will implicitly be unconsidered from potential contribution, Watercraft maintainers consider such behavior voluntary forfeiture of contribution admissibility
- REMINDER - The Basic Goal is: 
    - user freedom AND convenience with no false dichotomy to gatekeep the underlying system
- Linux should be a nice OS to use, not just the default free alternative to mainstream options

---
## License

 
GPL-3.0. 
---
