#!/usr/bin/env bash
DISK_NAME=devuan-boatswain
qemu-system-x86_64 \
    -enable-kvm -m 8192 \
    -smp 4 -vga virtio   \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file="$HOME"/"$DISK_NAME".qcow2,format=qcow2 \
    -netdev user,id=n0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=n0

