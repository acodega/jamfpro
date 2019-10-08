#!/bin/bash
#
# File Name:CheckDownloadsFolder.sh
# Check and report via EA size of user's Downloads folder
# github.com/acodega
#

#find logged in user
loggedinuser=$( scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}' )

#find how large downloads is
downloads=$(du -hd 1 /Users/"$loggedinuser"/Downloads | awk 'END{print $1}')

#echo it for EA
echo "<result>$downloads</result>"
