-- drop table if exists psf_files cascade;

SELECT psf.create_table('psf_files','public');

SELECT 
       	psf.add_column('psf_files','id',		'serial',	'not null','public'),
        psf.add_column('psf_files','filename',		'text','not null','public','Just the name of the file.'),
        psf.add_column('psf_files','job_id',		'integer','null','public','PSF Loader Number'),
        psf.add_primary_key('psf_files','id','public')       ;

-- Add a unique index on filename -- last param TRUE = unique
SELECT psf.add_index('psf_files','filename','psf_files_filename_uniq','btree','public',TRUE);

COMMENT ON TABLE public.psf_files is 'Loaded files with Job ID';

