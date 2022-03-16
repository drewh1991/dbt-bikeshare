
    
    

with all_values as (

    select
        rental_method_id as value_field,
        count(*) as n_records

    from `bikeshare-339917`.`dbt_drew`.`stationrentalmethods`
    group by rental_method_id

)

select *
from all_values
where value_field not in (
    'CREDITCARD','KEY'
)


