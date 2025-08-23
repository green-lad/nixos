#!/usr/bin/env -S nu

def main [] {
  let d = nmcli -t -f TYPE,DEVICE,STATE device | lines | parse -r '(?P<type>.*?):(?P<device>.*?):(?P<state>.*)' | where type == "ethernet" | get 0
  if $d.state == "connected" {
    nmcli dev down $d.device
  } else if $d.state == "disconnected" {
    nmcli dev up $d.device
  }
}
