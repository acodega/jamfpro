#!/bin/bash
#File Name:ResetPrinters.sh
########################################################################
# Created By: Jacob Salmela (JAMF Nation) and customized by Adam Codega
# Creation Date: December 2015
# Brief Description: Reset printer system by restoring CUPS to default
# and removing all printers. cocoaDialog is used to interact with the user
########################################################################
#

#Find out where JAMF is because of the JSS 9.8 binary move
jamfbinary='/usr/bin/which jamf'

# Check for cocoaDialog and if not install it
if [ -d "/Applications/Utilities/cocoaDialog.app" ]; then
	echo "CocoaDialog.app installed, continuing on"
else
	echo "CocoaDialog.app not found, pausing to install"
	$jamfbinary policy -event cocoa
fi
coDi="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"

# Ask user to confirm they want to reset all printers
confirm=`$coDi msgbox --float --title "Resetting Printers" --icon x --height 150 --text "Are you sure you want to remove all printers?" --informative-text "You will need to reinstall them from Self Service" --button1 "Yes" --button2 "No" --button3 "Cancel"`

# Check result of confirm
if [ "$confirm" == "1" ]; then
    echo "User confirmed, continuing.."
elif [ "$confirm" == "2" ]; then
    echo "User did not confirm, exiting.."
		exit 0
elif [ "$confirm" == "3" ]; then
    echo "User canceled, exiting.."
		exit 0
fi

# Stop CUPS
echo "launchctl stop org.cups.cupsd"

# Remove CUPS config file
echo "rm /etc/cups/cupsd.conf"

# Restore the default config by copying it
echo "cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf"

# Remove the printers
echo "rm /etc/cups/printers.conf"

# Start CUPS again
echo "launchctl start org.cups.cupsd"
