-- drop table trs_sites;

SELECT psf.create_table('trs_sites','public');

SELECT 
       	psf.add_column('trs_sites','site_id',		'serial'	,'not null'	,'public'),
       	psf.add_column('trs_sites','rfss',		'text'	,''	,'public'),
        psf.add_column('trs_sites','site_dec',		'text'		,''	,'public'),
        psf.add_column('trs_sites','site_hex',		'text'		,''		,'public'),
        psf.add_column('trs_sites','site_nac',		'text'		,''		,'public'),
        psf.add_column('trs_sites','description',		'text'		,''		,'public'),
        psf.add_column('trs_sites','county_name',		'text'		,''		,'public'),
        psf.add_column('trs_sites','lat',		'text'		,''		,'public'),
        psf.add_column('trs_sites','lon',		'text'		,''		,'public'),
        psf.add_column('trs_sites','range',		'text'		,''		,'public'),
        psf.add_primary_key('trs_sites','site_id','public'),
        TRUE;

COMMENT ON TABLE public.trs_sites is $$ 
RR TRS Sites
Downloaded from https://www.radioreference.com/db/browse
$$;
