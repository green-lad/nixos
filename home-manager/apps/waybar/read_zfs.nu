#!/usr/bin/env -S nu

def main []: nothing -> table {
  let data =  zfs list -j
    | from json
    | get datasets
    | transpose name data
    | get data
    | flatten
    | flatten
    | group-by pool
    | transpose pool data
    | each {
        |e| {
          pool: $e.pool,
          datasets: (
            $e.data
              | drop nth 0
              | select name mountpoint_value value
              | rename --column {mountpoint_value: mountpoint}
              | update value {into filesize}
              | insert percent {
                  (
                    (
                      $in
                        | get value
                        | into int
                    )
                    /
                    (
                      $e.data
                        | get 0
                        | get value
                        | into filesize
                        | into int
                    )
                    * 100
                  ) | math round --precision 0 | into int
                }
            ),
          used: ($e.data | get 0 | get value | into filesize)
          available: ($e.data | get 0 | get available_value | into filesize)
        }
      }
    | insert percent { ( ($in | get used | into int) / ($in | get available | into int) * 100 ) | math round --precision 0 | into int }
  # return $data
  return (
    {
      text: ($data | get 0 | get percent),
      tooltip: (nu -c $"($data | to nuon) | table -e -w 200")
    } | to json | to text | lines | str join
  )
}
