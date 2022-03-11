
{{ config(materialized='table') }}

SELECT --Insert all NY stations

 {{ dbt_utils.surrogate_key(['station_id', 'location_code']) }} as station_key
,location_code
,station_id
,name
,capacity
,num_bikes_available
,num_bikes_disabled
,num_docks_available
,num_docks_disabled
,is_renting
,is_returning
,num_ebikes_available
FROM {{ ref('stg_station') }}
