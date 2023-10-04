#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo "Working dir is $DIR"

PGCMD='psql -AtXq -U postgres -p 5443 -h localhost sdr -f '


FFURL_QRY=$1

WORKDATE=$( date +"%Y-%m-%d-%H%M-%S" )


MP3_OUT_PATH="/storage/sdrtrunk_recordings/merged"
MP3_FILE_NAME="${FFURL_QRY%%.*}-${WORKDATE}.mp3"
MP3_OUT="${MP3_OUT_PATH}/${MP3_FILE_NAME}"

RES_OUT=${FFURL_QRY}.results

if [[ -z ${FFURL_QRY} ]]; then
 echo "Feed me a query file!"
 echo "i.e.:"
 echo "

  Example contents of file myquery.sql:
       SELECT ffurl FROM vw_all WHERE category='Police' and dt='2023-09-30';

  Then run it like:
      ./$(basename $0) myquery.sql

"
 exit

else

FFURL_LIST=$( ${PGCMD} ${FFURL_QRY} > ${RES_OUT} )
PGRES=${?}

if [[  ${PGRES} -ne 0 ]]; then

 echo "PostgreSQL Error"
 echo "Check ${PGCMD}.  Exiting."
exit
else

# ROW_COUNT=$( wc -l ${RES_OUT} | cut -d' ' -f1 )
ROW_COUNT=$( echo -n "${RES_OUT}" | grep -c '^' )
echo "Query ran successfully."
echo "Wrote ${ROW_COUNT} records to ${RES_OUT}"

if [[ ${ROW_COUNT} == "0" ]]; then
echo "No rows. Check Query"
exit
fi


fi

# FFURL_LIST=$( psql -At -U postgres -p 5443 -d sdr -f ${FFURL_QRY} > ${RES_OUT} )



echo "Running ffmpeg"

ffmpeg -loglevel verbose -f concat -safe 0 -i <( cat ${RES_OUT} ) -c copy ${MP3_OUT}
FFRES=${?}

if [[ "1" == ${FFRES} ]]; then
echo "Error: ${FFRES}"

else
echo "ffmpeg merged ${ROW_COUNT} files into:"
echo "${MP3_OUT}"
fi

fi


#1. Create a query in a file i.e. merge.qry with a query in it:
#  Look at fields in the vw_all view. Column ffurl is already formatted the way ffmpeg wants it.
# select ffurl from vw_all where  dt='2023-09-30' and category ~'Service' and hms between '13:00:00' AND '18:00:00' ORDER BY ts_tz;

#2.  Run the query and redirect to list.out
# psql -At -U postgres -p 5443 -d sdr -f merge.qry > list.out

#3. Feed the list.out to ff_merge.sh i.e.:
# ./ff_merge.sh list.out
# *****************
# Created file as /storage/sdrtrunk_recordings/merged/qryMerged-2023-10-03-0002-26.mp3
# ****************
