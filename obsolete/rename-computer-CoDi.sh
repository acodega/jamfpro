#!/bin/sh
########################################################################
# Created By: Ross Derewianko Ping Identity Corporation
# Creation Date: Febuary, 2015 
# Last modified: Febuary 27, 2015
# Modified for Swipely: May 21st, 2015 Adam Codega
# Brief Description: Changes machine hostname
########################################################################

#check for CocoaDialog & if not install it

if [ -d "/usr/sbin/cocoaDialog.app" ]; then
	CoDi="/usr/sbin/cocoaDialog.app/Contents/MacOS/cocoaDialog"
else
	echo "CocoaDialog.app not found installing" 
	/usr/sbin/jamf policy -trigger cocoa
fi

########################################################################
# Functions
#######################################################################

#asks for the new hostname & then call in the cleaner!

function cdprompt() {
	hostname=`"$CoDi" standard-inputbox --title "Rename Computer" --informative-text "Enter new computer name"`

	if [ "$hostname" == "2" ]; then
		echo "user cancelled"
		exit 1
	fi
	cleanhostname
}

#cleans the first two characters out (cocoaDialog adds a 1 \n to the string value which we don't need.)

function cleanhostname() {
	hostname=${hostname:2}
}

#checks for a blank hostname, and if its blank prompt agian 

function checkforblank() {
	while [[ -z $hostname && {$hostname+1} ]]
	do
		cdprompt
	done
}

function sethostname() {
	scutil --set HostName $hostname
	scutil --set ComputerName $hostname
	scutil --set LocalHostName $hostname
}

########################################################################
# Script
########################################################################

cdprompt
checkforblank
sethostname