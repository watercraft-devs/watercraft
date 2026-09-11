#!/bin/bash
# for yarr sea shanties and such
# entertainment package install helper
y=""
if [[ "$1" != "" ]]; then
	if [[ "$1" == "-y" ]]; then
		y="-y"
	fi
fi

printf "\n\n\n\n\n\n\n\nMandatory Software Disclaimer: \n
Spotify is installed from its own apt repository and signed with its own gpg key.\n
Adding their key and installing Spotify implies you trust this chain of verification from them for this installation and future Spotify upgrades.\n
It will be upgraded alongside your other system packages when you run apt upgrade.\n
Spotify's client is proprietary / non-free software.\n\n\n\n"
read -p "Do you want to install Spotify? (y/n): " spotify_yn
case "$spotify_yn" in [Yy]|[Yy][Ee][Ss])
	curl  https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg ;
	echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list ;
	sudo apt update ;
	sudo apt install spotify-client "$y";
	#verify gpg keys landed properly
	ls -la /etc/apt/trusted.gpg.d/spotify.gpg ;
	gpg --show-keys /etc/apt/trusted.gpg.d/spotify.gpg ;
	read -p "Create a Spotify desktop icon? (y/n): " sds_yn
	case "$sds_yn" in [Yy]|[Yy][Ee][Ss])
		cp /usr/share/applications/spotify.desktop ~/Desktop/ ;
		chmod +x ~/Desktop/spotify.desktop ;
		printf "Spotify Install Finished!\n" ;;
	*) printf "Spotify Install Finished!\n" ; 
	esac ;;
*) printf "NOT INSTALLED: Spotify\n" ;;
esac

#Terminal Toys
read -p $'Do you want to install Terminal Toys? (cowsay sl fortune-mod cmatrix lolcat)\n\n(y/n): ' tt_yn
case "$tt_yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install cowsay sl fortune-mod cmatrix lolcat "$y";;
*) printf "NOT INSTALLED: Terminal Toys (cowsay sl fortune-mod cmatrix lolcat)\n" ;;
esac
###

#Project M (Old school OpenGL based Audio Visualizer)
read -p "Do you want to install Project M? (y/n): " projmyn
case "$projmyn" in [Yy]|[Yy][Ee][Ss])
# Requires VLC ?
	sudo apt install  projectm-sdl projectm-data libprojectm3 projectm-pulseaudio "$y";;
	#TODO: pulseaudio may not be the correct audio driver for other systems, needs porting
*) printf "NOT INSTALLED: Project M\n" ;;
esac

printf "\n\n\n\n\n\n\n\n\n\nMandatory Software Disclaimer: \n
If installed, Discord will be installed using Flathub, not directly.
Therefore it needs Flatpak, it WILL INSTALL Flatpak if you don't have it yet. (few hundred MB)
The Flathub package is a community-maintained wrapper around Discord's official binary.
It is signed and verified by Flathub.
It is not endorsed by Discord.
It is SANDBOXED which gives it limited filesystem access by default.
We're choosing to use the Flatpak because of this feature alone.
The sandbox breaks the drag-and-drop files feature, and workarounds to that break grant Discord access to your /home directory.
That would defeat the whole purpose of sandboxing, so we recommend users only do that if it's absolutely necessary and know how to turn it off when not using that feature too.
Discord is proprietary / non-free software. \n\n\n\n"

#Discord
read -p "Do you want to install Discord? (y/n): " discord_yn
case "$discord_yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install flatpak "$y";
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo ;
	printf "IF IT BREAKS HERE JUST RE-RUN! (glitch with first time flatpak remote-add since it's a chicken or egg situation as to whether flatpak gets installed on the system or not, Discord is only thing that uses it and likely only amusements will use it in the future)" ;
	flatpak install flathub com.discordapp.Discord	;;
*) printf "NOT INSTALLED: Discord\n" ;;
esac

