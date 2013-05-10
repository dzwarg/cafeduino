package require http

global chisto
set chisto [dict create]

bind pub - .coffee getcoffee
proc getcoffee {nick host handle chan args} {
  global chisto
        set cbuffer 5
        set cip "192.168.1.96"
        set feed 1

  if {[dict exists $chisto $nick last]} {
          set buffer [dict get $chisto $nick last]
    set now [clock seconds]
                if {$now > $buffer} {
                  dict set chisto $nick last [clock add [clock seconds] $cbuffer minutes]
                        dict set chisto $nick count 1
                } else {
                        set ndict [dict get $chisto $nick]
                  dict incr ndict count
                        dict set chisto $nick $ndict
                }
        } else {
                dict set chisto $nick last [clock add [clock seconds] $cbuffer minutes]
                dict set chisto $nick count 1
        }

        set token [::http::geturl "http://$cip/"]
  set body [::http::data $token]
        set match [regexp {(\d+),(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)} $body whole min1 min2 w1 w2 max1 max2 life]

        if {$match eq 0} {
          putlog "cafeduino: could not read HTTP response from device"
                puthelp "PRIVMSG $chan : $nick: sorry, I asked the cafeduino, but it didn't respond in a way that I expected."
                return 1
        }

  if { $feed == 0 } {
          set current [expr {double($w1-$min1)/double($max1-$min1)}]
  } else {
          set current [expr {double($w2-$min2)/double($max2-$min2)}]
        }
        set current [expr {round($current*10000)/double(100)}]

  if {[dict get $chisto $nick count] > 4} {
                if {[dict get $chisto $nick level]*0.95<$current &&
                    [dict get $chisto $nick level]*1.05>$current} {
                        # level hasn't changed, and nick is asking so damn much
                        puthelp "PRIVMSG $chan : $nick, why don't you go refresh the pot? It hasn't changed, and you keep nagging me."
                        return 0
                }
        }

        dict set chisto $nick level $current
        puthelp "PRIVMSG $chan : $nick: Cafeduino is $current% full."

        return 0
}

putlog "Loaded cafeduino module."

