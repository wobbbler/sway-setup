#!/usr/bin/env bash
set -euo pipefail

readonly BEMENU_OPTS=(
    "-i"
    "--fn" "JetBrains Mono 12"
    "-l" "15"
    "--scrollbar" "autohide"
    "--counter" "none"
    "--fixed-height"
    "-p" ""
)
readonly PREVIEW_WIDTH=120
export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

check_dep() {
    if ! command -v "$1" >/dev/null; then
        notify-send "error" "$1 is not installed."
        exit 1
    fi
}

check_dep bemenu
check_dep cliphist
check_dep wl-copy

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

items_file="$tmpdir/items"
display_file="$tmpdir/display"

cliphist list >"$items_file"
[[ -s "$items_file" ]] || exit 0

awk -v width="$PREVIEW_WIDTH" '
{
    item = $0
    gsub(/\t+/, " ", item)
    gsub(/[[:space:]]+/, " ", item)

    if (length(item) > width) {
        item = substr(item, 1, width - 3) "..."
    }

    printf "%04d  %s\n", NR, item
}
' "$items_file" >"$display_file"

selected=$(bemenu "${BEMENU_OPTS[@]}" <"$display_file")
[[ -n "$selected" ]] || exit 0

index=${selected%% *}
[[ "$index" =~ ^[0-9]+$ ]] || exit 0

line_number=$((10#$index))
sed -n "${line_number}p" "$items_file" | cliphist decode | wl-copy
