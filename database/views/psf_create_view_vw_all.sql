SELECT psf.create_view('public.vw_all', $BODY$

   SELECT
    'file '''::text || fetchpreftext('archive_path') || '/' ||TO_CHAR(psf_meta.p_time,'YYYYMMDD')  || '/' || psf_meta.p_tg || '/' || psf_files.filename || '''' AS ffurl,
     *
    FROM psf_files
  JOIN psf_meta ON psf_files.id = psf_meta.p_id
     JOIN trs_sites ON psf_meta.p_sys1 = trs_sites.county_name
     JOIN trs_tg ON psf_meta.p_tg::integer = trs_tg.tg_decimal;
$BODY$, false);


