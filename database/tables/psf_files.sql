-- drop table if exists psf_files cascade;

SELECT psf.create_table('psf_files','public');

SELECT 
       	psf.add_column('psf_files','id',		'serial',	'not null','public'),
        psf.add_column('psf_files','filename',		'text','not null','public'),
        psf.add_column('psf_files','job_id',		'integer','not null','public'),
        psf.add_primary_key('psf_files','id','public')       ;

-- Add a unique index on filename
SELECT psf.add_index('psf_files','filename','psf_files_filename_uniq','btree','public',TRUE);

COMMENT ON TABLE public.psf_files is 'Loaded Scanner Files';

-- insert into psf_files (filename, job_id) select ext_filename, ext_job from extdat where ext_job between 1640 and 1650;
