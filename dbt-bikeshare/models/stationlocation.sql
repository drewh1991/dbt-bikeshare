
SELECT
 {{ dbt_utils.surrogate_key(['station_id', 'location_code']) }} as station_key
,latitude
,longitude
,region_id
,zip_code
,location_code
,ST_GeogPoint(longitude, latitude) as Geo
FROM {{ ref('stg_stationlocation') }}