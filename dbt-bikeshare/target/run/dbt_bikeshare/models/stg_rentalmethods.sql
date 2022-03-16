

  create or replace view `bikeshare-339917`.`dbt_drew`.`stg_rentalmethods`
  OPTIONS()
  as SELECT split(rental_methods,',') AS rental_methods -- split to array
    FROM ( -- Gather all distinct rental methods
            SELECT
            rental_methods
            FROM `bigquery-public-data.new_york_citibike.citibike_stations`
            UNION DISTINCT
            SELECT 
            REGEXP_REPLACE(rental_methods,r'([\'\"\[\]])','') as rental_methods -- remove brackets and single quotes
            FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
        );

