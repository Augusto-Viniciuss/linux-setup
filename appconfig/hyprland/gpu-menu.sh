#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
choice="$(printf 'mesa\nnvidia\nnvidia-hybrid\n' | rofi -dmenu -i -p 'GPU da sessao')" || exit 0
case "$choice" in
  mesa|nvidia|nvidia-hybrid)
    install -d "$config_home/hypr"
    printf '%s\n' "$choice" > "$config_home/hypr/gpu"
    notify-send 'Hyprland' "GPU configurada para $choice. Encerre a sessao e entre novamente para aplicar."
    ;;
  *) exit 0 ;;
esac
