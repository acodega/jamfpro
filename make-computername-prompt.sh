#!/bin/bash

# Let's name this computer based off the user who's logged in right now.
# We'll display the name to the user and let them change it.

# find the JAMF binary location
jamfbinary=$(/usr/bin/which jamf)

# find the user who's logged in
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )

# get full name
name=$(finger "$user" | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //' )

# get first name initial
finitial="$(echo "$name" | head -c 1)"
echo "$finitial"

# get lastname
ln="$(echo "$name" | cut -d \  -f 2)"
echo "$ln"

# add first and last together
fullname=($finitial$ln)

# clean up fullname to lower case
hostname=$(echo "$fullname" | awk '{print tolower($0)}')

# prompt user to name computer with hostname prefilled and capture it
prompt=$(sudo -u $currentUser osascript -e 'display dialog "Enter computer name:" default answer "'$hostname'"')

# get the user's input from the prompt variable. We should sanitize this in case they inserted spaces. But we're not.
theName=$( echo "$prompt" | /usr/bin/awk -F "text returned:" '{print $2}' )

# check if theName is was entered empty, and set the hostname to what we want. I don't think this is the best way to do this though.
if [ -z "$theName" ]
  then $jamfbinary setComputerName -name "$hostname"
  else $jamfbinary setComputerName -name "$theName"
fi
