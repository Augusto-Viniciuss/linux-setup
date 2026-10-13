#!/usr/bin/env bash
set -euo pipefail

layout="$(hyprctl -j devices | jq -r '.keyboards[]? | select(.main == true) | .active_keymap' | head -n 1)"
if [ -z "$layout" ]; then
  layout="$(hyprctl -j devices | jq -r '.keyboards[0].active_keymap // "Unknown"')"
fi

case "$layout" in
  *Czech*|*Cesky*) label=CZ ;;
  *English*|*US*) label=US ;;
  *) label="$layout" ;;
esac

jq -cn --arg text " $label" --arg tooltip "Keyboard layout: $layout" \
  '{text: $text, tooltip: $tooltip}'
