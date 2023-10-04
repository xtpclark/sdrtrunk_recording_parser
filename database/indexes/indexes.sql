CREATE INDEX extdat_ext_date_idx ON public.extdat USING btree (ext_date);
CREATE UNIQUE INDEX extdat_ext_filename_idx ON public.extdat USING btree (ext_filename);
CREATE INDEX extdat_ext_talkgroup_idx ON public.extdat USING btree (ext_talkgroup);
CREATE UNIQUE INDEX pref_pref_name_idx ON public.pref USING btree (pref_name);
CREATE INDEX trs_tg_tg_alpha_tg_idx ON public.trs_tg USING btree (tg_alpha_tg);
CREATE INDEX trs_tg_tg_decimal_idx ON public.trs_tg USING btree (tg_decimal);
CREATE INDEX trs_tg_tg_decimal_tg_alpha_tg_idx ON public.trs_tg USING btree (tg_decimal, tg_alpha_tg);


