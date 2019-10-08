#!/bin/bash
# 
# swipely-disable-awdl0.sh
#
# Check if awdl0 interface is active,
# if it is, then disable it.
# 
# awdl0 has been documented to cause Wi-Fi issues on OS X Yosemite 10.10-10.10.2
# 
# This script can run at startup using a JSS policy and "User login" as trigger
#
# (Or launchd/offset if that's your thing.)
# 
# https://medium.com/@mariociabarra/wifried-ios-8-wifi-performance-issues-3029a164ce94
# 
# Adam Codega, Swipely
#

# set awdl0 status as a variable

awdlstatus=$(ifconfig awdl0 | awk '/status/{print $2}')

# find out if awdl0 is already inactive, if it is, end script. If it's not, disable it.

if [ "$awdlstatus" = "inactive" ]; then
        end
else
        ifconfig awdl0 down
fi