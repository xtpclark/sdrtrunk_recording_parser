--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2 (Ubuntu 15.2-1.pgdg18.04+1)
-- Dumped by pg_dump version 15.2 (Ubuntu 15.2-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fetchpreftext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fetchpreftext(pprefname text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT pref_value FROM pref WHERE pref_name = pprefName LIMIT 1;
$$;


ALTER FUNCTION public.fetchpreftext(pprefname text) OWNER TO postgres;

--
-- Name: psqlout(text, integer, text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('COPY (SELECT 1) TO PROGRAM ''sudo psql -At -h %s -p %s -U %s %s -c "%s" > %s'' ', pPGHost, pPGPort, pPGUser, pPGDBName, pQuery, pOutFile);
 --   EXECUTE format('COPY (SELECT 1) TO PROGRAM ''psql -At -h %s -p %s -U %s -d %s -c "%s" > %s'' ', pPGHost, pPGPort, pPGUser, pPGDBName, pQuery, pOutFile);
    RETURN pOutFile;
END;
$$;


ALTER FUNCTION public.psqlout(ppghost text, ppgport integer, ppguser text, ppgdbname text, pquery text, poutfile text) OWNER TO postgres;

--
-- Name: setpref(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.setpref(pprefname text, pprefvalue text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO pref (pref_name, pref_value)
  VALUES (pprefName, pprefValue)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION public.setpref(pprefname text, pprefvalue text) OWNER TO postgres;

--
-- Name: setpref(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.setpref(pprefname text, pprefvalue text, pprefdesc text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

  INSERT INTO pref (pref_name, pref_value, pref_desc)
  VALUES (pprefName, pprefValue, pprefDesc)
  ON CONFLICT (pref_name)
  DO UPDATE SET pref_value=pprefValue, pref_desc=pprefDesc;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION public.setpref(pprefname text, pprefvalue text, pprefdesc text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: extdat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extdat (
    ext_filename text,
    ext_talkgroup integer,
    ext_radio text,
    ext_time text,
    ext_date date,
    ext_sys text,
    ext_sys1 text,
    ext_sys2 text,
    ext_id integer NOT NULL,
    ext_created timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ext_job integer
);


ALTER TABLE public.extdat OWNER TO postgres;

--
-- Name: extdat_ext_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.extdat_ext_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extdat_ext_id_seq OWNER TO postgres;

--
-- Name: extdat_ext_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.extdat_ext_id_seq OWNED BY public.extdat.ext_id;


--
-- Name: extdat_job_num_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.extdat_job_num_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extdat_job_num_seq OWNER TO postgres;

--
-- Name: pref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pref (
    pref_id integer DEFAULT nextval(('pref_pref_id_seq'::text)::regclass) NOT NULL,
    pref_name text NOT NULL,
    pref_value text,
    pref_desc text,
    CONSTRAINT pref_pref_name_check CHECK ((pref_name <> ''::text))
);


ALTER TABLE public.pref OWNER TO postgres;

--
-- Name: pref_pref_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pref_pref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.pref_pref_id_seq OWNER TO postgres;

--
-- Name: trs_sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trs_sites (
    rfss text,
    site_dec text,
    site_hex text,
    site_nac text,
    description text,
    county_name text,
    lat text,
    lon text,
    range text,
    f1 text,
    f2 text,
    f3 text,
    f4 text,
    f5 text,
    f6 text,
    f7 text,
    f8 text,
    f9 text,
    f10 text,
    f11 text,
    f12 text,
    f13 text,
    f14 text,
    f15 text,
    f16 text,
    f17 text,
    f18 text,
    f19 text,
    f20 text,
    f21 text,
    f22 text,
    f23 text,
    f24 text,
    f25 text,
    f26 text,
    f27 text,
    f28 text,
    f29 text,
    f30 text,
    f31 text,
    f32 text,
    f33 text,
    f34 text,
    f35 text,
    f36 text,
    f37 text,
    f38 text,
    f39 text,
    f40 text,
    f41 text,
    f42 text,
    f43 text,
    f44 text,
    f45 text
);


ALTER TABLE public.trs_sites OWNER TO postgres;

--
-- Name: trs_tg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trs_tg (
    tg_decimal integer,
    tg_hex text,
    tg_alpha_tg text,
    tg_mode text,
    tg_desc text,
    tg_tag text,
    tg_category text
);


ALTER TABLE public.trs_tg OWNER TO postgres;

--
-- Name: vw_all; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_all AS
 SELECT extdat.ext_id,
    (((((((('file '''::text || public.fetchpreftext('archive_path'::text)) || '/'::text) || "left"(extdat.ext_filename, 8)) || '/'::text) || trs_tg.tg_decimal) || '/'::text) || extdat.ext_filename) || ''''::text) AS ffurl,
    ((((((public.fetchpreftext('archive_path'::text) || '/'::text) || "left"(extdat.ext_filename, 8)) || '/'::text) || trs_tg.tg_decimal) || '/'::text) || extdat.ext_filename) AS fpath,
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
    ("left"(extdat.ext_filename, 15))::timestamp with time zone AS ts_tz,
    ("left"(extdat.ext_filename, 8))::date AS dt,
    (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'HH24:MI:SS'::text))::time without time zone AS hms,
    (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'HH24'::text))::integer AS hod,
    (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'MI'::text))::integer AS moh,
    (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'SS'::text))::integer AS soh,
    (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'SSSS'::text))::integer AS sod,
    ((to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'SSSS'::text))::integer / 60) AS mod,
    to_char((("left"(extdat.ext_filename, 15))::date)::timestamp with time zone, 'day'::text) AS day,
    to_char((("left"(extdat.ext_filename, 15))::date)::timestamp with time zone, 'month'::text) AS mon,
    (EXTRACT(day FROM ("left"(extdat.ext_filename, 15))::timestamp without time zone))::integer AS dom,
    date_part('YEAR'::text, (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp with time zone) AS yr,
    date_part('month'::text, (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp with time zone) AS mo,
    date_part('Dow'::text, (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp with time zone) AS dow,
    date_part('DOY'::text, (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp with time zone) AS doy,
    date_part('WEEK'::text, (to_char(("left"(extdat.ext_filename, 15))::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS'::text))::timestamp with time zone) AS wno
   FROM (public.extdat
     JOIN public.trs_tg ON ((extdat.ext_talkgroup = trs_tg.tg_decimal)));


ALTER TABLE public.vw_all OWNER TO postgres;

--
-- Name: vw_call_stats; Type: VIEW; Schema: public; Owner: postgres
--

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

--
-- Name: vw_stats_current; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_stats_current AS
 SELECT vw_call_stats.recorded_date,
    vw_call_stats.talkgroup,
    vw_call_stats.tg_alpha_tg,
    vw_call_stats.tg_desc,
    vw_call_stats.tg_tag,
    vw_call_stats.tg_category,
    vw_call_stats.calls
   FROM public.vw_call_stats
  WHERE (vw_call_stats.recorded_date = CURRENT_DATE)
  ORDER BY vw_call_stats.calls;


ALTER TABLE public.vw_stats_current OWNER TO postgres;

--
-- Name: vw_top; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_top AS
 SELECT vw_call_stats.talkgroup,
    vw_call_stats.tg_alpha_tg,
    vw_call_stats.tg_category,
    sum(vw_call_stats.calls) AS total_calls
   FROM public.vw_call_stats
  GROUP BY vw_call_stats.talkgroup, vw_call_stats.tg_alpha_tg, vw_call_stats.tg_category
  ORDER BY (sum(vw_call_stats.calls)) DESC;


ALTER TABLE public.vw_top OWNER TO postgres;

--
-- Name: vw_yesterday_calls; Type: VIEW; Schema: public; Owner: postgres
--

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

--
-- Name: extdat ext_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extdat ALTER COLUMN ext_id SET DEFAULT nextval('public.extdat_ext_id_seq'::regclass);


--
-- Name: extdat extdat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extdat
    ADD CONSTRAINT extdat_pkey PRIMARY KEY (ext_id);


--
-- Name: extdat_ext_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extdat_ext_date_idx ON public.extdat USING btree (ext_date);


--
-- Name: extdat_ext_filename_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX extdat_ext_filename_idx ON public.extdat USING btree (ext_filename);


--
-- Name: extdat_ext_talkgroup_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extdat_ext_talkgroup_idx ON public.extdat USING btree (ext_talkgroup);


--
-- Name: pref_pref_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX pref_pref_name_idx ON public.pref USING btree (pref_name);


--
-- Name: trs_tg_tg_alpha_tg_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trs_tg_tg_alpha_tg_idx ON public.trs_tg USING btree (tg_alpha_tg);


--
-- Name: trs_tg_tg_decimal_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trs_tg_tg_decimal_idx ON public.trs_tg USING btree (tg_decimal);


--
-- Name: trs_tg_tg_decimal_tg_alpha_tg_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX trs_tg_tg_decimal_tg_alpha_tg_idx ON public.trs_tg USING btree (tg_decimal, tg_alpha_tg);


--
-- PostgreSQL database dump complete
--

