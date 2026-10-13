#!/usr/bin/env bash
set -euo pipefail

workspace_id="${1:-}"
if [[ ! "$workspace_id" =~ ^([1-9]|10)$ ]]; then
  printf 'Use a workspace number from 1 to 10.\n' >&2
  exit 2
fi

active_id="$(hyprctl -j activeworkspace | jq -er '.id')"
if [ "$active_id" = "$workspace_id" ]; then
  state=active
else
  state=inactive
fi

case "$workspace_id" in
  1|2|3|4) label="$workspace_id: " ;;
  *) label="$workspace_id" ;;
esac

jq -cn --arg text "$label" --arg class "$state" \
  --arg tooltip "Workspace $workspace_id" \
  '{text: $text, class: $class, tooltip: $tooltip}'
