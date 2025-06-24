#!/bin/sh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}

run "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
run "nm-applet"
run "ibus-daemon" -drxR
run "blueman-applet"
run "xcompmgr" -c -l0 -t0 -r0 -o.00
