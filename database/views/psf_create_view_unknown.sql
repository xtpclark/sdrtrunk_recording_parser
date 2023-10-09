SELECT psf.create_view('rpt.unknown_tg', $BODY$

   SELECT
    'file '''::text || fetchpreftext('archive_path') || '/' ||TO_CHAR(psf_meta.p_time,'YYYYMMDD')  || '/' || psf_meta.p_tg || '/' || psf_files.filename || '''' AS ffurl,
     *
   FROM public.psf_files JOIN public.psf_meta ON (psf_files.id = psf_meta.p_id)
      WHERE  p_tg::text NOT IN (select tg_decimal::text from trs_tg);

$BODY$, false);


