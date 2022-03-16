

  create or replace table `bikeshare-339917`.`dbt_drew`.`stg_rentalmethodscrosswalk`
  
  
  OPTIONS()
  as (
    

SELECT 
    station_key
    ,split(rental_methods,',') AS rental_methods -- split to array
    FROM ( -- Gather all distinct rental methods, join back to get station key
            SELECT
            stat.station_key
            ,ny.rental_methods
            FROM `bigquery-public-data.new_york_citibike.citibike_stations` ny
            INNER JOIN `bikeshare-339917`.`dbt_drew`.`station`  stat on stat.station_id = ny.station_id
            INNER JOIN `bikeshare-339917`.`dbt_drew`.`stationlocation` loc on loc.station_key = stat.station_key
                and loc.location_code = 'NY'
            UNION ALL
            SELECT 
            stat.station_key
            ,REGEXP_REPLACE(sf.rental_methods,r'([\'\"\[\]])','') as rental_methods -- remove brackets and single quotes
            FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` sf
            INNER JOIN `bikeshare-339917`.`dbt_drew`.`station` stat on stat.station_id = sf.station_id
            INNER JOIN `bikeshare-339917`.`dbt_drew`.`stationlocation` loc on loc.station_key = stat.station_key
                and loc.location_code = 'SF'
            )
  );
  