#!/bin/bash

# Configure the dock for a new user

DOCKUTIL=/usr/local/bin/dockutil

$DOCKUTIL --remove all --no-restart

$DOCKUTIL --add '/Applications/Launchpad.app' --no-restart

$DOCKUTIL --add '/Applications/Google Chrome.app' --no-restart

$DOCKUTIL --add '/Applications/System Preferences.app' --no-restart

$DOCKUTIL --add '~/Downloads'

sleep 2

/usr/bin/killall Dock >/dev/null 2>&1

exit 0