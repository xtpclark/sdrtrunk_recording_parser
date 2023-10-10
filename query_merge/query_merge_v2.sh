#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
# echo "Working dir is $DIR"


INIFILE=../psf_settings.ini

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


TS=$( date +"%s" )

RPT_SCHEMA=rpt
# rpt_schema=tg_rpt

# can set a pref, a just-these-views table, a list, etc.
# Example showing loop through all views found in rpt schema where viewname is like 15m
# Shortly these will be an easier database defined thing.
 
VIEWS="select viewname from pg_views where schemaname ='${RPT_SCHEMA}' and lower(viewname) ~'tdy' order by 1;"

# Alternatively, you can create custom views from vw_all on tg_alpha_tg, or whatever you wish:
# create view rpt.my_zoo_today AS select ffurl from vw_all where p_time::date = CURRENT_DATE AND tg_alpha_tg ~'Zoo' order by p_time;
# Then pass that to VIEWS="my_zoo_today"

# Get this from the database pref table with fetchpreftext
MP3_OUT_PATH=$( ${PGQRY} "SELECT fetchpreftext('merged_path')" )

VIEWS_LIST=$( ${PGQRY} "${VIEWS}" )

for VIEW in ${VIEWS_LIST}; do

MP3_OUT=${MP3_OUT_PATH}/${VIEW}_${TS}.mp3

ffmpeg -loglevel quiet -f concat -safe 0 -i <( ${PGQRY} "SELECT ffurl FROM ${RPT_SCHEMA}.${VIEW}" ) -c copy ${MP3_OUT}
echo "wrote: ${MP3_OUT} "
done

# Should do some error checking...
