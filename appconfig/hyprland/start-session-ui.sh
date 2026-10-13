#!/usr/bin/env bash
set -u

config_home="$HOME/.config/hypr"

# Apply the selected layout and theme before Waybar starts. apply-theme.sh
# reloads a running Waybar with SIGUSR2; sending that signal during Waybar's
# startup can terminate it before it installs its reload handler.
"$config_home/apply-layout.sh" || true
"$config_home/apply-theme.sh" || true

if pgrep -x waybar >/dev/null 2>&1; then
  exit 0
fi

exec "$HOME/.local/bin/linux-setup-hyprland-app" waybar
