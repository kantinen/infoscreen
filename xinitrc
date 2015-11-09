#!/bin/sh

xsetroot -solid white
export PATH=/home/odroid/bin:$PATH
xdotool mousemove 2000 2000
(sleep 5; infoscreen/background/irc.sh) &

# If X has restarted then tmux with the kantinfo script may already
# be running - if so, kill it before we start a new one.
tmux kill-session -t kantinfo

dbus-launch tmux new-session -s kantinfo -d './kantinfo/kantinfo.py infoscreen/content; bash'
exec matchbox-window-manager -use_titlebar no
