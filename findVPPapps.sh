#!/bin/bash
#
# JAMF Extension Attribute that finds any MAS apps
# that were purchased through VPP and which account
# purchased it.
# Crafted by Craig Lindsey for Starz 2017-2-10
#

mdfind -onlyin /Applications/ 'kMDItemAppStoreReceiptIsVPPLicensed == "1"' | while read VPPApp; do
  AppOwner=$( mdls "$VPPApp" -name kMDItemAppStoreReceiptOrganizationDisplayName | awk '{ print $3, $4 }' | sed -e 's/^\"//' -e 's/"$//' )
  AppName=$( echo "$VPPApp" | awk -F'/' '{print $NF}' | sed -e 's/^"//' -e 's/"$//')
  result="$AppName $AppOwner"

  echo "<result>$result</result>"
  echo "Hello."
done
