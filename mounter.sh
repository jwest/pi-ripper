#!/bin/bash

MOUNT_DIR=/mnt/usb/

while :
do

  DRIVE=$(sudo lsblk -o NAME -e 11,1,179 -n -l | awk 'NR == 3')

  if [[ -n "${DRIVE/[ ]*\n/}" ]]
  then
    DRIVE_PATH="/dev/$DRIVE"
    echo $DRIVE_PATH

    sudo mount $DRIVE_PATH $MOUNT_DIR

    break
  fi

  echo "NO DEVICES"
  sleep 5
done
