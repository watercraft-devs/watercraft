#!/usr/bin/env bash
sudo umount /mnt/vm 
sudo qemu-nbd -d /dev/nbd0

