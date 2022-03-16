

  create or replace table `bikeshare-339917`.`dbt_drew`.`rentalmethodscrosswalk`
  
  
  OPTIONS()
  as (
    

SELECT DISTINCT
rm_rows.station_key
,rm_cat.rental_method_id
FROM `bikeshare-339917`.`dbt_drew`.`stg_rentalmethodscrosswalk2` rm_rows
INNER JOIN `bikeshare-339917`.`dbt_drew`.`stationrentalmethods` rm_cat on rm_cat.rental_method_name = rm_rows.rental_methods 

ORDER BY rm_rows.station_key, rm_cat.rental_method_id
  );
  