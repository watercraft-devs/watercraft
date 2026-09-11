#!/usr/bin/env bash
# adds boatswain to sudoers, necessary for any OS dev


ADD_BOATSWAIN="$USER"
BOATSWAIN_HOME="$HOME"

su - root -c 'cd "$2" && bash /root/build/rigging/add_sudo.sh "$1" ' -- sh "$ADD_BOATSWAIN" "$BOATSWAIN_HOME"





