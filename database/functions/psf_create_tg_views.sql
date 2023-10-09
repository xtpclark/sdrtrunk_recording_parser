CREATE OR REPLACE FUNCTION psf.create_tg_views() RETURNS integer AS $$
DECLARE
    vrpt RECORD;
BEGIN

    RAISE NOTICE 'Checking/Creating schema...';
    PERFORM psf.create_schema('tg_rpt');   

    RAISE NOTICE 'Creating TalkGroup views...';

    FOR vrpt IN
      SELECT distinct 'tg_rpt' AS vschema, 
      tg_decimal AS tgid,
      county_name AS vcounty,
      lower(regexp_replace(county_name,'[^a-zA-Z0-9]+', '_', 'g'))||'_'||tg_decimal||'_'||lower(regexp_replace(tg_alpha_tg, '[^a-zA-Z0-9]+', '_', 'g')) AS vname
        FROM trs_tg JOIN trs_sites on (site_id=tg_site_id) ORDER BY vname
    LOOP

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_tdy AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::date = ( CURRENT_DATE ) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Creating view %.', vrpt.vname||'_tdy';      
    
EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_yda AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::date = ( CURRENT_DATE - 1) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_yda';          

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_15m AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::timestamptz >= CURRENT_TIMESTAMP - INTERVAL '15 Minutes'
       AND p_time::date =  ( CURRENT_DATE ) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_15m';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_30m AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::timestamptz >= CURRENT_TIMESTAMP - INTERVAL '30 Minutes'
       AND p_time::date =  ( CURRENT_DATE ) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_30m';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_45m AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::timestamptz >= CURRENT_TIMESTAMP - INTERVAL '45 Minutes'
       AND p_time::date =  ( CURRENT_DATE ) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_45m';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_60m AS
    SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
     FROM psf_files 
		JOIN psf_meta ON (id=p_id)
		JOIN trs_sites ON (p_sys1 = county_name ) 
		JOIN trs_tg ON (tg_site_id=site_id)
     WHERE p_time::timestamptz >= CURRENT_TIMESTAMP - INTERVAL '60 Minutes'
       AND p_time::date =  ( CURRENT_DATE ) 
     AND p_tg = '%s'
     GROUP BY filename, p_time, p_tg
     ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.tgid );
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_60m';      

     
     
  
    END LOOP;

    RAISE NOTICE 'Done creating TG views.';

    RETURN 1;
END;
$$ LANGUAGE plpgsql;


-- SELECT psf.create_tg_views();
