select ffurl from vw_all where lower(category) ~'fire' and dt = CURRENT_DATE and hms between '19:00:00' AND '21:30:00'  order by ts_tz;
