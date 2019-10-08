#!/bin/bash
#
# This script will show to the user when their laptop is due for replacement
# by estimating its estimated manufacturer date and adding two years to that date.
#
# We'll display the info to the user using cocoaDialog.
#
# Warranty estimator via https://github.com/chilcote/warranty
#
# Update lines 15 and 16 for your organization
#
# Adam Codega, Upserve
#

coDi="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"
borndate=`/Library/Application\ Support/Upserve/warranty-check/warranty | awk '/Manufactured/ {print $3}'`
deathdate=`date -j -f %Y-%m-%d -v+2y $borndate +"%b %d, %Y"`

$coDi ok-msgbox --no-cancel --title "Laptop Replacement Check" --text "Your laptop warranty expires on or around $deathdate" --informative-text "Your laptop replacement will be scheduled near that date" --icon computer &> /dev/null

exit 0
