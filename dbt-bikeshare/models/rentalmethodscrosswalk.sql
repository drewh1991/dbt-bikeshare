
{{ config(materialized='table') }}

SELECT DISTINCT
rm_rows.station_key
,rm_cat.rental_method_id
FROM {{ ref('stg_rentalmethodscrosswalk2') }} rm_rows
INNER JOIN {{ ref('stationrentalmethods') }} rm_cat on rm_cat.rental_method_name = rm_rows.rental_methods 

ORDER BY rm_rows.station_key, rm_cat.rental_method_id