#!/bin/bash
# 
# swipely-awdl0-EA.sh
#
# Check if awdl0 interface is active, for use as an extension attribute.
# 
# awdl0 has been documented to cause Wi-Fi issues on OS X Yosemite 10.10-10.10.2
# 
# https://medium.com/@mariociabarra/wifried-ios-8-wifi-performance-issues-3029a164ce94
# 
# Adam Codega, Swipely
#

echo "<result>$(ifconfig awdl0 | awk '/status/{print $2}')</result>"