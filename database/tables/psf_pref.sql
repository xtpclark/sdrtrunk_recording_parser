SELECT psf.create_table('psf_pref','public');

SELECT 
       	psf.add_column('psf_pref','pref_id',		'serial'	,'not null'	,'public'),
        psf.add_column('psf_pref','pref_name',		'text'		,'not null'	,'public'),
        psf.add_column('psf_pref','pref_value',		'text'		,''		,'public'),
        psf.add_column('psf_pref','pref_desc',		'text'		,''		,'public'),
        psf.add_primary_key('psf_pref','pref_id','public'),
	TRUE;

SELECT psf.add_index('psf_pref','pref_name','pref_name_uniq','btree','public',TRUE);

COMMENT ON TABLE public.psf_pref is 'PSF Preferences';
