#!/bin/bash
WORKING_DIR=/home/pi/ripper
LOCK_FILE=/tmp/ripping.lock
OUTPUT_DIR=/mnt/usb/
WHIPPER_LOG_FILE=/home/pi/ripper_whipper.log
RIPPING_LOG_FILE=/home/pi/ripper_rip.log

source $WORKING_DIR/logging.sh
exec 3>>$RIPPING_LOG_FILE

rm $RIPPING_LOG_FILE
rm $WHIPPER_LOG_FILE

touch $LOCK_FILE
log_debug 'start ripping'
sudo WHIPPER_DEBUG=DEBUG WHIPPER_LOGFILE=$WHIPPER_LOG_FILE whipper cd rip --output-directory $OUTPUT_DIR --track-template '%r/%A - %d/%t'
log_info "end ripping with status: $?"
rm $LOCK_FILE
