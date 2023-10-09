CREATE OR REPLACE FUNCTION psf.raise_notice(message text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  RAISE NOTICE '%', message;

END;
$$;


ALTER FUNCTION psf.raise_notice(message text) OWNER TO psfadmin;
