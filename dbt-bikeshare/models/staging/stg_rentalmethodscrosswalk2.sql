
{{ config(materialized='table') }}

    SELECT DISTINCT
     station_key
    ,TRIM(rental_methods) as rental_methods
    FROM {{ ref('stg_rentalmethodscrosswalk') }}
    CROSS JOIN UNNEST(rental_methods) AS rental_methods -- split array to rows