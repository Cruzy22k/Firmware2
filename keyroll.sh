#!/bin/bash
set -euo pipefail
# This script downloads a recovery key file and applies it to the firmware using futility.  This script is ONLY intended for use on Dedede, Nissa or Corsola. Use at your own risk. I might add more keyrolled devices in the near future
# This script requires to be ran as chronos, not root. Failure to do so may result in the recovery key not being applied correctly, or the device not being able to access the recovery key file.

if grep -q "Chrom" /etc/lsb-release ; then
    DOWNLOADS_DIR="/home/chronos/user/MyFiles/Downloads"
else
    DOWNLOADS_DIR="$HOME/Downloads"
fi
CHECK_SUM="https://raw.githubusercontent.com/Cruzy22k/NissaFW2/main/checks/"
RECOVERY_KEY_NISSA="https://raw.githubusercontent.com/Cruzy22k/NissaFW2/main/nissa_recovery_v2.vbpubk"
RECOVERY_KEY_NISSA_FILE="nissa_recovery_v2.vbpubk"
RECOVERY_KEY_DEDEDE="https://raw.githubusercontent.com/Cruzy22k/NissaFW2/main/dedede_recovery_v2.vbpubk"
RECOVERY_KEY_DEDEDE_FILE="dedede_recovery_v2.vbpubk"
RECOVERY_KEY_CORSOLA="https://raw.githubusercontent.com/Cruzy22k/NissaFW2/main/corsola_recovery_v2.vbpubk"
RECOVERY_KEY_CORSOLA_FILE="corsola_recovery_v2.vbpubk"
output=$(flashrom --wp-status 2>&1) 
if ! echo "$output" | grep -qi "protection mode:.*disabled"; then
    echo "Could not confirm WP is disabled. Output was:"
    echo "$output"
    exit 1
fi

echo -e "\e[32m<Firmware2>  Copyleft (C) 2024  Cruzy22k\e[0m"
echo -e "\e[32mThis program comes with ABSOLUTELY NO WARRANTY.\e[0m"
echo -e "\e[32mThis is free software, and you are welcome to redistribute it under certain conditions.\e[0m"
echo


echo "Determining key url, and file name..."
#Automatic board determination taken from https://github.com/MercuryWorkshop/sh1mmer/blob/beautifulworld/wax/payloads/br0ker.sh
if [ -f /etc/lsb-release ]; then
	BOARD=$(grep -m 1 "^CHROMEOS_RELEASE_BOARD=" /etc/lsb-release)
	BOARD="${BOARD#*=}"
	BOARD="${BOARD%-signed-*}"
    RECOVERY_KEY_URL="https://raw.githubusercontent.com/Cruzy22k/NissaFW2/main/${BOARD}_recovery_v2.vbpubk"
    RECOVERY_KEY_FILE="${BOARD}_recovery_v2.vbpubk"
else
    echo "Failed to determine board."
    echo "Falling back on manual selection."
    echo "please select what device you have, dedede (1), nissa (2) or corsola (3)"
    echo    
    read -p "Enter the number of the device you have: " -n 1 -r
    echo
    echo "DEBUG: You entered '$REPLY'"
    if [[ $REPLY =~ ^[1]$ ]]; then
        RECOVERY_KEY_URL="$RECOVERY_KEY_DEDEDE"
        RECOVERY_KEY_FILE="$RECOVERY_KEY_DEDEDE_FILE"
    elif [[ $REPLY =~ ^[2]$ ]]; then
        RECOVERY_KEY_URL="$RECOVERY_KEY_NISSA"
        RECOVERY_KEY_FILE="$RECOVERY_KEY_NISSA_FILE"
    elif [[ $REPLY =~ ^[3]$ ]]; then
        RECOVERY_KEY_URL="$RECOVERY_KEY_CORSOLA"
        RECOVERY_KEY_FILE="$RECOVERY_KEY_CORSOLA_FILE"
    else
    echo "Invalid input. Please enter 1, 2 or 3."
    exit 1
    fi
fi

# Debug output:
echo "DEBUG: Selected URL: $RECOVERY_KEY_URL"
echo "DEBUG: Selected file name: $RECOVERY_KEY_FILE"

mkdir -p "$DOWNLOADS_DIR"
echo "Downloading the recovery key file..."
cd "$DOWNLOADS_DIR" || exit 1
curl -L -o "$RECOVERY_KEY_FILE" "$RECOVERY_KEY_URL"
curl -sLO "${CHECK_SUM}${RECOVERY_KEY_FILE}.md5"
if [ ! -f "$RECOVERY_KEY_FILE" ]; then
    echo "Failed to download the recovery key file."
    exit 1
fi

if ! md5sum -c "${RECOVERY_KEY_FILE}.md5" > /dev/null 2>&1; then
        echo "download checksum fail; download corrupted, cannot flash"
        exit 1
    fi
echo "Downloaded the recovery key file to $DOWNLOADS_DIR/$RECOVERY_KEY_FILE."

# Ask for confirmation before applying the recovery key
echo "WARNING: Before proceeding, ensure that Write Protect (WP) is disabled on your device."
echo "Failure to disable WP may result in the recovery key not being applied correctly."
read -p "Are you sure you want to apply the recovery key with futility? (y/n) " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting the process."
    exit 1
fi


echo -e "\e[31mFlashing key\e[0m"
futility gbb -s --flash --recoverykey="$DOWNLOADS_DIR/$RECOVERY_KEY_FILE"

# Check if application was successful
if [ $? -eq 0 ]; then
    echo -e "\033[32mSuccessfully applied the recovery key.\033[0m"

else
    echo -e "\e[31mFailed to apply the recovery key.\e[0m"
        echo -e "\e[31mThis shouldn't ever happen!\e[0m"

    # Clear the vbpubk files from the Downloads folder only if the previous command fails
    rm -f "$DOWNLOADS_DIR"/*.vbpubk
    echo "Removed vpubk files."

    exit 1
fi
# Creds
echo "Finished!" 
echo " "
echo "Made by Cruzy22k" 
echo ":3"
echo ""
echo " A reboot is required for the changes to take effect."

# Cleanup
rm -f "$DOWNLOADS_DIR"/*.vbpubk
echo "Removed vpubk files."
echo " "


read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi

echo "Please reboot your system manually to see changes take effect"


