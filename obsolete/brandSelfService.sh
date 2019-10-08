#!/bin/bash
#
# brandSelfService.sh
#
# Copy pre-made graphic files inside
# of Self Service.app for branding purposes
#
# HOW TO:
# 1: Download Self Service from your JSS (SelfService.tar.gz)
#
# 2: Place this script and SelfService.tar.gz in a folder
# chmod +x this script
# Place assets (see Files Needed below) in a subfolder named icons
#
# 3: Run ./brandSelfService.sh from Terminal
#
# Files Needed:
# Your replacement icon for the app, 256x256: /icons/appicon.icns
# Your Retina replacement icon for the app, 512x512: /icons/appicon@2x.icns
# Your replacement for the status area of SS, 84x84: /icons/logo-SelfService.tiff
#
# YOU MUST RUN THIS COMMAND WITH ELEVATED PRIVILEGES (sudo)
#
# For use with the JAMF Casper Suite
#
# Adam Codega, Swipely
#

# Unzip SelfService.tar.gz
tar -zxvf SelfService.tar.gz

# Clear the quarantine from Self Service.app
xattr -r -d com.apple.quarantine Self\ Service.app

# Copy the icon into place
echo "Copying the icon file into place.."
cp icons/appicon.icns Self\ Service.app/Contents/Resources/Self\ Service.icns
chmod 744 Self\ Service.app/Contents/Resources/Self\ Service.icns

# Copy the Retina icon into place
echo "Copying the Retina icon into place.."
cp icons/appicon@2x.icns Self\ Service.app/Contents/Resources/Self\ Service@2x.icns
chmod 744 Self\ Service.app/Contents/Resources/Self\ Service.icns

# Copy the status area icon into place
echo "Copying the status area icon into place.."
cp icons/logo-SelfService.tiff Self\ Service.app/Contents/Resources/jsLogo-SelfService.tiff
chmod 744 Self\ Service.app/Contents/Resources/Self\ Service.icns

# Rename Self Service in it's plist
echo "Renaming Self Service in info.plist and chmoding it.."
# Put your preferred app name at the end of this line in double quotes
defaults write Self\ Service.app/Contents/Info CFBundleName "Swipely Service"
chmod 744 Self\ Service.app/Contents/Info.plist

# Rename the app itself
echo "Renaming Self Service the app itself.."
# Put your preferred app name at the end of the next line in double quotes
mv Self\ Service.app "Swipely Service.app"

echo
echo "Done. You've been branded."
echo
