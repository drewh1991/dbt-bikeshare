SELECT
 FARM_FINGERPRINT(CONCAT(CAST(station_id as string),'NY')) as station_key
,latitude
,longitude
,region_id
,CAST(null as string) as zip_code
,'NY' as location_code
,ST_GeogPoint(longitude, latitude) as Geo
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 

UNION ALL

SELECT
 FARM_FINGERPRINT(CONCAT(CAST(station_id as string),'SF')) as station_key
,lat
,lon
,region_id
,CAST(null as string) as zip_code
,'SF' as location_code
,ST_GeogPoint(lon, lat) as Geo
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`