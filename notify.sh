#!/bin/bash
WORKING_DIR=/home/pi/ripper
MAIL="j.westfalewski@gmail.com"

$WORKING_DIR/mail.py $MAIL CDRIP_$1 _$2 &
