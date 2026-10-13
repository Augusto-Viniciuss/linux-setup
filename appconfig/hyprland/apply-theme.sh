#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
theme="DARK"
if [ -r "$config_home/hypr/theme" ]; then
  IFS= read -r theme < "$config_home/hypr/theme" || true
fi

case "$theme" in
  DARK) active='rgba(005fafff)'; inactive='rgba(333333ff)' ;;
  LIGHT) active='rgba(aaaaaaff)'; inactive='rgba(ddddddff)' ;;
  GRUN) active='rgba(3f8f00ff)'; inactive='rgba(333333ff)' ;;
  *) printf 'Tema invalido salvo em %s/hypr/theme: %s\n' "$config_home" "$theme" >&2; exit 2 ;;
esac

install -m 0644 "$config_home/kitty/themes/$theme.conf" "$config_home/kitty/current-theme.conf"
install -m 0644 "$config_home/rofi/themes/$theme.rasi" "$config_home/rofi/current-theme.rasi"
install -m 0644 "$config_home/waybar/themes/$theme.css" "$config_home/waybar/theme.css"

hyprctl eval "hl.config({ general = { col = { active_border = \"$active\", inactive_border = \"$inactive\" } }, group = { groupbar = { col = { active = \"$active\", inactive = \"$inactive\" } } } })"
pkill -USR2 -x waybar 2>/dev/null || true
