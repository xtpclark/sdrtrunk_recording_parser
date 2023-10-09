CREATE OR REPLACE FUNCTION psf.execute_query(query text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin

  execute query;

  return true;
  
end;
$$;


ALTER FUNCTION psf.execute_query(query text) OWNER TO psfadmin;
