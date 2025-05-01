#!/bin/sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Firefox.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/Discord.app"
dockutil --no-restart --add "/Applications/Warp.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Gitkraken.app"

killall Dock
