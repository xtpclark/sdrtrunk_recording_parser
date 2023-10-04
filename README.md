# sdrtrunk_recording_parser
Scripts to parse the sdrtrunk recording dir and move stuff around by date and talk group.

Major update to how this works.

## Prerequsites
1. SDRTrunk: https://github.com/DSheirer/sdrtrunk
1. ffmpeg (or other utility to merge mp3s in a dir...)
1. PostgreSQL Database, any reasonably recent version should be fine.

## Crontab
1. `*/10 * * * *  cd /home/pclark/sdrtrunk_recordings/script/psf && bash ./psf.sh`


## RR Thread


https://forums.radioreference.com/threads/shell-script-to-parse-sdrtrunk-recording-dir-and-sort-things-out-by-date-talkgroup-and-merge-mp3.463763/
