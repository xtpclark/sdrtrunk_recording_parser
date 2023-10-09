-- drop table trs_freq;

SELECT psf.create_table('trs_freq','public');

SELECT 
       	psf.add_column('trs_freq','freq_id',		'serial'  ,'not null'	,'public'),
       	psf.add_column('trs_freq','freq_site_id',	'integer' ,''		,'public'),
       	psf.add_column('trs_freq','freq',		'text'	  ,''		,'public'),
        psf.add_column('trs_freq','iscontrol',		'boolean' ,''		,'public'),
        psf.add_primary_key('trs_freq','freq_id','public'),
        psf.add_index('trs_freq','freq_site_id,freq','trs_freq_site_freq_uniq','btree','public',TRUE),
	psf.add_constraint('trs_freq','trs_freq_trs_sites_fk','FOREIGN KEY (freq_site_id) REFERENCES public.trs_sites' , 'public'),
	TRUE;

COMMENT ON TABLE public.trs_freq is 'RR TRS Site Frequencies CSV Data Import';



