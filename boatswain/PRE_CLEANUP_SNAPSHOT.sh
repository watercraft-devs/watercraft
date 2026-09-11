#!/usr/bin/env bash
#runs on HOST of QEMU VM (not the VM itself)


DISK_NAME=devuan-boatswain
qemu-img snapshot -c pre-cleanup "$HOME"/"$DISK_NAME".qcow2
qemu-img snapshot -l "$HOME"/"$DISK_NAME".qcow2



