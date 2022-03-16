

  create or replace view `bikeshare-339917`.`dbt_drew`.`my_second_dbt_model`
  OPTIONS()
  as -- Use the `ref` function to select from other models

select *
from `bikeshare-339917`.`dbt_drew`.`my_first_dbt_model`
where id = 1;

