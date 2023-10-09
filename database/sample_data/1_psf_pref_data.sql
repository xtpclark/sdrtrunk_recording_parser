INSERT INTO psf_pref (pref_id, pref_name, pref_value, pref_desc) VALUES 
(1, 'archive_path', '/storage/sdrtrunk_recordings/archive', 'Path to archived mp3s'),
(2, 'current_path', '/storage/sdrtrunk_recordings/current', 'Path that sdrtrunk puts recorded mp3s in.'),
(3, 'merged_path', '/storage/sdrtrunk_recordings/merged', 'Path for merged mp3.'),
(4, 'move_qry', 'SELECT ''''mkdir --parents ''''||fetchpreftext(''''archive_path'''')||''''/''''||to_char(p_time::date,''''YYYYMMDD'''')||''''/''''||p_tg||''''/; mv ''''||fetchpreftext(''''current_path'''')||''''/''''||filename||E'' \$_'' FROM psf_files JOIN psf_meta ON (id=p_id) WHERE job_id=${EXT_JOB_NUM};', 'Command to move the files into archive.'),
(5, 'cron', '/2 * * * *', 'Cron interval'),
(6, 'cron_test', '/30 * * * *', 'Cron interval');


SELECT pg_catalog.setval('psf_pref_pref_id_seq', 6, true);

