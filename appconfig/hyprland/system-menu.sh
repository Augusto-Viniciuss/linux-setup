#!/usr/bin/env bash
set -eu

action=$(printf 'lock\nsuspend\nhibernate\nlogout\nreboot\nshutdown\n' | linux-setup-hyprland-app rofi -dmenu -i -p 'Power')
case "$action" in
  lock) linux-setup-hyprland-app swaylock ;;
  suspend) linux-setup-hyprland-app swaylock --daemonize && systemctl suspend ;;
  hibernate) linux-setup-hyprland-app swaylock --daemonize && systemctl hibernate ;;
  logout) hyprctl dispatch 'hl.dsp.exit()' ;;
  reboot) systemctl reboot ;;
  shutdown) systemctl poweroff ;;
  *) exit 0 ;;
esac
