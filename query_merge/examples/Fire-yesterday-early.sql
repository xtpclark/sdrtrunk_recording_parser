select ffurl from vw_all where lower(category) ~'fire' and dt = CURRENT_DATE - 1 and hms between '00:00:00' and '06:00:00' order by ts_tz;
