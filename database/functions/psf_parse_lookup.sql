CREATE OR REPLACE FUNCTION psf.psf_parse_lookup() RETURNS TRIGGER AS
$BODY$


DECLARE
pFilename TEXT := NEW.filename;
pTrm TEXT := REGEXP_REPLACE(TRIM(LEADING LEFT(pFilename,15) FROM pFilename),'([.])\w+', '');

--psf_meta
pMetaFilesID INTEGER := NEW.id;
pMetaTime TIMESTAMP := LEFT(pFilename,15);

--Should radio be split into it's own table?
pMetaRadio   TEXT := SPLIT_PART(pTrm:: TEXT, '_',8);

--trs_sites county_name
pTRSCounty TEXT := SPLIT_PART(pTrm:: TEXT, '_',1);
pTRSSys2   TEXT := SPLIT_PART(pTrm:: TEXT, '_',2);

-- trs_tg trs_tgtg_decimal::integer
pTG_Decimal INTEGER := SPLIT_PART(pTrm:: TEXT, '_',6);

pSiteID INTEGER;
pTGID INTEGER;
BEGIN

pSiteID  := site_id FROM trs_sites WHERE county_name = pTRSCounty;
pTGID := tg_id FROM trs_tg WHERE tg_decimal::integer = pTG_Decimal AND tg_site_id=pSiteID;

-- CREATE TABLE psf_meta2 (m_id serial not null, f_id int, m_site_id int, m_tg_id int,m_radio_id text, m_created timestamp);

INSERT INTO psf_meta2  (  f_id, m_site_id, m_tg_id, m_radio_id, m_created) VALUES
( pMetaFilesID, pSiteID, pTGID, pMetaRadio, pMetaTime );

      RETURN new;
END;
$BODY$
language plpgsql;


 CREATE OR REPLACE TRIGGER _psf_parse_lookup_trg
     AFTER INSERT ON psf_files2
     FOR EACH ROW
     EXECUTE PROCEDURE psf.psf_parse_lookup();
