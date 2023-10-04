CREATE TABLE pref (
    pref_id integer DEFAULT nextval(('pref_pref_id_seq'::text)::regclass) NOT NULL,
    pref_name text NOT NULL,
    pref_value text,
    pref_desc text
    CONSTRAINT pref_pref_name_check CHECK ((pref_name <> ''::text))
);


CREATE SEQUENCE pref_pref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;



CREATE OR REPLACE FUNCTION setpref(pprefName TEXT, pprefValue TEXT) RETURNS BOOLEAN AS $$
BEGIN

  INSERT INTO pref (pref_name, pref_value)
  VALUES (pprefName, pprefValue)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue;

  RETURN TRUE;

END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION public.fetchpreftext(pprefname text)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  SELECT pref_value FROM pref WHERE pref_name = pprefName LIMIT 1;
$function$;

