#!/bin/bash
set -u

pkill -x swayidle 2>/dev/null || true
sleep 0.2

# 5m: dim, 6m40s: lock, 10m: turn displays off.
exec swayidle -w \
    timeout 300 "$HOME/.config/sway/scripts/dimmer.sh" \
        resume "$HOME/.config/sway/scripts/dimmer.sh stop" \
    timeout 400 "swaylock -f -c 000000" \
    timeout 600 "swaymsg 'output * power off'" \
        resume "swaymsg 'output * power on'" \
    before-sleep "$HOME/.config/sway/scripts/dimmer.sh stop; pgrep -x swaylock >/dev/null || swaylock -f -c 000000" \
    lock "$HOME/.config/sway/scripts/dimmer.sh stop; pgrep -x swaylock >/dev/null || swaylock -f -c 000000"
