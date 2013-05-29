########
#
# get_segments -- get segments of a length >= min_segment_length
#                 from a given time series
#
# $Id: get_segments.tcl,v 1.3 2002/04/11 19:50:58 dwchin Exp $
#
########
proc get_segments { tseries min_segment_length} {
    # Now, use the $tseries to find the segments
    # that are longer than $min_segment_length, and stuff them
    # in a list
    set last_locked_p  0
    set locked_p       0
    set time           [expr $::e7_start_time - 1]
    set start_time     0
    set segment_length 0
    set segment_list [list]
    
    puts_debug "get_segments: entered" 0

    foreach x $tseries {
        
        incr time
        
        if { ! $locked_p } { # not in lock at previous second
            
            if { $x } {          # in lock for current second
                
                # we have transitioned to lock
                
                set locked_p 1
                set start_time $time
                
                puts_debug "get_segments: Lock acquired: $start_time" 2
            } 
            
            continue
        } else {             # in lock at previous second
            
            if { ! $x } {        # not in lock for current second
                
                # we have transitioned out of lock
                
                set locked_p 0
                
                puts_debug "get_segments: Lock lost: start_time = $start_time" 2
                
                set segment_length [expr [expr $time - $start_time] - 1]
                
                if { $segment_length >= $min_segment_length } {
                    lappend segment_list [list $start_time $segment_length]
                }
                
                puts_debug "get_segments: Lock lost: $segment_length (end time = $time)" 2
            }
            
            continue
        }
    }
    
    # if there were no segments, make the segment list
    # a null list
    if { [llength $segment_list] == 0 } {
        lappend segment_list [list]
    }
    
    return $segment_list
} 
#### END -- get_segments()
