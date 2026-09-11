# Trouble Booting

This page contains documented booting issues we encountered during testing and how we resolved them.
If you have trouble booting Watercraft reference this guide for potential solutions based on your specific circumstance.

**Sections are organized based on what you will boot into upon failure.**

---

## UEFI shell (`Shell>`)

In this circumstance the machine's EFI Firmware found no bootloader.

To resolve this, plug in your Watercraft liveusb and then boot into it the same way you did when first installing.

Then open a terminal and check the EFI partition.

**Substitute the actual name of your EFI partition if it is not `/dev/sda1` like our example:**

```sh
sudo mkdir -p /mnt/esp
sudo mount /dev/sda1 /mnt/esp
sudo find /mnt/esp -name '*.efi'
```

If only `EFI/watercraft/grubx64.efi` is found with no
`EFI/BOOT/BOOTX64.EFI` (or if nothing is found), reinstall GRUB by chrooting in:

**(Again we are using example partition paths `/dev/sda1` and `/dev/sda3` if your Watercraft installation partition differs you must change it to your specific partition paths)**
```sh
sudo mount /dev/sda3 /mnt # the system installation partition
sudo mount /dev/sda1 /mnt/boot/efi # the efi partition
for d in dev dev/pts proc sys; do sudo mount --bind /$d /mnt/$d; done
sudo chroot /mnt

grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable
update-grub
exit

sudo umount -R /mnt
```

---

## GRUB rescue prompt (`grub>`)

This circumstance means that GRUB loaded but can't find the config. You need to manually set `prefix` and `root`.

Type `ls` to get a list of partitions available, then look through them to find your attempted installation:

**(The scripts below use `hd0,gpt3` as an example path, yours will likely be named differently. Ensure you are setting the proper path according to your system configuration)**
```
ls
ls (hd0,gpt3)/
```

You need to find the Watercraft partition showing `etc`, `usr`, `boot`. 
Once you find it, set its `prefix` and `root` and then run `insmod normal` and `normal`:
```
set prefix=(hd0,gpt3)/boot/grub
set root=(hd0,gpt3)
insmod normal
normal
```

Once booted, make it permanent by opening a terminal and running this:

**Again `/dev/sda1` is our example EFI partition path, if yours differs change it to your correct path**
```sh
sudo mount /dev/sda1 /boot/efi
sudo update-grub
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable
```

---

## Dropped to `initramfs`

In this case the Linux kernel failed to mount root.

Likely causes:

- `/etc/fstab` records a device path instead of a UUID and then the device names / paths changed in between boot cycles
- the `GRUB` kernel line records a device path instead of a UUID and then the device names / paths changed in between boot cycles

This was encountered on a Laptop with multiple NVMe drives installed onto it.

The device names / paths of NVMe drives on this particular laptop proved to be unstable, and likely behave similarly on other machines.

Run this command to find your root partition:

```
blkid
```

Once you've found it, mount it with these commands:

(`/dev/nvmeXnYpZ` is used as a boilerplate filler here, you must change it to your exact drive name)

```
mount -t ext4 /dev/nvmeXnYpZ /root
exit # exit will continue the boot sequence here
```

Once booted, remount root as writeable because it may be read only after running the previous commands:

```sh
sudo mount -o remount,rw /
```

Now to permanently fix it, edit `/etc/fstab` so the `root` and `swap` partitions use `UUID=` identifiers instead of device paths.
```sh
sudo vim /etc/fstab 
# open it with your editor of choice, we're using `vim` here. if you're unsure use `nano` instead maybe
```
If you see something like:
```
/dev/nvme0n1p3 /
```
Find the correlating UUID for that path (run `sudo blkid` to find all of them) and then set it in `/etc/fstab` like this instead:

```
UUID=REALUUIDGOESHERE /
```


Finally update the bootloader to confirm the changes:

```sh
sudo update-grub
```

---

## Other systems missing from the boot menu

```sh
sudo apt install os-prober
echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
sudo update-grub
```

If Windows still doesn't appear, check that the EFI partition wasn't
formatted during installation.

---

## Firmware shows a generic name like "Linpus lite"

That's your Watercraft entry. Firmware falls back to a generic label for
the removable boot path when there is no NVRAM entry to name. Select it.

To register a properly named entry:

```sh
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi \
    --bootloader-id=Watercraft
sudo efibootmgr -v
```

If `efibootmgr` fails with "No space left on device", NVRAM is full:

```sh
sudo rm -f /sys/firmware/efi/efivars/dump-*
```
