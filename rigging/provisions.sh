#!/bin/bash

if [ "$(id -u)" -eq 0 ]; then
	printf "Root user detected, exiting..."
	printf "Run as normal user! Not as root!"
	printf "This script 'provisions.sh' touches configs like ~/.vimrc and installs packages with sudo where needed"
	printf "All provision type .sh files should be ran as normal user, not root."
	exit 1
fi

Y=""

if [ "$1" != "" ]; then 
	if [ "$1" == "-y" ]; then # pass -y as arg 1 to accept all apt installs automatically / non-interactively
		Y="-y"
	fi
fi


has_pkg() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "^install ok installed$"
}


read -p "Run apt update and upgrade? Necessary if you just installed the OS and haven't ran upgrade yet) (y / n): " aptyn

do_upgrade() {
	printf "\nUpdating and Upgrading!\n" 
        sudo apt update && sudo apt upgrade "$Y" 
}

case "$aptyn" in [Yy]|[Yy][Ee][Ss]) do_upgrade ;;
*) printf "Skipping Upgrade\n" ;;
esac

#basic packages
sudo apt install timeshift vim-gtk3 curl git wget cmake pkg-config openssh-client p7zip-full unrar-free valgrind "$Y"
###

get_desktop() {
	tasksel install devuan-desktop xfce-desktop
}

desktop_prompt() {
	read -p "Install Desktop? (y/n): " xfce4_yn
        case "$xfce4_yn" in [Yy]|[Yy][Ee][Ss]) get_desktop ;;
        *) printf "SKIPPING XFCE4 DESKTOP INSTALLATION\n" ;;
        esac
}

if has_pkg xfce4; then
	printf "XFCE4 DESKTOP INSTALLED\n"
else
	desktop_prompt
fi	


#let vim assume .sh is bash for syntax highlighting
#grep checks for the line before writing it in, idempotency
grep -q 'g:is_bash' ~/.vimrc 2>/dev/null || echo "let g:is_bash = 1" >>  ~/.vimrc 
###



# brave origin web browser (beta)
# 100% free on Linux
sudo curl -fsSLo /usr/share/keyrings/brave-browser-beta-archive-keyring.gpg https://brave-browser-apt-beta.s3.brave.com/brave-browser-beta-archive-keyring.gpg

sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-beta.sources https://brave-browser-apt-beta.s3.brave.com/brave-browser.sources

sudo apt update

sudo apt install brave-origin-beta

cp /usr/share/applications/brave-origin-beta.desktop ~/Desktop/

chmod +x ~/Desktop/brave-origin-beta.desktop
###



# additional QOL packages
sudo apt install htop fastfetch tree unzip zip rsync tmux smartmontools vlc mpv gifview chrony gparted "$Y"
###

# vlc desktop icon
cp /usr/share/applications/vlc.desktop ~/Desktop/
chmod +x ~/Desktop/vlc.desktop
###

# bulk firmware 
sudo apt install firmware-linux firmware-linux-nonfree firmware-misc-nonfree "$Y"
###


# vulkan core dev packages
#
#
printf "\n\n\nNOTICE:\n
Vulkan install may not fully succeed if you responded 'n' to the 'apt' firmware installs or the apt upgrade that was prompted earlier in the script.\n\n
If 'vkcube' fails to run, run this script again and make sure to respond 'y' to both prompts.\n\n
Alternatively if you know you want EVERYTHING this script installs via 'apt', simply provide '-y' as argument 1 when running this script, it makes the script mostly non-interactive other than testing vulkan install and providing gpu vendor.\n\n"

sudo apt install libvulkan1 libvulkan-dev vulkan-tools vulkan-validationlayers spirv-tools glslang-tools "$Y"


amd_vk_install() {
	printf "AMD GPU Chosen\n\nInstalling mesa vulkan drivers...\n\n"
        sudo apt install mesa-vulkan-drivers mesa-utils "$Y"
        read -p "Vulkan install finished, test install? (y/n): " yn
	case "$yn" in [Yy]|[Yy][Ee][Ss]) 
		printf "\n\n\nNOTE: Close spinning vkcube window to continue...\n\n\n" ;
		vkcube ;;
        *) echo "skipping vulkan test" ;;
	esac
}

nvidia_vk_install() {
        printf "\n"
        printf "==============================================\n"
        printf "NVIDIA driver requires contrib and non-free\n"
        printf "repositories, which are NOT enabled by default.\n"
        printf "\n"
        printf "This will add them to /etc/apt/sources.list.\n"
        printf "The driver is proprietary / non-free software.\n"
        printf "A REBOOT is required afterwards.\n"
        printf "==============================================\n\n"

        read -p "Enable non-free repos and install NVIDIA driver? (y/n) " yn
        case "$yn" in
                [Yy]|[Yy][Ee][Ss]) ;;
                *) printf "SKIPPING NVIDIA INSTALLATION\n"; return 0 ;;
        esac

        sudo sed -i '/^deb .*deb\.devuan\.org/ s/ main / main contrib non-free /' /etc/apt/sources.list
        sudo apt update

        sudo apt install -y linux-headers-amd64 nvidia-driver nvidia-vulkan-icd vulkan-tools --no-install-recommends "$Y"

        printf "\nREBOOT REQUIRED. nouveau is loaded until then.\n"
        printf "After reboot verify with:  nvidia-smi\n"
        printf "To manually check your Vulkan device enter the following into a terminal:       vulkaninfo | grep deviceName\n"
}


while true; do #while true good to use for things that are potentially mis-spellable, for yn it's too much
	read -p "AMD or Nvidia GPU? [for vulkan install] (amd/nvidia/skip(none or no install)): " gpu_platform
	gpu_platform=$(printf '%s' "$gpu_platform" | tr '[:upper:]' '[:lower:]')
	case "$gpu_platform" in  
		amd)  
			amd_vk_install ;
			break ;;
		nvidia) 
			nvidia_vk_install ;
			break ;;
		skip) 
			printf "Skipping GPU Vulkan setup...\n" ;
		       	break ;;
		*) printf "\nunexpected answer: %s\n" "$gpu_platform" ;;
	esac
done
###




# "present" command
present_path="/usr/local/bin/present"
if [ -f "$present_path" ]; then
	echo "present command already exists, skipping..."
else
	printf "writing present command...\n"
	sudo sh -c "echo 'clear && ls -lah --color=auto' >> '$present_path'"
	sudo chmod +x "$present_path"
fi
###

# ensure window tiling enabled 
xfconf-query -c xfwm4 -p /general/tile_on_move -s true
xfconf-query -c xfwm4 -p /general/wrap_windows -s false # disable pacman-esque warping / wrap, it blocks tiling


# should return true after logout: 
# 		 xfconf-query -c xfwm4 -p /general/tile_on_move
###
