SELECT ffurl
   FROM vw_all
 WHERE tag ~'Hospital'
   AND dt = ( CURRENT_DATE - 1 )
   AND hms BETWEEN '00:00:00' AND '12:00:00'
ORDER BY ts_tz;
