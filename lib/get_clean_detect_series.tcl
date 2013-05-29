
# 
# get_clean_detect_series
#
# $Id: get_clean_detect_series.tcl,v 1.7 2002/04/12 20:55:50 dwchin Exp $
#
#
# OK.  We want to parse the conlog output of clean lock stretches.
# The file looks like this:
#
#    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
#    <HTML><HEAD><TITLE>LIGO Epics Controls Log Interface -- Hanford</TITLE>
#    <LINK REV=MADE HREF="mailto:shawhan_p%40ligo.caltech.edu">
#    <BASE HREF="http://blue.ligo-wa.caltech.edu/perl/conlog_web.pl">
#    <STYLE TYPE="text/css"><!--
#    H1,H2,H3,H4 {color: midnightblue}
#    --></STYLE>
#    </HEAD><BODY BGCOLOR="#aadddd">
#    <pre>
#    LIGO controls: L1 clean locked segments at least 60 seconds long
#    Between  693590413- 695066413  2001 12/28 16:00:00 - 2002 01/14 18:00:00 utc
#    Number after 'Clean' is the duration of the clean locked segment, in seconds
#    Lock/Unlock events are shown only if associated with a clean locked segment
#
#    Detect-mode at  693592713
#    <b>Clean      99   693592714- 693592813  2001 12/28 16:38:21 - 12/28 16:40:00 utc
#    </b>Unlock      at  693592813
#
#    Detect-mode at  693597086
#    <b>Clean     106   693597087- 693597193  2001 12/28 17:51:14 - 12/28 17:53:00 utc
#    </b>Touch L1:LSC-dewhiteSelect
#    Touch L1:LSC-dewhiteRead_bit0 (Dewhitening filter ITMX)
#    Touch L1:LSC-dewhiteRead_bit3 (Dewhitening filter BS)
#    Touch L1:LSC-dewhiteRead_bit4 (Dewhitening filter ETMX)
#    Touch L1:LSC-dewhiteRead_bit5 (Dewhitening filter ETMY)
#    <b>Clean     882   693597259- 693598141  2001 12/28 17:54:06 - 12/28 18:08:48 utc
#    </b>Unlock      at  693598141
#
#    Detect-mode at  693598384
#    <b>Clean     216   693598385- 693598601  2001 12/28 18:12:52 - 12/28 18:16:28 utc
#    </b>Touch L1:LSC-dewhiteSelect
#    Touch L1:LSC-dewhiteRead_bit4 (Dewhitening filter ETMX)
#    Touch L1:LSC-dewhiteRead_bit5 (Dewhitening filter ETMY)
#    Unlock      at  693598605
#
#    Detect-mode at  693598751
#    <b>Clean      81   693598752- 693598833  2001 12/28 18:18:59 - 12/28 18:20:20 utc
#    </b>Touch L1:LSC-Lm_Limit_Hi (DARM_CTRL Limit)
#    Touch L1:LSC-Lp_Limit_Hi (CARM_CTRL Limit)
#    <b>Clean      91   693598837- 693598928  2001 12/28 18:20:24 - 12/28 18:21:55 utc
#    </b>Unlock      at  693598928
#
#    Detect-mode at  693599195
#    <b>Clean     135   693599196- 693599331  2001 12/28 18:26:23 - 12/28 18:28:38 utc
#    </b>Touch L1:ASC-ITMX_YOFF (ITMX Yaw dc offset)
#    Touch L1:ASC-ITMX_POFF (ITMX Pitch dc offset)
#    Touch L1:ASC-ITMY_YOFF (ITMY Yaw dc offset)
#    Touch L1:ASC-ETMY_YOFF (ETMY Yaw dc offset)
#    Unlock      at  693599359
#
#    Detect-mode at  693600043
#    <b>Clean     207   693600152- 693600359  2001 12/28 18:42:19 - 12/28 18:45:46 utc
#    </b>Touch L1:ASC-IB_POFF (MMT3 Pitch dc offset)
#    Touch L1:ASC-IB_YOFF (MMT3 Yaw dc offset)
#    Touch L1:ASC-ETMX_POFF (ETMX Pitch dc offset)
#    Touch L1:ASC-ETMX_YOFF (ETMX Yaw dc offset)
#    Touch L1:ASC-ITMX_YOFF (ITMX Yaw dc offset)
#    Touch L1:ASC-ITMX_POFF (ITMX Pitch dc offset)
#    Touch L1:ASC-ITMY_YOFF (ITMY Yaw dc offset)
#    Touch L1:ASC-ITMY_POFF (ITMY Pitch dc offset)
#    Touch L1:ASC-BS_YOFF (BS Yaw dc offset)
#    Touch L1:ASC-BS_POFF (BS Pitch dc offset)
#    <b>Clean     208   693600531- 693600739  2001 12/28 18:48:38 - 12/28 18:52:06 utc
#    </b>Unlock      at  693600739
#
#    Detect-mode at  693600775
#    <b>Clean     858   693600776- 693601634  2001 12/28 18:52:43 - 12/28 19:07:01 utc
#    </b>Unlock      at  693601634
#
#    ...
#
#    </pre></BODY></HTML>
#
#
# So, we skip the first 14 lines.  Then, each clean detect mode segment looks like:
# 
#    Detect-mode at  gpsTime
#    <b>Clean   duration  startTime- endTime utcTimeStamp
#    </b>[Touch chanName (commentField)]
#    [Touch chanName (commentField)]
#    [<b>Clean     duration  startTime- endTime utcTimeStamp
#    </b>[Touch chanName (commentField)]]
#    Unlock   at gpsTime
#
# i.e. Look for Detect mode
#      if in detect mode,
#          look for start of clean segment
#          check for end of clean segment precipitated by
#             control being touched, or FE_MODE being changed
#          look for loss of lock
#
proc get_clean_detect_series { ifo min_segment_length } {

    global auto_path
    
    puts_debug "get_clean_detect_series: entered" 1
    
    # conlog
    set conlog "conlog_"
    append conlog $ifo
    append conlog "_E7.txt"
    
    if { [info exists ::DEBUG] } {
        append conlog ".debug"
    }
    
    # open the conlog file
    if { [catch { set conlog_stream [open $conlog r] }] } {
        puts stderr "Cannot open $conlog"
        exit 2
    }
    
    set stripped_conlog "stripped_conlog_"
    append stripped_conlog $ifo
    append stripped_conlog ".txt"
    
    if { [info exists ::DEBUG] } {
        append stripped_conlog ".debug"
    }
    
    #
    # make a list of patterns which occur in channel names
    # whose changes should be ignored when deciding on clean
    # locks
    #

    # Remove the wanted IFO from the list of
    # IFOs to ignore.  
    # This is unnecessary if the conlog file is contains
    # only "H0:" and "L0:" entries and entries for the desired IFO,
    # but let's not count on that.
    set ifos_to_ignore [list "H1" "H2" "L1"]
    set ifos_to_ignore [lreplace $ifos_to_ignore \
                            [lsearch -exact $ifos_to_ignore $ifo] \
                            [lsearch -exact $ifos_to_ignore $ifo]]
    
    foreach ifo_ignored $ifos_to_ignore {
        set tmpifo $ifo_ignored
        append ifo_ignored ":"
        set position [lsearch -exact $ifos_to_ignore $tmpifo]
        set ifos_to_ignore \
            [lreplace $ifos_to_ignore $position $position $ifo_ignored]
    }

    set ignore_list [list "H0:" "L0:"]
    set ignore_list [concat $ignore_list $ifos_to_ignore]
    
    # notice the space in "LSC-dewhiteRead " -- we cannot ignore
    # "LSC-dewhiteRead_bit[0-9]+"
    lappend ignore_list "IOO-MC_PWR_IN" "PSL-FSS_TIDALSET" "PSL-FSS_SLOWDC" \
        "PZEnable" "PZReadout" "_COMM" "LA_ALIGN_BITS" "LA_ALIGN_BITS_RD" \
        "LSC-dewhiteRead\ "

    puts_debug "get_clean_detect_series: ignore_list = $ignore_list" 1
    
    # Remove all lines containing the patterns to be ignored
    # from the conlog file and put it in tmplog
    set ignore_pat [join $ignore_list "|"]
    if { [catch {exec -- egrep -v "($ignore_pat)" $conlog > $stripped_conlog} ] } {
        puts stderr "Error: either grep or output redirection failed"
        exit 3
    }
    
    # open the stripped conlog
    if { [catch {set stripped_conlog_stream [open $stripped_conlog r] } ] } {
        puts stderr "Cannot open $stripped_conlog" 
        exit 2
    }
    
    # close the original conlog
    close $conlog_stream
    
    #
    # Stuff for looking at the state fo the dewhitening filters
    #
    
    # Make a hash array to contain the states of the whitening
    # and dewhitening filters.  NOTE: for each IFO, only a subset
    # of these are necessary.  See the function filters_on_p below.
    set filter(dewhite_itmx) 0
    set filter(dewhite_itmy) 0
    set filter(dewhite_bs)   0
    set filter(dewhite_etmx) 0
    set filter(dewhite_etmy) 0
    set filter(white_as_q)   0
    set filter(white_as_i)   0
    set filter(po_q)         0
    set filter(po_i)         0
    set filter(white_ref_q)  0
    set filter(white_ref_i)  0

    #
    # Return AND of appropriate whitening/dewhitening filters
    # Here's note from P.Shawhan <pshawhan@ligo.caltech.edu>:
    #
    #   Based on querying the LLO conlog for a random 48-hour section of the E7
    #   run, it looks like the operating procedure we were following at LLO for
    #   low-noise running was to turn on the AS_I, AS_Q, REF_I, REF_Q, ETMX,
    #   and ETMY whitening/dewhitening filters.  All the others were kept off.
    #
    #   Repeating this check using the Hanford conlog, it looks like H1 used
    #   only AS_I, AS_Q, REF_I, REF_Q, while H2 used AS_I, AS_Q, REF_I, REF_Q,
    #   PO_I, PO_Q, ETMX, ETMY.
    #
    # However, a scan through the conlog itself shows a different set:
    #
    # Summarize:
    #
    # H1:  AS_I
    #      AS_Q
    #      REF_I
    #      REF_Q
    #
    # H2:  AS_I
    #      AS_Q
    #      REF_I
    #      REF_Q
    #      ;ETMX  - not in use, as it turns
    #      ;ETMY  - out from conlog
    #
    # L1:  AS_I
    #      AS_Q
    #      REF_I
    #      REF_Q
    #      ETMX
    #      ETMY

    proc filters_on_p {} {
        upvar ifo    ifo
        upvar filter filter
        
        if { $ifo == "H1" } {
            return [expr $filter(white_as_i) & \
                    [expr $filter(white_as_q) & \
                     [expr $filter(white_ref_i) & $filter(white_ref_q)]]]
        }
        
        if { $ifo == "H2" } {

            return [expr $filter(white_as_i) & \
                            [expr $filter(white_as_q) & \
                                 [expr $filter(white_ref_i) & \
                                      $filter(white_ref_q)]]]
        }
        
        if { $ifo == "L1" } {
            return [expr $filter(white_as_i) & \
                    [expr $filter(white_as_q) & \
                     [expr $filter(white_ref_i) & \
                      [expr $filter(white_ref_q) & \
                       [expr $filter(dewhite_etmx) & \
                            $filter(dewhite_etmy)]]]]]
        }
    }
    # END: proc filters_on_p

    #
    # Set the filter state, given the conlog line
    #   assumes that the line given DOES contain
    #   filter state information
    #
    proc set_filter_state { line } {
        upvar filter filter
        
        puts_debug "set_filter_state: line = $line" 3
        
        regexp {dewhiteRead_bit[0-9]+} $line chan_string
        regexp {(On|Off)} $line state_string
        if { $state_string == "On" } {
            set state 1
        } else {
            set state 0
        }
        
        puts_debug "set_filter_state: chan_string = $chan_string" 2
        puts_debug "set_filter_state: state = $state" 2
        
        if { $chan_string == "dewhiteRead_bit0" } {
            set filter(dewhite_itmx) $state
        }
        
        if { $chan_string == "dewhiteRead_bit1" } {
            set filter(dewhite_itmy) $state
        }
        
        if { $chan_string == "dewhiteRead_bit3" } {
            set filter(dewhite_bs) $state
        }
        
        if { $chan_string == "dewhiteRead_bit4" } {
            set filter(dewhite_etmx) $state
        }
        
        if { $chan_string == "dewhiteRead_bit5" } {
            set filter(dewhite_etmy) $state
        }
        
        if { $chan_string == "dewhiteRead_bit6" } {
            set filter(white_as_q) $state
        }
        
        if { $chan_string == "dewhiteRead_bit7" } {
            set filter(white_as_i) $state
        }
        
        if { $chan_string == "dewhiteRead_bit10" } {
            set filter(white_ref_q) $state
        }
        
        if { $chan_string == "dewhiteRead_bit11" } {
            set filter(white_ref_i) $state
        }
    }
    # END: proc set_filter_state
    
    #
    # print_filter_state
    #
    proc print_filter_state {} {
        upvar filter filter
        
        puts "filter state: dewhite_itmx: $filter(dewhite_itmx)"
        puts "filter state: dewhite_itmy: $filter(dewhite_itmy)"
        puts "filter state: dewhite_bs:   $filter(dewhite_bs)"
        puts "filter state: dewhite_etmx: $filter(dewhite_etmx)"
        puts "filter state: dewhite_etmy: $filter(dewhite_etmy)"
        puts "filter state: white_as_i:   $filter(white_as_i)"
        puts "filter state: white_as_q:   $filter(white_as_q)"
        puts "filter state: white_ref_i:  $filter(white_ref_i)"
        puts "filter state: white_ref_q:  $filter(white_ref_q)"
        puts "filter state: po_i:         $filter(po_i)"
        puts "filter state: po_q:         $filter(po_q)"
    }
    # END: proc print_filter_state

    
    # Drop first 2 lines of stripped conlog
    gets $stripped_conlog_stream line
    gets $stripped_conlog_stream line
    
    ######### 
    
    #
    # initial values of various variables
    #
    
    # segment starting time
    set segment_start 0
    # detect mode?
    set detect_p      0
    
    while { ! [eof $stripped_conlog_stream] } {
        
        gets $stripped_conlog_stream line
        
        # avoid all lines that denote the starting state
        # of various channels
        if { [regexp {^\ +start} $line] } {
            continue
        }
        
        if { !$detect_p && ![filters_on_p] } {
            
            puts_debug "00" 3

            # OK. Bloody annoying.  H1 has "Detection",
            # H2 has "Detect", L1 has "Detect"
            if { [regexp {FE_MODE} $line] } {
                if { [lindex $line end] == "Detection" || \
                         [lindex $line end] == "Detect" } {
                    set detect_p 1
                }
            } elseif { [regexp {dewhiteRead_bit} $line] } {
                set_filter_state $line
            }
            
        } elseif { $detect_p && ![filters_on_p] } {
            
            puts_debug "10" 3
            
            if { [regexp {FE_MODE} $line] } {
                set detect_p 0
            } elseif { [regexp {dewhiteRead_bit} $line] } {
                set_filter_state $line
            
                if { [filters_on_p] == 1 } {
                    set segment_start [expr [lindex $line 0] + 1]
                    puts "Clean segment BEGINS: $segment_start"
                }
            }
            
        } elseif { !$detect_p && [filters_on_p] } {
            
            puts_debug "01" 3
            
            if { [regexp {FE_MODE} $line] } {
                
                # OK. Bloody annoying.  H1 has "Detection",
                # H2 has "Detect", L1 has "Detect"
                if { [lindex $line end] == "Detection" || \
                         [lindex $line end] == "Detect" } {
                    set detect_p 1
                    set segment_start [expr [lindex $line 0] + 1]
                    puts "Clean segment BEGINS: $segment_start"
                }
            } elseif { [regexp {dewhiteRead_bit} $line] } {
                set_filter_state $line
            }
            
        } elseif { $detect_p && [filters_on_p] } {
            
            puts_debug "11" 3
            
            if { [regexp {FE_MODE} $line] } {
                set detect_p 0
            } elseif { [regexp {dewhiteRead_bit} $line] } {
                set_filter_state $line
            } else {
                # do nothing
            }
            
            # in any case, we've just found the end of a clean segment
            puts "    Control changed: $line"
            set segment_end [expr [lindex $line 0] - 1]
            set segment_duration [expr $segment_end - $segment_start]

            if { $segment_duration > $min_segment_length } {
                lappend clean_detect_list [list $segment_start $segment_duration]
                puts "  Clean segment ENDS: $segment_end"
                
                # set new segment starting time
                # set segment_start [expr $segment_end + $::recovery]
            } 
            
            set segment_start [expr $segment_end + 2]
            
        } else {
            # We can NEVER reach here
            puts stderr "How the hell did we get here?!"
            exit 13
        }
    } 
    ## End -- while { ! [eof $stripped_conlog_stream] }
    
    set clean_segments_filename "clean_detects_$ifo.txt"
    if { [info exists ::DEBUG] } {
        append clean_segments_filename ".debug"
    }
    print_out_segments $clean_detect_list $clean_segments_filename
    
    close $stripped_conlog_stream
    
    puts_debug "get_clean_detect_series: about to return make_series on $ifo" 1
    
    return [make_series $clean_detect_list]
}
### END -- get_clean_detect_series
