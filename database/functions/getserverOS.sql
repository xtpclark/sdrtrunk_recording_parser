CREATE OR REPLACE FUNCTION psf.getServerOS()
RETURNS varchar AS
$$
  SELECT CASE
    WHEN os_version LIKE '%w64%'
      OR os_version LIKE '%w32%'
      OR os_version LIKE '%mingw%'
      OR os_version LIKE '%visual%'
      THEN 'win'
    WHEN os_version LIKE '%linux%'
      THEN 'lin'
    WHEN os_version LIKE '%mac%' 
      OR os_version LIKE '%darwin%'
      OR os_version LIKE '%osx%'
      OR os_version LIKE '%apple%'
      THEN 'mac'
    ELSE
    'UNKNOWN'
    END
    FROM lower(version()) AS os_version;
$$
LANGUAGE SQL;
