#!/bin/bash
WHIPPER_LOG_FILE=whipper.log
SERVICE_URL=https://piripper.herokuapp.com
SERVICE_DISKS_PATH=api/v1/disks

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

WORKING_DIR=$DIR

source $WORKING_DIR/config.sh

LOG_FILE=$WHIPPER_LOG_FILE

sudo touch $LOG_FILE
ID=$(curl -v -XPOST $SERVICE_URL/$SERVICE_DISKS_PATH -d '{}' -H'Content-Type:application/json' | jq '.id' | tr -d '"')
echo $ID

while :
do

  if [ ! -f $LOG_FILE ]; then
    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
    break;
  fi

  MATCH=$(cat $LOG_FILE |grep "Matching releases" | sed 's/^ *//;s/ *$//')

  if [[ -z "${MATCH// }" ]]; then
    echo 'not matching'

    ARTIST=$(cat $LOG_FILE |grep "MusicBrainz lookup URL" | sed 's/MusicBrainz lookup URL //')
    TITLE='Unknown'

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"status\":\"END\"}" -H'Content-Type:application/json'
  else
    echo 'matching'

    ARTIST=$(cat $LOG_FILE |grep "Artist *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $ARTIST
    TITLE=$(cat $LOG_FILE |grep "Title *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    echo $TITLE

    ACTUAL_TRACK=$(cat $LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '^[0-9]+')
    ALL_TRACK=$(cat $LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '[0-9]+$')
    #LOGS=$(cat $LOG_FILE | tr '"' "'")

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"trackCount\":\"$ALL_TRACK\", \"rippedTrackCount\":\"$ACTUAL_TRACK\"}" -H'Content-Type:application/json'
  fi

  sleep 5
done
