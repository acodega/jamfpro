#!/bin/zsh --no-rcs
# shellcheck shell=bash
# set -x

# Name: uslWatcherUploader.zsh
# v0.3
# In my Jamf repo cause you can have Jamf run this regularly.

serialNumber=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
orgScriptName="uslWatcherUploader"
orgFQDN="com.contoso"
scriptVersion=0.3
scriptLog=$(mktemp /var/logs/$orgFQDN.$orgScriptName-XXX)
date=$(date +%Y_%m_%dT%H%M%S)
syslogFile="sysdiagnose-${serialNumber}-${date}.logarchive"
log="/usr/bin/log"
errorCode=0
chmod 644 "$scriptLog"

logger() {
    echo -e "${orgScriptName} v($scriptVersion): $(date +%Y-%m-%d\ %H:%M:%S) - ${1}" | tee -a "${scriptLog}"
}

uploader() {
    logger "Making results directory.."
    date=$(date +%Y_%m_%dT%H%M%S)
    resultsDirectory=$(mktemp -d /Users/Shared/sysdiagnose-"${date}")
    sysdiagnoseName="sysdiagnose-${serialNumber}-${date}.tar.gz"
    chmod 755 "${resultsDirectory}"

    logger "Made directory $resultsDirectory\$sysdiagnoseName. This may take 5 minutes.."
    /usr/bin/sysdiagnose -f "${resultsDirectory}" -A "$sysdiagnoseName" -u > /dev/null

    logger "Checking if sysdiagnose was created.."
        if [[ -f "$resultsDirectory/$sysdiagnoseName" ]]; then
        chmod 755 "$resultsDirectory/$sysdiagnoseName"
        logger "Sysdiagnose successfully created.."
        else
        logger "Sysdiagnose file was not created. Exiting.."
        errorCode=1
    fi

    logger "Sysdiagnose collection complete. It is stored at $resultsDirectory/$sysdiagnoseName"
    logger "Now FTPing to storage (ftp.contoso.com/$sysdiagnoseName)"

    #pretend it's 2005 and FTP servers are still relevant. Obviously this is where you'd do something like upload to S3, SMB, etc
    if ! curl -s -T "$resultsDirectory"/"$sysdiagnoseName" -u user:pass ftp://ftp.contoso.com/; then
        logger "Something went wrong with the FTP upload. Exiting.."
        errorCode=1
        else
        logger "FTP upload successful"
    fi
}

logOptions=(
    collect
    --output /Users/Shared/"$syslogFile"
    --last 1d
)

logger "Logging to $scriptLog"
logger "My generated log bundle is here $syslogFile"
logger "Collecting the log now..."
$log "${logOptions[@]}"
logger "Checking the log for errors.."
$log show /Users/Shared/"$syslogFile" --predicate 'processImagePath CONTAINS[c] "kernel" && eventMessage CONTAINS[c] "AppleUSBRequest::complete"' &> "/Users/Shared/cat_$syslogFile.txt" 2>&1

# Grep /Users/Shared/cat_$syslogFile.txt for "AppleUSBRequest::complete"
if grep -q "AppleUSBRequest::complete" "/Users/Shared/cat_$syslogFile.txt"; then
    logger "Found the search phrase in /Users/Shared/cat_$syslogFile.txt"
    # change uploader function to what you want, S3 upload etc.
    uploader
    rm /Users/Shared/"$syslogFile"
    rm /Users/Shared/cat_"$syslogFile".txt
    # exit 1 seems odd but you may want the script to exit with an error if it's *found*, so that your MDM alerts you of the "error"
    errorCode=1
else
    logger "Did not find the search phrase in /Users/Shared/cat_$syslogFile.txt"
fi

rm -f /Users/Shared/"$syslogFile"
rm /Users/Shared/cat_"$syslogFile".txt

logger "---------------------------------"
logger "Done"
exit $errorCode
