
    SELECT -- create a row number as a rental method category id, starting with the next highest value
    ROW_NUMBER() OVER (ORDER BY rm.rental_methods) 
        -- + (SELECT IFNULL(MAX(rental_method_id),0) FROM `project.bikeshare.BikeShareStationRentalMethods`)
         as rental_method_id 
    ,rm.rental_methods as rental_method_name
    FROM {{ ref('stg_rentalmethods2') }} rm
    -- WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareStationRentalMethods` WHERE rental_method_name = rm.rental_methods)
