CREATE OR REPLACE FUNCTION psf.fetchpgport() RETURNS TEXT AS $$

  SELECT setting FROM pg_settings WHERE name = 'port';
$$ LANGUAGE 'sql';

REVOKE ALL ON FUNCTION psf.fetchpgport() FROM public;
GRANT EXECUTE ON FUNCTION psf.fetchpgport() TO psfadmin;
