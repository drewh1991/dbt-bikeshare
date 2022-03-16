

  create or replace table `bikeshare-339917`.`dbt_drew`.`station`
  
  
  OPTIONS()
  as (
    

SELECT --Insert all NY stations

 to_hex(md5(cast(coalesce(cast(station_id as 
    string
), '') || '-' || coalesce(cast(location_code as 
    string
), '') as 
    string
))) as station_key
,location_code
,station_id
,name
,capacity
,num_bikes_available
,num_bikes_disabled
,num_docks_available
,num_docks_disabled
,is_renting
,is_returning
,num_ebikes_available
FROM `bikeshare-339917`.`dbt_drew`.`stg_station`
  );
  