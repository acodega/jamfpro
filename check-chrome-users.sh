#!/bin/bash
#
# check-chrome-users.sh
#
# Extension attribute to report which accounts
# are logged into Google Chrome on a Mac.
#
# For use as a JAMF Casper Suite extension attribute
#
# Adam Codega, Swipely
#

loggedinuser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

chromestate=`cat /Users/$loggedinuser/Library/Application\ Support/Google/Chrome/Local\ State | python -m json.tool | grep user_name`

echo "<result>$chromestate</result>"
