-- There are stations in the trip data that don't exist in the stations table, but for simplicitys sake we only care about those that have a record in the stations table

-- BikeShareStation
TRUNCATE TABLE  `project.bikeshare.BikeShareStation`;

INSERT INTO `project.bikeshare.BikeShareStation` (
    station_key
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

)

SELECT --Insert all NY stations
 FARM_FINGERPRINT(CONCAT(CAST(station_id as string),'NY')) as station_key
,station_id
,name
,capacity
,num_bikes_available
,num_bikes_disabled
,num_docks_available
,num_docks_disabled
,is_renting
,is_returning
,0 as num_ebikes_available
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 
;

INSERT INTO `project.bikeshare.BikeShareStation` (
    station_key
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
)

SELECT -- Insert all SF bike stations
 FARM_FINGERPRINT(CONCAT(CAST(i.station_id as string),'SF')) as station_key
,i.station_id
,i.name
,IFNULL(s.num_bikes_available,0) + IFNULL(s.num_bikes_disabled,0) as capacity
,IFNULL(s.num_bikes_available,0)
,IFNULL(s.num_bikes_disabled,0)
,IFNULL(s.num_docks_available,0)
,IFNULL(s.num_docks_disabled,0)
,s.is_renting
,s.is_returning
,IFNULL(s.num_ebikes_available,0)
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` i
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_status` s on s.station_id = i.station_id
;

--BikeShareStationLocation
TRUNCATE TABLE `project.bikeshare.BikeShareStationLocation`;

INSERT INTO `project.bikeshare.BikeShareStationLocation` (
    station_key
   ,latitude
   ,longitude
   ,region_id
   ,zip_code
   ,location_code
   ,station_geo
) 

SELECT
 FARM_FINGERPRINT(CONCAT(CAST(station_id as string),'NY')) as station_key
,latitude
,longitude
,region_id
,CAST(null as string) as zip_code
,'NY' as location_code
,ST_GeogPoint(longitude, latitude)
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 
;

INSERT INTO `project.bikeshare.BikeShareStationLocation` (
    station_key
   ,latitude
   ,longitude
   ,region_id
   ,zip_code
   ,location_code
   ,station_geo
) 

SELECT
 FARM_FINGERPRINT(CONCAT(CAST(station_id as string),'SF')) as station_key
,lat
,lon
,region_id
,CAST(null as string) as zip_code
,'SF' as location_code
,ST_GeogPoint(lon, lat)
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` 
;

--BikeShareStationRegion
TRUNCATE TABLE `project.bikeshare.BikeShareStationRegion`;

INSERT INTO `project.bikeshare.BikeShareStationRegion`
SELECT DISTINCT
 ny.region_id
,CAST(null as string) as region_name
FROM `bigquery-public-data.new_york_citibike.citibike_stations` ny
WHERE ny.region_id is not null
UNION ALL
SELECT DISTINCT
 sf.region_id
,sf.name as region_name
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` sf
;

