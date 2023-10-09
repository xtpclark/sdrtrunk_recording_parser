CREATE OR REPLACE FUNCTION psf.raise_debug(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE DEBUG '%', message;

END;
$$;


ALTER FUNCTION psf.raise_debug(message text) OWNER TO psfadmin;
