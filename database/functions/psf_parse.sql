CREATE OR REPLACE FUNCTION psf.psf_parse() RETURNS TRIGGER AS
$BODY$
DECLARE

BEGIN

WITH original_filename AS ( 
           SELECT LEFT(new.filename,15)::TIMESTAMP AS p_time,
           REGEXP_REPLACE(TRIM(LEADING LEFT(new.filename,15) FROM new.filename),'([.])\w+', '') AS trm ),
      parsed_filename AS ( 
           SELECT new.id AS p_id,
           p_time,
           SPLIT_PART(trm:: TEXT, '_',1) p_sys1,
           SPLIT_PART(trm:: TEXT, '_',2) p_sys2,
           SPLIT_PART(trm:: TEXT, '_',3) p_type,
           SPLIT_PART(trm:: TEXT, '_',4) p_alias,
           SPLIT_PART(trm:: TEXT, '_',5) p_dir1,
           SPLIT_PART(trm:: TEXT, '_',6) p_tg,
           SPLIT_PART(trm:: TEXT, '_',7) p_dir2,
           SPLIT_PART(trm:: TEXT, '_',8)  p_radio,
           SPLIT_PART(trm:: TEXT, '_',9) p_ext1
    FROM original_filename )
    INSERT INTO psf_meta (p_id, p_time, p_sys1, p_sys2, p_type, p_alias, p_dir1, p_tg, p_dir2, p_radio, p_ext1 )
    SELECT p_id, p_time, p_sys1, p_sys2, p_type, p_alias, p_dir1,  p_tg , p_dir2,  p_radio, p_ext1 FROM parsed_filename;    
        
      RETURN new;
END;
$BODY$
language plpgsql;


-- CREATE OR REPLACE TRIGGER _psf_parse_trg
--     AFTER INSERT ON psf_files
--     FOR EACH ROW
--     EXECUTE PROCEDURE psf.psf_parse();
