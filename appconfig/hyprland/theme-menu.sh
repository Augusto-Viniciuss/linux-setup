#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
choice="$(printf 'DARK\nLIGHT\nGRUN\n' | rofi -dmenu -i -p 'Esquema de cores')" || exit 0
case "$choice" in
  DARK|LIGHT|GRUN)
    install -d "$config_home/hypr" "$config_home/kitty"
    printf '%s\n' "$choice" > "$config_home/hypr/theme"
    install -m 0644 "$config_home/kitty/themes/$choice.conf" "$config_home/kitty/current-theme.conf"
    "$config_home/hypr/apply-theme.sh"
    pkill -USR1 -x kitty 2>/dev/null || true
    notify-send 'Hyprland' "Esquema $choice aplicado."
    ;;
  *) exit 0 ;;
esac
