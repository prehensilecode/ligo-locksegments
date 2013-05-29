# Author: David Chin <dwchin@umich.edu>
# Phone: 734-763-7208
# Mobile: 734-730-1274
#
# $Id: cull_segments.tcl,v 1.2 2002/03/13 16:47:49 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

########
#
# cull_segments
#      remove segments that are not >= min_segment_length
#      returns a new segment list
# 
########
proc cull_segments { segment_list min_segment_length } {
    
    set counter 0
    foreach x $segment_list {
        
        if { [lindex $x 1] < $min_segment_length } {
            set segment_list [lreplace $segment_list $counter $counter]
            continue
        }
        
        incr counter
    }
    
    return $segment_list
}
### END -- cull_segments
