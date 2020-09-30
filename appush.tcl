# ##############################################################################
# System policy EEM script to automate writing AP tags to AP
# ##############################################################################
# Author  :  Francisco Sedano, 2020
# ##############################################################################

::cisco::eem::event_register_none tag ev_none maxrun 2000

namespace import ::cisco::eem::*
namespace import ::cisco::lib::*


set DEBUG_FLAG         0

proc debug {str} {
    global DEBUG_FLAG
    if {$DEBUG_FLAG == 1} {
        action_syslog msg "$str\n"
		puts "Debug: $str"
    }
}

proc p_error {str} {
    action_syslog msg "ERROR: $str\n"
}

# ### Start new CLI session and move to enable mode
proc cli_session_start {} {
    debug "Opening CLI TTY1 line"

    if [catch {cli_open} result] {
        p_error "Unable to open a CLI session, Result: $result"
        exit 1
    }
    array set cli_sess $result

    debug "CLI session created - entering enabled mode"

    if [catch {cli_exec $cli_sess(fd) "enable"} result] {
        p_error "Unable to enter enabled mode, Result: $result"
        cli_close $cli_sess(fd) $cli_sess(tty_id)
        exit 1
    }

    return [array get cli_sess]
}

proc execute {cli} {
	upvar $cli cli_sess

    catch {cli_exec $cli_sess(fd) "show ap summary | i Registered"} result
    set aplist [split $result "\n"]

    foreach apentry $aplist {
        if {[llength $apentry] > 1} {
            set apname [string trim [lindex $apentry 0] " "]
            set ap_cli "ap name $apname write tag-config"
            puts stdout "Send --> $ap_cli"
            if [catch {cli_exec $cli_sess(fd) $ap_cli} result] {
                puts stdout "Error sending CLI: $ap_cli"
            }
        }
    }
}

array set cli_sess [cli_session_start]
set ret [execute cli_sess]

