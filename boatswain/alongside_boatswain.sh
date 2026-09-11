#!/usr/bin/env bash
sudo modprobe nbd max_part=8


DISK_NAME=devuan-boatswain

sudo qemu-nbd -c /dev/nbd0 $HOME/$DISK_NAME.qcow2



for i in $(seq 20); do
  [ -b /dev/nbd0p2 ] && break
  sleep 0.25
done
[ -b /dev/nbd0p2 ] || { echo "nbd0p2 never appeared" >&2; exit 1; }

mkdir -p /mnt/vm/

sudo mount /dev/nbd0p2 /mnt/vm/

#sudo cp /mnt/vm/home/snapshot/*.iso .
