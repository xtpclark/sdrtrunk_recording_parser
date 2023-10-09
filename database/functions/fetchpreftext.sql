CREATE OR REPLACE FUNCTION public.fetchpreftext(pprefname text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT pref_value FROM psf_pref WHERE pref_name = pprefName LIMIT 1;
$$;


ALTER FUNCTION public.fetchpreftext(pprefname text) OWNER TO psfadmin;
