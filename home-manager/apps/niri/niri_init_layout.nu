#!/usr/bin/env -S nu

niri msg action spawn -- librewolf
niri msg action spawn -- wezterm

while not (niri msg -j windows | from json | any {|e| $e.app_id == "librewolf"}) {
  sleep 100ms
}
let librewolf_id = niri msg -j windows | from json | where {|e| $e.app_id == "librewolf"} | get 0 | get id
niri msg action focus-window --id $librewolf_id
niri msg action move-window-to-workspace 1
niri msg action focus-window-previous
