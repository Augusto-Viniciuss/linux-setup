#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
choice="$(printf 'dwindle\nmaster\n' | linux-setup-hyprland-app rofi -dmenu -i -p 'Layout')" || exit 0
case "$choice" in
  dwindle|master)
    install -d "$config_home/hypr"
    printf '%s\n' "$choice" > "$config_home/hypr/layout"
    "$config_home/hypr/apply-layout.sh"
    notify-send 'Hyprland' "Layout: $choice"
    ;;
  *) exit 0 ;;
esac
