# Author: David Chin <dwchin@umich.edu>
# Phone: 734-763-7208
# Mobile: 734-730-1274
#
# $Id: insert_delay.tcl,v 1.4 2002/04/11 19:50:40 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

#############
#
# max
#     returns the maximum of a list of numbers
#
#############
proc max { numbers } {
    set cur_max [lindex $numbers 0]
    foreach x $numbers {
        if { $x > $cur_max } {
            set cur_max $x
        }
    }
    
    return $cur_max
}