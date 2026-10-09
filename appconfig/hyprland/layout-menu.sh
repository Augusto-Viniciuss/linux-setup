#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
choice="$(printf 'dwindle\nmaster\n' | rofi -dmenu -i -p 'Layout')" || exit 0
case "$choice" in
  dwindle|master)
    install -d "$config_home/hypr"
    printf '%s\n' "$choice" > "$config_home/hypr/layout"
    hyprctl keyword general:layout "$choice"
    notify-send 'Hyprland' "Layout: $choice"
    ;;
  *) exit 0 ;;
esac
