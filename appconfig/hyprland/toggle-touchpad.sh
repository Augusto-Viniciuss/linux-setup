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
  enabled=true
  rm -f "$state_file"
  message='Touchpad ativado.'
else
  enabled=false
  : > "$state_file"
  message='Touchpad desativado.'
fi

lua_device="$(printf '%s' "$device" | jq -Rr @json)"
hyprctl eval "hl.device({ name = $lua_device, enabled = $enabled })"
notify-send 'Hyprland' "$message"
