
    
    

with dbt_test__target as (
  
  select rental_method_name as unique_field
  from `bikeshare-339917`.`dbt_drew`.`stationrentalmethods`
  where rental_method_name is not null
  
)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


