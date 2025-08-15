#!/usr/bin/env -S nu

def main [sops_otp_file = "~/sops_secrets/otp.yaml"] {
  let otp_secrets = sops -d ($sops_otp_file | path expand) | from yaml
  let choice = $otp_secrets.tokens.issuerExt | to text | fuzzel -d
  if $env.LAST_EXIT_CODE > 0 { exit }
  let otp_base32_secret = (
    $otp_secrets
      | get tokens
      | where issuerExt == $choice
      | get 0
      | get secret
      | each { |e| if $e < 0 {$e + 256} else {$e}
          | into binary -c
          | encode hex
        }
      | str join
      | decode hex
      | encode base32
  )
  $otp_base32_secret | oathtool --totp | wl-copy
}
