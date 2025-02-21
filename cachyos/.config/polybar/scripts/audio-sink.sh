#!/usr/bin/env bash
set -euo pipefail

if [[ $(amixer get Master) == *"off"* ]]; then
  echo -e "\uf026 "
else
  if [[ $(pactl get-default-sink) == *"hdmi"* ]]; then
    echo -e "\uf028"
  else
    echo -e "\uf025"
  fi
fi
