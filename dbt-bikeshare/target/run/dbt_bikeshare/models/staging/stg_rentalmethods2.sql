

  create or replace view `bikeshare-339917`.`dbt_drew`.`stg_rentalmethods2`
  OPTIONS()
  as SELECT DISTINCT
TRIM(rental_methods) as rental_methods 
FROM `bikeshare-339917`.`dbt_drew`.`stg_rentalmethods`
CROSS JOIN UNNEST(rental_methods) AS rental_methods -- split array to rows;

