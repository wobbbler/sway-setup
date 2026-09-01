#!/bin/bash
set -u

# Очищаем историю dunst
dunstctl history-clear 2>/dev/null

# Получаем батарею
batt="N/A"
bats=(/sys/class/power_supply/BAT*)
[[ -f "${bats[0]}/capacity" ]] && batt="$(cat "${bats[0]}/capacity")%"

# Получаем воркспейсы гарантированно без символа перевода строки (\n)
workspaces=$(swaymsg -t get_workspaces | jq -j '[ .[] | if .focused then "\(.name)*" else .name end ] | join(" ")')
workspaces="${workspaces:-N/A}"

# Форматируем дату
datetime=$(date '+%a, %d.%m.%Y | %H:%M:%S')

# Показываем число окон в scratchpad, только если он не пуст.
scratchpad_count=$(swaymsg -t get_tree | jq '[recurse(.nodes[], .floating_nodes[]) | select(.scratchpad_state? == "fresh" or .scratchpad_state? == "changed")] | length')
if (( scratchpad_count > 0 )); then
    scratchpad=" | SP:$scratchpad_count"
else
    scratchpad=""
fi

# Отправляем весь текст строго как один аргумент (summary)
notify-send -t 3000 -h string:x-dunst-stack-tag:sysinfo "[$workspaces] | $batt | $datetime$scratchpad" ""
