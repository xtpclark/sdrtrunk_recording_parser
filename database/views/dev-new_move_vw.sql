-- NEW psf move last
CREATE VIEW last_job AS
WITH last_job AS (
			      SELECT last_value AS max_job_num FROM extdat_job_num_seq 
		),
	url AS (
            SELECT 
                 'file '''::text || fetchpreftext('archive_path') || '/' ||TO_CHAR(psf_meta.p_time,'YYYYMMDD')  || '/' || psf_meta.p_tg || '/' || psf_files.filename || '''' AS ffurl
             FROM last_job
				JOIN psf_files ON (max_job_num=job_id) 
				JOIN psf_meta ON (id=p_id)
				LEFT OUTER JOIN psf_fstat ON (p_id=fs_id AND fs_arch IS FALSE) 
			    AND psf_files.job_id = max_job_num 
         )
SELECT ffurl FROM url ORDER BY psf_meta.p_time;

    
    
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
    
    
    
 SELECT vw_all.ffurl
   FROM vw_all
  WHERE vw_all.ts_tz >= (CURRENT_TIMESTAMP - '00:15:00'::interval);


    (((((fetchpreftext('archive_path'::text) || '/'::text) || "left"(extdat.ext_filename, 8)) || '/'::text) || trs_tg.tg_decimal) || '/'::text) || extdat.ext_filename AS fpath,
    extdat.ext_filename AS filename,
    extdat.ext_radio AS radio,
    extdat.ext_time AS filets,
    extdat.ext_sys AS county,
    extdat.ext_sys1 AS sys1,
    extdat.ext_sys2 AS sys2,
    extdat.ext_job AS jobnum,
    trs_tg.tg_decimal AS talkgroup,
    trs_tg.tg_hex AS hex,
    trs_tg.tg_alpha_tg AS atag,
    trs_tg.tg_mode AS mode,
    trs_tg.tg_desc AS descrip,
    trs_tg.tg_tag AS tag,
    trs_tg.tg_category AS category,
    "left"(extdat.ext_filename, 15)::timestamp with time zone AS ts_tz,
    "left"(extdat.ext_filename, 8)::date AS dt,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'HH24:MI:SS'::text)::time without time zone AS hms,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'HH24'::text)::integer AS hod,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'MI'::text)::integer AS moh,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'SS'::text)::integer AS soh,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'SSSS'::text)::integer AS sod,
    to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'SSSS'::text)::integer / 60 AS mod,
    to_char("left"(extdat.ext_filename, 15)::date::timestamp with time zone, 'day'::text) AS day,
    to_char("left"(extdat.ext_filename, 15)::date::timestamp with time zone, 'month'::text) AS mon,
    EXTRACT(day FROM "left"(extdat.ext_filename, 15)::timestamp without time zone)::integer AS dom,
    date_part('YEAR'::text, to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp with time zone) AS yr,
    date_part('month'::text, to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp with time zone) AS mo,
    date_part('Dow'::text, to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp with time zone) AS dow,
    date_part('DOY'::text, to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp with time zone) AS doy,
    date_part('WEEK'::text, to_char("left"(extdat.ext_filename, 15)::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text)::timestamp with time zone) AS wno
   FROM extdat
     JOIN trs_tg ON extdat.ext_talkgroup = trs_tg.tg_decimal;
