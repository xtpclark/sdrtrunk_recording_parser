INSERT INTO trs_sites (site_id, rfss, site_dec, site_hex, site_nac, description, county_name, lat, lon, range) VALUES 
(1,'1','001','1' ,'461', 'Simulcast',      'Norfolk', 	    '36.846810', '-76.28522', '25'),
(2,'1','20' ,'14','195', 'Virginia Beach', 'Virginia Beach','36.700000', '-76.03363', '17'),
(3,'1','14' ,'E' ,'19D', 'Chesapeake',     'Chesapeake',    '36.795797', '-76.23815', '30'),
(4,'1','1'  ,'1' ,'19F', 'Richmond',	   'Chesterfield',  '37.503198', '-77.54170', '30');

SELECT pg_catalog.setval('trs_sites_site_id_seq', 4, true);

INSERT INTO trs_freq(freq_id, freq_site_id, freq, iscontrol) VALUES
(nextval('trs_freq_freq_id_seq'),1,'854.162500', FALSE	),
(nextval('trs_freq_freq_id_seq'),1,'855.237500', FALSE	),
(nextval('trs_freq_freq_id_seq'),1,'856.637500', FALSE	),
(nextval('trs_freq_freq_id_seq'),1,'857.512500', TRUE	),
(nextval('trs_freq_freq_id_seq'),1,'857.987500', TRUE	),
(nextval('trs_freq_freq_id_seq'),1,'858.987500', TRUE	),
(nextval('trs_freq_freq_id_seq'),2,'152.517500', TRUE	),
(nextval('trs_freq_freq_id_seq'),2,'152.142500', TRUE	),
(nextval('trs_freq_freq_id_seq'),2,'152.802500', TRUE	),
(nextval('trs_freq_freq_id_seq'),3,'152.787500', TRUE	),
(nextval('trs_freq_freq_id_seq'),3,'151.212500', FALSE	),
(nextval('trs_freq_freq_id_seq'),4,'151.212500', FALSE	),
(nextval('trs_freq_freq_id_seq'),4,'151.152500', TRUE	),
(nextval('trs_freq_freq_id_seq'),4,'152.037500', TRUE	),
(nextval('trs_freq_freq_id_seq'),4,'159.112500', FALSE	),
(nextval('trs_freq_freq_id_seq'),4,'159.457500', FALSE	);