--BikeShareStationRentalMethods
--TRUNCATE TABLE `project.bikeshare.BikeShareStationRentalMethods`;
INSERT INTO `project.bikeshare.BikeShareStationRentalMethods` (
    rental_method_id
    ,rental_method_name
)

    WITH rm_split AS (
    SELECT split(rental_methods,',') AS rental_methods -- split to array
    FROM ( -- Gather all distinct rental methods
            SELECT
            rental_methods
            FROM `bigquery-public-data.new_york_citibike.citibike_stations`
            UNION DISTINCT
            SELECT 
            REGEXP_REPLACE(rental_methods,r'([\'\"\[\]])','') as rental_methods -- remove brackets and single quotes
            FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
        )
    )


    SELECT -- create a row number as a rental method category id, starting with the next highest value
    ROW_NUMBER() OVER (ORDER BY rm.rental_methods) 
        + (SELECT IFNULL(MAX(rental_method_id),0) FROM `project.bikeshare.BikeShareStationRentalMethods`) as rental_method_id 
    ,rm.rental_methods as rental_method_name
    FROM (
            SELECT DISTINCT
            TRIM(rental_methods) as rental_methods 
            FROM rm_split
            CROSS JOIN UNNEST(rm_split.rental_methods) AS rental_methods -- split array to rows
        ) rm
    WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareStationRentalMethods` WHERE rental_method_name = rm.rental_methods)
    ;

--BikeShareSTationRentalMethodsCrosswalk
--TRUNCATE TABLE `project.bikeshare.BikeShareStationRentalMethodsCrosswalk`;

INSERT INTO `project.bikeshare.BikeShareStationRentalMethodsCrosswalk` (
    station_key
   ,rental_method_id
)
    WITH rm_split AS ( -- get all rental methods by surrogate key
    SELECT 
    station_key
    ,split(rental_methods,',') AS rental_methods -- split to array
    FROM ( -- Gather all distinct rental methods, join back to get station key
            SELECT
            stat.station_key
            ,ny.rental_methods
            FROM `bigquery-public-data.new_york_citibike.citibike_stations` ny
            INNER JOIN `project.bikeshare.BikeShareStation` stat on stat.station_id = ny.station_id
            INNER JOIN `project.bikeshare.BikeShareStationLocation` loc on loc.station_key = stat.station_key
                and loc.location_code = 'NY'
            UNION ALL
            SELECT 
            stat.station_key
            ,REGEXP_REPLACE(sf.rental_methods,r'([\'\"\[\]])','') as rental_methods -- remove brackets and single quotes
            FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` sf
            INNER JOIN `project.bikeshare.BikeShareStation` stat on stat.station_id = sf.station_id
            INNER JOIN `project.bikeshare.BikeShareStationLocation` loc on loc.station_key = stat.station_key
                and loc.location_code = 'SF'
        ) 
    )

   ,rm_rows as (
    SELECT DISTINCT
     station_key
    ,TRIM(rental_methods) as rental_methods
    FROM rm_split
    CROSS JOIN UNNEST(rm_split.rental_methods) AS rental_methods -- split array to rows
   )

   SELECT DISTINCT
    rm_rows.station_key
   ,rm_cat.rental_method_id
   FROM rm_rows 
   INNER JOIN `project.bikeshare.BikeShareStationRentalMethods` rm_cat on rm_cat.rental_method_name = rental_methods 
   WHERE NOT EXISTS ( -- Must be new values
                        SELECT 1 FROM `project.bikeshare.BikeShareStationRentalMethodsCrosswalk` 
                        WHERE rental_method_id = rm_cat.rental_method_id
                        and station_key = rm_rows.station_key
                     )

    ORDER BY rm_rows.station_key, rm_cat.rental_method_id
    ;


--TRUNCATE TABLE `project.bikeshare.BikeShareMemberGender`;
INSERT INTO `project.bikeshare.BikeShareMemberGender` (
    member_gender_id
   ,member_gender
)

SELECT DISTINCT
  ROW_NUMBER() OVER (ORDER BY gender.gender) + (SELECT IFNULL(MAX(member_gender_id),0) FROM `project.bikeshare.BikeShareMemberGender`) as member_gender_id 
 ,gender.gender
FROM (
        SELECT
        NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                CASE WHEN ny.gender IS NULL THEN 'unknown'
                                    WHEN ny.gender = '' THEN 'unknown'
                                    ELSE ny.gender
                                    END 
        ) as Gender
        FROM `bigquery-public-data.new_york_citibike.citibike_trips` ny
        UNION DISTINCT 
        SELECT
        NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                CASE WHEN sf.member_gender IS NULL THEN 'unknown'
                                    WHEN sf.member_gender = '' THEN 'unknown'
                                    ELSE sf.member_gender
                                    END 
        ) as Gender
        FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` sf

) gender

WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareMemberGender` WHERE member_gender = gender.gender)
;

--BikeShareMemberSubscriptionType
--TRUNCATE TABLE `project.bikeshare.BikeShareMemberSubscriptionType`;

INSERT INTO `project.bikeshare.BikeShareMemberSubscriptionType` (
    member_subscription_type_id
   ,member_subscription_type
)

