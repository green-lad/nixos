#!/usr/bin/env -S nu

def main [take_action, simple_output] {
  let file_indicator = "/tmp/waybar_mail_nix_build.tmp";
  mut exists = $file_indicator | path exists
  if $take_action {
    if $exists {
      rm $file_indicator
    } else {
      touch $file_indicator
    }
    $exists = $file_indicator | path exists
  }
  if $simple_output {
    print $exists
  } else {
    let status = if $exists {'enabled'} else {'disabled'}
    let result =  {
      text: "",
      tooltip: $"send mail when finished ($status)",
      alt: $status
    }
    $result | to json | to text | lines | str join | print
  }
}
