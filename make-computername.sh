#!/bin/bash
#
# make-computername.sh
#
# Get computer user's full name
# And make a firstinitiallastname hostname
# To set the computer name
#
# Adam Codega
#

# find the JAMF binary location
jamfbinary=$(/usr/bin/which jamf)

# find the user who's logged in
user=$( scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )

# get full name
name=$(finger "$user" | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )

# get first name
finitial="$(echo "$name" | head -c 1)"
echo "$finitial"

# clean for lastname
ln="$(echo "$name" | cut -d \  -f 2)"
echo "$ln"

# add first and last together
fullname=($finitial$ln)

# clean up fullname to lower case
hostname=$(echo "$fullname" | awk '{print tolower($0)}')

# name the computer
$jamfbinary setComputerName -name "$hostname"
