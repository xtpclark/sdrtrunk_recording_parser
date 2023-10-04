CREATE VIEW public.vw_top AS
 SELECT vw_call_stats.talkgroup,
    vw_call_stats.tg_alpha_tg,
    vw_call_stats.tg_category,
    sum(vw_call_stats.calls) AS total_calls
   FROM public.vw_call_stats
  GROUP BY vw_call_stats.talkgroup, vw_call_stats.tg_alpha_tg, vw_call_stats.tg_category
  ORDER BY (sum(vw_call_stats.calls)) DESC;


ALTER TABLE public.vw_top OWNER TO postgres;

