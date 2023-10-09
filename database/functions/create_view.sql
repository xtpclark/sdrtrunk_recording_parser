CREATE OR REPLACE FUNCTION psf.create_view(view_name text, select_text text, read_only boolean DEFAULT true) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _viewNameSchema text := '';
  _viewNameTable  text := '';
BEGIN
  _viewNameTable := split_part(view_name, '.', 2);
  IF (_viewNameTable = '') THEN
    _viewNameTable := split_part(view_name, '.', 1);
    _viewNameSchema := 'public';
  ELSE
    _viewNameSchema := split_part(view_name, '.', 1);
  END IF;

  BEGIN
    EXECUTE format('CREATE OR REPLACE VIEW %I.%I AS %s', _viewNameSchema, _viewNameTable, select_text);
  EXCEPTION
    WHEN OTHERS THEN
      /* DROP ... CASCADE the view and try again */
      EXECUTE format('DROP VIEW IF EXISTS %I.%I CASCADE;', _viewNameSchema, _viewNameTable);
      EXECUTE format('CREATE OR REPLACE VIEW %I.%I AS %s', _viewNameSchema, _viewNameTable, select_text);
  END;

  EXECUTE format('GRANT ALL ON TABLE %I.%I TO psfrole;', _viewNameSchema, _viewNameTable);

  IF (read_only) THEN
    EXECUTE format('CREATE OR REPLACE RULE _CREATE AS ON INSERT TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
    EXECUTE format('CREATE OR REPLACE RULE _UPDATE AS ON UPDATE TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
    EXECUTE format('CREATE OR REPLACE RULE _DELETE AS ON DELETE TO %I.%I DO INSTEAD NOTHING;', _viewNameSchema, _viewNameTable);
  END IF;

  RETURN true;
END;
$$;


ALTER FUNCTION psf.create_view(view_name text, select_text text, read_only boolean) OWNER TO psfadmin;
