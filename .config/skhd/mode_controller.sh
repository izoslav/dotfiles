#!/usr/bin/env bash

# Colors taken from tokyo night theme

case "$1" in
default)
  spacebar -m config background_color   0xff282828
  spacebar -m config foreground_color   0xfffbf1c7
  ;;
resize)
  spacebar -m config background_color 0xffb8bb26
  spacebar -m config foreground_color 0xff282828
  ;;
launch)
  spacebar -m config background_color 0xff8ec07c
  spacebar -m config foreground_color 0xff282828
  ;;
esac
