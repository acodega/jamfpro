#!/bin/bash

#
# File Name:LastRestart.sh
# Extension attribute to check and report the time of the Mac's last startup
# Extension attributes are intended for use with Jamf Pro
# Available at https://github.com/acodega
#

# Use sysctl kern.boottime to get date and time, then format it as a date attribute for Jamf
echo "<result>$(date -jf "%s" "$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')" +"%Y-%m-%d %T")</result>"
