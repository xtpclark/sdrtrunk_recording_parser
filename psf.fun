#!/bin/bash
DATE=$( date +"%Y%m%d" )

log_exec() {
  "$@" | tee -a $LOG_FILE 2>&1
  RET=${PIPESTATUS[0]}
  return $RET
}

log() {
  echo "$( date +"%T" ) psf >> $@" | tee -a $LOG_FILE
}

LOG_FILE=$(pwd)/logs/psf-$DATE.log
log "Logging initialized. Current session will be logged to $LOG_FILE"

do_exit() {
  echo "In: ${BASH_SOURCE} ${FUNCNAME[@]}"

  log "Exiting PSF"
  exit 0
}

