CREATE OR REPLACE FUNCTION psf.create_rpt_views() RETURNS integer AS $$
DECLARE
    vrpt RECORD;
BEGIN
     
    RAISE NOTICE 'Checking/Creating rpt schema...';
    PERFORM psf.create_schema('rpt');   
        
    RAISE NOTICE 'Creating views...';

    FOR vrpt IN
      SELECT distinct 'rpt' AS vschema, lower(regexp_replace(tg_category, '[^a-zA-Z0-9]+', '_', 'g')) AS vname, tg_category AS vcat
        FROM trs_tg ORDER BY 1
    LOOP
    
        
        RAISE NOTICE 'Creating view %.% %...',
                     quote_ident(vrpt.vschema),
                     quote_ident(vrpt.vname),
                     quote_ident(vrpt.vcat);
                     
	-- View by category today (tdy)       
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_tdy AS SELECT ffurl FROM public.vw_all WHERE vw_all.dt = (CURRENT_DATE) AND vw_all.category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );

	-- View by category yesterday (yda)        
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_yda AS SELECT ffurl FROM public.vw_all WHERE vw_all.dt = (CURRENT_DATE -1) AND vw_all.category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
 
	-- View by category 15 and 30 min ago.
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_15m AS SELECT ffurl FROM public.vw_all WHERE ts_tz >=  CURRENT_TIMESTAMP - INTERVAL ''15 Minutes'' AND vw_all.category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_30m AS SELECT ffurl FROM public.vw_all WHERE ts_tz >=  CURRENT_TIMESTAMP - INTERVAL ''30 Minutes'' AND vw_all.category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
        
        -- View ALL calls 15 and 30 min ago.
        EXECUTE format('CREATE OR REPLACE VIEW %I.all_15m AS SELECT ffurl FROM public.vw_all WHERE ts_tz >=  CURRENT_TIMESTAMP - INTERVAL ''15 Minutes'' ', vrpt.vschema, vrpt.vname );
        EXECUTE format('CREATE OR REPLACE VIEW %I.all_30m AS SELECT ffurl FROM public.vw_all WHERE ts_tz >=  CURRENT_TIMESTAMP - INTERVAL ''30 Minutes'' ', vrpt.vschema, vrpt.vname );

    END LOOP;

    RAISE NOTICE 'Done creating views.';
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- This will likely change with the migration to psf_files, psf_meta, psf_fstat
