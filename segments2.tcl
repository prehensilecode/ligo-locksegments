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



#
# Some global variables
#

# E7 ran from 693590413 to 695066413
set ::e7_start_time 693590413
set ::e7_end_time 695066413

set ::recovery 60

#set ::DEBUG 3

if { [info exists ::DEBUG] } {
    set ::e7_end_time 693879062
}

########
#
# usage -- prints out simple usage message
#
########
proc usage {} {
    return [puts stderr "Usage: you should know how to use this"]
}
#### END -- usage

########
#
# puts_debug -- print out given debug statement
#
########
proc puts_debug { debug_string level } {
    if { ! [info exists level] } {
        set level 0
    }
    
    if { [info exists ::DEBUG] } {
        if { $::DEBUG >= $level } {
            puts stderr "segments2: DEBUG: $debug_string"
        }
    }
    return
}
#### END -- puts_debug



######################################################
#
# MAIN procedure
#
######################################################

set min_segment_length 60

set ifo_list [list "H1" "H2" "L1"]

foreach ifo $ifo_list {
    puts "Doing $ifo..."

    #
    # First, get the clean detect times
    #
    set clean_detect_series_name "clean_detect_series_$ifo"
    
    puts_debug "clean_detect_series_name = $clean_detect_series_name" 0
    
    set $clean_detect_series_name [get_clean_detect_series $ifo $min_segment_length]
    
    #
    # Then, get the locked times
    #
    set lock_segments_list_name "lock_segments_list_$ifo"
    
    puts_debug "lock_segments_list_name = $lock_segments_list_name" 0
    
    set guild_filename "$ifo"
    append guild_filename "guild.txt"
    
    set $lock_segments_list_name [guild2segments $guild_filename]
    
    puts "Done $ifo"
}

# Total time of run
set total_time [expr $::e7_end_time - $::e7_start_time]

# Have to do this outside the loop because I don't know 
# how to do it inside the loop. Looks like I should be
# able to do it in that loop, doesn't it?

set lock_segments_list_H1 [cull_segments $lock_segments_list_H1 $min_segment_length]
set lock_segments_list_H2 [cull_segments $lock_segments_list_H2 $min_segment_length]
set lock_segments_list_L1 [cull_segments $lock_segments_list_L1 $min_segment_length]

puts_debug "segments2: before calling make_series lock_segments_list_H1" 2
set lock_series_H1 [make_series $lock_segments_list_H1]
puts_debug "segments2: before calling make_series lock_segments_list_H2" 2
set lock_series_H2 [make_series $lock_segments_list_H2]
puts_debug "segments2: before calling make_series lock_segments_list_L1" 2
set lock_series_L1 [make_series $lock_segments_list_L1]

print_out_segments $lock_segments_list_H1 "locks_H1.txt"
print_out_segments $lock_segments_list_H2 "locks_H2.txt"
print_out_segments $lock_segments_list_L1 "locks_L1.txt"

unset lock_segments_list_H1
unset lock_segments_list_H2
unset lock_segments_list_L1

puts_debug "ALOHA: clean_detect_series_H1 length = [llength $clean_detect_series_H1]" 0
puts_debug "ALOHA: lock_series_H1 length = [llength $lock_series_H1]" 0
puts_debug "ALOHA: clean_detect_series_H1(0) =  [lindex $clean_detect_series_H1 0]" 0
puts_debug "ALOHA: lock_series_H1(0) =  [lindex $lock_series_H1 0]" 0

for {set i 0} {$i < $total_time} {incr i} { 
    puts_debug "INTERSECT: [expr $i + $::e7_start_time] [lindex $lock_series_H1 $i] [lindex $clean_detect_series_H1 $i]" 1
    lappend clean_lock_series_H1 \
        [expr [lindex $clean_detect_series_H1 $i] & \
             [lindex $lock_series_H1 $i]]
}

# don't need the raw locks
unset lock_series_H1
unset clean_detect_series_H1

puts_debug "NKRUMAH" 1

set clean_lock_segment_list_H1 \
    [get_segments $clean_lock_series_H1 $min_segment_length]

if { [info exists ::DEBUG] && $::DEBUG > 0 } {
    puts_debug "CLEAN LOCK SERIES H1: " 1
    for {set i 0} {$i < $total_time} {incr i} {
        puts_debug "[expr $i + $::e7_start_time] [lindex $clean_lock_series_H1 $i]" 1
    }
}

puts_debug "CELINE IS NUTS" 1
puts_debug $clean_lock_segment_list_H1 1

# insert recovery time, and then cull segments
set clean_lock_segment_list_H1 [insert_delay $clean_lock_segment_list_H1]

puts_debug "HAIL ERIS" 1
puts_debug $clean_lock_segment_list_H1 1

set clean_lock_segment_list_H1 [cull_segments $clean_lock_segment_list_H1 $min_segment_length]

puts_debug "ALL HAIL DISCORDIA" 1
puts_debug $clean_lock_segment_list_H1 1


set clean_lock_segments_filename "clean_locks_H1.txt"
if { [info exists ::DEBUG] } {
    append clean_lock_segments_filename ".debug"
}
print_out_segments $clean_lock_segment_list_H1 $clean_lock_segments_filename

unset clean_lock_segment_list_H1

