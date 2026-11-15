#!/usr/bin/env bash
Y=""

full_upgrade() {
	sudo apt update && sudo apt full-upgrade "$Y"
}

if [[ $1 != "" ]]; then
	if [[ $1 == "-y" ]]; then
		Y="-y"
		if [[ $2 == "--full" ]]; then
			full_upgrade
		fi
	elif [[ $1 == "--full" ]]; then
		if [[ $2 == "-y" ]]; then
			Y="-y"
		fi
		full_upgrade
	fi
fi
sudo apt update && sudo apt upgrade "$Y" 
