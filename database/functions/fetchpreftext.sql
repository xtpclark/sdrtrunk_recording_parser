CREATE FUNCTION public.fetchpreftext(pprefname text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT pref_value FROM pref WHERE pref_name = pprefName LIMIT 1;
$$;


ALTER FUNCTION public.fetchpreftext(pprefname text) OWNER TO postgres;


