#!/bin/bash
set -u

SCREENSHOTS_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOTS_DIR"

TIMESTAMP=$(date +'%Y-%m-%d-%H%M%S')
readonly BEMENU_OPTS=("-i" "--fn" "JetBrains Mono Bold 25" "-p" "")

check_dep() {
    if ! command -v "$1" >/dev/null; then
        notify-send "error" "$1 is not installed."
        exit 1
    fi
}

get_active_window_geometry() {
    sleep 0.15
    swaymsg -t get_tree | jq -er '
        recurse(.nodes[]?, .floating_nodes[]?)
        | select(.focused == true)
        | .rect
        | select(.width > 0 and .height > 0)
        | "\(.x),\(.y) \(.width)x\(.height)"
    ' 2>/dev/null
}

OPTIONS=("area" "window" "full")
choice=$(IFS=$'\n'; echo "${OPTIONS[*]}" | bemenu "${BEMENU_OPTS[@]}")

[[ -z "$choice" ]] && exit 0

case "$choice" in
    "area")
        check_dep grim; check_dep slurp; check_dep wl-copy
        FILENAME="$SCREENSHOTS_DIR/${TIMESTAMP}_area.png"
        geom=$(slurp)
        [[ -n "$geom" ]] && grim -g "$geom" "$FILENAME" && wl-copy < "$FILENAME"
        ;;
    "window")
        check_dep grim; check_dep jq; check_dep wl-copy
        FILENAME="$SCREENSHOTS_DIR/${TIMESTAMP}_window.png"
        geom=$(get_active_window_geometry)
        
        if [[ -z "$geom" || "$geom" == "0,0 0x0" ]]; then
            grim "$FILENAME" && wl-copy < "$FILENAME"
        else
            grim -g "$geom" "$FILENAME" && wl-copy < "$FILENAME"
        fi
        ;;
    "full")
        check_dep grim; check_dep wl-copy
        FILENAME="$SCREENSHOTS_DIR/${TIMESTAMP}_full.png"
        grim "$FILENAME" && wl-copy < "$FILENAME"
        ;;
esac
