#!/bin/bash

# Get the MAC address of the computer's assigned Belkin USB adapter and write it locally
# Helpful when you want to know the MAC address of the adapter being used at the time this script is run
# To be paired with a Jamf Extension Attribute to report this MAC address
# Works in macOS Mojave 10.14

USBMAC=$(networksetup -listallhardwareports | awk '/Hardware Port: Belkin USB-C LAN/{getline; getline; print $NF}')

if [[ "$USBMAC" == "" ]]; then
  defaults write /Library/Preferences/org.vandelay.network.plist Belkin -string "N/A"
else
  defaults write /Library/Preferences/org.vandelay.network.plist Belkin -string "$USBMAC"
fi
