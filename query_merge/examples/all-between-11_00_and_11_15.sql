select ffurl from vw_all where dt = CURRENT_DATE - 1  and hms between '11:00:00' and '11:15:00' order by ts_tz;
