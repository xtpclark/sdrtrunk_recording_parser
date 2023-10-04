select ffurl from vw_all where descrip ~'2nd Precinct' and dt = CURRENT_DATE - 1  order by ts_tz;
