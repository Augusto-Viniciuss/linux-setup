#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
choice="$(printf 'DARK\nLIGHT\nGRUN\n' | linux-setup-hyprland-app rofi -dmenu -i -p 'Esquema de cores')" || exit 0
case "$choice" in
  DARK|LIGHT|GRUN)
    install -d "$config_home/hypr" "$config_home/kitty"
    printf '%s\n' "$choice" > "$config_home/hypr/theme"
    "$config_home/hypr/apply-theme.sh"
    pkill -USR1 -x kitty 2>/dev/null || true
    notify-send 'Hyprland' "Esquema $choice aplicado."
    ;;
  *) exit 0 ;;
esac
