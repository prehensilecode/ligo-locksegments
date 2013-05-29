# Author: David Chin <dwchin@umich.edu>
#
# $Id: insert_delay.tcl,v 1.4 2002/04/11 19:50:40 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

################
#
# sum
#     sum up a list of numbers
#
################
proc sum { numbers } {
    set total 0
    foreach x $numbers {
        set total [expr $total + $x]
    }
    
    return $total
}
