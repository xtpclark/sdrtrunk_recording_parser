CREATE OR REPLACE FUNCTION psf.lsfile()
  RETURNS SETOF text AS
$BODY$
BEGIN
  SET client_min_messages TO WARNING;
  DROP TABLE IF EXISTS lsfiles;
  CREATE TEMP TABLE lsfiles(filename text);
  COPY lsfiles FROM PROGRAM 'find /storage/sdrtrunk_recordings/current -maxdepth 1 -type f -printf "%f\n"';
  RETURN QUERY SELECT * FROM lsfiles ORDER BY filename ASC;
END;
$BODY$
  LANGUAGE plpgsql SECURITY DEFINER;
