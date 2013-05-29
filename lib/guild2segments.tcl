# Author: David Chin <dwchin@umich.edu>
#
# $Id: guild2segments.tcl,v 1.3 2002/04/06 22:36:52 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

# We want to convert the segment output from GUILD to a
# "segment list", i.e. the list members are
#
#     start_time  duration
# 
# GUILD output format is
# 
#     start_time  end_time
#
# where the time interval is no more than 200 seconds

# For every line in the file,
#    if the start time is equal to the previous end time,
#        we have a continuation of a segment
#    else
#        we have a new segment
#

proc guild2segments { guild_filename } {
    
    # open guild output file
    if { [catch {set guild_stream [open $guild_filename r] } ] } {
        puts stderr "Cannot open $guild_filename"
        exit 2
    }
    
    # first line is special
    gets $guild_stream line
    set start_time [lindex $line 0]
    set end_time   [lindex $line 1]
    
    
    while { ! [eof $guild_stream] } {
        
        # read in a line
        gets $guild_stream line
        
        #
        # check if new segment or continuation of last segment
        #
        if { [lindex $line 0] == $end_time} {
            
            # we continue the previous segment
            
            # extend end time
            set end_time [lindex $line 1]
            
        } else {
            
            # we have a new segment
            
            # store previous segment
            lappend segment_list [list $start_time \
                                      [expr [expr $end_time - 1] - $start_time]]
            
            # set new start and end times, and segment length
            set start_time [lindex $line 0]
            set end_time   [lindex $line 1]
        }
    }

    close $guild_stream
    
    return $segment_list
}
### END -- guild2segments
