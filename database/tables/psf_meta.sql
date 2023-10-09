-- drop table psf_meta;

SELECT psf.create_table('psf_meta','public');

SELECT 
       	psf.add_column('psf_meta','p_id',		'integer',	'not null','public'),
        psf.add_column('psf_meta','p_time',		'timestamp','not null','public'),
        psf.add_column('psf_meta','p_sys1',		'text',		'','public'),
        psf.add_column('psf_meta','p_sys2',		'text','','public'),
        psf.add_column('psf_meta','p_type',		'text','','public'),
        psf.add_column('psf_meta','p_alias',		'text','','public'),
        psf.add_column('psf_meta','p_dir1',		'text','','public'),
        psf.add_column('psf_meta','p_tg',		'text','','public'),
        psf.add_column('psf_meta','p_dir2',		'text','','public'),
        psf.add_column('psf_meta','p_radio',		'text','','public'),
        psf.add_column('psf_meta','p_ext1',		'text','','public'),
        psf.add_column('psf_meta','created_at', 'timestamp','not null default transaction_timestamp()','public','Time PSF loaded this data.'),
        TRUE;

COMMENT ON TABLE public.psf_meta is 'Scanner File parsed data, from trigger on insert';

SELECT psf.add_constraint('psf_meta','psf_meta_psf_files_fk','FOREIGN KEY (p_id) REFERENCES public.psf_files ON DELETE CASCADE','public');


