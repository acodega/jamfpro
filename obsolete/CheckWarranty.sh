#!/bin/sh
#File Name:CheckWarranty.sh
########################################################################
# Created By: Andrew Tomson Modified by Ross Derewianko for Self Service
# Creation Date: Sept 2015
# Last modified: Sept 28, 2015
# Brief Description: Lets the user Know its changed
########################################################################
#	this script was written to query apple's service database to determine warranty coverage
#	base on a system's serial number. This updated version stores the information locally so
#	as not to have to query apple's website repeatedly. 

#Find out where JAMF is
jamfbinary=`/usr/bin/which jamf`

#check for cocoaDialog and if not install it
if [ -d "/Applications/Utilities/cocoaDialog.app" ]; then
echo "CocoaDialog.app installed, continuing on"
else
 $jamf_binary policy -trigger cocoa
echo "CocoaDialog.app not found, pausing to install"
fi
coDi="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"


if [ -f /Library/Preferences/com.apple.warranty.plist ]; then
	#	get plist data
	WarrantyDate=`/usr/bin/defaults read /Library/Preferences/com.apple.warranty WarrantyDate`
	WarrantyStatus=`/usr/bin/defaults read /Library/Preferences/com.apple.warranty WarrantyStatus`
	
	#	convert dates to integers 
	ExpirationDate=`/bin/date -j -f  "%Y-%m-%d" "${WarrantyDate}" +%s`
	TodaysDate=`/bin/date +%s`
	
	#	if warranty is listed as active but date is expired, update plist entry
	if [ "${WarrantyStatus}" == "Active" ] && [ ${TodaysDate} -gt ${ExpirationDate} ]; then 
		WarrantyStatus="Inactive"
		/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyStatus ${WarrantyStatus}
		echo Status updated.
	else
		echo Status unchanged.
	fi
	echo "<result>${WarrantyStatus} : ${WarrantyDate}</result>"
fi


#	set temp file
WarrantyTempFile="/tmp/warranty.$(date +%s).txt"


#	get serial number
SerialNumber=`ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }'`
if [ -z "${SerialNumber}" ]; then
		echo "Serial Number not found."
		exit 1
fi


#	query url
WarrantyURL="https://selfsolve.apple.com/wcResults.do?sn=${SerialNumber}&Continue=Continue&num=0"
WarrantyInfo=$(curl -k -s $WarrantyURL | awk '{gsub(/\",\"/,"\n");print}' | awk '{gsub(/\":\"/,":");print}' | sed s/\"\}\)// > ${WarrantyTempFile})


#	check validity of serial number
InvalidSerial=$(grep 'invalidserialnumber\|productdoesnotexist' "${WarrantyTempFile}")
if [[ -n "${InvalidSerial}" ]]; then
	echo "Invalid Serial Number."
	exit 2
fi


#	determine warranty status	
WarrantyStatus=$(grep displayHWSupportInfo "${WarrantyTempFile}")
if [[ $WarrantyStatus =~ "Active" ]]; then
	WarrantyStatus="Active"
else
	WarrantyStatus="Inactive"
fi


#	check for expiration date
if [[ `grep displayHWSupportInfo "${WarrantyTempFile}"` ]]; then
	WarrantyDate=`grep displayHWSupportInfo "${WarrantyTempFile}" | grep -i "Estimated Expiration Date:"| awk -F'<br/>' '{print $2}'|awk '{print $4,$5,$6}'`
fi


#	convert format of date
if [[ -n "$WarrantyDate" ]]; then
	WarrantyDate=$(/bin/date -jf "%B %d, %Y" "${WarrantyDate}" +"%Y-%m-%d") > /dev/null 2>&1 
else
	WarrantyDate="N/A"
fi


#	write status and date to plist
if [[ -n "$WarrantyStatus" ]] && [[ -n "$WarrantyDate" ]]; then
	/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyStatus ${WarrantyStatus}
	/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyDate ${WarrantyDate}
fi
	
#--- debug lines--
#echo Serial Number: "${SerialNumber}"
#echo Warranty Status: ${WarrantyStatus}
#echo Warranty Expiration: ${WarrantyDate}
#---/debug---
#lets pop this info up to the user
"$coDi" ok-msgbox --title "Your Warranty Expires" --text "Warranty info" --informative-text "Serial Number: ${SerialNumber}
Warranty Status: ${WarrantyStatus}
Warranty Expiration: ${WarrantyDate}" --no-cancel --icon info
exit 0


