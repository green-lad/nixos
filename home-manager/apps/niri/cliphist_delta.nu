#!/usr/bin/env -S nu

def update_files [a, b] {
  let c = cliphist list | lines
  $c | get 0 | cliphist decode | save -f $a
  $c | get 1 | cliphist decode | save -f $b
}

def main [] {
  let a = mktemp -t
  let b = mktemp -t

  mut s = true
  mut c = "u"
  while not ($c in ["q", "esc"]) {
    if $c == "u" {
      update_files $a $b
    }
    if $c == "s" {
      $s = not $s
    }
    try {
      clear
      # calling it this way updates the window size seen by delta
      if $s {
        nu -c $'delta -s ($a) ($b)'
      } else {
        nu -c $'delta ($a) ($b)'
      }
    }

    print $"(ansi green_italic){quit: [q, esc], update: [u], toggle_side_view: [s], refresh: [<other>]}(ansi reset)"
    $c = ""
    while $c == "" {
      try {
        sleep 100ms
        $c = (input listen).code
      }
    }
  }

  rm $a $b
}
