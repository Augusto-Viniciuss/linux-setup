#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
if ! command -v brightnessctl >/dev/null 2>&1; then
  notify-send 'Brilho' 'brightnessctl nao esta instalado.'
  exit 1
fi

if ! brightnessctl --class=backlight -l >/dev/null 2>&1; then
  notify-send 'Brilho' 'Nenhum dispositivo de brilho de tela foi encontrado.'
  exit 0
fi

read_percent() {
  local current maximum
  current="$(brightnessctl --class=backlight -q get)"
  maximum="$(brightnessctl --class=backlight -q max)"
  [ "$maximum" -gt 0 ] || return 0
  printf '%s\n' "$((current * 100 / maximum))"
}

before="$(read_percent)"

case "$action" in
  -) brightnessctl --class=backlight -e4 -n2 set 10%- ;;
  +) brightnessctl --class=backlight -e4 -n2 set 10%+ ;;
  -5) brightnessctl --class=backlight -e4 -n2 set 5%- ;;
  +5) brightnessctl --class=backlight -e4 -n2 set 5%+ ;;
  2) brightnessctl --class=backlight -e4 -n2 set 2% ;;
  100) brightnessctl --class=backlight -e4 -n2 set 100% ;;
  *) printf 'Uso: %s {+|-|+5|-5|2|100}\n' "$0" >&2; exit 2 ;;
esac

after="$(read_percent)"
if [ "$after" -le 5 ]; then
  brightnessctl --class=backlight -e4 -n2 set 5% >/dev/null
  notify-send -u low -t 500 'Brilho minimo' 'O brilho foi mantido em 5%.'
elif [ "$action" = + ] && [ "$after" -eq "$before" ]; then
  notify-send -u low -t 500 'Brilho maximo' 'O brilho ja esta no maximo.'
fi
