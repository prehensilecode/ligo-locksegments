# Author: David Chin <dwchin@umich.edu>
#
# $Id: insert_delay.tcl,v 1.4 2002/04/11 19:50:40 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 


##############
#
# stddev
#      computes standard deviation, i.e. sqrt(variance)
#
##############
proc stddev { numbers } {
    return [expr sqrt([variance $numbers])]
}
