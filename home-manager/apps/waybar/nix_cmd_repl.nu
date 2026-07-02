#!/usr/bin/env -S nu

def main [cmd, file_indicator_send_mail = '', file_indicator_use_internal_cache = '', mail_address = "markus.schoetz@fau.de", quit_keys = [q, esc], retry_keys = [enter]] {
  let entry_keys = $quit_keys | append $retry_keys
  mut c = ""
  mut result = {exit_code: 1}
  mut options = ""

  if ($file_indicator_use_internal_cache | path exists) {
    $options = $"--option substituters 'https://cache.nixos.org/?priority=1'"
  }

  let to_execute = $"($cmd) ($options)"

  while $result.exit_code > 0 and not ($c in $quit_keys) {
    let start_time = date now
    $result = do -i { nu -c $to_execute } | tee -e { print } | tee { print } | complete
    if ($file_indicator_send_mail | path exists) {
      let header = $"'($cmd)' ($start_time) (if $result.exit_code > 0 { "failed" } else { "succeeded" })"
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