SELECT DISTINCT
  -- create next highest subcription type id
  ROW_NUMBER() OVER (ORDER BY sub.member_subscription_type) + (SELECT IFNULL(MAX(member_subscription_type_id),0) FROM `project.bikeshare.BikeShareMemberSubscriptionType`) as member_subscription_type_id
 ,sub.member_subscription_type
FROM (
        SELECT
        NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                CASE WHEN ny.usertype IS NULL THEN 'unknown'
                                    WHEN ny.usertype = '' THEN 'unknown'
                                    ELSE ny.usertype
                                    END 
        ) as member_subscription_type
        FROM `bigquery-public-data.new_york_citibike.citibike_trips` ny
        UNION DISTINCT 
        SELECT
        NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                CASE WHEN sf.subscriber_Type IS NULL THEN 'unknown'
                                    WHEN sf.subscriber_type = '' THEN 'unknown'
                                    ELSE sf.subscriber_type
                                    END 
        ) as member_subscription_type
        FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` sf

) sub

WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareMemberSubscriptionType` WHERE member_subscription_type = sub.member_subscription_type)
;

--BikeShareTrips
--TRUNCATE TABLE `project.bikeshare.BikeShareTrips`;

INSERT INTO `project.bikeshare.BikeShareTrips` (
    trip_id
    ,start_station_key
    ,end_station_key
    ,member_birth_year
    ,member_gender_id
    ,member_subscription_type_id
    ,bike_id
)

SELECT
 trip.trip_id
,trip.start_station_key
,trip.end_station_key
,trip.birth_year
,g.member_gender_id
,st.member_subscription_type_id
,trip.bikeid
FROM (  
        SELECT
        FARM_FINGERPRINT(CONCAT(CAST(ny.start_station_id as string), CAST(ny.end_station_id as string), CAST(ny.starttime as string), CAST(ny.stoptime as string))) as trip_id
        ,start_stat.station_key as start_station_key
        ,end_stat.station_key as end_station_key
        ,ny.birth_year
        ,NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                    CASE WHEN ny.gender IS NULL THEN 'unknown'
                                        WHEN ny.gender = '' THEN 'unknown'
                                        ELSE ny.gender
                                        END 
        ) as member_gender
        ,NORMALIZE_AND_CASEFOLD(ny.usertype) as member_subscription_type
        ,ny.bikeid
        FROM `bigquery-public-data.new_york_citibike.citibike_trips` ny
        INNER JOIN `project.bikeshare.BikeShareStation` start_stat on start_stat.station_id = ny.start_station_id
        INNER JOIN `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_stat.station_key
            and start_loc.location_code = 'NY'
        INNER JOIN `project.bikeshare.BikeShareStation` end_stat on end_stat.station_id = ny.end_station_id
        INNER JOIN `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = end_stat.station_key
            and end_loc.location_code = 'NY'
) trip
LEFT JOIN `project.bikeshare.BikeShareMemberGender` g on g.member_gender = trip.member_gender
LEFT JOIN `project.bikeshare.BikeShareMemberSubscriptionType` st on st.member_subscription_type = trip.member_subscription_type

WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareTrips` WHERE trip_id = trip.trip_id)

UNION ALL 

SELECT
 trip.trip_id 
,trip.start_station_key 
,trip.end_station_key 
,trip.member_birth_year
,g.member_gender_id
,st.member_subscription_type_id
,trip.bike_number

FROM (
        SELECT
        FARM_FINGERPRINT(CONCAT(CAST(sf.start_station_id as string), CAST(sf.end_station_id as string), CAST(sf.start_date as string), CAST(sf.end_date as string))) as trip_id
        ,start_stat.station_key as start_station_key
        ,end_stat.station_key as end_station_key
        ,sf.member_birth_year
        ,NORMALIZE_AND_CASEFOLD( -- normalize values to eliminate dupes
                                CASE WHEN sf.member_gender IS NULL THEN 'unknown'
                                    WHEN sf.member_gender = '' THEN 'unknown'
                                    ELSE sf.member_gender
                                    END 
        ) as member_gender
        ,NORMALIZE_AND_CASEFOLD(sf.subscriber_type) as member_subscription_type
        ,sf.bike_number
        FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` sf
        INNER JOIN `project.bikeshare.BikeShareStation` start_stat on start_stat.station_id = sf.start_station_id
        INNER JOIN `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_stat.station_key
            and start_loc.location_code = 'SF'
        INNER JOIN `project.bikeshare.BikeShareStation` end_stat on end_stat.station_id = sf.start_station_id
        INNER JOIN `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = start_stat.station_key
            and end_loc.location_code = 'SF'
) trip 
LEFT JOIN `project.bikeshare.BikeShareMemberGender` g on g.member_gender = trip.member_gender
LEFT JOIN `project.bikeshare.BikeShareMemberSubscriptionType` st on st.member_subscription_type = trip.member_subscription_type

