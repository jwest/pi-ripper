#!/bin/bash

sudo rm -rf /mnt/usb/output.log

touch /tmp/rip.lock
current_dir=$PWD
cd /mnt/usb
sudo WHIPPER_DEBUG=DEBUG WHIPPER_LOGFILE=whipper.log whipper cd rip --output-directory /mnt/usb/ --track-template '%r/%A - %d/%t' >> /mnt/usb/out$
rm /tmp/rip.lock
cd $current_dir
