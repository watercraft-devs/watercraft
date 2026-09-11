#!/usr/bin/env bash

chmod +x ./comandeer_sudo.sh
./comandeer_sudo.sh

sudo apt install vim openssh-server git tmux rsync htop etckeeper

chmod +x ./dev_provisions.sh
./dev_provisions.sh --refracta --qemu
