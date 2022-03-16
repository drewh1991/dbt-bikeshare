

  create or replace view `bikeshare-339917`.`dbt_drew`.`stationrentalmethods`
  OPTIONS()
  as WITH rm_split AS (
    SELECT split(rental_methods,',') AS rental_methods -- split to array
    FROM ( -- Gather all distinct rental methods
            SELECT
            rental_methods
            FROM `bigquery-public-data.new_york_citibike.citibike_stations`
            UNION DISTINCT
            SELECT 
            REGEXP_REPLACE(rental_methods,r'([\'\"\[\]])','') as rental_methods -- remove brackets and single quotes
            FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
        )
    )


    SELECT -- create a row number as a rental method category id, starting with the next highest value
    ROW_NUMBER() OVER (ORDER BY rm.rental_methods) 
        -- + (SELECT IFNULL(MAX(rental_method_id),0) FROM `project.bikeshare.BikeShareStationRentalMethods`)
         as rental_method_id 
    ,rm.rental_methods as rental_method_name
    FROM (
            SELECT DISTINCT
            TRIM(rental_methods) as rental_methods 
            FROM rm_split
            CROSS JOIN UNNEST(rm_split.rental_methods) AS rental_methods -- split array to rows
        ) rm
    -- WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareStationRentalMethods` WHERE rental_method_name = rm.rental_methods);

