#!/usr/bin/env -S nu

def main [url revision = ""] {
  # TODO: add other compatible formats
  if ($url | parse --regex '.*\.(?<ext>(zip)|(tar\.gz))$' | length) > 0 {
    nix hash convert $"sha256:(nix-prefetch-url --unpack $url --quiet)"
  } else {
    if ($revision | is-not-empty) {
      nix-shell -p nix-prefetch-git jq --run "nix hash convert sha256:\$(nix-prefetch-git --url $url --rev $revision --quiet | jq -r '.sha256')"
    } else {
      nix-shell -p nix-prefetch-git jq --run "nix hash convert sha256:\$(nix-prefetch-git --url $url --quiet | jq -r '.sha256')"
    }
  }
}
