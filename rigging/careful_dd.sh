#!/usr/bin/env bash
devices=$(lsblk -o NAME,SIZE,MODEL,SERIAL,TRAN | grep 'usb')


select_iso_and_write() {
	USB_CAND="$1"
	mapfile -d '' -t iso_files < <(find . -type f -name '*.iso' -print0)
	if [ ${#iso_files[@]} -eq 0 ]; then
		printf "\ncareful_dd: no .iso files found in cwd\n"
		exit 1
	fi
	printf "Choose ISO to flash (enter the number, if it's the only one it'll be 1 ) :\n"
	select chosen_iso in ${iso_files[@]}; do
		if [[ -z $chosen_iso ]]; then
			echo "Invalid: $REPLY" >&2
			continue
		fi
		printf "%s WILL BE FLASHED ONTO %s!!!\n" "$chosen_iso" "$USB_CAND"
		read -p "READY? (y/n): " ready
		case "$ready" in [Yy]|[Yy][Ee][Ss])
			printf "\nFLASHING %s!\n" "$USB_CAND"
			sudo dd if="$chosen_iso" of=/dev/"$USB_CAND" bs=4M status=progress oflag=sync ;
                	break ;;
		exit) return ;;
  	        *) printf "Restarting ISO choosing prompt...\n" ; REPLY=; continue ;;
		esac
	done
}

if [ "$(echo "$devices" | wc -l)" -eq 1 ]; then
	USB_CAND=$(echo "$devices" | awk '{print $1}') # assign usb name to variable
	if [[ -z "$devices" ]]; then
		printf "\ncareful_dd: No USB devices found! Exiting...\n"
		exit 1
	fi
	printf "Only one usb found:\n\n"    
	printf "%s\n\n" "$devices" 
	#prompt user to verify that this matches their USB, ensure extreme caution not to be overwriting anything important
	read -p "Does this match the USB device you want to overwrite? (y/n): " yn
	case "$yn" in [Yy]|[Yy][Ee][Ss])
		printf "\n\n$devices\n\n" ;
		read -p "Please MAKE SURE this is not any important drive, use a designated drive for ISOs! (y/n): "  yn2 ;
		case "$yn2" in [Yy]|[Yy][Ee][Ss])
			printf "\n%s\n\nSELECTED THIS ISO FOR OVERWRITING %s!!!\n\n" "$devices" "$USB_CAND" ;
			#after confirming that this is the usb device we want to overwrite, proceed with dd on the netinstall iso
			if [[ -z "$USB_CAND" ]]; then
				printf "\ncareful_dd: Empty USB candidate selected, exiting...\n"
				exit 1
			fi
			select_iso_and_write "$USB_CAND" ;;
		*) echo "\ncareful_dd: EXITING\n" ;;
		esac ;;
	*) echo "\ncareful_dd: EXITING\n" ;;
	esac
else
	echo "\ncareful_dd: Multiple usb devices found: unhandled. Exiting...\n"
fi

