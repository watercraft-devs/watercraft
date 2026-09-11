#!/usr/bin/env bash
#runs on HOST of QEMU VM (not the VM itself)
# run only when you want to rollback to the pre-iso-packaged state and develop the distro further
printf "\nTHIS WILL OVERWRITE YOUR CURRENT STATE ON THE DISTRO DEVELOPING VM, RESETS TO YOUR LATEST SNAPSHOT!!!\n\n\n"
read -p "PROCEED? : (y/n):  " restore_yn



DISK_NAME=devuan-boatswain
DISK=$HOME/$DISK_NAME.qcow2
LATEST=$(qemu-img snapshot -l "$DISK" | awk 'NR>2 {print $1}' | tail -1)
echo "RESTORING: $TAG #$LATEST"

if [[ "$restore_yn" == "y" ]]; then
	qemu-img snapshot -a $LATEST"" "$DISK"
else
	exit
fi
