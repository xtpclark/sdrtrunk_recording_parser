#!/bin/bash
TS=$( date +"%s" )
PGCMD="psql -At -U postgres -p 5443 psf5 -c "
rpt_schema=rpt

# can set a pref, a just-these-views table, a list, etc.
# Example showing loop through all views found in rpt schema where viewname is like 15m
 
VIEWS="select viewname from pg_views where schemaname ='${rpt_schema}' and viewname ~'15m' order by 1;"

# Alternatively, you can create custom views from vw_all on tg_alpha_tg, or whatever you wish:
# create view rpt.my_zoo_today AS select ffurl from vw_all where p_time::date = CURRENT_DATE AND tg_alpha_tg ~'Zoo' order by p_time;
# Then pass that to VIEWS="my_zoo_today"


# Should get this from the database pref table with fetchpreftext
MP3_OUT_PATH=$( ${PGCMD} "SELECT fetchpreftext('merged_path')" )

VIEWS_LIST=$( ${PGCMD} "${VIEWS}" )


for VIEW in ${VIEWS_LIST}; do

MP3_OUT=${MP3_OUT_PATH}/${VIEW}_${TS}.mp3

ffmpeg -loglevel quiet -f concat -safe 0 -i <( ${PGCMD} "SELECT ffurl FROM rpt.${VIEW}" ) -c copy ${MP3_OUT}
echo "wrote: ${MP3_OUT} "
done

# Should do some error checking...
