
    
    

with all_values as (

    select
        rental_method_name as value_field,
        count(*) as n_records

    from `bikeshare-339917`.`dbt_drew`.`stationrentalmethods`
    group by rental_method_name

)

select *
from all_values
where value_field not in (
    'CREDITCARD','KEY'
)


