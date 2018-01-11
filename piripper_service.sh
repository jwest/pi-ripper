#!/bin/bash
sudo touch /mnt/usb/output.log
ID=$(curl -v -XPOST https://piripper.herokuapp.com/api/v1/disks -d '{}' -H'Content-Type:application/json' | jq '.id' | tr -d '"')
echo $ID

while :
do

  if [ ! -f /mnt/usb/output.log ]; then
    curl -v -XPUT https://piripper.herokuapp.com/api/v1/disks/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
    break;
  fi

  MATCH=$(cat /mnt/usb/output.log |grep "Matching releases" | sed 's/^ *//;s/ *$//')

  if [[ -z "${MATCH// }" ]]; then
    echo 'not matching'

    ARTIST=$(cat /mnt/usb/output.log |grep "MusicBrainz lookup URL" | sed 's/MusicBrainz lookup URL //')
    TITLE='Unknown'

    curl -v -XPUT https://piripper.herokuapp.com/api/v1/disks/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
  else
    echo 'matching'

    ARTIST=$(cat /mnt/usb/output.log |grep "Artist *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $ARTIST
    TITLE=$(cat /mnt/usb/output.log |grep "Title *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $TITLE

    ACTUAL_TRACK=$(cat /mnt/usb/output.log |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '^[0-9]+')
    ALL_TRACK=$(cat /mnt/usb/output.log |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '[0-9]+$')
    #LOGS=$(cat /mnt/usb/output.log | tr '"' "'")

    curl -v -XPUT https://piripper.herokuapp.com/api/v1/disks/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"trackCount\":\"$ALL_TRACK\", \"rippedTrackCount\":\"$ACTUAL_TRACK\"}" -H'Content-Type:application/json'
  fi

  sleep 5
done
