--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: psf; Type: SCHEMA; Schema: -; Owner: psfadmin
--

CREATE SCHEMA psf;


ALTER SCHEMA psf OWNER TO psfadmin;

--
-- Name: rpt; Type: SCHEMA; Schema: -; Owner: psfadmin
--

CREATE SCHEMA rpt;


ALTER SCHEMA rpt OWNER TO psfadmin;

--
-- Name: add_column(text, text, text, text, text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.add_column(ptable text, pcolumn text, ptype text, pconstraint text DEFAULT NULL::text, pschema text DEFAULT 'psf'::text, pcomment text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _count INTEGER;
  _query TEXT;
  _constraintNull BOOLEAN;
  _constraintDefault TEXT;
  _columnNull BOOLEAN := FALSE;
  _sequence TEXT;
  _commentQuery TEXT;
  _current RECORD;
BEGIN

  pTable := lower(pTable);
  pColumn := lower(pColumn);
  pSchema := lower(pSchema);

  SELECT format_type(a.atttypid, a.atttypmod) AS type, a.attnotnull AS notnull, pg_get_expr(d.adbin, d.adrelid) AS defaultval INTO _current
  FROM pg_attribute a
  JOIN pg_class c ON a.attrelid=c.oid
  JOIN pg_namespace n ON c.relnamespace=n.oid
  LEFT OUTER JOIN pg_attrdef d ON a.attrelid=d.adrelid AND a.attnum=d.adnum
  WHERE c.relname = pTable
  AND n.nspname = pSchema
  AND a.attname = PColumn
  AND a.attnum > 0;

  GET DIAGNOSTICS _count := ROW_COUNT;

  IF (_count > 0) THEN
    IF (_current.type !~~* pType AND pType !~* 'serial') THEN
--The operator !~~* when used with no special regular expression operators amounts to a straight case-insensitive comparison
      _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET DATA TYPE %s', pSchema, pTable, pColumn, pType);

      EXECUTE _query;
    END IF;

    _query := format('SELECT 1 FROM %I.%I WHERE %I IS NULL', pSchema, pTable, pColumn);

    EXECUTE _query;

    GET DIAGNOSTICS _count := ROW_COUNT;

    IF (_count > 0) THEN
      _columnNull := TRUE;
    END IF;

    IF (COALESCE(pConstraint, '') ~* 'not null') THEN
      _constraintNull := TRUE;
      _constraintDefault := trim(regexp_replace(COALESCE(pConstraint, ''), 'not null', '', 'i'));
    ELSE
      _constraintNull := FALSE;
      _constraintDefault := trim(regexp_replace(COALESCE(pConstraint, ''), 'null', '', 'i'));
    END IF;

--    Have to handle serial columns otherwise we lose the link to the sequence
    IF (pType ~* 'serial') THEN
      _constraintDefault = _current.defaultval;
    END IF;

--The above does not behave correctly in most cases wherein a constraint or the default value
--contains the text 'not null' or 'null' (e.g. constraint_text='default ''not null''')

    IF (_constraintDefault ~* 'default') THEN
      IF (_constraintDefault ~* 'check') THEN
        IF (strpos(_constraintDefault, 'default') < strpos(_constraintDefault, 'check')) THEN
          _constraintDefault := trim((regexp_matches(_constraintDefault, '(default .*) check.*', 'i'))[1]::TEXT);
        ELSE
          _constraintDefault := trim((regexp_matches(_constraintDefault, 'check.*(default .*)', 'i'))[1]::TEXT);
        END IF;
      END IF;

--The above only handles check constraints, and only if the default value does not contain
--the text 'check' and the check constraint does not contain the text 'default'.
--It does not handle unique constraints, primary keys (though these should never be used with a default),
--foreign key constraints, or exclude constraints correctly.
--Check constraints are also simply ignored on existing columns rather than added/updated idempotently

      _constraintDefault := trim(regexp_replace(_constraintDefault, 'default', '', 'i'));
      IF (COALESCE(_current.defaultval, '')!=_constraintDefault) THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET DEFAULT %s', pSchema, pTable, pColumn, _constraintDefault);

        EXECUTE _query;

        IF (_current.defaultval IS NULL AND _constraintNull AND _columnNull) THEN
          _query := format('UPDATE %I.%I SET %I=%s WHERE %I IS NULL', pSchema, pTable, pColumn, _constraintDefault, pColumn);

          EXECUTE _query;
          _columnNull := FALSE;
        END IF;
      END IF;
    ELSE
      IF (_current.defaultval IS NOT NULL AND _current.defaultval!=_constraintDefault AND pConstraint !~* 'primary key') THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I DROP DEFAULT', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    END IF;

    IF (_constraintNull) THEN
      IF (NOT _current.notnull AND NOT _columnNull) THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET NOT NULL', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    ELSE
      IF (_current.notnull AND pType !~* 'serial' AND pConstraint !~* 'primary key') THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I DROP NOT NULL', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    END IF;
  ELSE
    _query := format('ALTER TABLE %I.%I ADD COLUMN %I %s %s', pSchema, pTable, pColumn, pType, COALESCE(pConstraint, ''));

    EXECUTE _query;
  END IF;

  IF (pType ~~* 'serial') THEN
    _sequence := format('%I_%I_seq', pTable, pColumn);
    IF (EXISTS(SELECT 1 FROM pg_class WHERE relname=_sequence
               AND relkind='S' AND relacl IS NULL ORDER BY relname)) THEN
      _query := format('GRANT ALL ON SEQUENCE %I.%I TO psfrole;', pSchema, _sequence);

      EXECUTE _query;
    END IF;
  END IF;

  IF (pComment IS NOT NULL) then
    _commentQuery := format('COMMENT ON COLUMN %I.%I.%I IS %s', pSchema, pTable, pColumn, quote_literal(pComment));
    EXECUTE _commentQuery;
  END IF;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION psf.add_column(ptable text, pcolumn text, ptype text, pconstraint text, pschema text, pcomment text) OWNER TO psfadmin;

--
-- Name: add_constraint(text, text, text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.add_constraint(table_name text, constraint_name text, constraint_text text, schema_name text DEFAULT 'psf'::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare
  count integer;
  query text;
begin

  perform *
  from pg_constraint
    join pg_namespace on (connamespace=pg_namespace.oid)
    join pg_class f on (conrelid=f.oid)
  where f.relname = table_name
    and nspname = schema_name
    and conname = constraint_name;
  
  get diagnostics count = row_count;
  
  if (count > 0) then
    return false;
  end if;

  query = 'alter table ' || schema_name || '.' || table_name || ' add constraint ' || constraint_name || ' ' || constraint_text || ';';
  execute query;

  return true;
  
end;
$$;


ALTER FUNCTION psf.add_constraint(table_name text, constraint_name text, constraint_text text, schema_name text) OWNER TO psfadmin;

--
-- Name: add_index(text, text, text, text, text, boolean, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.add_index(ptable text, pcolumns text, pidxname text, pidxtype text DEFAULT 'btree'::text, pschema text DEFAULT 'psf'::text, punique boolean DEFAULT false, pwhere text DEFAULT ''::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _idx   RECORD;
BEGIN
  SELECT pg_get_indexdef(i.oid) AS indexdef, indisunique INTO _idx
    FROM pg_index x
    JOIN pg_class     c ON c.oid = x.indrelid
    JOIN pg_class     i ON i.oid = x.indexrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind IN ('r', 'm') AND i.relkind = 'i'
     AND n.nspname = pSchema
     AND c.relname = pTable
     AND i.relname = pIdxName;

  -- if the index exists and matches our expectations, no need to create it
  IF _idx.indexdef ~ format('USING %s \(%s\)', pIdxType, pColumns) AND
     _idx.indisunique = pUnique THEN
    RETURN false;
  END IF;

  EXECUTE format('DROP INDEX IF EXISTS %I.%I;', pSchema, pIdxName);
  EXECUTE format('CREATE %s INDEX %I ON %I.%I USING %s (%s) %s %s;',
                  CASE WHEN pUnique THEN 'UNIQUE' ELSE '' END,
                  pIdxName, pSchema, pTable, pIdxType, pColumns,
                  CASE pWhere WHEN '' THEN '' ELSE 'WHERE' END,
                  pWhere);

  RETURN true;
END;
$$;


ALTER FUNCTION psf.add_index(ptable text, pcolumns text, pidxname text, pidxtype text, pschema text, punique boolean, pwhere text) OWNER TO psfadmin;

--
-- Name: add_primary_key(text, text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.add_primary_key(table_name text, column_name text, schema_name text DEFAULT 'psf'::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare
  count integer;
  query text;
begin

  perform *
  from pg_constraint
    join pg_namespace on (connamespace=pg_namespace.oid)
    join pg_class f on (conrelid=f.oid)
  where f.relname = table_name
    and nspname = schema_name
    and contype = 'p';
  
  get diagnostics count = row_count;
  
  if (count > 0) then
    return false;
  end if;

  query = 'alter table ' || schema_name || '.' || table_name || ' add primary key (' || column_name || ');';
  execute query;

  return true;
  
end;
$$;


ALTER FUNCTION psf.add_primary_key(table_name text, column_name text, schema_name text) OWNER TO psfadmin;

--
-- Name: create_rpt_views(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.create_rpt_views() RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_tdy AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::date = (CURRENT_DATE) AND vw_all.tg_category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );

	-- View by category yesterday (yda)        
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_yda AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::date = (CURRENT_DATE -1) AND vw_all.tg_category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
 
	-- View by category 15 and 30 min ago.
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_15m AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::timestamptz >=  CURRENT_TIMESTAMP - INTERVAL ''15 Minutes'' AND vw_all.tg_category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
        EXECUTE format('CREATE OR REPLACE VIEW %I.%I_30m AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::timestamptz >=  CURRENT_TIMESTAMP - INTERVAL ''30 Minutes'' AND vw_all.tg_category=''%s''', vrpt.vschema, vrpt.vname, vrpt.vcat );
        
        -- View ALL calls 15 and 30 min ago.
        EXECUTE format('CREATE OR REPLACE VIEW %I.all_15m AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::timestamptz >=  CURRENT_TIMESTAMP - INTERVAL ''15 Minutes'' ', vrpt.vschema, vrpt.vname );
        EXECUTE format('CREATE OR REPLACE VIEW %I.all_30m AS SELECT ffurl FROM public.vw_all WHERE vw_all.p_time::timestamptz >=  CURRENT_TIMESTAMP - INTERVAL ''30 Minutes'' ', vrpt.vschema, vrpt.vname );

    END LOOP;

    RAISE NOTICE 'Done creating views.';
    RETURN 1;
END;
$$;


ALTER FUNCTION psf.create_rpt_views() OWNER TO psfadmin;

--
-- Name: create_schema(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.create_schema(sch text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare
  count integer;
  query text;
begin

  /* Only create the schema if it hasn't been created already */
  perform *
  from information_schema.schemata
  where schema_name = sch;

  get diagnostics count = row_count;

  if (count > 0) then
    return false;
  end if;

  query = 'create schema ' || sch || ';' ||
           'grant all on schema ' || sch || ' to group psfrole;';
  execute query;

  return true;

end;
$$;


ALTER FUNCTION psf.create_schema(sch text) OWNER TO psfadmin;

--
-- Name: create_table(text, text, boolean, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.create_table(table_name text, schema_name text DEFAULT 'psf'::text, with_oids boolean DEFAULT false, inherit_table text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  inherit_from TEXT := '';
BEGIN

  IF EXISTS(SELECT 1
              FROM pg_tables
             WHERE lower(schemaname) = lower(schema_name)
               AND lower(tablename)  = lower(table_name)) THEN
    RETURN FALSE;
  END IF;

  IF with_oids THEN
    RAISE NOTICE 'psf.create_table() ignoring with_oids param';
  END IF;

  IF inherit_table IS NOT NULL THEN
    inherit_from := ' INHERITS (' || inherit_table || ') ';
  END IF;

  EXECUTE format('create table %I.%I () %s;',
                 lower(schema_name), lower(table_name), inherit_from);
  EXECUTE format('grant all on %I.%I TO psfrole;',
                 lower(schema_name), lower(table_name));

  RETURN TRUE;

END;
$$;


ALTER FUNCTION psf.create_table(table_name text, schema_name text, with_oids boolean, inherit_table text) OWNER TO psfadmin;

--
-- Name: create_tg_views(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.create_tg_views() RETURNS integer
    LANGUAGE plpgsql
    AS $_$
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

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_15min AS
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
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_15min';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_30min AS
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
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_30min';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_45min AS
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
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_45min';      

EXECUTE format($f$CREATE OR REPLACE VIEW %I.%I_60min AS
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
  
    RAISE NOTICE 'Created view %.', vrpt.vname||'_60min';      

     
     
  
    END LOOP;

    RAISE NOTICE 'Done creating TG views.';

    RETURN 1;
END;
$_$;


ALTER FUNCTION psf.create_tg_views() OWNER TO psfadmin;

--
-- Name: create_view(text, text, boolean); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.create_view(view_name text, select_text text, read_only boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _viewNameSchema text := '';
  _viewNameTable  text := '';
BEGIN
  _viewNameTable := split_part(view_name, '.', 2);
  IF (_viewNameTable = '') THEN
    _viewNameTable := split_part(view_name, '.', 1);
    _viewNameSchema := 'public';
  ELSE
    _viewNameSchema := split_part(view_name, '.', 1);
  END IF;

  BEGIN
    EXECUTE format('CREATE OR REPLACE VIEW %I.%I AS %s', _viewNameSchema, _viewNameTable, select_text);
  EXCEPTION
    WHEN OTHERS THEN
      /* DROP ... CASCADE the view and try again */
      EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE;', _viewNameSchema, _viewNameTable);
      EXECUTE format('CREATE OR REPLACE VIEW %I.%I AS %s', _viewNameSchema, _viewNameTable, select_text);
  END;

  EXECUTE format('GRANT ALL ON TABLE %I.%I TO psfrole;', _viewNameSchema, _viewNameTable);

  IF (read_only) THEN
    EXECUTE format('CREATE OR REPLACE RULE _CREATE AS ON INSERT TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
    EXECUTE format('CREATE OR REPLACE RULE _UPDATE AS ON UPDATE TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
    EXECUTE format('CREATE OR REPLACE RULE _DELETE AS ON DELETE TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
  END IF;

  RETURN true;
END;
$$;


ALTER FUNCTION psf.create_view(view_name text, select_text text, read_only boolean) OWNER TO psfadmin;

--
-- Name: execute_query(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.execute_query(query text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin

  execute query;

  return true;
  
end;
$$;


ALTER FUNCTION psf.execute_query(query text) OWNER TO psfadmin;

--
-- Name: fetchpgbin(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.fetchpgbin() RETURNS text
    LANGUAGE sql
    AS $$

  SELECT setting FROM pg_config WHERE name = 'BINDIR';
$$;


ALTER FUNCTION psf.fetchpgbin() OWNER TO psfadmin;

--
-- Name: fetchpgport(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.fetchpgport() RETURNS text
    LANGUAGE sql
    AS $$

  SELECT setting FROM pg_settings WHERE name = 'port';
$$;


ALTER FUNCTION psf.fetchpgport() OWNER TO psfadmin;

--
-- Name: fetchserverver(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.fetchserverver() RETURNS text
    LANGUAGE sql
    AS $$

   SELECT setting from pg_settings WHERE name='server_version_num';
$$;


ALTER FUNCTION psf.fetchserverver() OWNER TO psfadmin;

--
-- Name: getserveros(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.getserveros() RETURNS character varying
    LANGUAGE sql
    AS $$
  SELECT CASE
    WHEN os_version LIKE '%w64%'
      OR os_version LIKE '%w32%'
      OR os_version LIKE '%mingw%'
      OR os_version LIKE '%visual%'
      THEN 'win'
    WHEN os_version LIKE '%linux%'
      THEN 'lin'
    WHEN os_version LIKE '%mac%' 
      OR os_version LIKE '%darwin%'
      OR os_version LIKE '%osx%'
      OR os_version LIKE '%apple%'
      THEN 'mac'
    ELSE
    'UNKNOWN'
    END
    FROM lower(version()) AS os_version;
$$;


ALTER FUNCTION psf.getserveros() OWNER TO psfadmin;

--
-- Name: psf_parse(); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.psf_parse() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

WITH original_filename AS ( 
           SELECT LEFT(new.filename,15)::TIMESTAMP AS p_time,
           REGEXP_REPLACE(TRIM(LEADING LEFT(new.filename,15) FROM new.filename),'([.])\w+', '') AS trm ),
      parsed_filename AS ( 
           SELECT new.id AS p_id,
           p_time,
           SPLIT_PART(trm:: TEXT, '_',1) p_sys1,
           SPLIT_PART(trm:: TEXT, '_',2) p_sys2,
           SPLIT_PART(trm:: TEXT, '_',3) p_type,
           SPLIT_PART(trm:: TEXT, '_',4) p_alias,
           SPLIT_PART(trm:: TEXT, '_',5) p_dir1,
           SPLIT_PART(trm:: TEXT, '_',6) p_tg,
           SPLIT_PART(trm:: TEXT, '_',7) p_dir2,
           SPLIT_PART(trm:: TEXT, '_',8)  p_radio,
           SPLIT_PART(trm:: TEXT, '_',9) p_ext1
    FROM original_filename )
    INSERT INTO psf_meta (p_id, p_time, p_sys1, p_sys2, p_type, p_alias, p_dir1, p_tg, p_dir2, p_radio, p_ext1 )
    SELECT p_id, p_time, p_sys1, p_sys2, p_type, p_alias, p_dir1,  p_tg , p_dir2,  p_radio, p_ext1 FROM parsed_filename;    
        
      RETURN new;
END;
$$;


ALTER FUNCTION psf.psf_parse() OWNER TO psfadmin;

--
-- Name: psqlout(text, integer, text, text, text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('COPY (SELECT 1) TO PROGRAM ''sudo psql -At -h %s -p %s -U %s %s -c "%s" > %s'' ', pPGHost, pPGPort, pPGUser, pPGDBName, pQuery, pOutFile);
    RETURN pOutFile;
END;
$$;


ALTER FUNCTION psf.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) OWNER TO psfadmin;

--
-- Name: raise_debug(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.raise_debug(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE DEBUG '%', message;

END;
$$;


ALTER FUNCTION psf.raise_debug(message text) OWNER TO psfadmin;

--
-- Name: raise_exception(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.raise_exception(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin

  raise exception '%', message;
  
end;
$$;


ALTER FUNCTION psf.raise_exception(message text) OWNER TO psfadmin;

--
-- Name: raise_notice(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.raise_notice(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE NOTICE '%', message;

END;
$$;


ALTER FUNCTION psf.raise_notice(message text) OWNER TO psfadmin;

--
-- Name: raise_warning(text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.raise_warning(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE WARNING '%', message;

END;
$$;


ALTER FUNCTION psf.raise_warning(message text) OWNER TO psfadmin;

--
-- Name: setpref(text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.setpref(pprefname text, pprefvalue text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO psf_pref (pref_name, pref_value)
  VALUES (pprefName, pprefValue)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION psf.setpref(pprefname text, pprefvalue text) OWNER TO psfadmin;

--
-- Name: setpref(text, text, text); Type: FUNCTION; Schema: psf; Owner: psfadmin
--

CREATE FUNCTION psf.setpref(pprefname text, pprefvalue text, pprefdesc text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO psf_pref (pref_name, pref_value, pref_desc)
  VALUES (pprefName, pprefValue, pprefDesc)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue, pref_desc=pprefDesc;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION psf.setpref(pprefname text, pprefvalue text, pprefdesc text) OWNER TO psfadmin;

--
-- Name: fetchpreftext(text); Type: FUNCTION; Schema: public; Owner: psfadmin
--

CREATE FUNCTION public.fetchpreftext(pprefname text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT pref_value FROM psf_pref WHERE pref_name = pprefName LIMIT 1;
$$;


ALTER FUNCTION public.fetchpreftext(pprefname text) OWNER TO psfadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: psf_files; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.psf_files (
    id integer NOT NULL,
    filename text NOT NULL,
    job_id integer
);


ALTER TABLE public.psf_files OWNER TO psfadmin;

--
-- Name: TABLE psf_files; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.psf_files IS 'Loaded files with Job ID';


--
-- Name: COLUMN psf_files.filename; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_files.filename IS 'Just the name of the file.';


--
-- Name: COLUMN psf_files.job_id; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_files.job_id IS 'PSF Loader Number';


--
-- Name: psf_files_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.psf_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.psf_files_id_seq OWNER TO psfadmin;

--
-- Name: psf_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: psfadmin
--

ALTER SEQUENCE public.psf_files_id_seq OWNED BY public.psf_files.id;


--
-- Name: psf_files_job_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.psf_files_job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.psf_files_job_id_seq OWNER TO psfadmin;

--
-- Name: psf_fstat; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.psf_fstat (
    fs_id integer NOT NULL,
    fs_arch boolean DEFAULT false NOT NULL,
    fs_del boolean DEFAULT false NOT NULL
);


ALTER TABLE public.psf_fstat OWNER TO psfadmin;

--
-- Name: TABLE psf_fstat; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.psf_fstat IS 'Parsed file archive, deleted, moved status';


--
-- Name: COLUMN psf_fstat.fs_id; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_fstat.fs_id IS 'FK reference to psf_files.id';


--
-- Name: COLUMN psf_fstat.fs_arch; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_fstat.fs_arch IS 'Has file been moved to archive dir';


--
-- Name: COLUMN psf_fstat.fs_del; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_fstat.fs_del IS 'Has file been deleted from archive dir';


--
-- Name: psf_meta; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.psf_meta (
    p_id integer NOT NULL,
    p_time timestamp without time zone NOT NULL,
    p_sys1 text,
    p_sys2 text,
    p_type text,
    p_alias text,
    p_dir1 text,
    p_tg text,
    p_dir2 text,
    p_radio text,
    p_ext1 text,
    created_at timestamp without time zone DEFAULT transaction_timestamp() NOT NULL
);


ALTER TABLE public.psf_meta OWNER TO psfadmin;

--
-- Name: TABLE psf_meta; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.psf_meta IS 'Scanner File parsed data, from trigger on insert';


--
-- Name: COLUMN psf_meta.created_at; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON COLUMN public.psf_meta.created_at IS 'Time PSF loaded this data.';


--
-- Name: psf_pref; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.psf_pref (
    pref_id integer NOT NULL,
    pref_name text NOT NULL,
    pref_value text,
    pref_desc text
);


ALTER TABLE public.psf_pref OWNER TO psfadmin;

--
-- Name: TABLE psf_pref; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.psf_pref IS 'PSF Preferences';


--
-- Name: psf_pref_pref_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.psf_pref_pref_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.psf_pref_pref_id_seq OWNER TO psfadmin;

--
-- Name: psf_pref_pref_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: psfadmin
--

ALTER SEQUENCE public.psf_pref_pref_id_seq OWNED BY public.psf_pref.pref_id;


--
-- Name: trs_freq; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.trs_freq (
    freq_id integer NOT NULL,
    freq_site_id integer,
    freq text,
    iscontrol boolean
);


ALTER TABLE public.trs_freq OWNER TO psfadmin;

--
-- Name: TABLE trs_freq; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.trs_freq IS 'RR TRS Site Frequencies CSV Data Import';


--
-- Name: trs_freq_freq_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.trs_freq_freq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trs_freq_freq_id_seq OWNER TO psfadmin;

--
-- Name: trs_freq_freq_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: psfadmin
--

ALTER SEQUENCE public.trs_freq_freq_id_seq OWNED BY public.trs_freq.freq_id;


--
-- Name: trs_sites; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.trs_sites (
    site_id integer NOT NULL,
    rfss text,
    site_dec text,
    site_hex text,
    site_nac text,
    description text,
    county_name text,
    lat text,
    lon text,
    range text
);


ALTER TABLE public.trs_sites OWNER TO psfadmin;

--
-- Name: TABLE trs_sites; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.trs_sites IS ' 
RR TRS Sites
Downloaded from https://www.radioreference.com/db/browse
';


--
-- Name: trs_sites_site_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.trs_sites_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trs_sites_site_id_seq OWNER TO psfadmin;

--
-- Name: trs_sites_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: psfadmin
--

ALTER SEQUENCE public.trs_sites_site_id_seq OWNED BY public.trs_sites.site_id;


--
-- Name: trs_tg; Type: TABLE; Schema: public; Owner: psfadmin
--

CREATE TABLE public.trs_tg (
    tg_id integer NOT NULL,
    tg_site_id integer,
    tg_decimal integer NOT NULL,
    tg_hex text NOT NULL,
    tg_alpha_tg text,
    tg_mode text,
    tg_desc text,
    tg_tag text,
    tg_category text
);


ALTER TABLE public.trs_tg OWNER TO psfadmin;

--
-- Name: TABLE trs_tg; Type: COMMENT; Schema: public; Owner: psfadmin
--

COMMENT ON TABLE public.trs_tg IS 'RR TRS TG CSV Data Import';


--
-- Name: trs_tg_tg_id_seq; Type: SEQUENCE; Schema: public; Owner: psfadmin
--

CREATE SEQUENCE public.trs_tg_tg_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trs_tg_tg_id_seq OWNER TO psfadmin;

--
-- Name: trs_tg_tg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: psfadmin
--

ALTER SEQUENCE public.trs_tg_tg_id_seq OWNED BY public.trs_tg.tg_id;


--
-- Name: vw_all; Type: VIEW; Schema: public; Owner: psfadmin
--

CREATE VIEW public.vw_all AS
 SELECT (((((((('file '''::text || public.fetchpreftext('archive_path'::text)) || '/'::text) || to_char(psf_meta.p_time, 'YYYYMMDD'::text)) || '/'::text) || psf_meta.p_tg) || '/'::text) || psf_files.filename) || ''''::text) AS ffurl,
    psf_files.id,
    psf_files.filename,
    psf_files.job_id,
    psf_meta.p_id,
    psf_meta.p_time,
    psf_meta.p_sys1,
    psf_meta.p_sys2,
    psf_meta.p_type,
    psf_meta.p_alias,
    psf_meta.p_dir1,
    psf_meta.p_tg,
    psf_meta.p_dir2,
    psf_meta.p_radio,
    psf_meta.p_ext1,
    psf_meta.created_at,
    trs_sites.site_id,
    trs_sites.rfss,
    trs_sites.site_dec,
    trs_sites.site_hex,
    trs_sites.site_nac,
    trs_sites.description,
    trs_sites.county_name,
    trs_sites.lat,
    trs_sites.lon,
    trs_sites.range,
    trs_tg.tg_id,
    trs_tg.tg_site_id,
    trs_tg.tg_decimal,
    trs_tg.tg_hex,
    trs_tg.tg_alpha_tg,
    trs_tg.tg_mode,
    trs_tg.tg_desc,
    trs_tg.tg_tag,
    trs_tg.tg_category
   FROM (((public.psf_files
     JOIN public.psf_meta ON ((psf_files.id = psf_meta.p_id)))
     JOIN public.trs_sites ON ((psf_meta.p_sys1 = trs_sites.county_name)))
     JOIN public.trs_tg ON ((trs_tg.tg_site_id = trs_sites.site_id)));


ALTER TABLE public.vw_all OWNER TO psfadmin;

--
-- Name: unknown_tg; Type: VIEW; Schema: rpt; Owner: psfadmin
--

CREATE VIEW rpt.unknown_tg AS
 SELECT (((((((('file '''::text || public.fetchpreftext('archive_path'::text)) || '/'::text) || to_char(psf_meta.p_time, 'YYYYMMDD'::text)) || '/'::text) || psf_meta.p_tg) || '/'::text) || psf_files.filename) || ''''::text) AS ffurl,
    psf_files.id,
    psf_files.filename,
    psf_files.job_id,
    psf_meta.p_id,
    psf_meta.p_time,
    psf_meta.p_sys1,
    psf_meta.p_sys2,
    psf_meta.p_type,
    psf_meta.p_alias,
    psf_meta.p_dir1,
    psf_meta.p_tg,
    psf_meta.p_dir2,
    psf_meta.p_radio,
    psf_meta.p_ext1,
    psf_meta.created_at
   FROM (public.psf_files
     JOIN public.psf_meta ON ((psf_files.id = psf_meta.p_id)))
  WHERE (NOT (psf_meta.p_tg IN ( SELECT (trs_tg.tg_decimal)::text AS tg_decimal
           FROM public.trs_tg)));


ALTER TABLE rpt.unknown_tg OWNER TO psfadmin;

--
-- Name: psf_files id; Type: DEFAULT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_files ALTER COLUMN id SET DEFAULT nextval('public.psf_files_id_seq'::regclass);


--
-- Name: psf_pref pref_id; Type: DEFAULT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_pref ALTER COLUMN pref_id SET DEFAULT nextval('public.psf_pref_pref_id_seq'::regclass);


--
-- Name: trs_freq freq_id; Type: DEFAULT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_freq ALTER COLUMN freq_id SET DEFAULT nextval('public.trs_freq_freq_id_seq'::regclass);


--
-- Name: trs_sites site_id; Type: DEFAULT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_sites ALTER COLUMN site_id SET DEFAULT nextval('public.trs_sites_site_id_seq'::regclass);


--
-- Name: trs_tg tg_id; Type: DEFAULT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_tg ALTER COLUMN tg_id SET DEFAULT nextval('public.trs_tg_tg_id_seq'::regclass);


--
-- Data for Name: psf_files; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.psf_files (id, filename, job_id) FROM stdin;
\.


--
-- Data for Name: psf_fstat; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.psf_fstat (fs_id, fs_arch, fs_del) FROM stdin;
\.


--
-- Data for Name: psf_meta; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.psf_meta (p_id, p_time, p_sys1, p_sys2, p_type, p_alias, p_dir1, p_tg, p_dir2, p_radio, p_ext1, created_at) FROM stdin;
\.


--
-- Data for Name: psf_pref; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.psf_pref (pref_id, pref_name, pref_value, pref_desc) FROM stdin;
1	archive_path	/storage/sdrtrunk_recordings/archive	Path to archived mp3s
2	current_path	/storage/sdrtrunk_recordings/current	Path that sdrtrunk puts recorded mp3s in.
3	merged_path	/storage/sdrtrunk_recordings/merged	Path for merged mp3.
4	move_qry	SELECT ''mkdir --parents ''||fetchpreftext(''archive_path'')||''/''||to_char(p_time::date,''YYYYMMDD'')||''/''||p_tg||''/; mv ''||fetchpreftext(''current_path'')||''/''||filename||E' \\$_' FROM psf_files JOIN psf_meta ON (id=p_id) WHERE job_id=${EXT_JOB_NUM};	Command to move the files into archive.
5	cron	/2 * * * *	Cron interval
6	cron_test	/30 * * * *	Cron interval
\.


--
-- Data for Name: trs_freq; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.trs_freq (freq_id, freq_site_id, freq, iscontrol) FROM stdin;
\.


--
-- Data for Name: trs_sites; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.trs_sites (site_id, rfss, site_dec, site_hex, site_nac, description, county_name, lat, lon, range) FROM stdin;
\.


--
-- Data for Name: trs_tg; Type: TABLE DATA; Schema: public; Owner: psfadmin
--

COPY public.trs_tg (tg_id, tg_site_id, tg_decimal, tg_hex, tg_alpha_tg, tg_mode, tg_desc, tg_tag, tg_category) FROM stdin;
\.


--
-- Name: psf_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.psf_files_id_seq', 1, false);


--
-- Name: psf_files_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.psf_files_job_id_seq', 1, false);


--
-- Name: psf_pref_pref_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.psf_pref_pref_id_seq', 6, true);


--
-- Name: trs_freq_freq_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.trs_freq_freq_id_seq', 1, false);


--
-- Name: trs_sites_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.trs_sites_site_id_seq', 1, false);


--
-- Name: trs_tg_tg_id_seq; Type: SEQUENCE SET; Schema: public; Owner: psfadmin
--

SELECT pg_catalog.setval('public.trs_tg_tg_id_seq', 1, false);


--
-- Name: psf_files psf_files_pkey; Type: CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_files
    ADD CONSTRAINT psf_files_pkey PRIMARY KEY (id);


--
-- Name: psf_pref psf_pref_pkey; Type: CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_pref
    ADD CONSTRAINT psf_pref_pkey PRIMARY KEY (pref_id);


--
-- Name: trs_freq trs_freq_pkey; Type: CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_freq
    ADD CONSTRAINT trs_freq_pkey PRIMARY KEY (freq_id);


--
-- Name: trs_sites trs_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_sites
    ADD CONSTRAINT trs_sites_pkey PRIMARY KEY (site_id);


--
-- Name: trs_tg trs_tg_pkey; Type: CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_tg
    ADD CONSTRAINT trs_tg_pkey PRIMARY KEY (tg_id);


--
-- Name: pref_name_uniq; Type: INDEX; Schema: public; Owner: psfadmin
--

CREATE UNIQUE INDEX pref_name_uniq ON public.psf_pref USING btree (pref_name);


--
-- Name: psf_files_filename_uniq; Type: INDEX; Schema: public; Owner: psfadmin
--

CREATE UNIQUE INDEX psf_files_filename_uniq ON public.psf_files USING btree (filename);


--
-- Name: trs_freq_site_freq_uniq; Type: INDEX; Schema: public; Owner: psfadmin
--

CREATE UNIQUE INDEX trs_freq_site_freq_uniq ON public.trs_freq USING btree (freq_site_id, freq);


--
-- Name: trs_tg_imp_uniq; Type: INDEX; Schema: public; Owner: psfadmin
--

CREATE UNIQUE INDEX trs_tg_imp_uniq ON public.trs_tg USING btree (tg_decimal, tg_hex, tg_alpha_tg, tg_mode, tg_desc, tg_tag, tg_category);


--
-- Name: trs_tg_tg_decimal_idx; Type: INDEX; Schema: public; Owner: psfadmin
--

CREATE INDEX trs_tg_tg_decimal_idx ON public.trs_tg USING btree (tg_decimal);


--
-- Name: psf_files _psf_parse_trg; Type: TRIGGER; Schema: public; Owner: psfadmin
--

CREATE TRIGGER _psf_parse_trg AFTER INSERT ON public.psf_files FOR EACH ROW EXECUTE FUNCTION psf.psf_parse();


--
-- Name: psf_fstat psf_fstat_fs_id_psf_files_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_fstat
    ADD CONSTRAINT psf_fstat_fs_id_psf_files_id_fk FOREIGN KEY (fs_id) REFERENCES public.psf_files(id);


--
-- Name: psf_meta psf_meta_psf_files_fk; Type: FK CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.psf_meta
    ADD CONSTRAINT psf_meta_psf_files_fk FOREIGN KEY (p_id) REFERENCES public.psf_files(id) ON DELETE CASCADE;


--
-- Name: trs_tg tg_site_id_trs_sites_fk; Type: FK CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_tg
    ADD CONSTRAINT tg_site_id_trs_sites_fk FOREIGN KEY (tg_site_id) REFERENCES public.trs_sites(site_id);


--
-- Name: trs_freq trs_freq_trs_sites_fk; Type: FK CONSTRAINT; Schema: public; Owner: psfadmin
--

ALTER TABLE ONLY public.trs_freq
    ADD CONSTRAINT trs_freq_trs_sites_fk FOREIGN KEY (freq_site_id) REFERENCES public.trs_sites(site_id);


--
-- Name: SCHEMA psf; Type: ACL; Schema: -; Owner: psfadmin
--

GRANT ALL ON SCHEMA psf TO psfrole;


--
-- Name: SCHEMA rpt; Type: ACL; Schema: -; Owner: psfadmin
--

GRANT ALL ON SCHEMA rpt TO psfrole;


--
-- Name: FUNCTION fetchpgbin(); Type: ACL; Schema: psf; Owner: psfadmin
--

REVOKE ALL ON FUNCTION psf.fetchpgbin() FROM PUBLIC;


--
-- Name: FUNCTION fetchpgport(); Type: ACL; Schema: psf; Owner: psfadmin
--

REVOKE ALL ON FUNCTION psf.fetchpgport() FROM PUBLIC;


--
-- Name: FUNCTION fetchserverver(); Type: ACL; Schema: psf; Owner: psfadmin
--

REVOKE ALL ON FUNCTION psf.fetchserverver() FROM PUBLIC;


--
-- Name: TABLE psf_files; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.psf_files TO psfrole;


--
-- Name: SEQUENCE psf_files_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.psf_files_id_seq TO psfrole;


--
-- Name: SEQUENCE psf_files_job_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.psf_files_job_id_seq TO psfrole;


--
-- Name: TABLE psf_fstat; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.psf_fstat TO psfrole;


--
-- Name: TABLE psf_meta; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.psf_meta TO psfrole;


--
-- Name: TABLE psf_pref; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.psf_pref TO psfrole;


--
-- Name: SEQUENCE psf_pref_pref_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.psf_pref_pref_id_seq TO psfrole;


--
-- Name: TABLE trs_freq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.trs_freq TO psfrole;


--
-- Name: SEQUENCE trs_freq_freq_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.trs_freq_freq_id_seq TO psfrole;


--
-- Name: TABLE trs_sites; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.trs_sites TO psfrole;


--
-- Name: SEQUENCE trs_sites_site_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.trs_sites_site_id_seq TO psfrole;


--
-- Name: TABLE trs_tg; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.trs_tg TO psfrole;


--
-- Name: SEQUENCE trs_tg_tg_id_seq; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON SEQUENCE public.trs_tg_tg_id_seq TO psfrole;


--
-- Name: TABLE vw_all; Type: ACL; Schema: public; Owner: psfadmin
--

GRANT ALL ON TABLE public.vw_all TO psfrole;


--
-- Name: TABLE unknown_tg; Type: ACL; Schema: rpt; Owner: psfadmin
--

GRANT ALL ON TABLE rpt.unknown_tg TO psfrole;


--
-- PostgreSQL database dump complete
--

