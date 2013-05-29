#!/bin/sh

## The next line tells sh to execute the script using tclshexe \
exec tclshexe "$0" ${1+"$@"}

set auto_path "lib"
auto_mkindex "lib" *.tcl

# Author: David Chin <dwchin@umich.edu>
#
# $Id: segments2.tcl,v 1.3 2002-04-12 16:55:30-04 dwchin Exp $
#
# For those of you reading this who are not conversant with TCL,
# everything I know about TCL I learnt from:
#     http://www.arsdigita.com/books/tcl/index 

# Lock segment file is in format
#
#  start_GPS    duration_in_secs    duration_in_hh:mm:ss
#


# for each segment
#     add segment to histogram
#     increment total lock duration by current segment duration


# let's histogram in bins of 360s 
#   each histogram is a list, with the position in the list
#   representing the bin
# each segment is a list {start_time duration_in_secs}

set ::bin_width 360

set h1_histogram [list]
set h2_histogram [list]
set l1_histogram [list]

#
# initial histogram
#
proc init_histogram {} {
    # max. segment duration is had by H2: 26687 seconds
    set max_bin   [expr 27000 / $::bin_width]
    set histogram [list 0]

    for {set i 1} {$i < $max_bin} {incr i} {
        lappend histogram 0
    }

    return $histogram
}
# END init_histogram

#
# procedure to add a segment to a histogram.
#    a histogram is merely a list of numbers, each
#    number representing the frequency in that bin
#
proc add_segment_to_histogram { segment histogram } {
    set duration  [lindex $segment 1]
    set which_bin [expr $duration / $::bin_width]

    set histogram [lreplace $histogram $which_bin $which_bin [expr [lindex $histogram $which_bin] + 1]]

    return $histogram
}  
# END add_segment_to_histogram



#
# Initialize histograms
#
set h1_histogram [init_histogram]
set h2_histogram [init_histogram]
set l1_histogram [init_histogram]

set h1_total_lock_time 0
set h2_total_lock_time 0
set l1_total_lock_time 0

set h1_segment_list [list]
set h2_segment_list [list]
set l1_segment_list [list]

set ifo_list [list "H1" "H2" "L1"]
foreach ifo $ifo_list {

    set segment_filename "clean_locks_$ifo"
    append segment_filename ".txt"

    if { [catch {set segment_stream [open $segment_filename r] } ] }  {
        puts stderr "Cannot open $segment_filename"
        exit 2
    }

    while { ! [eof $segment_stream] } {
        
        # read in a line
        gets $segment_stream line

        set segment [lrange $line 0 1]

        if { [llength $segment] > 0 } {
            if { $ifo == "H1" } {
                set h1_histogram [add_segment_to_histogram $segment $h1_histogram]
                set h1_total_lock_time [expr $h1_total_lock_time + [lindex $segment 1]]
                lappend h1_segment_list [lindex $segment 1]
            } elseif { $ifo == "H2" } {
                set h2_histogram [add_segment_to_histogram $segment $h2_histogram]
                set h2_total_lock_time [expr $h2_total_lock_time + [lindex $segment 1]]
                lappend h2_segment_list [lindex $segment 1]
            } elseif { $ifo == "L1" } {
                set l1_histogram [add_segment_to_histogram $segment $l1_histogram]
                set l1_total_lock_time [expr $l1_total_lock_time + [lindex $segment 1]]
                lappend l1_segment_list [lindex $segment 1]
            } else {
                puts stderr "FOOBAR!"
                exit 3
            }
        }
    }
}

#puts $h1_histogram
#puts $h2_histogram
#puts $l1_histogram

puts "H1:"
puts "    No. of segments = [llength $h1_segment_list]"
puts "    Total lock time = $h1_total_lock_time s = [secs_to_hours $h1_total_lock_time]"
puts "                Max = [max $h1_segment_list] s = [secs_to_hours [max $h1_segment_list]]"
puts "               Mean = [mean $h1_segment_list] s"
puts "          Std. dev. = [stddev $h1_segment_list] s"
puts " "

puts "H2:"
puts "    No. of segments = [llength $h2_segment_list]"
puts "    Total lock time = $h2_total_lock_time s = [secs_to_hours $h2_total_lock_time]"
puts "                Max = [max $h2_segment_list] s = [secs_to_hours [max $h2_segment_list]]"
puts "               Mean = [mean $h2_segment_list] s"
puts "          Std. dev. = [stddev $h2_segment_list] s"
puts " "

puts "L1:"
puts "    No. of segments = [llength $l1_segment_list]"
puts "    Total lock time = $l1_total_lock_time s = [secs_to_hours $l1_total_lock_time]"
puts "                Max = [max $l1_segment_list] s = [secs_to_hours [max $l1_segment_list]]"
puts "               Mean = [mean $l1_segment_list] s"
puts "          Std. dev. = [stddev $l1_segment_list] s"
puts " "
