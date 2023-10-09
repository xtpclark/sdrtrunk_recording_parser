CREATE OR REPLACE FUNCTION psf.fetch_hostname()
  RETURNS SETOF text AS
$BODY$

BEGIN
  SET client_min_messages TO WARNING;
  DROP TABLE IF EXISTS fetch_hostname;
  CREATE TEMP TABLE fetch_hostname(hostname text);
--  COPY instanceid FROM PROGRAM 'ec2metadata --instance-id';
  COPY fetch_hostname FROM PROGRAM 'hostname -s';
  RETURN QUERY SELECT * FROM fetch_hostname;

END;

$BODY$

  LANGUAGE plpgsql SECURITY DEFINER;
