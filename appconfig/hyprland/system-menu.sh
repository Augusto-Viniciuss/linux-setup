#!/usr/bin/env bash
set -eu

action=$(printf 'lock\nsuspend\nhibernate\nlogout\nreboot\nshutdown\n' | rofi -dmenu -i -p 'Power')
case "$action" in
  lock) swaylock ;;
  suspend) swaylock --daemonize && systemctl suspend ;;
  hibernate) swaylock --daemonize && systemctl hibernate ;;
  logout) hyprctl dispatch exit ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
  *) exit 0 ;;
esac
