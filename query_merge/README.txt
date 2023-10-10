This is being worked on, but works.
See query_merge_v2.sh for more details.


Default example showing loop through all views found in rpt schema where viewname is like 15m
 
VIEWS="select viewname from pg_views where schemaname ='${rpt_schema}' and lower(viewname) ~'15m' order by 1;"

Alternatively, you can create custom views from vw_all on tg_alpha_tg, or whatever you wish:

Can set a pref, a just-these-views table, a list, etc.

select psf.create_view( 'myview', $BODY$ SELECT ffurl FROM vw_all WHERE p_time::DATE = ( CURRENT_DATE - 1 ) AND tg_alpha_tg ~'Zoo' ORDER BY  p_time;$BODY$ );

select setpref('qm1','myview');

See:  database/sample_data/5_psf_set_query_merge_rpts.sql
# Then pass that to VIEWS="my_zoo_today"


# Should get this from the database pref table with fetchpreftext

pclark@nvr:/storage/sdrtrunk_recordings/script/sdrtrunk_recording_parser/query_merge$ bash ./query_merge_v2.sh 
wrote: /storage/sdrtrunk_recordings/merged/all_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/fire_ems_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/norfolk_international_airport_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/norfolk_state_university_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/old_dominion_university_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/police_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/schools_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/services_15m_1696886632.mp3 
wrote: /storage/sdrtrunk_recordings/merged/sheriff_15m_1696886632.mp3 

