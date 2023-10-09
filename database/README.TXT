# Loading the PSF database

As the postgres or other admin user:

If this is your first time setting up PSF on the server:

1. Create the user/role and  database:

  psql -U postgres -p 5432 < database/init_psf.sql

2. Then load the database as the psfadmin user:

  psql -U psfadmin -p 5432 psf < database/psf_database.sql


Setting PSF Prefrences:
Except for psf_prefs, all other tables are empty.

There are 3 Preferences that need to be set from the loaded defaults:
 
 current_path - Path that SDRTrunk is configured to save recordings to.
 archive_path - Path where you want to archive things into.
 merged_path - Path where merged mp3s will end up.

To set these do:

 psql -U psfadmin -p 5432 psf -c "SELECT psf.setpref('current_path', '/path/to/sdrtrunk/recordings');"
 psql -U psfadmin -p 5432 psf -c "SELECT psf.setpref('archive_path', '/storage/archive');"
 psql -U psfadmin -p 5432 psf -c "SELECT psf.setpref('merged_path',  '/storage/shared');"

This can be done from pgAdmin4 or directly on the CLI.

These are the loaded defaults, they likely need to be changed:
 pref_id |  pref_name   |              pref_value              |                 pref_desc                 
---------+--------------+--------------------------------------+-------------------------------------------
       1 | archive_path | /storage/sdrtrunk_recordings/archive | Path to archived mp3s
       2 | current_path | /storage/sdrtrunk_recordings/current | Path that sdrtrunk puts recorded mp3s in.
       3 | merged_path  | /storage/sdrtrunk_recordings/merged  | Path for merged mp3.


The init_psf.sql script is doing:

CREATE ROLE psfrole;
CREATE USER psfadmin IN GROUP psfrole CREATEDB CREATEROLE PASSWORD 'changeme';
CREATE DATABASE psf OWNER psfadmin;


The next step is to load your trs_sites and trs_tg data for the systems you monitor.

There are 3 tables: trs_tg, trs_sites and trs_freqs. The sites and talkgroup data are important.

trs_freqs isn't very important at this point.

There is sample trs data in the sample_data directory to see what the CSV or whatever needs to look like.


What else:

Once your Site and TG data is loaded, there are 2 functions to run to generate merging/reporting views.
The purpose of these views is to 'easily' present an ffmpeg style URL, ordered by the timestamp of the individual mp3.

SELECT psf.create_rpt_views(); -- to generate the rpt. schema views for each TG Category.

Views in rpt schema are for all tg categories in 15 min ago, 30 min ago, (tdy) = midnight till now() and yesteday (yda)  = current_date - 1 day
 
rpt.all_15m      
rpt.all_30m      
rpt.fire_ems_15m 
rpt.fire_ems_30m 
rpt.fire_ems_tdy 
rpt.fire_ems_yda 

i.e. rpt.all_15m
                                                         ffurl                                                           
--------------------------------------------------------------------------------------------------------------------------
 file '/storage/sdrtrunk_recordings/archive/20231009/834/20231009_031057Norfolk_Norfolk_TRAFFIC__TO_834_FROM_5557643.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/646/20231009_031159Norfolk_Norfolk_TRAFFIC__TO_646_FROM_16045.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/646/20231009_031156Norfolk_Norfolk_TRAFFIC__TO_646_FROM_5555161.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/834/20231009_031109Norfolk_Norfolk_TRAFFIC__TO_834_FROM_5557756.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/885/20231009_031144Norfolk_Norfolk_TRAFFIC__TO_885_FROM_15268.mp3'

This data is read by the query_merge.sh script to concat them all together and move them to your merged folder.


TALKGROUP VIEWS.
Basically the same thing as the tg categories views, but for the individual talk groups.

SELECT psf.create_tg_views();


 tg_rpt.norfolk_740_norf_lifegrd_15min 
 tg_rpt.norfolk_740_norf_lifegrd_30min 
 tg_rpt.norfolk_740_norf_lifegrd_45min 
 tg_rpt.norfolk_740_norf_lifegrd_60min 
 tg_rpt.norfolk_740_norf_lifegrd_tdy   
 tg_rpt.norfolk_740_norf_lifegrd_yda   
 tg_rpt.norfolk_742_norf_parks_15min   
 tg_rpt.norfolk_742_norf_parks_30min   
 tg_rpt.norfolk_742_norf_parks_45min   
 tg_rpt.norfolk_742_norf_parks_60min   
 tg_rpt.norfolk_742_norf_parks_tdy     
 tg_rpt.norfolk_742_norf_parks_yda     


psf5=# select * from tg_rpt.norfolk_608_npd_1st_main_15min ;
                                                          ffurl                                                           
--------------------------------------------------------------------------------------------------------------------------
 file '/storage/sdrtrunk_recordings/archive/20231009/608/20231009_032931Norfolk_Norfolk_TRAFFIC__TO_608_FROM_5556109.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/608/20231009_032939Norfolk_Norfolk_TRAFFIC__TO_608.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/608/20231009_032943Norfolk_Norfolk_TRAFFIC__TO_608_FROM_5556109.mp3'
 file '/storage/sdrtrunk_recordings/archive/20231009/608/20231009_032944Norfolk_Norfolk_TRAFFIC__TO_608.mp3'
(4 rows)






