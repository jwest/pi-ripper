#!/bin/bash
WHIPPER_LOG_FILE=whipper.log
SERVICE_URL=https://piripperservice.herokuapp.com
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

source $WORKING_DIR/logging.sh
exec 3>>$PIRIPPERSERVICE_LOG_FILE

LOG_FILE=$WHIPPER_LOG_FILE

ARTIST='Unknown'
TITLE='Unknown'

log_debug "START pi ripping service notifier with $LOG_FILE file"

sudo touch $LOG_FILE
ID=$(curl -v -XPOST $SERVICE_URL/$SERVICE_DISKS_PATH -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\"}" -H'Content-Type:application/json' | jq '.id' | tr -d '"')

log_info "DISK ID ripping service $ID"

while :
do
  log_debug "START precessing while"

  if [ ! -f $LOG_FILE ]; then
    log_info "Log file $LOG_FILE not exist"
    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\"}" -H'Content-Type:application/json'
    break;
  fi

  MATCH=$(cat $LOG_FILE |grep "Matching releases" | sed 's/^ *//;s/ *$//')

  if [[ -z "${MATCH// }" ]]; then
    log_warn "DISK NOT matching with MusicBrainz"

    LINK=$(cat $LOG_FILE |grep "MusicBrainz lookup URL" | sed 's/MusicBrainz lookup URL //')

    log_warn "USE LINK: $LINK for create release"

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\",  \"meta\":{\"link\":\"$LINK\"}}" -H'Content-Type:application/json'
  else
    log_info "DISK matching with MusicBrainz"

    ARTIST=$(cat $LOG_FILE |grep "Artist *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    log_info "DISK ARTIST: $ARTIST"    

    TITLE=$(cat $LOG_FILE |grep "Title *:.*" | cut -d":" -f2 | sed 's/^ *//;s/ *$//' | tail -n1)
    log_info "DISK TITLE: $TITLE"

    ACTUAL_TRACK=$(cat $LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '^[0-9]+')
    ALL_TRACK=$(cat $LOG_FILE |grep "Ripping track .* of .*" | tail -n1 | grep -Po '^Ripping track ([0-9]+) of ([0-9]+):' | grep -Po '([0-9]+) of ([0-9]+)' | grep -Po '[0-9]+$')
    log_info "RIPPING TRACKS: $ACTUAL_TRACK/$ALL_TRACK"

    curl -v -XPUT $SERVICE_URL/$SERVICE_DISKS_PATH/$ID -d "{\"artist\":\"$ARTIST\", \"title\":\"$TITLE\", \"trackCount\":\"$ALL_TRACK\", \"rippedTrackCount\":\"$ACTUAL_TRACK\"}" -H'Content-Type:application/json'
  fi

  sleep 5
done
