select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        rental_method as value_field,
        count(*) as n_records

    from `bikeshare-339917`.`dbt_drew`.`stationrentalmethods`
    group by rental_method

)

select *
from all_values
where value_field not in (
    'CREDITCARD','KEY'
)



      
    ) dbt_internal_test