# sdrtrunk_recording_parser
Scripts to parse the sdrtrunk recording dir and move stuff around by date and talk group.


Major update to how this works.

##  Prerequisites
1. SDRTrunk: https://github.com/DSheirer/sdrtrunk
1. ffmpeg (or other utility to merge mp3s in a dir...)
1. PostgreSQL Database, any reasonably recent version should be fine.

## Database Installation
1. Create a postgresql database.

- createdb -U postgres -h localhost -p 5432 psf

2. Load the database. 

- pg_restore -U postgres -h localhost -p 5432 -d psf database/schema/psf-compressed.backup

3. Connect to the database and set paths to locations in the database pref table.  You can use the setpref function.

- SELECT setpref('current_path','/home/user/SDRTrunk/recordings'); -- This is the path that SDRTrunk writes recordings to.
- SELECT setpref('archive_path','/storage/path/archive'); -- This is where you want to move recordings into DATE/Talkgroup directories
- SELECT setpref('merged_path','/some/other/path/merged'); -- The is where you want merged talkgroup recordings to end up.

4. If using the psf-compressed.backup, you should see some test data:

- SELECT * FROM vw_all;

5. Import info from RR for the talkgroups.

- This data gets loaded into trs_tg.  Sample talkgroup data is in the trs_tg table for my locality.

## Setup PSF
1. Edit settings.ini to match your database, "reasonable" defaults are set, save after editing.
1. You can `source settings.ini & psql` as a quick test to see if the database lets you in.  If not, troubleshoot.
1. If you can connect, try to run it...
- bash ./psf.sh

## Automate the running
1. `*/10 * * * *  cd /home/pclark/sdrtrunk_recordings/script/psf && bash ./psf.sh`


## RR Thread

https://forums.radioreference.com/threads/shell-script-to-parse-sdrtrunk-recording-dir-and-sort-things-out-by-date-talkgroup-and-merge-mp3.463763/
