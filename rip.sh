#!/bin/bash
LOCK_FILE=/tmp/ripping.lock
OUTPUT_DIR=/mnt/usb/
RIPPING_LOG_FILE=/mnt/usb/whipper.log
TRACK_TEMPLATE='%r/%A - %d/%t'

rm $RIPPING_LOG_FILE
touch $LOCK_FILE
sudo WHIPPER_DEBUG=DEBUG WHIPPER_LOGFILE=$RIPPING_LOG_FILE whipper cd rip --output-directory $OUTPUT_DIR --track-template $TRACK_TEMPLATE
rm $LOCK_FILE
