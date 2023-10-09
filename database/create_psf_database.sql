-- Creates schema psf for functions, internals
\i schema/create_psf_schema.sql
\i schema/grant_acl.sql

-- Idempotent Postgres DDL wrappers
\i functions/create_schema.sql
\i functions/create_table.sql
\i functions/create_view.sql
\i functions/add_column.sql
\i functions/add_constraint.sql
\i functions/add_index.sql
\i functions/add_primary_key.sql
\i functions/execute_query.sql

-- RAISE Handling
\i functions/raise_debug.sql
\i functions/raise_exception.sql
\i functions/raise_warning.sql
\i functions/raise_notice.sql

-- Utilities/helper functions
\i functions/fetchpgbin.sql
\i functions/fetchpgport.sql
\i functions/fetchserverver.sql
\i functions/getserverOS.sql

-- Other utilities/helpers, some may be "not a good idea."
-- generally need more work other than "Work on my computer"
\i functions/psqlout.sql


-- Preferences
\i functions/setpref.sql
\i tables/psf_pref.sql
\i functions/fetchpreftext.sql

-- RR Site and Talkgroup Tables
\i tables/trs_sites.sql
\i tables/trs_site_freq.sql
\i tables/trs_tg.sql

-- Scanner File Tables
\i tables/psf_files.sql
\i tables/psf_fstat.sql
\i tables/psf_meta.sql

-- Scanner Parser Plinko Function/Trigger
\i functions/psf_parse.sql
\i triggers/_psf_parse_trg.sql

-- Create views by tg category in rpt. schema loops.  Several views per category.
-- select psf.create_rpt_views();
\i functions/psf_create_rpt_views.sql

-- Creates views by talkgroup in tg_rpt. schema loops. Several views per TalkGroup.
-- select psf.create_tg_views();
\i functions/psf_create_tg_views.sql

-- Load this, need a GUI...
SELECT psf.raise_warning('Loading sample pref data');
\i sample_data/1_psf_pref_data.sql

\i views/psf_create_view_vw_all.sql

-- unknown tg files view rpt.unknown
SELECT psf.create_schema('rpt');
\i views/psf_create_view_unknown.sql


