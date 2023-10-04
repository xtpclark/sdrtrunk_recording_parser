-- Some say this is a bad idea... 
CREATE FUNCTION public.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('COPY (SELECT 1) TO PROGRAM ''sudo psql -At -h %s -p %s -U %s %s -c "%s" > %s'' ', pPGHost, pPGPort, pPGUser, pPGDBName, pQuery, pOutFile);
    RETURN pOutFile;
END;
$$;


ALTER FUNCTION public.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) OWNER TO postgres;

