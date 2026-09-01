#!/bin/bash
set -u

if ! command -v bemenu >/dev/null; then
    notify-send "error" "bemenu is not installed."
    exit 1
fi

OPTIONS=(
    "lock"
    "logout"
    "suspend"
    "reboot"
    "shutdown"
)

readonly BEMENU_OPTS=("-i" "--fn" "JetBrains Mono Bold 25" "-p" "")

choice=$(IFS=$'\n'; echo "${OPTIONS[*]}" | bemenu "${BEMENU_OPTS[@]}")

[[ -z "$choice" ]] && exit 0

case "$choice" in
    "lock")     swaylock -c 000000 ;;
    "logout")   swaymsg exit ;;
    "suspend")  systemctl suspend ;;
    "reboot")   systemctl reboot ;;
    "shutdown") systemctl poweroff ;;
esac
