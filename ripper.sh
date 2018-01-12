#!/bin/bash
WORKING_DIR=/home/pi/ripper
OUTPUT_DIR=/mnt/usb
PIRIPPER_LOG_FILE=/home/pi/ripper.log
RIPPING_LOG_FILE=/mnt/usb/output.log

source $WORKING_DIR/logging.sh
exec 3>>$PIRIPPER_LOG_FILE

log_info "START pi-ripper"

log_info "EJECT cd drive"
eject

while true
do
  log_debug "processing while start"

  CD=$(udisks --show-info /dev/sr0 |grep -c "has media: *1")

  if [[ $CD -eq 0 ]]
    then
    log_debug "CD not inserted"
    sleep 5
  else
    log_info "CD inserted"

    log_info "MOUNT disk"
    $WORKING_DIR/mounter.sh
    sleep 2

    log_info "SEND notify"
    $WORKING_DIR/notify.sh START

    log_info "STARTING notifications for pi-ripper-service"
    $WORKING_DIR/piripper_service.sh &

    log_info "RIPPING starting, output created in $WORKING_DIR/output.log"
    $WORKING_DIR/rip.sh > RIPPING_LOG_FILE &>&1

    log_info "SEND notify"
    $WORKING_DIR/notify.sh END "`cat $RIPPING_LOG_FILE | tr '\r' '\n'`"
    log_info "EJECT cd drive"
    eject

    log_info "UNMOUNT disk"
    $WORKING_DIR/unmounter.sh

    log_info "END pi-ripper"

    log_info "SHUTDOWN pi now"
    sudo shutdown now
  fi
done
