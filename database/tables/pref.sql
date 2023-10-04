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

