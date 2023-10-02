#/bin/bash

source parselog_settings.ini

test_a_file() {

# NOTE  ! -newer 00:00:00 ... means NOT newer than today. Remove the ! if you want today.

TEST_FILE_NAME=$( find ${CALL_LOG_PATH} ! -newermt 00:00:00 -iname "*${LOG_TYPE}*" -print | grep ${LOG_DATE} | head -1 )
#TEST_FILE_NAME=$( find ${CALL_LOG_PATH} -iname "*${LOG_TYPE}*" -print | grep ${LOG_DATE} | head -1 )

if [[ -z ${TEST_FILE_NAME} ]]; then
echo "No \"${LOG_TYPE}\" files found in ${CALL_LOG_PATH} that match date format ${LOG_DATE}"
exit
fi


FILE_COUNT=$( find ${CALL_LOG_PATH} ! -newermt 00:00:00 -iname "*${LOG_TYPE}*" | grep ${LOG_DATE} |  wc -l )
# FILE_COUNT=$( find ${CALL_LOG_PATH} -iname "*${LOG_TYPE}*" | grep ${LOG_DATE} |  wc -l )


FULL_FILE_PATH="${TEST_FILE_NAME}"

echo ${FULL_FILE_PATH}

FILE="${FULL_FILE_PATH}"

echo "Testing ${FILE}"

FIELDS=$(cat ${FILE} | head -1 | sed 's/,/ /g')

for FIELD in $FIELDS; do
COL_NAMES="${COLUMN_PREFIX}${FIELD,,},"
COL_NAMES2+=${COL_NAMES}

FIELDCAT="${COLUMN_PREFIX}${FIELD,,} text,"
FIELDCAT2+=${FIELDCAT}

done

COL_NAMES_TRUNC=${COL_NAMES2%?}
FIELD_TRUNC=${FIELDCAT2%?}

cat << EOF > ${COL_NAME_LIST}
${COL_NAMES_TRUNC}
EOF

DROP_TABLE="DROP TABLE IF EXISTS ${TABLE_NAME}; "
CREATE_TABLE="CREATE TABLE ${TABLE_NAME} ( ${FIELD_TRUNC} );"

# psql -U ${PGUSER} -p ${PGPORT} -d ${PGDB} -c "${DROP_TABLE}"

psql -U ${PGUSER} -p ${PGPORT} -d ${PGDB} -c "${CREATE_TABLE}"

}

process_files() {

COLUMN_LIST=$( cat ${COL_NAME_LIST} )

FILES=$( find ${CALL_LOG_PATH} ! -newermt 00:00:00 -iname "*${LOG_TYPE}*" -print | grep ${LOG_DATE} | sort | head -2)
# `FILES=$( find ${CALL_LOG_PATH} -iname "*${LOG_TYPE}*" -print | grep ${LOG_DATE} | sort | head -2)

for LOG in ${FILES}; do
PLOG=${LOG}

# exit
psql -U ${PGUSER} -p ${PGPORT} -d ${PGDB} "\copy ${TABLE_NAME} ( ${COLUMN_LIST} ) FROM ${PLOG} CSV HEADER;"

#echo "Processed: ${PLOG}"
#cat << EOF >> processed_log-${LOG_DATE}_${WORKDATE}
#$PLOG
#EOF

done

}

test_a_file
process_files
