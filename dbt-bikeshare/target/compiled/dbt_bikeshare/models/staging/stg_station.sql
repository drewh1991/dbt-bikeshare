

SELECT --Insert all NY stations
 'NY' as location_code
,station_id
,name
,capacity
,num_bikes_available
,num_bikes_disabled
,num_docks_available
,num_docks_disabled
,is_renting
,is_returning
,0 as num_ebikes_available
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 

UNION ALL

SELECT -- Insert all SF bike stations
 'SF' as location_code
,i.station_id
,i.name
,IFNULL(s.num_bikes_available,0) + IFNULL(s.num_bikes_disabled,0) as capacity
,IFNULL(s.num_bikes_available,0)
,IFNULL(s.num_bikes_disabled,0)
,IFNULL(s.num_docks_available,0)
,IFNULL(s.num_docks_disabled,0)
,s.is_renting
,s.is_returning
,IFNULL(s.num_ebikes_available,0)
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` i
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_status` s on s.station_id = i.station_id