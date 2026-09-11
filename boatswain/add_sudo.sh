#!/usr/bin/env bash

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
        echo "needs sudo perms" >&2
        exit 1
fi

TARGET_USER="${1:-${SUDO_USER:-$USER}}"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
        echo "USER '${TARGET_USER}' doesn't exist." >&2
        exit 1
fi

SUDOERS_FILE="/etc/sudoers.d/90-${TARGET_USER}"

echo "${TARGET_USER} ALL=(ALL:ALL) ALL" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"


if visudo -cf "$SUDOERS_FILE"; then
        echo "Added ${TARGET_USER} to sudoers via ${SUDOERS_FILE}"
else
        echo "Syntax Error... removing file" >&2
        rm -f "$SUDOERS_FILE"
        exit 1
fi
