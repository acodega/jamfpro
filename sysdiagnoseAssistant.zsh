#!/bin/zsh --no-rcs
# shellcheck shell=bash
# set -x

#

dialogApp='/usr/local/bin/dialog'
dialogCommandFile=$(mktemp /var/tmp/exampleDialog.XXXXX)
serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }')
uid=$(id -u "$currentUser")
errorCode=0

# This function sends a command to our command file, and sleeps briefly to avoid race conditions
function dialogCommand() {
    /bin/echo "$@" >> "$dialogCommandFile"
    sleep 0.1
}

Run as user function, as always
runAsUser() {
    if [ "$currentUser" != "loginwindow" ]; then
        launchctl asuser "$uid" sudo -u "$currentUser" "$@"
    else
        printLog "No user logged in"
        exit 1
    fi
}

# Calling our initial dialog window. The & is crucial so that our script progresses.

$dialogApp \
--title "Sysdiagnose Assistant" \
--message "Preparing to run.."  \
--ontop \
--moveable \
--button1disabled \
--commandfile "$dialogCommandFile" \
--progress 5 \
--icon "SF=bolt.circle color1=pink color2=blue" \
&

# Pause for effect
sleep 2

dialogCommand "progress: increment"
dialogCommand "message: Creating directory to store sysdiagnose.."
date=$(date +%Y_%m_%dT%H%M%S)
resultsDirectory=$(mktemp -d /Users/Shared/sysdiagnose-XX-"${date}")
sysdiagnoseName="sysdiagnose-${serialNumber}-${date}.tar.gz"
chmod 755 "${resultsDirectory}"
sleep 1

dialogCommand "progress: increment"
dialogCommand "message: Running sysdiagnose. This may take 5 minutes.."
sleep 1
/usr/bin/sysdiagnose -f "${resultsDirectory}" -A "$sysdiagnoseName" -u

dialogCommand "progress: increment"
dialogCommand "Checking if sysdiagnose was created.."
sleep 1
if [[ -f "$resultsDirectory/$sysdiagnoseName" ]]; then
    chmod 755 "$resultsDirectory/$sysdiagnoseName"
    dialogCommand "progress: increment"
    dialogCommand "message: Sysdiagnose successfully created.."
    sleep 1
else
    dialogCommand "progress: complete"
    dialogCommand "message: Sysdiagnose file not created. Please try again our contact the [yourorg] Apple team."
    errorCode=1
    dialogCommand "button1: enable"
    exit $errorCode
fi

dialogCommand "progress: complete"
dialogCommand "message: Sysdiagnose collection complete.  \n\nSysdiagnose stored at $resultsDirectory/$sysdiagnoseName  \n\nPlease send this file to the [yourorg] Apple team."
dialogCommand "button1: enable"

runAsUser open -R "$resultsDirectory/$sysdiagnoseName"

exit $errorCode

# Close our dialog window
# dialogCommand "quit:"

# Delete our command file
# rm "$dialogCommandFile"
