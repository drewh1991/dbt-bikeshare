
    
    

with dbt_test__target as (
  
  select station_key as unique_field
  from `bikeshare-339917`.`dbt_drew`.`stationlocation`
  where station_key is not null
  
)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


