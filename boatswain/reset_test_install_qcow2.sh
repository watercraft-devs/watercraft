#!/usr/bin/env bash
set -euo pipefail

DISK="${DISK:-$HOME/test-install.qcow2}"
SIZE="${SIZE:-20G}"

hail() { echo; echo "== $*"; }

if pgrep -f "$DISK" >/dev/null; then
	printf "Process still open! Shut down the VM before running.\n">&2
	exit 1
fi

printf "\nwiping $DISK\n"
rm -f "$DISK"
qemu-img create -f qcow2 "$DISK" "$SIZE"

printf "\n$DISK RESET COMPLETE\n"

qemu-img info "$DISK" | sed -n '1,4p'
