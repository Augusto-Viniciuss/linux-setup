#!/usr/bin/env bash
set -eu

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
nix_profile="$HOME/.nix-profile/bin"
choices=(mesa)
if [ -x "$nix_profile/nixGLNvidia" ]; then
  choices+=(nvidia)
fi
if [ -x "$nix_profile/nixGLNvidiaBumblebee" ]; then
  choices+=(nvidia-hybrid)
fi
choice="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p 'GPU da sessao')" || exit 0
case "$choice" in
  mesa|nvidia|nvidia-hybrid)
    install -d "$config_home/hypr"
    printf '%s\n' "$choice" > "$config_home/hypr/gpu"
    notify-send 'Hyprland' "GPU configurada para $choice. Encerre a sessao e entre novamente para aplicar."
    ;;
  *) exit 0 ;;
esac
