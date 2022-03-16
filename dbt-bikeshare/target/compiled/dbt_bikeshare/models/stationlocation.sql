SELECT
 to_hex(md5(cast(coalesce(cast(station_id as 
    string
), '') || '-' || coalesce(cast(location_code as 
    string
), '') as 
    string
))) as station_key
,latitude
,longitude
,region_id
,zip_code
,location_code
,ST_GeogPoint(longitude, latitude) as Geo
FROM `bikeshare-339917`.`dbt_drew`.`stg_stationlocation`