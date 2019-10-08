#!/bin/bash
#
########################################################################
# Created By: Adam Codega, Swipely Inc.
# 	with help from Ross Derewianko Ping Identity Corporation
# Creation Date: June 2015
# Last updated: Dec 2015
# Brief Description: Changes machine hostname based on first initial and
# 	last name of local user. Then, ask IT tech which department to
# 	set computer to in JSS. Follows up with installing updates,
#   running a recon, and telling tech it's ready to restart.
########################################################################

########################################################################
# Lets locate some Applications
########################################################################

#Find out where JAMF is because of the JSS 9.8 binary move
jamfbinary='/usr/bin/which jamf'

#check for cocoaDialog and if not install it
if [ -d "/Applications/Utilities/cocoaDialog.app" ]; then
	echo "CocoaDialog.app installed, continuing on"
else
	echo "CocoaDialog.app not found, pausing to install"
	$jamfbinary policy -event cocoa
fi
coDi="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"

#check for Dockutil and if not install it
if [ -f "/usr/local/bin/dockutil" ]; then
	echo "Dockutil.app installed, continuing on"
else
	echo "Dockutil not found, pausing to install"
	$jamfbinary policy -event dockutil
fi
dockutil="/usr/local/bin/dockutil"

#######################################################################
# Figure out the hostname
#######################################################################

#Set the hostname

# figure out the user
user=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#figure out the user's full name
name=$(finger "$user" | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )

# get first initial
finitial="$(echo "$name" | head -c 1)"

# get last name
ln="$(echo "$name" | cut -d \  -f 2)"

# add first and last together
un=($finitial$ln)

# clean up un to have all lower case
hostname=$(echo "$un" | awk '{print tolower($0)}')

#######################################################################
# Clean up the dock
#######################################################################

$dockutil --remove all
$dockutil --add '/Applications/Launchpad.app' --no-restart
$dockutil --add '/Applications/System Preferences.app' --no-restart
$dockutil --add "/$HOME/Downloads"

#######################################################################
# Functions
#######################################################################

sethostname() {
	$jamfbinary setComputerName -name "$hostname"
}

cdprompt() {
	jssdept=$("$coDi" standard-dropdown --string-output --title "Choose a Department" --height 150 --text "Department" --items "Business Administration" Technology Finance Marketing Product Sales Success Talent)

	if [ "$jssdept" == "2" ]; then
		echo "user cancelled"
		exit 1
	fi
	cleanjssdept
}

#cleans the first two characters out (cocoaDialog adds a 1 \n to the string value which we don't need.)
cleanjssdept() {
	dept=$(echo "$jssdept" | sed -n 2p)
}

#sets department using JAMF Framework Recon command
setdepartment() {
	$jamfbinary recon -department "$dept"
}


########################################################################
# Script
########################################################################

# sometimes we image (don't tell anyone) so we need to makes sure Site is Upserve and Department is None
$jamfbinary recon -building "Upserve"
$jamfbinary recon -department "None"

sethostname
cdprompt
setdepartment

# now that the dept is set let's apply profiles and policies
$jamfbinary manage
$jamfbinary policy

# manage and policy probably changed stuff, so let's submit an updated inventory
$jamfbinary recon

# set softwareupdate schedule On
softwareupdate --schedule on

# install all updates with verbose output
softwareupdate -via

# recon again
$jamfbinary recon

#notify the tech that computer is ready for restart
$coDi bubble --no-timeout --title "Upserve Enrollment Complete" --text "Restart to enable FileVault 2 Encryption" --icon "computer"
