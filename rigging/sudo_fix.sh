#!/usr/bin/env bash
#if your user isn't in the sudoers group even though you added it, run this
#activates sudo perms without having to log out
#should be permanent after full log out log in cycle though
newgrp sudo
