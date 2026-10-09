#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "${1:-}" = "--legacy" ]; then
  shift
  exec bash "$repo_root/install-legacy.sh" "$@"
fi

if [ "$#" -gt 0 ]; then
  printf 'Uso: %s [--legacy [opcoes antigas]]\n' "$0" >&2
  printf 'O perfil Hyprland nao aceita opcoes adicionais.\n' >&2
  exit 2
fi

exec bash "$repo_root/appconfig/hyprland/install.sh"
