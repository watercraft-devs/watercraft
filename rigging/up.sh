#!/usr/bin/env bash
Y=""
if [[ $1 != "" ]]; then
	if [[ $1 == "-y" ]]; then
		Y="-y"
	fi
fi
sudo apt update && sudo apt upgrade "$Y" 
