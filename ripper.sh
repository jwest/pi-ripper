#!/bin/bash
source /home/pi/ripper/logging.sh
exec 3>>/home/pi/ripper.log

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
    /home/pi/ripper/mounter.sh
    sleep 2

    log_info "SEND notify"
    /home/pi/ripper/notify.sh START

    log_info "STARTING notifications for pi-ripper-service"
    /home/pi/ripper/piripper_service.sh &

    log_debug "REMOVE log file"
    sudo rm -rf /home/pi/output.log

    log_info "RIPPING starting, output created in /home/pi/output.log"
    /home/pi/ripper/rip.sh >> /home/pi/output.log

    log_info "SEND notify"
    /home/pi/ripper/notify.sh END "`cat /mnt/usb/output.log | tr '\r' '\n'`"
    log_info "EJECT cd drive"
    eject

    log_info "UNMOUNT disk"
    /home/pi/ripper/unmounter.sh

    log_info "END pi-ripper"

    log_info "SHUTDOWN pi now"
    sudo shutdown now
  fi
done
