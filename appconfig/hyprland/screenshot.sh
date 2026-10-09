#!/usr/bin/env bash
set -eu

area="$(slurp)" || exit 0
[ -n "$area" ] || exit 0

output_dir="$HOME/Pictures/Screenshots"
install -d "$output_dir"
output_file="$output_dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
grim -g "$area" "$output_file"
wl-copy < "$output_file"
notify-send 'Captura de tela' "Salva e copiada: $output_file"
