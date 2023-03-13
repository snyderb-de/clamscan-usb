#!/bin/bash

# Prompt the user to select a USB drive
USB_DRIVE=$(zenity --file-selection --directory --title="Select a USB drive to scan")

# Check if the user canceled the selection
if [ -z "$USB_DRIVE" ]; then
    zenity --error --text="No USB drive selected."
    exit 1
fi

# Run the virus scan and save the results to clamscan.log
sudo -u $USER stdbuf -oL clamscan -r -i -v "$USB_DRIVE" 2>&1 | tee "$HOME/clamscan.log" | zenity --text-info --title="Scan Results" --width=800 --height=600 --auto-scroll

# Show the scan results to the user
zenity --text-info --title="Scan Results" --width=800 --height=600 --filename="$HOME/clamscan.log"

