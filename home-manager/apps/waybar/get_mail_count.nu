#!/usr/bin/env -S nu

def get_tooltip [] {
  let last_success = (journalctl --user -r -u mbsync
    | lines
    | where {|e| $e =~ '.*: Finished mbsync mailbox synchronization\.'}
    | first
    | parse -r '(?P<time>.*\d\d:\d\d:\d\d) '
    | get time
    | get 0
  )

  let next_sync = systemctl --user show mbsync.timer -p TimersCalendar

  return {"last_successful_sync": $"'($last_success)'", "next_sync": $"'($next_sync)'"}
}

def have_network_connection [] {
  return ((nmcli networking connectivity) == 'full')
}

def get_state [maildir, channel] {
  let new_mails = (glob $'($maildir)/**/($channel)/**/new/*' | length)
  let opened_mails = (glob $'($maildir)/**/($channel)/**/cur/*' | length)
  let total = $new_mails + $opened_mails
  mut alt = ""
  mut icon = ""
  if $new_mails > 0 {
    $icon = " "
    $alt = "new"
  } else {
    $icon = " "
    $alt = "opened"
  }
  if not (have_network_connection) {
    $alt = $alt + "_failed"
  }
  return (
    {
      text: $"\(($new_mails)/($total)\)",
      tooltip: (nu -c $"(get_tooltip | to nuon) | table -e -w 200"),
      alt: $alt
    } | to json | to text | lines | str join
  )
}

def main [maildir = "~/Maildir", channel = "INBOX", --only_get_state, --get_tooltip] {
  if $get_tooltip {
    return (get_tooltip) 
  } else if $only_get_state {
    return (get_state $maildir $channel)
  } else {
    let send_job = { get_state $maildir $channel | job send 0 }
    try {
      mbsync -a -q
    }
    print (get_state $maildir $channel)
    job spawn { watch -r true $maildir $send_job }
    job spawn { watch /var/network.json $send_job }
    loop {
      print (job recv)
    }
  }
}
