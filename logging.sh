#!/bin/bash

##
## Simple logging mechanism for Bash
##
## Author: Michael Wayne Goodman <goodman.m.w@gmail.com>
## Thanks: Jul for the idea to add a datestring. See:
## http://www.goodmami.org/2011/07/simple-logging-in-bash-scripts/#comment-5854
## Thanks: @gffhcks for noting that inf() and debug() should be swapped,
##         and that critical() used $2 instead of $1
##
## License: Public domain; do as you wish
##


SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

WORKING_DIR=$DIR

source $WORKING_DIR/config.sh

exec 3>&2 # logging stream (file descriptor 3) defaults to STDERR
verbosity=$VERBOSITY_LVL
silent_lvl=0
crt_lvl=1
err_lvl=2
wrn_lvl=3
inf_lvl=4
dbg_lvl=5

log_notify() { log $silent_lvl "NOTE: $1"; } # Always prints
log_critical() { log $crt_lvl "CRITICAL: $1"; }
log_error() { log $err_lvl "ERROR: $1"; }
log_warn() { log $wrn_lvl "WARNING: $1"; }
log_info() { log $inf_lvl "INFO: $1"; } # "info" is already a command
log_debug() { log $dbg_lvl "DEBUG: $1"; }
log() {
    if [ $verbosity -ge $1 ]; then
        datestring=`date +'%Y-%m-%d %H:%M:%S'`
        # Expand escaped characters, wrap at 70 chars, indent wrapped lines
        echo -e "$datestring $2" | fold -w70 -s >&3
    fi
}
