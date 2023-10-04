#!/bin/bash

source $(pwd)/settings.ini
source $(pwd)/psf.fun

test_files() {

MP3DIR_SRC=$( ${PGQRY} "SELECT fetchpreftext('current_path');" )

ARCHIVE_DIR=$( ${PGQRY} "SELECT fetchpreftext('archive_path');" )


TEST_FULLFILE=$(find ${MP3DIR_SRC} ! -newermt ${NOT_NEWER_THAN} -iname "*.${MP3_EXT}" -print)
TEST_FULLFILE_COUNT=$( echo -n "${TEST_FULLFILE}" | grep -c '^' )

log echo "Count for Find: ${TEST_FULLFILE_COUNT}"
if [[ -z ${TEST_FULLFILE} ]]; then

log echo "No files found in ${MP3DIR_SRC}... Exiting!"

else


if [[ "1" == ${PARSED_DB_ENABLED} ]]; then
log echo "Setup the top of the SQL file..."
EXT_JOB_NUM=$( ${PGQRY} "SELECT nextval('extdat_job_num_seq');" )

log echo "Writing parsed sql inserts to ${PARSED_SQL_OUT}"
cat << EOF > ${PARSED_SQL_OUT}
INSERT INTO ${PARSED_DATA_TABLE} ( ext_filename, ext_talkgroup, ext_radio, ext_time, ext_date, ext_sys, ext_sys1, ext_sys2, ext_job ) VALUES
EOF

else
log echo "Not generating parsed SQL file"

fi


echo "Found ${TEST_FULLFILE_COUNT} $MP3_EXT files in $MP3DIR_SRC to sort!"
fi

for FILE in ${TEST_FULLFILE}; do
TEST_FILENAME=$(basename -- "${FILE}")

TEST_EXTENSION="${TEST_FILENAME##*.}"
TEST_FILENOEXT="${TEST_FILENAME%.*}"

TEST_FILEDATE="${TEST_FILENAME:0:8}"
TEST_CALLTS="${TEST_FILENAME:9:6}"

TEST_CALL_AREA="${TEST_FILENOEXT:15}"

TEST_SYSEARCHSTRING="_TRAFFIC"
TEST_SYREST=${TEST_CALL_AREA%${TEST_SYSEARCHSTRING}*}
TEST_SYREST_CUT=$( cut -d'_' -f 1 <<< "${TEST_SYREST}" )
TEST_SYREST_CUT2=$( cut -d'_' -f 2 <<< "${TEST_SYREST}" )
TEST_SYREST_CUT3=$( cut -d'_' -f 3 <<< "${TEST_SYREST}" )

TEST_TGSEARCHSTRING="_TRAFFIC__TO_"
TEST_TGREST=${TEST_FILENOEXT#*${TEST_TGSEARCHSTRING}}
TEST_TGREST_CUT=$( cut -d'_' -f1 <<< "${TEST_TGREST}" )

TEST_RASEARCHSTRING="_FROM_"
TEST_RAREST=${TEST_TGREST#*${TEST_RASEARCHSTRING}}
TEST_RAREST_CUT=$( cut -d'_' -f2 <<< "${TEST_RAREST}" )

TALKGROUP=${TEST_TGREST_CUT}

RADIOID=${TEST_RAREST_CUT}

if [[ ${TALKGROUP} -eq ${RADIOID} ]]; then
RADIOID="-1"
fi


if [[ "1" == ${PARSED_DB_ENABLED} ]]; then

cat << EOF >> ${PARSED_SQL_OUT}
('${TEST_FILENAME}','${TALKGROUP}','${RADIOID}','${TEST_CALLTS}','${TEST_FILEDATE}','${TEST_SYREST_CUT}','${TEST_SYREST_CUT2:-NULL}','${TEST_SYREST_CUT3:-NULL}','${EXT_JOB_NUM}'),
EOF

fi

done

if [[ "1" == ${PARSED_DB_ENABLED} ]]; then

# Clean up the bottom of the sql file...
cat << EOF >> ${PARSED_SQL_OUT}
('',null,'','','${WORKDATE}','','','',${EXT_JOB_NUM});
DELETE FROM ${PARSED_DATA_TABLE} WHERE ext_talkgroup is null and ext_job=${EXT_JOB_NUM};
EOF

fi

}


load_file_data() {


if [[ "1" == ${PARSED_DB_ENABLED} ]]; then
  psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE <  ${PARSED_SQL_OUT}
log  echo "Job Num ${EXT_JOB_NUM} Complete."
 else
log  echo "Parsed data loading disabled."
fi

 }




make_pg_move_scripts() {
TMPS_DIR=$(pwd)/temp_scripts
# TMPS_DIR=$( ${PGQRY} "SELECT fetchpreftext('psf_temp_dir');" )

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

