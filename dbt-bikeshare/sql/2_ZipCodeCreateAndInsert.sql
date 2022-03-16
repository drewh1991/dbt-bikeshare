
CREATE TABLE IF NOT EXISTS `project.bikeshare.GeoUSZipCodeBoundaries` (
     zip_code string
    ,city string
    ,county string
    ,state_fips_code string
    ,state_code string
    ,state_name string
    ,fips_class_code string
    ,mtfcc_feature_class_code string
    ,functional_status string
    ,area_land_meters float64
    ,area_water_meters float64
    ,internal_point_lat float64
    ,internal_point_lon float64
    ,internal_point_geom geography
    ,zip_code_geom geography
)
;

INSERT INTO `project.bikeshare.GeoUSZipCodeBoundaries`
SELECT
     zip_code
    ,city
    ,county
    ,state_fips_code
    ,state_code
    ,state_name
    ,fips_class_code
    ,mtfcc_feature_class_code
    ,functional_status
    ,area_land_meters
    ,area_water_meters
    ,internal_point_lat
    ,internal_point_lon
    ,internal_point_geom
    ,zip_code_geom

FROM `bigquery-public-data.geo_us_boundaries.zip_codes` geo
WHERE geo.state_code in ('CA','NY')
and (lower(geo.city) like '%san francisco%'
        or
     lower(geo.city) like '%new york%'
     )
;


