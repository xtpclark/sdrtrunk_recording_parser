CREATE OR REPLACE FUNCTION psf.add_index(ptable text, pcolumns text, pidxname text, pidxtype text DEFAULT 'btree'::text, pschema text DEFAULT 'psf'::text, punique boolean DEFAULT false, pwhere text DEFAULT ''::text) RETURNS boolean
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
