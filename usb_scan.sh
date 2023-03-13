#!/bin/bash

# Prompt the user to select a USB drive
USB_DRIVE=$(zenity --file-selection --directory --title="Select a USB drive to scan")

# Check if the user canceled the selection
if [ -z "$USB_DRIVE" ]; then
    zenity --error --text="No USB drive selected."
    exit 1
fi

# Scan the USB drive for viruses and display a progress bar
sudo -u $USER clamscan -r -i -l "$HOME/clamscan.log" "$USB_DRIVE" | pv -pterb -s $(sudo du -sb "$USB_DRIVE" | awk '{print $1}') > /dev/null

# Show the scan results to the user
SCAN_RESULT=$(cat "$HOME/clamscan.log")
zenity --text-info --title="Scan Results" --width=800 --height=600 --filename="$HOME/clamscan.log"

