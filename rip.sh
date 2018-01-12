#!/bin/bash
TEMPORARY_OUTPUT_DIR=/tmp/piripper
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
exec 3>>$RIPPING_LOG_FILE

rm -rf $TEMPORARY_OUTPUT_DIR
mkdir -p $TEMPORARY_OUTPUT_DIR

rm $RIPPING_LOG_FILE
rm $WHIPPER_LOG_FILE
rm $WHIPPER_DEBUG_LOG_FILE

log_debug 'start ripping'
sudo WHIPPER_DEBUG=DEBUG WHIPPER_LOGFILE=$WHIPPER_DEBUG_LOG_FILE whipper cd rip --output-directory $TEMPORARY_OUTPUT_DIR >> $WHIPPER_LOG_FILE
log_info "end ripping in $TEMPORARY_OUTPUT_DIR with status: $?"
