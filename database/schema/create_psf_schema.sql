do $$
declare
  count integer;
  query text;
begin
  /* Only create the schema if it hasn't been created already */
  perform *
  from information_schema.schemata 
  where schema_name = 'psf';

  get diagnostics count = row_count;

  if (count > 0) then
    return;
  end if;

  query = 'create schema psf;';
  execute query;

  query = 'grant all on schema psf to group psfrole;';
  execute query;

end;
$$ language 'plpgsql';

ALTER SCHEMA psf OWNER TO psfadmin;
