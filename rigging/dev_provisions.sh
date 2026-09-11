#!/usr/bin/env bash
printf  "\n\n\nDeveloper Provisions Package Installer\n\n\n"


refracta=false
qemu=false
y=""
for arg in "$@"; do
	case "$arg" in
		--refracta) refracta=true ;;
		--qemu) qemu=true;;
		-y) y="-y";;
	esac
done

if [[ "$refracta" == true || "$qemu" == true ]]; then
	if [[ "$refracta" == true ]]; then
		sudo apt install refractasnapshot-base refractainstaller-base "$y"
	fi
	if [[ "$qemu" == true  ]]; then
		sudo apt install qemu-system-x86 ovmf "$y"
	fi
	exit
else
	printf "\n---\nNo handled flags provided\n---\n"
fi


printf "ENSURE YOU HAVE RUN './provisions' OR INSTALLED NECESSARY PREREQUISITE COMMANDS BEFORE RUNNING THIS\n"

printf "You will be prompted for each programming language or other developer software that you may want to install packages for.\n\n"

read -p "Install Python3 Packages? (y/n): " python3yn
case "$python3yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install python3 python3-pip python3-venv python3-dev "$y" ;;
*) printf "Skipping Python3...\n" ;;
esac

read -p "Install NodeJS Packages? (y/n): " nodejsyn
case "$nodejsyn" in [Yy]|[Yy][Ee][Ss])
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - ;
	sudo apt install nodejs "$y" ;;
*) printf "Skipping NodeJS...\n" ;;
esac

read -p "Install C++ Packages? (y/n): " cppyn
case "$cppyn" in [Yy]|[Yy][Ee][Ss])	
	sudo apt install gcc g++ gdb make cmake ninja-build clang clang-tools clang-format "$y" ;;
*) printf "Skipping C++...\n" ;;
esac

read -p "Install Refracta Packages? (y/n): " refracta_yn
case "$refracta_yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install refractasnapshot-base refractainstaller-base "$y" ;;
*) printf "Skipping Refracta...\n" ;;
esac

read -p "Install QEMU Packages? (y/n): " QEMU_yn
case "$QEMU_yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install qemu-system-x86 ovmf "$y" ;;
*) printf "Skipping QEMU\n" ;;
esac

read -p "Install Remmina Packages? (y/n): " Remmina_yn
case "$Remmina_yn" in [Yy]|[Yy][Ee][Ss])
	sudo apt install remmina remmina-plugin-rdp remmina-plugin-vnc "$y" ;;  
*) printf "Skipping Remmina\n" ;;
esac



