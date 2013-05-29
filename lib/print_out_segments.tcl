########
#
# print_out_segments -- print out segment list to file
#
#    segments are:  start_time duration
#
# $Id: print_out_segments.tcl,v 1.2 2002/03/13 03:00:12 dwchin Exp $
#
########
proc print_out_segments {segment_list filename} {
    
    # DEBUG
    if {[info exists ::DEBUG]} {
        puts stderr "segment_list length: [llength $segment_list]"
        puts stderr [lindex $segment_list 0]
    }
    
    if { [llength $segment_list] > 0 && [llength [lindex $segment_list 0]] > 0 } {
    
        if { [catch { set segment_stream [open $filename w] } ] } {
            puts stderr "Cannot open $filename for write"
            exit 2
        }
    
        foreach x $segment_list {
            puts $segment_stream [format "%u  %7s %8s" [lindex $x 0] [lindex $x 1] [secs_to_hours [lindex $x 1]]]
        }
    
        close $segment_stream
    } else {
        puts stderr "Error: print_out_segments: segment list is empty"
        return
    }
}
#### END -- print_out_segments
