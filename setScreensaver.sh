#!/bin/bash
#
# Set the screen saver time, password delay, and ask for
# password preference for the logged in user.
#
# Adam Codega
#

loggedinuser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

sudo -u "$loggedinuser" -i defaults -currentHost write com.apple.screensaver idleTime -int 600

sudo -u "$loggedinuser" -i defaults -currentHost write com.apple.screensaver askForPassword -int 1

sudo -u "$loggedinuser" -i defaults -currentHost write com.apple.screensaver askForPasswordDelay -int 0
