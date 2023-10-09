CREATE OR REPLACE FUNCTION psf.create_rpt_views() RETURNS integer AS $$
DECLARE
    vrpt RECORD;
BEGIN
     
    RAISE NOTICE 'Checking/Creating rpt schema...';
    PERFORM psf.create_schema('rpt');   
        
    RAISE NOTICE 'Creating Category Views...';

    FOR vrpt IN
      SELECT distinct 'rpt' AS vschema, lower(regexp_replace(tg_category, '[^a-zA-Z0-9]+', '_', 'g')) AS vname, tg_category AS vcat
        FROM trs_tg ORDER BY 1
    LOOP

        RAISE NOTICE 'Creating Category views for  %...', quote_ident(vrpt.vcat);

	-- View by category today (tdy)       
        EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_tdy AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::date = CURRENT_DATE
			AND tg_category = '%s' ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.vcat );

	-- View by category yesterday (yda)        
        EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_yda AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::date = ( CURRENT_DATE - 1 )
			AND tg_category = '%s' ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.vcat );

	-- 15 m ago
      	 EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_15m AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::timestamptz >= ( CURRENT_TIMESTAMP - INTERVAL '15 Minutes' )
			AND tg_category = '%s' ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.vcat );

         -- 30 m ago
      	 EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_30m AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::timestamptz >= ( CURRENT_TIMESTAMP - INTERVAL '30 Minutes' )
			AND tg_category = '%s' ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.vcat );

         -- 60 m ago
      	 EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_30m AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::timestamptz >= ( CURRENT_TIMESTAMP - INTERVAL '60 Minutes' )
			AND tg_category = '%s' ORDER BY p_time$f$, vrpt.vschema, vrpt.vname, vrpt.vcat );


    END LOOP;

    RAISE NOTICE 'Done creating Category Views.';
    RAISE NOTICE 'Creating views for all_15 and all_30.';

         -- ALL 15 m ago
      	 EXECUTE format($f$CREATE OR REPLACE VIEW %I.all_15m AS SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::timestamptz >= ( CURRENT_TIMESTAMP - INTERVAL '15 Minutes' ) ORDER BY p_time$f$, vrpt.vschema, vrpt.vname );

         -- ALL 30 m ago
      	 EXECUTE format($f$
CREATE OR REPLACE VIEW %I.all_30m AS 
SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
			FROM psf_files
			  JOIN psf_meta ON (id=p_id)
			  JOIN trs_sites on (p_sys1 = county_name)
			  JOIN trs_tg ON (p_tg::int=tg_decimal::int)
			WHERE
			 p_time::timestamptz >= ( CURRENT_TIMESTAMP - INTERVAL '30 Minutes' ) ORDER BY p_time$f$, vrpt.vschema, vrpt.vname );

    RAISE NOTICE 'Done creating views for all_15 and all_30.';


PERFORM psf.create_view('rpt.unknown', $f$SELECT 'file '''||fetchpreftext('archive_path')||'/'|| to_char(psf_meta.p_time, 'YYYYMMDD') || '/'||psf_meta.p_tg||'/'||psf_files.filename || '''' AS ffurl
   FROM psf_files
     JOIN psf_meta ON (psf_files.id = psf_meta.p_id)
      WHERE  p_tg::text NOT IN (select tg_decimal::text from trs_tg)$f$);

RAISE NOTICE 'Done creating views for rpt.unknown.';

    RETURN 1;
END;
$$ LANGUAGE plpgsql;


-- SELECT psf.create_rpt_views();
