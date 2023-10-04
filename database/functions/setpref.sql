CREATE FUNCTION public.setpref(pprefname text, pprefvalue text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO pref (pref_name, pref_value)
  VALUES (pprefName, pprefValue)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION public.setpref(pprefname text, pprefvalue text) OWNER TO postgres;



CREATE FUNCTION public.setpref(pprefname text, pprefvalue text, pprefdesc text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO pref (pref_name, pref_value, pref_desc)
  VALUES (pprefName, pprefValue, pprefDesc)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue, pref_desc=pprefDesc;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION public.setpref(pprefname text, pprefvalue text, pprefdesc text) OWNER TO postgres;