puts_debug "FOOBAR" 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend clean_lock_series_H2 \
        [expr [lindex $clean_detect_series_H2 $i] & \
             [lindex $lock_series_H2 $i]]
}

unset lock_series_H2
unset clean_detect_series_H2

set clean_lock_segment_list_H2 \
    [get_segments $clean_lock_series_H2 $min_segment_length]

# insert recovery time, and then cull segments
set clean_lock_segment_list_H2 [insert_delay $clean_lock_segment_list_H2]
set clean_lock_segment_list_H2 [cull_segments $clean_lock_segment_list_H2 $min_segment_length]

set clean_lock_segments_filename "clean_locks_H2.txt"
if { [info exists ::DEBUG] } {
    append clean_lock_segments_filename ".debug"
}
print_out_segments $clean_lock_segment_list_H2 $clean_lock_segments_filename

unset clean_lock_segment_list_H2

puts_debug "CUBAAN" 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend clean_lock_series_L1 \
        [expr [lindex $clean_detect_series_L1 $i] & \
             [lindex $lock_series_L1 $i]]
}

unset lock_series_L1
unset clean_detect_series_L1


set clean_lock_segment_list_L1 \
    [get_segments $clean_lock_series_L1 $min_segment_length]

# insert recovery time, and then cull segments
set clean_lock_segment_list_L1 [insert_delay $clean_lock_segment_list_L1]
set clean_lock_segment_list_L1 [cull_segments $clean_lock_segment_list_L1 $min_segment_length]

set clean_lock_segments_filename "clean_locks_L1.txt"
if { [info exists ::DEBUG] } {
    append clean_lock_segments_filename ".debug"
}
print_out_segments $clean_lock_segment_list_L1 $clean_lock_segments_filename

unset clean_lock_segment_list_L1


#####
# Do coincidences -- term-by-term Boolean AND of appropriate tseries
#     can't use the proc because it takes up too much memory
#####

puts_debug "About to do coincidences..." 0

#
# H1 & H2
# 
puts_debug "   H1 & H2..." 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend h1_h2_coincidence_series \
        [expr [lindex $clean_lock_series_H1 $i] & \
             [lindex $clean_lock_series_H2 $i]]
}

set h1_h2_coincidence_segments \
    [get_segments $h1_h2_coincidence_series $min_segment_length]

# print out to file
set h1_h2_coincidence_filename "h1_h2_coincidence_segments.txt"
if { [info exists ::DEBUG] } {
    append h1_h2_coincidence_filename ".debug"
}
print_out_segments $h1_h2_coincidence_segments $h1_h2_coincidence_filename

unset h1_h2_coincidence_segments

# delete that huge time series
unset h1_h2_coincidence_series


#
# H1 & L1
#
puts_debug "   H1 & L1..." 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend h1_l1_coincidence_series \
        [expr [lindex $clean_lock_series_H1 $i] & \
             [lindex $clean_lock_series_L1 $i]]    
}

# find segments >= $min_segment_length
set h1_l1_coincidence_segments \
    [get_segments $h1_l1_coincidence_series $min_segment_length]

# print out to file
set h1_l1_coincidence_filename "h1_l1_coincidence_segments.txt"
if {[info exists ::DEBUG]} {
    append h1_l1_coincidence_filename ".debug"
}
print_out_segments $h1_l1_coincidence_segments $h1_l1_coincidence_filename

unset h1_l1_coincidence_segments

# delete that huge time series
unset h1_l1_coincidence_series


#
# H2 & L1
#
puts_debug "   H2 & L1..." 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend h2_l1_coincidence_series \
        [expr [lindex $clean_lock_series_H2 $i] & \
             [lindex $clean_lock_series_L1 $i]]
}

# find segments >= 60s
set h2_l1_coincidence_segments \
    [get_segments $h2_l1_coincidence_series $min_segment_length]

# print out to file
set h2_l1_coincidence_filename "h2_l1_coincidence_segments.txt"
if {[info exists ::DEBUG]} {
    append h2_l1_coincidence_filename ".debug"
}
print_out_segments $h2_l1_coincidence_segments $h2_l1_coincidence_filename

unset h2_l1_coincidence_segments

# don't delete that huge time series because we'll use it below for the
# triple coincidence
# unset h2_l1_coincidence_series

# but can delete a bunch of other series
unset clean_lock_series_H2
unset clean_lock_series_L1

#
# H1 & H2 & L1
#
puts_debug "   H1 & H2 & L1..." 0

for {set i 0} {$i < $total_time} {incr i} {
    lappend h1_h2_l1_coincidence_series \
        [expr [lindex $h2_l1_coincidence_series $i] & \
             [lindex $clean_lock_series_H1 $i]]
}

# don't need these series any more
unset h2_l1_coincidence_series
unset clean_lock_series_H1

# find segments >= 60s
set h1_h2_l1_coincidence_segments \
    [get_segments $h1_h2_l1_coincidence_series $min_segment_length]

# print out to file
set h1_h2_l1_coincidence_filename "h1_h2_l1_coincidence_segments.txt"
if {[info exists ::DEBUG]} {
    append h1_h2_l1_coincidence_filename ".debug"
}
print_out_segments $h1_h2_l1_coincidence_segments $h1_h2_l1_coincidence_filename

unset h1_h2_l1_coincidence_segments

# delete that huge time series
unset h1_h2_l1_coincidence_series

# done
return 0
