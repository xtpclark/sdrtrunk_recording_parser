# sdrtrunk_recording_parser
Scripts to parse the sdrtrunk recording dir and move stuff around by date and talk group.


Major update to how this works...

##  Prerequisites
1. SDRTrunk: https://github.com/DSheirer/sdrtrunk
1. ffmpeg (or other utility to merge mp3s in a dir...)
1. PostgreSQL Database, any reasonably recent version should be fine.

## Database Installation

1. Create a postgresql database. SEE INSTRUCTIONS IN database/README.TXT

- `createdb -U postgres -h localhost -p 5432 psf`

2. Load the database - see instructions in database/ README.TXT


3. Connect to the database and set paths to locations in the database pref table.  You can use the setpref function.

- `SELECT setpref('current_path','/home/user/SDRTrunk/recordings');` -- This is the path that SDRTrunk writes recordings to.
- `SELECT setpref('archive_path','/storage/path/archive');` -- This is where you want to move recordings into DATE/Talkgroup directories
- `SELECT setpref('merged_path','/some/other/path/merged');` -- The is where you want merged talkgroup recordings to end up.


5. Import info from RR for the talkgroups and sites.

- This data gets loaded into `trs_tg`.  Sample talkgroup data is in the `trs_tg` table for my locality.
- Site data too. see readme.txt

## Setup PSF
1. Run setup.sh
1. If not, troubleshoot.
- `
source psf_settings.ini && psql

1. If you can connect, disconnect with `\q` and  try to run psf.sh...

- `bash ./psf.sh`

## Automate the running
1. `*/10 * * * *  cd /home/pclark/sdrtrunk_recordings/script/psf && bash ./psf.sh`


## RR Thread

https://forums.radioreference.com/threads/shell-script-to-parse-sdrtrunk-recording-dir-and-sort-things-out-by-date-talkgroup-and-merge-mp3.463763/
