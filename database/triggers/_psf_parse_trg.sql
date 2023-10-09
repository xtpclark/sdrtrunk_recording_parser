DROP TRIGGER IF EXISTS _psf_parse_trg ON psf_files;

CREATE OR REPLACE TRIGGER _psf_parse_trg
     AFTER INSERT ON psf_files
     FOR EACH ROW
     EXECUTE PROCEDURE psf.psf_parse();
