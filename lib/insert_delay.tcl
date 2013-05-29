# Author: David Chin <dwchin@umich.edu>
# Phone: 734-763-7208
# Mobile: 734-730-1274
#
# $Id: insert_delay.tcl,v 1.4 2002/04/11 19:50:40 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 


#########
#
# insert_delay
#    make sure the start of a segment is at least 60 seconds
#    after the end of the previous segment
#
########
proc insert_delay { segment_list } {
    
    set prev_end_time 0
    
    set counter 0
    foreach x $segment_list {
        set cur_start_time [lindex $x 0]
        set cur_duration   [lindex $x 1]
        set cur_end_time   [expr $cur_start_time + $cur_duration]
    
        # move start time up and reduce duration accordingly
        if { $cur_start_time - $prev_end_time < $::recovery } {
            set new_start_time [expr $prev_end_time + $::recovery]
            set new_duration   [expr $cur_end_time - $new_start_time]
            set x [lreplace $x 0 1 $new_start_time $new_duration]
            set segment_list [lreplace $segment_list $counter $counter $x]
        }
        
        set prev_end_time $cur_end_time
        incr counter
    }

    return $segment_list
}
### END -- insert_delay
