#!/usr/bin/env bash
set -eu

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

for number in {1..20}; do
  (
    if ping -n -q -c 1 -W 1 "192.168.69.$((100 + number))" >/dev/null 2>&1; then
      printf 'online' > "$temp_dir/$number"
    else
      printf 'offline' > "$temp_dir/$number"
    fi
  ) &
done
wait

reachable=()
tooltip_lines=()
for number in {1..20}; do
  state="$(cat "$temp_dir/$number")"
  if [ "$state" = online ]; then
    reachable+=("uav$number")
  fi
  tooltip_lines+=("uav$number: $state")
done

if [ "${#reachable[@]}" -gt 0 ]; then
  display="$(IFS=' '; printf '%s' "${reachable[*]}")"
  status_class=online
else
  display='UAV: offline'
  status_class=offline
fi
tooltip="$(printf '%s\\n' "${tooltip_lines[@]}")"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$display" "$tooltip" "$status_class"
