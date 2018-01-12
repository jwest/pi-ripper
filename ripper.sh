#!/bin/bash
OUTPUT_DIR=/mnt/usb
PIRIPPER_LOG_FILE=/home/pi/ripper.log
RIPPING_LOG_FILE=/mnt/usb/output.log

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

WORKING_DIR=$DIR

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

    log_info "STARTING notifications for pi-ripper-service"
    $WORKING_DIR/piripper_service.sh &

    log_info "RIPPING starting"
    $WORKING_DIR/rip.sh

    log_info "EJECT cd drive"
    eject

    log_info "MOUNT disk"
    $WORKING_DIR/mounter.sh
    sleep 2

    log_info "SANITIZE filenames and dir"
    detox -r -v $TEMPORARY_OUTPUT_DIR

    log_info "MOVE all to mounted disk"
    mv $TEMPORARY_OUTPUT_DIR/* $OUTPUT_DIR/

    log_info "UNMOUNT disk"
    $WORKING_DIR/unmounter.sh

    log_info "END pi-ripper"

#    log_info "SHUTDOWN pi now"
#    sudo shutdown now
  fi
done
