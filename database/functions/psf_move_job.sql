CREATE OR REPLACE FUNCTION psf.move_job(pSource text, pDestination text)
 RETURNS TEXT
 LANGUAGE plpgsql
AS $function$

DECLARE
  _result INTEGER := 0;
  _ckresult TEXT;
  _ckjsonresult JSONB;

  _os     TEXT    := psf.getserveros();
  _osinfo JSONB   :=
    -- vvv must exactly match what the ^^^^^ function returns
    '{ "win": { "sep": "\\", "mv": "move", "cp": "aws --only-show-errors s3 cp", 	 "bin": ".exe", "dir": "C:\\Windows\\Temp" },
       "mac": { "sep": "/",  "mv": "mv --parents", "cp": "aws --only-show-errors s3 cp", "bin": " ", "dir": "/tmp" },
       "lin": { "sep": "/",  "mv": "mv --parents", "cp": "aws --only-show-errors s3 cp", "bin": " ", "dir": "/tmp" }
    }'::JSONB;

  _bindir TEXT := psf.fetchpgbin();
  _movecmd  TEXT := 'mv'||(_osinfo #>> ARRAY[ _os, 'bin' ]);
  _mv TEXT := (_osinfo #>> ARRAY[ _os, 'sep' ])||_movecmd;

  _check BOOLEAN;


BEGIN
    EXECUTE format('COPY (SELECT 1) TO PROGRAM ''sudo mv %s %s'' ', pSource, pDestination);
    RETURN pDestination;
END;
$function$
;

REVOKE ALL ON FUNCTION psf.move_job(text,text) FROM postgres ;
GRANT EXECUTE ON FUNCTION psf.move_job(text,text) TO psfadmin;
