#!/usr/bin/env bash
set -eu

pkill -x swaybg 2>/dev/null || true
exec linux-setup-hyprland-app swaybg \
  -i "$HOME/.local/share/linux-setup-hyprland/capybots.jpg" \
  -m fill
