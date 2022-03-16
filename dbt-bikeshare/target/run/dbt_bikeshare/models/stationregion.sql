

  create or replace view `bikeshare-339917`.`dbt_drew`.`stationregion`
  OPTIONS()
  as SELECT DISTINCT
 ny.region_id
,CAST(null as string) as region_name
FROM `bigquery-public-data.new_york_citibike.citibike_stations` ny
WHERE ny.region_id is not null
UNION ALL
SELECT DISTINCT
 sf.region_id
,sf.name as region_name
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` sf;

