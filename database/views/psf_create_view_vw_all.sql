SELECT psf.create_view('public.vw_all', $BODY$

   SELECT
    'file '''::text || fetchpreftext('archive_path') || '/' ||TO_CHAR(psf_meta.p_time,'YYYYMMDD')  || '/' || psf_meta.p_tg || '/' || psf_files.filename || '''' AS ffurl,
     *
    FROM psf_files
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name )
		JOIN trs_tg ON (tg_site_id=site_id);

$BODY$, false);


