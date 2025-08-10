#!/usr/bin/env -S nu

def pick_color [] {
  let color = niri msg pick-color
    | lines
    | str join "; "
    | parse --regex '.*?(?P<rgb>rgb\(.*?\)).*?(?P<hex>#\w+)'
    | get hex
    | to text
  if ($color | is-empty) {
    return false
  }
  $color | pastel color
  $color | wl-copy
  return true
}

def main [] {
  while (pick_color) { }
}
