CREATE VIEW public.vw_call_stats AS
 SELECT extdat.ext_date AS recorded_date,
    extdat.ext_talkgroup AS talkgroup,
    trs_tg.tg_alpha_tg,
    trs_tg.tg_desc,
    trs_tg.tg_tag,
    trs_tg.tg_category,
    count(*) AS calls
   FROM (public.extdat
     JOIN public.trs_tg ON ((extdat.ext_talkgroup = trs_tg.tg_decimal)))
  GROUP BY extdat.ext_date, extdat.ext_talkgroup, trs_tg.tg_alpha_tg, trs_tg.tg_desc, trs_tg.tg_tag, trs_tg.tg_category
  ORDER BY extdat.ext_date;


ALTER TABLE public.vw_call_stats OWNER TO postgres;

