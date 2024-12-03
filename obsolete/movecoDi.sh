#!/bin/sh
#
#####
# Created By: Adam Codega, Swipely Inc.
# Creation Date: October 2016
# Brief Description: Check if cocoaDialog and dockutil exists at /usr/sbin and move
# to /Applications/Utilities, for OS X 10.11 support.
#####

if [ -d "/usr/sbin/cocoaDialog.app" ]; then
    mv /usr/sbin/cocoaDialog.app /Applications/Utilities/cocoaDialog.app
else
    echo "CocoaDialog.app not found."
fi

exit 0
