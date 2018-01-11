#!/bin/bash
eject

while true
do
  CD=$(udisks --show-info /dev/sr0 |grep -c "has media: *1")

  if [[ $CD -eq 0 ]]
    then
    sleep 5
  else
    /home/pi/ripper/mounter.sh
    sleep 2

    /home/pi/ripper/notify.sh START
    /home/pi/ripper/piripper_service.sh &

    /home/pi/ripper/rip.sh

    /home/pi/ripper/notify.sh END "`cat /mnt/usb/output.log | tr '\r' '\n'`"

    eject

    /home/pi/ripper/unmounter.sh

    sudo shutdown now
  fi
done
