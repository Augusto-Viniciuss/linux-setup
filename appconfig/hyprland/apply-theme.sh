#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
theme="DARK"
if [ -r "$config_home/hypr/theme" ]; then
  IFS= read -r theme < "$config_home/hypr/theme" || true
fi

case "$theme" in
  DARK) active='rgba(005fafff)'; inactive='rgba(333333ff)' ;;
  LIGHT) active='rgba(005fafff)'; inactive='rgba(aaaaaaff)' ;;
  GRUN) active='rgba(87af5fff)'; inactive='rgba(4e4e4eff)' ;;
  *) printf 'Tema invalido salvo em %s/hypr/theme: %s\n' "$config_home" "$theme" >&2; exit 2 ;;
esac

hyprctl keyword general:col.active_border "$active"
hyprctl keyword general:col.inactive_border "$inactive"
