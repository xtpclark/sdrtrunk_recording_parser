CREATE OR REPLACE TRIGGER _psf_parse_trg
     AFTER INSERT ON psf_files
     FOR EACH ROW
     EXECUTE PROCEDURE psf_parse();
