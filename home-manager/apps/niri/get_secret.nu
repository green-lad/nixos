#!/usr/bin/env -S nu

def main [secrets_file = "~/sops_secrets/other.yaml"] {
  mut secrets = sops -d ($secrets_file | path expand) | from yaml
  while ($secrets | describe) != "string" and ($secrets | describe) != "int" {
    $secrets = $secrets | transpose key value
    let choice = $secrets | get key | to text | fuzzel -d
    if $env.LAST_EXIT_CODE != 0 {
      return $env.LAST_EXIT_CODE
    }
    $secrets = $secrets | where {|e| $e.key == $choice} | get 0 | get value
  }
  $secrets | into string | wl-copy
}
