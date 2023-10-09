CREATE OR REPLACE FUNCTION psf.raise_warning(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE WARNING '%', message;

END;
$$;


ALTER FUNCTION psf.raise_warning(message text) OWNER TO psfadmin;
