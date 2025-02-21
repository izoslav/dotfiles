#!/usr/bin/env bash
set -euo pipefail

HDMI_SINK=$(pactl list short sinks | grep hdmi | cut -f1)
HEADPHONES_SINK=$(pactl list short sinks | grep Scarlett | cut -f1)

if [[ $(pactl get-default-sink) == *"hdmi"* ]]; then
  pactl set-default-sink $HEADPHONES_SINK
else
  pactl set-default-sink $HDMI_SINK
fi
