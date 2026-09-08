#!/usr/bin/env -S nu

def main [value=0] {
  let audio_outputs = rmpc outputs | from yaml
  let current_speed = $audio_outputs | where { |e| $e.enabled } | first | get id
  mut next_speed = $current_speed + $value
  if $value == 0 {
    let default_value_name = "pipewire (semitone-0)"
    $next_speed = $audio_outputs | where { |e| $e.name == $default_value_name } | first | get id
  }
  if $next_speed != $current_speed and $next_speed in ($audio_outputs | get id) {
    print $next_speed
    rmpc toggleoutput $next_speed
    rmpc toggleoutput $current_speed
  }
}
