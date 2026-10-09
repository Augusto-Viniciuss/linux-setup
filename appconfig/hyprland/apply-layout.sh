#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
layout="dwindle"
if [ -r "$config_home/hypr/layout" ]; then
  IFS= read -r layout < "$config_home/hypr/layout" || true
fi

case "$layout" in
  dwindle|master) hyprctl keyword general:layout "$layout" ;;
  *) printf 'Layout invalido salvo em %s/hypr/layout: %s\n' "$config_home" "$layout" >&2; exit 2 ;;
esac
