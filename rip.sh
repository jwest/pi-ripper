#!/bin/bash

OUTPUT_DIR=/mnt/usb/

touch /tmp/ripping.lock
sudo WHIPPER_DEBUG=DEBUG WHIPPER_LOGFILE=whipper.log whipper cd rip --output-directory $OUTPUT_DIR --track-template '%r/%A - %d/%t'
rm /tmp/ripping.lock
