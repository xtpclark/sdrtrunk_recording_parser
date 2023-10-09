CREATE OR REPLACE FUNCTION psf.add_primary_key(table_name text, column_name text, schema_name text DEFAULT 'psf'::text) RETURNS boolean
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
