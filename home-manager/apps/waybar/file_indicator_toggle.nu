#!/usr/bin/env -S nu

def main [file_indicator, topic, act] {
  if $act {
    if ($file_indicator | path exists) {
      rm $file_indicator
    } else {
      touch $file_indicator
    }
  }
  let status = if ($file_indicator | path exists) {'enabled'} else {'disabled'};
  let result =  {
    text: "",
    tooltip: $"($topic) ($status)",
    alt: $status
  }
  $result | to json | to text | lines | str join | print
}