WHERE NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareTrips` WHERE trip_id = trip.trip_id)

;

--BikeShareStationDuration
TRUNCATE TABLE `project.bikeshare.BikeShareDuration`;

INSERT INTO `project.bikeshare.BikeShareDuration` (
    trip_id
    ,start_time_local
    ,end_time_local
    ,trip_duration_seconds
    ,trip_duration_minutes
    ,trip_duration_hours
)

SELECT
 FARM_FINGERPRINT(CONCAT(CAST(ny.start_station_id as string), CAST(ny.end_station_id as string), CAST(ny.starttime as string), CAST(ny.stoptime as string))) as trip_id
,ny.starttime as start_time_local
,ny.stoptime as end_time_local
,DATETIME_DIFF(ny.stoptime, ny.starttime, SECOND) as trip_duration_seconds
,DATETIME_DIFF(ny.stoptime, ny.starttime, MINUTE) as trip_duration_minutes
,ROUND(DATETIME_DIFF(ny.stoptime, ny.starttime, MINUTE)/60,2) as trip_duration_hours
FROM `bigquery-public-data.new_york_citibike.citibike_trips` ny
INNER JOIN `project.bikeshare.BikeShareStation` start_stat on start_stat.station_id = ny.start_station_id
INNER JOIN `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_stat.station_key
    and start_loc.location_code = 'NY'
INNER JOIN `project.bikeshare.BikeShareStation` end_stat on end_stat.station_id = ny.end_station_id
INNER JOIN `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = end_stat.station_key
    and end_loc.location_code = 'NY'

UNION ALL 

SELECT
 FARM_FINGERPRINT(CONCAT(CAST(sf.start_station_id as string), CAST(sf.end_station_id as string), CAST(sf.start_date as string), CAST(sf.end_date as string))) as trip_id
,CAST(sf.start_date as DATETIME) as start_time_local
,CAST(sf.end_date as DATETIME) as end_time_local
,DATETIME_DIFF(sf.end_date, sf.start_date, SECOND) as trip_duration_seconds
,DATETIME_DIFF(sf.end_date, sf.start_date, MINUTE) as trip_duration_minutes
,ROUND(DATETIME_DIFF(sf.end_date, sf.start_date, MINUTE)/60,2) as trip_duration_hours
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` sf
INNER JOIN `project.bikeshare.BikeShareStation` start_stat on start_stat.station_id = sf.start_station_id
INNER JOIN `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_stat.station_key
    and start_loc.location_code = 'SF'
INNER JOIN `project.bikeshare.BikeShareStation` end_stat on end_stat.station_id = sf.start_station_id
INNER JOIN `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = start_stat.station_key
    and end_loc.location_code = 'SF'


;

--TRUNCATE TABLE `project.bikeshare.BikeShareZipCodeGeography`;

INSERT INTO `project.bikeshare.BikeShareZipCodeGeography` (
    station_key
    ,zip_code
    ,geo
)

SELECT
 loc.station_key
,zip.zip_code
,zip.zip_code_geom
FROM `project.bikeshare.BikeShareStationLocation` loc, `project.bikeshare.GeoUSZipCodeBoundaries` zip
WHERE ST_WITHIN(loc.station_geo, zip.zip_code_geom)
and NOT EXISTS (SELECT 1 FROM `project.bikeshare.BikeShareZipCodeGeography` WHERE station_key = loc.station_key)
;

