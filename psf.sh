#!/bin/bash

# TODO: GENERALLY MOVE ALL-THE-THINGS TO THE DATABASE

INIFILE=$(pwd)/psf_settings.ini

if [ -f "${INIFILE}" ]; then
    if [ -s "${INIFILE}" ]; then
        echo "File ${INIFILE} exists and not empty"
    else
        echo "File ${INIFILE} exists but empty"
	echo "Run setup.sh, or fix your ini."
       exit
    fi
else
    echo "File ${INIFILE} does not exist"
    echo "Run setup.sh first"
exit

fi



source ${INIFILE}

DATE=$( date +"%Y%m%d" )

log_exec() {
  "$@" | tee -a $LOG_FILE 2>&1
  RET=${PIPESTATUS[0]}
  return $RET
}

log() {
  echo "$( date +"%T" ) psf >> $@" | tee -a $LOG_FILE
}

## TODO: Log to database.
mkdir -p $(pwd)/logs

LOG_FILE=$(pwd)/logs/psf-$DATE.log
log "Logging initialized. Current session will be logged to $LOG_FILE"

do_exit() {
  echo "In: ${BASH_SOURCE} ${FUNCNAME[@]}"

  log "Exiting PSF"
  exit 0
}

test_files() {

MP3DIR_SRC=$( ${PGQRY} "SELECT fetchpreftext('current_path');" )

ARCHIVE_DIR=$( ${PGQRY} "SELECT fetchpreftext('archive_path');" )


TEST_FULLFILE=$(find ${MP3DIR_SRC} ! -newermt ${NOT_NEWER_THAN} -iname "*.${MP3_EXT}" -print)
TEST_FULLFILE_COUNT=$( echo -n "${TEST_FULLFILE}" | grep -c '^' )

log echo "Count for Find: ${TEST_FULLFILE_COUNT}"

if [[ -z ${TEST_FULLFILE} ]]; then

log echo "No files found in ${MP3DIR_SRC}... Exiting!"
exit
else


if [[ "1" == ${PARSED_DB_ENABLED} ]]; then
log echo "Setup the top of the SQL file..."
EXT_JOB_NUM=$( ${PGQRY} "SELECT nextval('psf_files_job_id_seq');" )

else
log echo "Not generating parsed SQL file"

fi


echo "Found ${TEST_FULLFILE_COUNT} $MP3_EXT files in $MP3DIR_SRC to sort!"
rm ${PARSED_SQL_OUT}

fi


for FILE in ${TEST_FULLFILE}; do

TEST_FILENAME=$(basename -- "${FILE}")

cat << EOF >> ${PARSED_SQL_OUT}
INSERT INTO ${PARSED_DATA_TABLE} ( filename, job_id ) VALUES ('${TEST_FILENAME}','${EXT_JOB_NUM}');
EOF


done

}


load_file_data() {


if [[ "1" == ${PARSED_DB_ENABLED} ]]; then
psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE < ${PARSED_SQL_OUT}

log  echo "Job Num ${EXT_JOB_NUM} Complete."
 else
log  echo "Parsed data loading disabled."
fi

 }



# TODO: Do this from the database
make_pg_move_scripts() {
TMPS_DIR=$(pwd)/temp_scripts
mkdir -p ${TMPS_DIR}

#TODO: TMPS_DIR=$( ${PGQRY} "SELECT fetchpreftext('psf_temp_dir');" )

MVQRY=${TMPS_DIR}/mvqry_${EXT_JOB_NUM}.sh

MVSCRIPT=${TMPS_DIR}/mvscript_${EXT_JOB_NUM}.sh

GET_MOVE_QRY=$( ${PGQRY} "SELECT fetchpreftext('move_qry');" )

CLEAN_QUOTES=$( sed "s/''/\'/g"  <<< "${GET_MOVE_QRY}" )

cat << EOF > ${MVQRY}
#!/bin/bash
EXT_JOB_NUM=${EXT_JOB_NUM}
${PGQRY} "${CLEAN_QUOTES}" >  ${MVSCRIPT}
EOF


}

# TODO: Do this from the database.
run_move_scripts() {

source ${MVQRY}

log echo "Query ${MVQRY} complete, generated ${MVSCRIPT}."

source ${MVSCRIPT}

log echo "Ran ${MVSCRIPT} Command complete"
}


test_files

load_file_data

make_pg_move_scripts

run_move_scripts

do_exit



exit
