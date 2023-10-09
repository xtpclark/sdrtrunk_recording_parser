CREATE OR REPLACE FUNCTION psf.raise_exception(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin

  raise exception '%', message;
  
end;
$$;


ALTER FUNCTION psf.raise_exception(message text) OWNER TO psfadmin;
