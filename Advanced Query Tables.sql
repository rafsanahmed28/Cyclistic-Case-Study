-- The goal of this query to find a big workable data to get hourly insights as well as geographical location to correlate between them
-- Calculate the average latitudes and longitudes for each station and group by stations, member_casual, hour of day

SELECT 
	member_casual,
    start_station_name AS all_stations,
    hour_of_day,
    SUM(total) AS total_trips,
    ROUND(AVG(avgtd),2) AS avg_trip_duration,
    ROUND(AVG(startlat), 4) AS start_lat,
	ROUND(AVG(startlng), 4) AS start_lng, 
    ROUND(AVG(endlat), 4) AS end_lat,
	ROUND(AVG(endlng), 4) AS end_lng
FROM (
    -- The Most Popular Starting Station Hourly for Member Riders
    SELECT member_casual, COUNT(*) AS total, start_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avgtd,
    ROUND(AVG(start_lat), 4) AS startlat,
	ROUND(AVG(start_lng), 4) AS startlng, 
    ROUND(AVG(end_lat), 4) AS endlat,
	ROUND(AVG(end_lng), 4) AS endlng
    FROM cyclistic.cyclisticclean
    GROUP BY member_casual, start_station_name, hour_of_day
    
    UNION ALL
    
    -- The Most Popular Ending Station Hourly for Member Riders
    SELECT member_casual, COUNT(*) AS total, end_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avgtd,
    ROUND(AVG(start_lat), 4) AS startlat,
	ROUND(AVG(start_lng), 4) AS startlng, 
    ROUND(AVG(end_lat), 4) AS endlat,
	ROUND(AVG(end_lng), 4) AS endlng
    FROM cyclistic.cyclisticclean
    GROUP BY member_casual, end_station_name, hour_of_day
) AS combined_count
GROUP BY member_casual, all_stations, hour_of_day
ORDER BY hour_of_day
;

-- The resultant table was later cleaned on Excel to remove inconsistent and unwanted data for proper visualization