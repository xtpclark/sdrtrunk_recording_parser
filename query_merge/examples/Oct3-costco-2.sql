select ffurl from vw_all where  dt = CURRENT_DATE and hms between '18:00:00' AND '22:00:00'  order by ts_tz;
