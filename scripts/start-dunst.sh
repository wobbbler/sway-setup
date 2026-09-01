#!/bin/bash
set -u

pkill -x dunst 2>/dev/null || true
sleep 0.2

exec dunst -config "$HOME/.config/dunst/dunstrc"
