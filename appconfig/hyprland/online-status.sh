#!/usr/bin/env bash
set -eu

if ping -n -q -c 1 -W 1 google.com >/dev/null 2>&1; then
  printf '{"text":"Online","class":"online"}\n'
else
  printf '{"text":"No Internet","class":"offline"}\n'
fi
