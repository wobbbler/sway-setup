#!/bin/bash
NIGHT="1.0 0.65 0.15" 
DAY="1.0 1.0 1.0"    

export SWAYSOCK="/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway | head -1).sock"
export DISPLAY=:0

apply_mode() {
    local mode=$1
    swaymsg "output * filter_color $mode" 2>/dev/null
}

HOUR=$(date +%H)

if [ "$HOUR" -ge 19 ] || [ "$HOUR" -lt 7 ]; then
    apply_mode "$NIGHT"
else
    apply_mode "$DAY"
fi
