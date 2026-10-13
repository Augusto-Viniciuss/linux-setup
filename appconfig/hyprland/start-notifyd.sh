#!/usr/bin/env bash
set -euo pipefail

notifyd="$(command -v xfce4-notifyd 2>/dev/null || true)"
if [ -z "$notifyd" ]; then
  for candidate in \
    /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd \
    /usr/lib/xfce4/notifyd/xfce4-notifyd; do
    if [ -x "$candidate" ]; then
      notifyd="$candidate"
      break
    fi
  done
fi

if [ -z "$notifyd" ]; then
  printf 'xfce4-notifyd nao foi encontrado.\n' >&2
  exit 127
fi

exec "$HOME/.local/bin/linux-setup-hyprland-app" "$notifyd"
