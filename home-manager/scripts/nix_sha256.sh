#!/bin/sh

# for zips:
# nix-prefetch-url --unpack <zip_url>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <github link> [<revision>]" >&2
  exit 1
fi
url="$1"
if [ "$#" -ge 2 ]; then
  rev="$2"
  nix-shell -p nix-prefetch-git jq --run "nix hash convert sha256:\$(nix-prefetch-git --url $url --rev $rev --quiet | jq -r '.sha256')"
else
  nix-shell -p nix-prefetch-git jq --run "nix hash convert sha256:\$(nix-prefetch-git --url $url --quiet | jq -r '.sha256')"
fi
