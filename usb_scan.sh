#!/bin/bash

function check_python_and_tkinter() {

  echo "Checking for Python 3 and Tkinter..."

  if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 is required but not installed on your system."
    echo "Please visit https://www.python.org/downloads/ to download and install Python 3."
    exit 1
  fi

  if ! python3 -c "import tkinter" >/dev/null 2>&1; then
    echo "Tkinter is required but not installed on your system."
    echo "Please install Tkinter for Python 3. You can learn more at https://tkdocs.com/tutorial/install.html"
    exit 1
  fi

  echo "Python 3 and Tkinter are installed. Proceeding with the script..."
  sleep 3

}

check_python_and_tkinter

function install_dependencies() {
  if command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt-get"
  elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
  elif command -v brew >/dev/null 2>&1; then
    PKG_MANAGER="brew"
  else
    echo "We checked for APT, YUM, PACMAN, DNF, and BREW. A package manager not found. Please install ClamAV manually."
    exit 1
  fi

  case $PKG_MANAGER in
    apt-get)
      sudo apt update && sudo apt install clamav && sudo freshclam
      ;;
    yum)
      sudo yum install epel-release && sudo yum install clamav clamav-update && sudo freshclam
      ;;
    pacman)
      sudo pacman -S clamav && sudo freshclam
      ;;
    dnf)
      sudo dnf install -y clamav clamd clamav-update && sudo freshclam
      ;;
    brew)
      brew install clamav && freshclam
      ;;
  esac
}

function is_clamav_installed() {
    echo "Checking for ClamAV..."
    sleep 3
  command -v clamscan >/dev/null 2>&1
}

if ! is_clamav_installed; then
  echo "The ClamAV package is required but is not installed."
  read -rp "Do you want to install it now? [y/N] " answer
  if [[ "$answer" =~ [yY](es)* ]]; then
    install_dependencies
  else
    echo "No? ... uh... alright, then."
    exit 1
  fi
fi


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
