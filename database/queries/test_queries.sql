 select talkgroup||'-'||tg_desc AS group, sum(calls) from vw_call_stats group by 1 order by 2;

/*
                      group                      |  sum  
 615-Special Events - Traffic                    |     2
 620-Emergency                                   |     3
 719-Waste Management                            |     4
 652-Tac 7 (Special Events)                      |     6
 649-Tac 4                                       |    15
 613-2nd Precinct Tactical                       |    25
 650-Tac 5                                       |    36
 610-1st Precinct Tactical                       |    41
 618-Detective Alternate                         |    41
 651-Tac 6 (Mutual Aid-Airport/Interstate)       |    42
 658-Children's Hospital of the King's Daughters |    61
 616-3rd Precinct Tactical                       |   182
 661-Sentara Norfolk Genaral Hospital            |   186
 648-Tac 3                                       |   189
 717-Storm Water and Street Cleaning             |   237
 660-Leigh Memorial Hospital                     |   336
 646-Dispatch                                    |   562
 614-Special Events                              |   618
 619-Admin/Towing                                |   739
 609-1st Precinct Alternate                      |   763
 647-Tac 2 (EMS Ops)                             |   783
 612-2nd Precinct Alternate                      |  1246
 617-Detective Dispatch                          |  1586
 611-2nd Precinct Dispatch                       |  8737
 608-1st Precinct Dispatch                       | 10269
(25 rows)

*/
