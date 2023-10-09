CREATE SCHEMA IF NOT EXISTS psf;
ALTER SCHEMA psf OWNER TO psfadmin;


\i database/functions/grant_acl.sql
\i database/functions/create_schema.sql
\i database/functions/create_table.sql
\i database/functions/create_view.sql
\i database/functions/add_column.sql
\i database/functions/add_constraint.sql
\i database/functions/add_index.sql
\i database/functions/add_primary_key.sql
\i database/functions/create_qmrpt_views.sql
\i database/functions/execute_query.sql
\i database/functions/fetchpgbin.sql
\i database/functions/fetchpgport.sql
\i database/functions/fetchserverver.sql
\i database/functions/getserverOS.sql
\i database/functions/psqlout.sql
\i database/functions/raise_debug.sql
\i database/functions/raise_exception.sql
\i database/functions/raise_warning.sql
\i database/functions/setpref.sql

\i database/tables/pref.sql
\i database/tables/psf_files.sql
\i database/tables/psf_meta.sql
\i database/tables/psf_fstat.sql

\i database/functions/fetchpreftext.sql
