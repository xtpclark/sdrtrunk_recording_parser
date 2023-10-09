CREATE OR REPLACE FUNCTION psf.add_column(ptable text, pcolumn text, ptype text, pconstraint text DEFAULT NULL::text, pschema text DEFAULT 'psf'::text, pcomment text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  _count INTEGER;
  _query TEXT;
  _constraintNull BOOLEAN;
  _constraintDefault TEXT;
  _columnNull BOOLEAN := FALSE;
  _sequence TEXT;
  _commentQuery TEXT;
  _current RECORD;
BEGIN

  pTable := lower(pTable);
  pColumn := lower(pColumn);
  pSchema := lower(pSchema);

  SELECT format_type(a.atttypid, a.atttypmod) AS type, a.attnotnull AS notnull, pg_get_expr(d.adbin, d.adrelid) AS defaultval INTO _current
  FROM pg_attribute a
  JOIN pg_class c ON a.attrelid=c.oid
  JOIN pg_namespace n ON c.relnamespace=n.oid
  LEFT OUTER JOIN pg_attrdef d ON a.attrelid=d.adrelid AND a.attnum=d.adnum
  WHERE c.relname = pTable
  AND n.nspname = pSchema
  AND a.attname = PColumn
  AND a.attnum > 0;

  GET DIAGNOSTICS _count := ROW_COUNT;

  IF (_count > 0) THEN
    IF (_current.type !~~* pType AND pType !~* 'serial') THEN
--The operator !~~* when used with no special regular expression operators amounts to a straight case-insensitive comparison
      _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET DATA TYPE %s', pSchema, pTable, pColumn, pType);

      EXECUTE _query;
    END IF;

    _query := format('SELECT 1 FROM %I.%I WHERE %I IS NULL', pSchema, pTable, pColumn);

    EXECUTE _query;

    GET DIAGNOSTICS _count := ROW_COUNT;

    IF (_count > 0) THEN
      _columnNull := TRUE;
    END IF;

    IF (COALESCE(pConstraint, '') ~* 'not null') THEN
      _constraintNull := TRUE;
      _constraintDefault := trim(regexp_replace(COALESCE(pConstraint, ''), 'not null', '', 'i'));
    ELSE
      _constraintNull := FALSE;
      _constraintDefault := trim(regexp_replace(COALESCE(pConstraint, ''), 'null', '', 'i'));
    END IF;

--    Have to handle serial columns otherwise we lose the link to the sequence
    IF (pType ~* 'serial') THEN
      _constraintDefault = _current.defaultval;
    END IF;

--The above does not behave correctly in most cases wherein a constraint or the default value
--contains the text 'not null' or 'null' (e.g. constraint_text='default ''not null''')

    IF (_constraintDefault ~* 'default') THEN
      IF (_constraintDefault ~* 'check') THEN
        IF (strpos(_constraintDefault, 'default') < strpos(_constraintDefault, 'check')) THEN
          _constraintDefault := trim((regexp_matches(_constraintDefault, '(default .*) check.*', 'i'))[1]::TEXT);
        ELSE
          _constraintDefault := trim((regexp_matches(_constraintDefault, 'check.*(default .*)', 'i'))[1]::TEXT);
        END IF;
      END IF;

--The above only handles check constraints, and only if the default value does not contain
--the text 'check' and the check constraint does not contain the text 'default'.
--It does not handle unique constraints, primary keys (though these should never be used with a default),
--foreign key constraints, or exclude constraints correctly.
--Check constraints are also simply ignored on existing columns rather than added/updated idempotently

      _constraintDefault := trim(regexp_replace(_constraintDefault, 'default', '', 'i'));
      IF (COALESCE(_current.defaultval, '')!=_constraintDefault) THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET DEFAULT %s', pSchema, pTable, pColumn, _constraintDefault);

        EXECUTE _query;

        IF (_current.defaultval IS NULL AND _constraintNull AND _columnNull) THEN
          _query := format('UPDATE %I.%I SET %I=%s WHERE %I IS NULL', pSchema, pTable, pColumn, _constraintDefault, pColumn);

          EXECUTE _query;
          _columnNull := FALSE;
        END IF;
      END IF;
    ELSE
      IF (_current.defaultval IS NOT NULL AND _current.defaultval!=_constraintDefault AND pConstraint !~* 'primary key') THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I DROP DEFAULT', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    END IF;

    IF (_constraintNull) THEN
      IF (NOT _current.notnull AND NOT _columnNull) THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I SET NOT NULL', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    ELSE
      IF (_current.notnull AND pType !~* 'serial' AND pConstraint !~* 'primary key') THEN
        _query := format('ALTER TABLE %I.%I ALTER COLUMN %I DROP NOT NULL', pSchema, pTable, pColumn);

        EXECUTE _query;
      END IF;
    END IF;
  ELSE
    _query := format('ALTER TABLE %I.%I ADD COLUMN %I %s %s', pSchema, pTable, pColumn, pType, COALESCE(pConstraint, ''));

    EXECUTE _query;
  END IF;

  IF (pType ~~* 'serial') THEN
    _sequence := format('%I_%I_seq', pTable, pColumn);
    IF (EXISTS(SELECT 1 FROM pg_class WHERE relname=_sequence
               AND relkind='S' AND relacl IS NULL ORDER BY relname)) THEN
      _query := format('GRANT ALL ON SEQUENCE %I.%I TO psfrole;', pSchema, _sequence);

      EXECUTE _query;
    END IF;
  END IF;

  IF (pComment IS NOT NULL) then
    _commentQuery := format('COMMENT ON COLUMN %I.%I.%I IS %s', pSchema, pTable, pColumn, quote_literal(pComment));
    EXECUTE _commentQuery;
  END IF;

  RETURN TRUE;

END;
$$;


ALTER FUNCTION psf.add_column(ptable text, pcolumn text, ptype text, pconstraint text, pschema text, pcomment text) OWNER TO psfadmin;
