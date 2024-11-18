-- In this query, we'll go through the Data Cleaning process
-- 12 months of data (June 2023- May 2024) was imported
-- Total 5743278 rows imported
SELECT * 
FROM cyclistic.cyclisticmain
;

-- Checking for ride_id with more or less than 16 characters
SELECT ride_id, length(ride_id) 
FROM cyclistic.cyclisticmain
WHERE length(ride_id)  != 16
;

-- Removing the odd ride_id's, 3865 rows deleted
DELETE 
FROM cyclistic.cyclisticmain
WHERE length(ride_id)  != 16
;

-- 3 different ride types, electric_bike, classic_bike and docked_bike
SELECT DISTINCT rideable_type
FROM cyclistic.cyclisticmain
;

-- Trying to find unusual lengths of ridetime
SELECT *, TIMESTAMPDIFF(MINUTE, started_at, ended_at) AS time_difference
FROM cyclistic.cyclisticclean
WHERE TIMESTAMPDIFF(MINUTE, started_at, ended_at) <= 1 OR TIMESTAMPDIFF(MINUTE, started_at, ended_at) >=1440
;

-- 192013 rows affected
DELETE
FROM cyclistic.cyclisticclean
WHERE TIMESTAMPDIFF(MINUTE, started_at, ended_at) <= 1 OR TIMESTAMPDIFF(MINUTE, started_at, ended_at) >=1440
;

-- The next data process removes a large portion of data which are missing which is why backup table was created
-- Backup Table: cyclisticmain, data will be cleaned on cyclisticcclean Table
CREATE TABLE cyclisticclean AS
SELECT * FROM cyclisticmain
;

-- Checking for empty rows with no start_station_name
SELECT start_station_name, COUNT(start_station_name)
FROM cyclistic.cyclisticclean
GROUP BY start_station_name
;

-- Checking for empty rows with no end_station_name
SELECT end_station_name, COUNT(start_station_name)
FROM cyclistic.cyclisticclean
GROUP BY end_station_name
;

-- Checking the ride types for the empty rows resulted in some interesting insights as majority of the empty rows were from electric bikes
SELECT rideable_type, COUNT(*)
FROM cyclistic.cyclisticclean
WHERE start_station_name = '' OR end_station_name = ''
GROUP BY rideable_type
;

-- We need to delete the empty rows to move forward with our analysis as they won't be useful for gathering insights from these trips
-- 1343975 rows affected
DELETE
FROM cyclistic.cyclisticclean
WHERE start_station_name = '' OR start_station_id = '' OR end_station_name = ''  OR end_station_id = ''
;

-- After deleting the empty rows of station_name, we will check why start_station_name and start_station_id doesn't have the same number
-- There are 1581 unique stations with 1553 unique station id's and this query helps to find that there are some stations with 2 distinct ids
-- This data doesn't really affect the accuracy much so we can ignore this part
SELECT start_station_name, COUNT(DISTINCT start_station_id) AS distinct_ids
FROM cyclistic.cyclisticclean
GROUP BY start_station_name
HAVING COUNT(DISTINCT start_station_id) > 1
;

-- Checking for NULL values for start_lat
SELECT start_lat, COUNT(*)
FROM cyclistic.cyclisticclean
GROUP BY start_lat
ORDER BY start_lat
;

-- Checking for NULL values for end_lat
SELECT end_lat
FROM cyclistic.cyclisticclean
GROUP BY end_lat
ORDER BY end_lat
;

-- Removing empty cells and 0 values for end_lat
DELETE
FROM cyclistic.cyclisticclean
WHERE end_lat = '' OR end_lat = '0'
;

-- Checking for NULL values in member_casual column
SELECT member_casual
FROM cyclistic.cyclisticclean
GROUP BY member_casual
ORDER BY member_casual
;

-- Upon further inspection, we'll remove data where start_station and end_station are the same as it doesn't give much information about trip data
DELETE
FROM cyclistic.cyclisticclean
WHERE start_station_name = end_station_name
;

-- docked_bike are only used by casual members, this study is to compare to see how casual riders differ from members
-- docked_bike also has almost doubles the trip duration of classic_bike rides for casual riders
SELECT member_casual, rideable_type, COUNT(*) AS number_of_rides_per_type, AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual, rideable_type
;

-- As there are not enough information to determine its nature and the data seems a bit skewed, we'll keep docked_bike out of our analysis
DELETE
FROM cyclistic.cyclisticclean
WHERE rideable_type = 'docked_bike'
;

-- With that, the data cleaning process has ended. This is the final dataset we'll be working on
-- 3982402 rows is the cleaned data size from an initial data size of 5743278 rows
SELECT *
FROM cyclistic.cyclisticclean;
;