#!/usr/bin/env bash
set -eu

if ! command -v jq >/dev/null 2>&1; then
  notify-send 'Hyprland' 'O comando jq nao esta disponivel.'
  exit 1
fi

device="$(hyprctl devices -j | jq -r '[.mice[]? | select((.name | ascii_downcase) | contains("touchpad")) | .name][0] // empty')"
if [ -z "$device" ]; then
  notify-send 'Hyprland' 'Nenhum touchpad foi encontrado.'
  exit 0
fi

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
state_file="$runtime_dir/linux-setup-touchpad-disabled-${UID:-$(id -u)}"
if [ -e "$state_file" ]; then
  hyprctl keyword "device:$device:enabled" true
  rm -f "$state_file"
  notify-send 'Hyprland' 'Touchpad ativado.'
else
  hyprctl keyword "device:$device:enabled" false
  : > "$state_file"
  notify-send 'Hyprland' 'Touchpad desativado.'
fi
