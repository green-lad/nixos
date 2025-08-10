#!/usr/bin/env -S nu

def main [cmd, quit_keys = [q, esc], retry_keys = [enter]] {
  let entry_keys = $quit_keys | append $retry_keys
  mut c = ""

  while not ($c in $quit_keys) {
    $c = try {
      nu -c $cmd
      "q"
    } catch { |err|
      print ($err.msg)
      print $"(ansi green_italic){quit: $($quit_keys), retry: $($retry_keys)}(ansi reset)"
      mut ct = ""
      while not ($ct in $entry_keys) {
        try {
          sleep 100ms
          $ct = (input listen).code
        }
      }
      $ct
    }
  }
}
