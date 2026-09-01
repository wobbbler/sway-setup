#!/bin/bash
set -u

readonly STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/sway-dimmer"
mkdir -p "$STATE_DIR"

readonly PIDFILE="$STATE_DIR/pid"
readonly ORIG_BRIGHTNESS_FILE="$STATE_DIR/orig_brightness"

if ! command -v brightnessctl >/dev/null; then
    exit 1
fi

restore_brightness() {
    if [[ -f "$ORIG_BRIGHTNESS_FILE" ]]; then
        local orig
        orig=$(cat "$ORIG_BRIGHTNESS_FILE")
        if [[ "$orig" =~ ^[0-9]+$ ]]; then
            brightnessctl set "$orig" >/dev/null 2>&1
        fi
        rm -f "$ORIG_BRIGHTNESS_FILE"
    fi
}

stop_dimming() {
    if [[ -f "$PIDFILE" ]]; then
        local pid
        pid=$(cat "$PIDFILE")
        if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null; then
            kill -TERM "$pid" 2>/dev/null
            wait "$pid" 2>/dev/null
        fi
        rm -f "$PIDFILE"
    fi
    restore_brightness
    exit 0
}

if [[ "${1:-}" == "stop" ]]; then
    stop_dimming
fi

if [[ -f "$PIDFILE" ]]; then
    pid=$(cat "$PIDFILE")
    if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null; then
        exit 0
    fi
fi

if [[ ! -f "$ORIG_BRIGHTNESS_FILE" ]]; then
    brightnessctl get >"$ORIG_BRIGHTNESS_FILE"
fi

current_pct=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
if [[ "$current_pct" -le 10 ]]; then
    rm -f "$ORIG_BRIGHTNESS_FILE"
    exit 0
fi

(
    trap "exit" TERM INT
    
    while true; do
        current_brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        
        if [[ -z "$current_brightness" || "$current_brightness" -le 10 ]]; then
            break
        fi
        
        brightnessctl set 2%- >/dev/null 2>&1
        sleep 0.2
        
        new_brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        if [[ "$new_brightness" -ge "$current_brightness" ]]; then
            break
        fi
    done
) &

echo $! >"$PIDFILE"
