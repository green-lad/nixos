#!/usr/bin/env -S nu

def main [type] {
  let ids = rfkill list $type -o ID -n -r | lines
  print (
    {
      text: " - ",
      tooltip: $"($type) not found",
      # alt: (job recv)
    } | to json | to text | lines | str join
  )
  job spawn {
    rfkill event
      | lines
      | parse -r 'idx (?P<id>\d+).*soft (?P<state>[01])'
      | where {$in.id in $ids}
      | get state
      | each { if $in == "0" {"open"} else {"blocked"} }
      | each { job send 0 }
  }
  loop {
    print (
      {
        text: "",
        tooltip: $type,
        alt: (job recv)
      } | to json | to text | lines | str join
    )
  }
}
