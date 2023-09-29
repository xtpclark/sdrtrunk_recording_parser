#!/bin/bash
DEBUG=0

MP3DIR_SRC=current
ARCHIVE_DIR=archive
MERGE_DIR=merged

MP3_EXT=mp3

WORKDATE=$(date +"%Y%m%d")

MP3_MERGE_LIST=merge-${WORKDATE}.list
MOVESCRIPT=move-${WORKDATE}.sh
EXIF_CSV_OUT=exif-mp3-${WORKDATE}.csv
EXTRASQLOUT=parsed-mp3-data-${WORKDATE}.sql
MERGE_SCRIPT=merge_cmd-${WORKDATE}.sh

rm $MP3_MERGE_LIST
rm $MOVESCRIPT
rm $EXIF_CSV_OUT
rm $EXTRASQLOUT
rm $MERGE_SCRIPT

source pg_settings.ini

export EXIFCOL="\$filename,\$filesize,\$mimetype,\$filetypeextension,\$comment,\$album,\$composer,\$genre,\$date,\$grouping,\$title,\$artist,\$duration"



test_files() {


if [[ "1" == ${DEBUG} ]]; then
echo "*******************Using DEBUG Config!****************"
TEST_FULLFILE="../${MP3DIR_SRC}/20230927_001335PossumCreek_PossumCreek_TRAFFIC__TO_611_FROM_16043.mp3"
TEST_FULLFILE_COUNT=1
else

TEST_FULLFILE=$(find ../$MP3DIR_SRC ! -newermt 00:00:00 -iname "*.mp3" -print)
TEST_FULLFILE_COUNT=$(find ../$MP3DIR_SRC ! -newermt 00:00:00 -iname "*.mp3" | wc -l)

fi


if [[ -z ${TEST_FULLFILE} ]]; then
 echo "No files found in $MP3DIR_SRC... Exiting!"
 exit
else

#Setup the top of the SQL file...
cat << EOFB > ${EXTRASQLOUT}
INSERT INTO extdat VALUES
EOFB


echo "Found ${TEST_FULLFILE_COUNT} $MP3_EXT files in $MP3DIR_SRC to sort!"
fi

for FILE in $TEST_FULLFILE; do
TEST_FILENAME=$(basename -- "$FILE")

TEST_EXTENSION="${TEST_FILENAME##*.}"
TEST_FILENOEXT="${TEST_FILENAME%.*}"

TEST_FILEDATE="${TEST_FILENAME:0:8}"
TEST_CALLTS="${TEST_FILENAME:9:6}"

TEST_CALL_AREA="${TEST_FILENOEXT:15}"

TEST_MVSEARCHSTRING="_FROM"
TEST_MVREST=${TEST_CALL_AREA%${TEST_MVSEARCHSTRING}*}
TEST_MVREST_CUT=$( cut -d'_' -f 1 <<< "${TEST_MVREST}" )

TEST_SYSEARCHSTRING="_TRAFFIC"
TEST_SYREST=${TEST_CALL_AREA%${TEST_SYSEARCHSTRING}*}
TEST_SYREST_CUT=$( cut -d'_' -f 1 <<< "${TEST_SYREST}" )
TEST_SYREST_CUT2=$( cut -d'_' -f 2 <<< "${TEST_SYREST}" )
TEST_SYREST_CUT3=$( cut -d'_' -f 3 <<< "${TEST_SYREST}" )
SYRES=$(( ${#TEST_FILENOEXT} - ${#TEST_SYREST} - ${#TEST_SYSEARCHSTRING} ))

TEST_TGSEARCHSTRING="_TRAFFIC__TO_"
TEST_TGREST=${TEST_FILENOEXT#*${TEST_TGSEARCHSTRING}}
TEST_TGREST_CUT=$( cut -d'_' -f1 <<< "${TEST_TGREST}" )
TGRES=$(( ${#TEST_FILENOEXT} - ${#TEST_TGREST} - ${#TEST_TGSEARCHSTRING} ))

TEST_RASEARCHSTRING="_FROM_"
TEST_RAREST=${TEST_TGREST#*${TEST_RASEARCHSTRING}}
TEST_RAREST_CUT=$( cut -d'_' -f2 <<< "${TEST_RAREST}" )
RARES=$(( ${#TEST_FILENOEXT} - ${#TEST_RAREST} - ${#TEST_RASEARCHSTRING} ))



TALKGROUP=${TEST_TGREST_CUT}
RADIOID=${TEST_RAREST_CUT}

if [[ $TALKGROUP -eq $RADIOID ]]; then
RADIOID="ALL"
fi

DATE_DIR=${TEST_FILEDATE}
CALLDATE=${TEST_FILEDATE}
TARGET_TG_DIR=${ARCHIVE_DIR}/${DATE_DIR}/${TALKGROUP}
FILENAME=${TEST_FILENAME}
SOURCE_DIR_FILE=${MP3DIR_SRC}/${FILENAME}
TARGET_DIR_FILE=${TARGET_TG_DIR}/${FILENAME}

MOVE_SELECTION="${TEST_FILEDATE}*${TEST_MVREST}*.${TEST_EXTENSION}"


MP3_MERGE_PATH=${TARGET_TG_DIR}

if [[ "1" ==  $DEBUG ]]; then

echo "

TEST_FILENAME: $TEST_FILENAME
TEST_FILENOEXT: $TEST_FILENOEXT
TEST_EXTENSION: $TEST_EXTENSION

TEST_FILEDATE: $TEST_FILEDATE
TEST_CALLTS: $TEST_CALLTS

TEST_MVREST: $TEST_MVREST

TEST_TGREST: ${TEST_TGREST}
TEST_TGREST_CUT: $TEST_TGREST_CUT

TEST_CALL_AREA: $TEST_CALL_AREA 
TEST_SYREST: $TEST_SYREST
TEST_SYREST_CUT: $TEST_SYREST_CUT
TEST_SYREST_CUT2: $TEST_SYREST_CUT2
TEST_SYREST_CUT3: ${TEST_SYREST_CUT3:-NULL}

TEST_RASEARCHSTRING: $TEST_RASEARCHSTRING
TEST_RAREST: $TEST_RAREST
TEST_RAREST_CUT: $TEST_RAREST_CUT

FILENAME: $TEST_FILENAME
LOC: $TEST_SYREST_CUT
LOC2: ${TEST_SYREST_CUT2:-NULL}
LOC3: ${TEST_SYREST_CUT3:-NULL}
TALKGROUP: ${TALKGROUP}
RADIOID: ${RADIOID}
CALLDATE: ${TEST_FILEDATE}
CALLTIME: ${TEST_CALLTS}

DATE_DIR: $DATE_DIR
SOURCE_DIR_FILE: ${SOURCE_DIR_FILE}
TARGET_TG_DIR: ${TARGET_TG_DIR}
TARGET_DIR_FILE: ${TARGET_TG_DIR}/${FILENAME}
MOVE_SELECTION: $MOVE_SELECTION

MP3_MERGE_PATH: ${MP3_MERGE_PATH}
MP3_MERGE_FILEOUT: ${MP3_MERGE_FILEOUT}
MP3_MERGE_LIST: ${MP3_MERGE_LIST}

"
read dummy

fi



MOVECMD="mv ../${SOURCE_DIR_FILE} ../${TARGET_DIR_FILE}"

 if [[ "1" == $DEBUG ]]; then

echo "Generating extra SQL:"
echo "INSERT INTO extdat VALUES ('$TEST_FILENAME','$TALKGROUP'.'$RADIOID','$TEST_CALLTS','$TEST_FILEDATE','$TEST_SYREST_CUT','${TEST_SYREST_CUT2:-NULL}','${TEST_SYREST_CUT3:-NULL}');"

echo "Running exiftool csv:"
echo "exiftool -f -r -p ${EXIFCOL} ../${SOURCE_DIR_FILE} >> ${EXIF_CSV_OUT}"

echo "mv file command:"
echo "${MOVECMD}"

read dummy

else


cat << EOF >> ${EXTRASQLOUT}
('$TEST_FILENAME','$TALKGROUP'.'$RADIOID','$TEST_CALLTS','$TEST_FILEDATE','$TEST_SYREST_CUT','${TEST_SYREST_CUT2:-NULL}','${TEST_SYREST_CUT3:-NULL}'),
EOF


exiftool -f -r -p ${EXIFCOL} ../${SOURCE_DIR_FILE} >> ${EXIF_CSV_OUT}


cat << OGG >> $MOVESCRIPT
${MOVECMD}
OGG

fi

check_date_dir



done

# Clean up the bottom of the sql file...
cat << EOFF >> ${EXTRASQLOUT}
('','','','','01/01/01','','','');
EOFF


}

load_psql_exif_data() {

if [[ "1" == ${DEBUG} ]]; then

  echo " PSQL copy from ${EXIT_CSV_OUT}:"
  echo " psql -c \"\copy mp3data FROM '${EXIF_CSV_OUT}' csv \" "
  echo " psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE <  ${EXTRASQLOUT}"

 read dummy

else

 psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE -c "\copy mp3data FROM '${EXIF_CSV_OUT}' csv "
 psql -U $PGUSER -h $PGHOST -p $PGPORT -d $PGDATABASE <  ${EXTRASQLOUT}

fi


}

merge_mp3() {

MERGE_WORKDIRS="$( cat ${MP3_MERGE_LIST} )"

for WORKDIR in ${MERGE_WORKDIRS}; do
echo "Merging In $WORKDIR"

F1=$( cut -d'/' -f 3 <<< "${WORKDIR}" )
F2=$( cut -d'/' -f 4 <<< "${WORKDIR}" )

MP3_MERGE_FILEOUT="${MERGE_DIR}/${F1}_${F2}.mp3"

cat << EOF >> ${MERGE_SCRIPT}
ffmpeg -f concat -safe 0 -i <(find "$(pwd)/${WORKDIR}" -iname '*.mp3' -printf "file '%p'\n" | sort) -c copy $(pwd)/../${MP3_MERGE_FILEOUT}
EOF

echo "Output in ${MP3_MERGE_FILEOUT}"

done

}

make_date_dir() {
	
mkdir -p ../${TARGET_TG_DIR}

check_date_dir

}
  
# Check if  dir  exists
check_date_dir() {
if [ -d ../${TARGET_TG_DIR} ]; then

#  echo "Talkgroup Directory ${TARGET_TG_DIR} exists."
  
   MP3DIR_TARGET=${TARGET_TG_DIR}
  
#  echo "Setting target to dir ${TARGET_TG_DIR}"
  
 else
# echo "Talkgroup Directory ${TARGET_TG_DIR} does not exist. Creating it."
cat << EOF >> ${MP3_MERGE_LIST}
../${TARGET_TG_DIR}
EOF
 
 make_date_dir
fi

}

move_mp3_src_to_target() {

echo "mv ../${MP3DIR_SRC}/${MOVE_SELECTION} ../${MP3DIR_TARGET}"

}

run_move() {
echo "Moving Files"
source ${MOVESCRIPT}

}

run_merge_mp3() {
echo "Merging MP3s"

source ${MERGE_SCRIPT}

}


test_files
run_move

load_psql_exif_data

merge_mp3
run_merge_mp3



exit

