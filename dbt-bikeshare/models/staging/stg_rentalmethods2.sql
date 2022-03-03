
SELECT DISTINCT
TRIM(rental_methods) as rental_methods 
FROM {{ ref('stg_rentalmethods') }}
CROSS JOIN UNNEST(rental_methods) AS rental_methods -- split array to rows