#Output direcotry @TODO remove
OUTPUT_DIR=/mnt/usb

#temporary directory
TEMPORARY_OUTPUT_DIR=/tmp/piripper

#Logs verbositi level
# silent_lvl=0
# crt_lvl=1
# err_lvl=2
# wrn_lvl=3
# inf_lvl=4
# dbg_lvl=5
VERBOSITY_LVL=5

#Logs from pi-ripper process
PIRIPPER_LOG_FILE=/home/pi/ripper.log

#Logs from pi ripper service notifier
PIRIPPERSERVICE_LOG_FILE=/home/pi/ripper_service.log

#Logs from whipper ripping
WHIPPER_LOG_FILE=/home/pi/ripper_whipper.log

#Logs from whipper debug ripping
WHIPPER_DEBUG_LOG_FILE=/home/pi/ripper_whipper_debug.log

#Logs from rip process
RIPPING_LOG_FILE=/home/pi/ripper_rip.log

SERVICE_URL=https://piripperservice.herokuapp.com
SERVICE_DISKS_PATH=api/v1/disks

