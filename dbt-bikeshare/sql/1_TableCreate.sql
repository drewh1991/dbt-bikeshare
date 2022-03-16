
DROP TABLE  `project.bikeshare.BikeShareStationLocation`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStationLocation`
(
     station_key int64
    ,latitude float64
    ,longitude float64
    ,region_id int
    ,zip_code string
    ,location_code string
    ,station_geo geography
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareStation`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStation`
(
     station_key int
    ,station_id int
    ,name string
    ,capacity int
    ,num_bikes_available int
    ,num_bikes_disabled int
    ,num_docks_available int
    ,num_docks_disabled int
    ,is_renting bool
    ,is_returning bool
    ,num_ebikes_available int
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareStationRegion`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStationRegion`
(
     region_id int
    ,region_name string
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareStationRentalMethods`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStationRentalMethods`
(
     rental_method_id int not null
    ,rental_method_name string
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareStationRentalMethodsCrosswalk`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStationRentalMethodsCrosswalk`
(
     station_key int not null
    ,rental_method_id int not null
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareMemberGender`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareMemberGender`
(
     
    member_gender_id int
   ,member_gender string
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareMemberSubscriptionType`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareMemberSubscriptionType`
(
     
    member_subscription_type_id int
   ,member_subscription_type string
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareTrips`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareTrips`
(
     trip_id int
    ,start_station_key int
    ,end_station_key int
    ,member_birth_year int
    ,member_gender_id int
    ,member_subscription_type_id int
    ,bike_id int
)
;

DROP TABLE IF EXISTS `project.bikeshare.BikeShareDuration`
;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareDuration`
(
     trip_id int
    ,start_time_local datetime
    ,end_time_local datetime
    ,trip_duration_seconds int
    ,trip_duration_minutes int
    ,trip_duration_hours float64
)
;

DROP TABLE IF EXISTS `project.bikeshare.GeoUSZipCodeBoundaries`
;
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

DROP TABLE IF EXISTS `project.bikeshare.BikeShareZipCodeGeography`;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareZipCodeGeography` (
    station_key int
    ,zip_code string
    ,geo geography
)
;

DROP TABLE IF EXISTS  `project.bikeshare.BikeShareStationMetrics`;
CREATE TABLE IF NOT EXISTS `project.bikeshare.BikeShareStationMetrics` (
         start_station_key int
        ,start_station_id int
        ,start_station_name string
        ,start_location_code string
        ,trip_count int
        ,avg_trip_length_minutes float64
        ,most_freq_destination_station_key int
        ,most_freq_destination_name string
        ,most_frequent_dest_trip_count int
        ,avg_meters_traveled float64
        ,station_geo geography

)
;





