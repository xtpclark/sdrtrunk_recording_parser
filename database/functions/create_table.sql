CREATE OR REPLACE FUNCTION psf.create_table(table_name text, schema_name text DEFAULT 'psf'::text, with_oids boolean DEFAULT false, inherit_table text DEFAULT NULL::text) RETURNS boolean
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
