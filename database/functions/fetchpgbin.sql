CREATE OR REPLACE FUNCTION psf.fetchpgbin() RETURNS TEXT AS $$

  SELECT setting FROM pg_config WHERE name = 'BINDIR';
$$ LANGUAGE 'sql';

REVOKE ALL ON FUNCTION psf.fetchpgbin() FROM public ;
GRANT EXECUTE ON FUNCTION psf.fetchpgbin() TO psfadmin;
