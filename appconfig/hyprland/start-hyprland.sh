#!/usr/bin/env bash
set -eu

# Login managers may not load the user's shell PATH.
export PATH="$HOME/.local/bin:$HOME/.local/share/linux-setup-hyprland:$HOME/.nix-profile/bin:$PATH"
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE XDG_DATA_DIRS || true
fi
if command -v systemctl >/dev/null 2>&1; then
  systemctl --user start pipewire.socket wireplumber.service >/dev/null 2>&1 || true
fi

# Hyprland 0.55+ detects and invokes the nixGL executable itself. The
# linux-setup nixGL shim at the front of PATH selects the configured GPU.
exec "$HOME/.nix-profile/bin/start-hyprland" "$@"
