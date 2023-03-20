#!/bin/bash

# Check the operating system and set the folder and output variables accordingly
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS: Use AppleScript to get the folder and output paths
  folder=$(osascript -e 'try' -e 'set _folder to choose folder with prompt "Select folder to scan"' -e 'POSIX path of _folder' -e 'on error' -e '' -e 'end try')
  output=$(osascript -e 'try' -e 'set _folder to choose folder with prompt "Select where to save log"' -e 'POSIX path of _folder' -e 'on error' -e '' -e 'end try')
else
  # Other platforms: Use Python's tkinter to get the folder and output paths
  folder=$(python3 -c 'import tkinter as tk; from tkinter import filedialog; root = tk.Tk(); root.withdraw(); folder = filedialog.askdirectory(title="Select folder to scan"); print(folder)' 2>/dev/null)
  output=$(python3 -c 'import tkinter as tk; from tkinter import filedialog; root = tk.Tk(); root.withdraw(); folder = filedialog.askdirectory(title="Select where to save log"); print(folder)' 2>/dev/null)
fi

# Run the virus scan and save the results to clamscan.log in the selected output directory
sudo -u "$USER" stdbuf -oL clamscan -r -i -v "$folder" 2>&1 | tee "${output}/clamscan.log"
