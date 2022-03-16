

  create or replace table `bikeshare-339917`.`dbt_drew`.`stg_rentalmethodscrosswalk2`
  
  
  OPTIONS()
  as (
    

    SELECT DISTINCT
     station_key
    ,TRIM(rental_methods) as rental_methods
    FROM `bikeshare-339917`.`dbt_drew`.`stg_rentalmethodscrosswalk`
    CROSS JOIN UNNEST(rental_methods) AS rental_methods -- split array to rows
  );
  