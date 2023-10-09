SELECT psf.create_table('trs_tg','public');

SELECT 
       	psf.add_column('trs_tg','tg_id',		'serial'	,'not null'	,'public'),
       	psf.add_column('trs_tg','tg_site_id',		'integer'	,''		,'public'),
       	psf.add_column('trs_tg','tg_decimal',		'integer'	,'not null'	,'public'),
        psf.add_column('trs_tg','tg_hex',		'text'		,'not null'	,'public'),
        psf.add_column('trs_tg','tg_alpha_tg',		'text'		,''		,'public'),
        psf.add_column('trs_tg','tg_mode',		'text'		,''		,'public'),
        psf.add_column('trs_tg','tg_desc',		'text'		,''		,'public'),
        psf.add_column('trs_tg','tg_tag',		'text'		,''		,'public'),
        psf.add_column('trs_tg','tg_category',		'text'		,''		,'public'),
        psf.add_primary_key('trs_tg','tg_id','public'),
        psf.add_index('trs_tg','tg_decimal, tg_hex, tg_alpha_tg, tg_mode, tg_desc, tg_tag, tg_category','trs_tg_imp_uniq','btree','public',TRUE),
        psf.add_index('trs_tg','tg_decimal','trs_tg_tg_decimal_idx','btree','public'),
        TRUE;

SELECT psf.add_constraint('trs_tg','tg_site_id_trs_sites_fk','FOREIGN KEY (tg_site_id) REFERENCES public.trs_sites' , 'public');

COMMENT ON TABLE public.trs_tg is 'RR TRS TG CSV Data Import';

