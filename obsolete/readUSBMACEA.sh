#!/bin/bash

# Extension attribute to use with writeUSBMAC.sh (which is run when the computer is deployed)
# Read the MAC address of the computer's assigned Belkin USB adapter which has already been stored locally
# Works in macOS Mojave 10.14

USBMAC=$(defaults read /Library/Preferences/org.vandelay.network.plist Belkin)

if [[ "$USBMAC" == "" ]]; then
  echo "<result>Value has not been set</result>"
else
  echo "<result>$USBMAC</result>"
fi
