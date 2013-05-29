# Author: David Chin <dwchin@umich.edu>
# Phone: 734-763-7208
# Mobile: 734-730-1274
#
# $Id: insert_delay.tcl,v 1.4 2002/04/11 19:50:40 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

###########
#
# variance
#     compute variance of a list of numbers
#     Uses the "corrected 2-pass algorithm" described in 
#     Numerical Recipes. Algorithm was published by
#     Savitzky and Golay in Analytical Chemistry, v.36,
#     pp.1627-1639
#
##########
proc variance { numbers } {
    set N   [llength $numbers]
    set ave [mean $numbers]
    set sq_dev_sum 0.
    set dev_sum    0.
    
    for {set i 0} {$i < $N} {incr i} {
        set dev [expr [lindex $numbers $i] - $ave]
        set dev_sum    [expr $dev + $dev_sum]
        set sq_dev_sum [expr [expr $dev * $dev] + $sq_dev_sum]
    }
    
    set tmp1 [expr [expr $dev_sum * $dev_sum] / [expr double($N)]]
    set tmp2 [expr $sq_dev_sum - $tmp1]
    
    return [expr $tmp2 / [expr double([expr $N - 1])]]
}