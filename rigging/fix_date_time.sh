#!/usr/bin/env bash
printf "Change the system time if it's incorrect.\n\n TIP: For exactness wait for a minute to pass before pressing enter.\n(prepare the text entry meanwhile)\nThen hit enter when the expected minute and time comes by."

#TODO automate exactness
read -p "Enter the current date (YYYY-MM-DD) : " current_date
read -p "Enter the current time [military time] (HH:MM:SS) : " current_time

sudo date -s "$current_date $current_time"
sudo hwclock --systohc --localtime

read -p "Restart XFCE panel? [if time in top right is incorrect too, restarting will sync that gui with system clock] (y/n) : " r_xfce
if [[ "$r_xfce" == "y" ]]; then

	xfce4-panel -r

	printf "System clock set.\nRestarting XFCE panel to sync gui clock...\n"

else
	printf "System clock set.\n"
fi

