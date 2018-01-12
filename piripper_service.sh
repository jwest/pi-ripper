#!/bin/bash
RIPPING_LOG_FILE=/mnt/usb/whipper.log
SERVICE_URL=https://piripper.herokuapp.com
SERVICE_DISKS_PATH=api/v1/disks

sudo touch $RIPPING_LOG_FILE
ID=$(curl -v -XPOST $SERVICE_URL/$SERVICE_DISKS_PATH -d '{}' -H'Content-Type:application/json' | jq '.id' | tr -d '"')
echo $ID

while :
do

  if [ ! -f $RIPPING_LOG_FILE ]; then
    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
    break;
  fi

  MATCH=$(cat $RIPPING_LOG_FILE |grep "Matching releases" | sed 's/^ *//;s/ *$//')

  if [[ -z "${MATCH// }" ]]; then
    echo 'not matching'

    ARTIST=$(cat $RIPPING_LOG_FILE |grep "MusicBrainz lookup URL" | sed 's/MusicBrainz lookup URL //')
    TITLE='Unknown'

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
  else
    echo 'matching'

    ARTIST=$(cat $RIPPING_LOG_FILE |grep "Artist *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $ARTIST
    TITLE=$(cat $RIPPING_LOG_FILE |grep "Title *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $TITLE

    ACTUAL_TRACK=$(cat $RIPPING_LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '^[0-9]+')
    ALL_TRACK=$(cat $RIPPING_LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '[0-9]+$')
    #LOGS=$(cat $RIPPING_LOG_FILE | tr '"' "'")

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"trackCount\":\"$ALL_TRACK\", \"rippedTrackCount\":\"$ACTUAL_TRACK\"}" -H'Content-Type:application/json'
  fi

  sleep 5
done
