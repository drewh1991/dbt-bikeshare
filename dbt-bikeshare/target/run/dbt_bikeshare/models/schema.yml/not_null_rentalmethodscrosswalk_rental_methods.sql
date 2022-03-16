select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select *
from `bikeshare-339917`.`dbt_drew`.`rentalmethodscrosswalk`
where rental_methods is null



      
    ) dbt_internal_test