UPDATE `project.bikeshare.BikeShareStationLocation` loc
SET loc.zip_code = geo.zip_code
FROM `project.bikeshare.BikeShareZipCodeGeography` geo
WHERE 
geo.station_key = loc.station_key
and loc.zip_code IS NULL
;


INSERT INTO `project.bikeshare.BikeShareStationMetrics`
SELECT
s.station_key as start_station_key
,s.station_id as start_station_id
,s.name as start_station_name
,loc.location_code as start_location_code
,tc.trip_count
,tc.avg_trip_length_minutes 
,freq_dest.most_freq_destination_station_key
,freq_dest.most_freq_destination_name
,freq_dest.most_frequent_dest_trip_count
,avg_dist.avg_meters_traveled 
,loc.station_geo


FROM `project.bikeshare.BikeShareStation` s
INNER JOIN `project.bikeshare.BikeShareStationLocation` loc on loc.station_key = s.station_key
INNER JOIN (
                    SELECT
                    start_station.station_key
                    ,avg(d.trip_duration_minutes) as avg_trip_length_minutes
                    ,count(t.trip_id) as trip_count
                    FROM `project.bikeshare.BikeShareTrips` t
                    INNER JOIN `project.bikeshare.BikeShareStation` start_station on start_station.station_key = t.start_station_key
                    INNER JOIN `project.bikeshare.BikeShareDuration` d on d.trip_id = t.trip_id
                    GROUP BY start_station.station_key
                    ORDER BY start_station.station_key

) tc on tc.station_key = s.station_key

INNER JOIN (
            SELECT
            a.*
            ,ROW_NUMBER() OVER (PARTITION BY station_key order by a.most_frequent_dest_trip_count DESC) as row_nbr
            FROM (    
                    SELECT
                    start_station.station_key
                    ,end_station.name as most_freq_destination_name
                    ,end_station.station_key as most_freq_destination_station_key
                    ,count(t.trip_id) as most_frequent_dest_trip_count
                    FROM `project.bikeshare.BikeShareTrips` t
                    INNER JOIN `project.bikeshare.BikeShareDuration` d on d.trip_id = t.trip_id
                    INNER JOIN `project.bikeshare.BikeShareStation` start_station on start_station.station_key = t.start_station_key
                    INNER JOIN  `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_station.station_key
                    INNER JOIN `project.bikeshare.BikeShareStation` end_station on end_station.station_key = t.end_station_key
                    INNER JOIN  `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = end_station.station_key
                    GROUP BY start_station.station_key, end_station.name, end_station.station_key
            ) a
            ) freq_dest on freq_dest.station_key = s.station_key
                    and freq_dest.row_nbr = 1

LEFT JOIN ( -- There's something wrong with the SF geo data, need to troubleshoot
                    SELECT
                    start_station.station_key
                    ,AVG(ST_DISTANCE(start_loc.station_geo, end_loc.station_geo)) as avg_meters_traveled
                    FROM `project.bikeshare.BikeShareTrips` t
                    INNER JOIN `project.bikeshare.BikeShareDuration` d on d.trip_id = t.trip_id
                    INNER JOIN `project.bikeshare.BikeShareStation` start_station on start_station.station_key = t.start_station_key
                    INNER JOIN  `project.bikeshare.BikeShareStationLocation` start_loc on start_loc.station_key = start_station.station_key
                    INNER JOIN `project.bikeshare.BikeShareStation` end_station on end_station.station_key = t.end_station_key
                    INNER JOIN  `project.bikeshare.BikeShareStationLocation` end_loc on end_loc.station_key = end_station.station_key
                    WHERE t.start_station_key != t.end_station_key
                    and ST_DISTANCE(start_loc.station_geo, end_loc.station_geo) < 10000
                    GROUP BY start_station.station_key

            ) avg_dist on avg_dist.station_key = s.station_key

