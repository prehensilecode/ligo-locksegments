########
#
# intersect_two_series -- take the boolean AND of two time series
#                         and return a time series of the result
#
#      Args:       first -- first time series
#                 second -- second time series
#             total_time -- total time (length) of both the series
#
# $Id: intersect_two_series.tcl,v 1.2 2002/03/13 16:48:25 dwchin Exp $
#
########
proc intersect_two_series { first second total_time} {
    
    for { set i 0 } { $i < $total_time } { incr i } {
        lappend intersection_series \
            [expr [lindex $first $i] & [lindex $second $i]]
    }
    
    return $intersection_series    
}
#### END -- intersect_two_series