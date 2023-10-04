
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


CREATE SEQUENCE public.extdat_ext_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extdat_ext_id_seq OWNER TO postgres;

ALTER SEQUENCE public.extdat_ext_id_seq OWNED BY public.extdat.ext_id;

CREATE SEQUENCE public.extdat_job_num_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extdat_job_num_seq OWNER TO postgres;

ALTER TABLE ONLY public.extdat ALTER COLUMN ext_id SET DEFAULT nextval('public.extdat_ext_id_seq'::regclass);


ALTER TABLE ONLY public.extdat
    ADD CONSTRAINT extdat_pkey PRIMARY KEY (ext_id);

