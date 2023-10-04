CREATE VIEW public.vw_yesterday_calls AS
 SELECT vw_call_stats.recorded_date,
    vw_call_stats.talkgroup,
    vw_call_stats.tg_alpha_tg,
    vw_call_stats.tg_desc,
    vw_call_stats.tg_tag,
    vw_call_stats.tg_category,
    vw_call_stats.calls
   FROM public.vw_call_stats
  WHERE (vw_call_stats.recorded_date = (CURRENT_DATE - 1))
  ORDER BY vw_call_stats.calls;


ALTER TABLE public.vw_yesterday_calls OWNER TO postgres;


