#!/usr/bin/env -S nu
try {killall -q
polybar
}try {killall -q
.polybar-wrappe
}let monitors = xrandr --listmonitors
| lines | skip 1
| split column
-r
"[ x+/]"
--collapse-empty
n
s
x
xs
y
ys
xp
yp
name
let mirror_group = $monitors | group-by {($in xp)+($in yp)}--to-table
let monitor_mirror_group_leader = $mirror_group | each {get items | first | get name}
for $m in
$monitor_mirror_group_leader {sh -c
$"MONITOR=($m ) polybar top &"}
