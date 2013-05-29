########
#
# secs_to_hours -- given seconds, returns a formatted string: HH:MM:SS
#
# $Id: secs_to_hours.tcl,v 1.1 2002/02/26 18:51:26 dwchin Exp $
#
########
proc secs_to_hours { secs } {
    set hr [expr $secs / 3600]
    set hs [expr $secs - [expr $hr * 3600]]
    set min [expr $hs / 60]
    set seconds [expr $hs - $min * 60]
    
    if {$seconds < 10} {
        set secstring "0$seconds"
    } else {
        set secstring "$seconds"
    }
    
    if {$min < 10} {
        set minstring "0$min"
    } else {
        set minstring "$min"
    }
    
    return "$hr:$minstring:$secstring"
}
#### END -- secs_to_hours
