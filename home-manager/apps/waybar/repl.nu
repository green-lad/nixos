#!/usr/bin/env -S nu

def main [cmd, file_indicator = '', mail_address = "markus.schoetz@fau.de", quit_keys = [q, esc], retry_keys = [enter]] {
  let entry_keys = $quit_keys | append $retry_keys
  mut c = ""
  mut result = {exit_code: 1}

  while $result.exit_code > 0 and not ($c in $quit_keys) {
    let start_time = date now
    $result = do -i { nu -c $cmd } | tee -e { print } | tee { print } | complete
    if ($file_indicator | path exists) {
      let header = if $result.exit_code > 0 { $"Nixos ($start_time) failed" } else { $"Nixos ($start_time) succeeded" }
      $result | neomutt -s $header $mail_address
    }

    if $result.exit_code > 0 {
      print $"(ansi green_italic){quit: $($quit_keys), retry: $($retry_keys)}(ansi reset)"

      $c = ""
      while not ($c in $entry_keys) {
        try {
          sleep 100ms
          $c = (input listen).code
        }
      }
    }
  }
}

