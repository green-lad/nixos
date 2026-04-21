#!/usr/bin/env -S nu

def main [suspend] {
  swaylock -feF 
  niri msg action power-off-monitors
  if $suspend {
    systemctl suspend
  }
}
