CREATE OR REPLACE FUNCTION psf.fetchserverver() RETURNS TEXT AS $$

   SELECT setting from pg_settings WHERE name='server_version_num';
$$ LANGUAGE 'sql';

REVOKE ALL ON FUNCTION psf.fetchserverver() FROM public;
GRANT EXECUTE ON FUNCTION psf.fetchserverver() TO psfadmin;
