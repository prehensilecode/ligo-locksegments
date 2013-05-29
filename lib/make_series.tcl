########
#
# make_series -- convert a list of segments to a time series
#
# $Id: make_series.tcl,v 1.6 2002/04/12 20:55:50 dwchin Exp $
#
########
proc make_series { segment_list } {
    
    puts_debug "make_series: segment_list =  $segment_list" 2
    
    for { set now $::e7_start_time } { $now < $::e7_end_time } { incr now } {
        
        #
        # we have to find the right segment
        #
        if { [llength $segment_list] > 0 } {  # segment list is non-empty
            
            #
            # drop segments which ended before the current time
            #
            set segment_start_time [lindex [lindex $segment_list 0] 0]
            set segment_length     [lindex [lindex $segment_list 0] 1]
            
            if { [info exists ::DEBUG] && ($::DEBUG > 2) } {
                if { [llength $segment_list] < 25 } {
                    puts_debug "make_series: segment_list length = [llength $segment_list]" 5
                    puts_debug "make_series: now = $now; [lindex $segment_list 0]: $segment_start_time, $segment_length" 5
                }
            }
            
            while { ([llength $segment_list] > 0) && ($now > [expr $segment_start_time + $segment_length]) } {
                set segment_list       [lrange $segment_list 1 [expr [llength $segment_list] - 1]]
                set segment_start_time [lindex [lindex $segment_list 0] 0]
                set segment_length     [lindex [lindex $segment_list 0] 1]
            }
            
            
            #
            # form the time series
            #
            if { [llength $segment_list] > 0 } { # we haven't exhausted the list
                set segment_end_time [expr $segment_start_time + $segment_length]
                
                # there are now 2 possibilities: current time occurs
                # before the beginning of a segment, or current time 
                # occurs within a segment
                if { $now < $segment_start_time } {
                    lappend clean_detect_series 0
                } elseif { ($now >= $segment_start_time) && ($now <= $segment_end_time)} {
                    puts_debug "make_series: $now in clean detect segment" 5
                    lappend clean_detect_series 1
                } else {
                    # should never reach here
                    puts stderr "Unknown error"
                    exit 1
                }
            } else { # we have exhausted the list
                lappend clean_detect_series 0
            }
        } else {     # segment list is empty
            lappend clean_detect_series 0
        }
    }
    
    puts_debug "make_series: length of clean_detect_series = [llength $clean_detect_series]" 0
    
    return $clean_detect_series
}
#### END -- make_series
