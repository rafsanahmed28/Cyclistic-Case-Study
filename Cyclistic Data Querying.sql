-- Here we'll dive deeper into the data and take a closer look at how different bikes are used, duration of the trips, usage in different days and months
-- Member vs Casual Total Rides and Average Trip Duration 
SELECT member_casual, 
	COUNT(member_casual) AS number_of_rides,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual
;

-- Member vs Casual Rides per Different Ride Types and Average Trip Duration
SELECT member_casual, rideable_type, 
	COUNT(*) AS number_of_rides_per_type, 
	AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual, rideable_type
;

-- Member vs Casual Rides Per Month
SELECT member_casual, rideable_type, DATE_FORMAT(started_at, '%M') AS month_name,
	COUNT(*) AS rides_per_month,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual, rideable_type, month, month_name
;

-- Member vs Casual Rides Per Weekday
SELECT member_casual, rideable_type, DATE_FORMAT(started_at, '%W') AS weekday,
	COUNT(*) AS rides_per_weekday,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual, rideable_type, weekday
ORDER BY weekday
;

-- Member vs Casual Rides Per Hour
SELECT member_casual, rideable_type, DATE_FORMAT(started_at, '%H') AS hour_of_day,
	COUNT(*) AS rides_per_hour,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY member_casual, rideable_type, hour_of_day
ORDER BY hour_of_day
;

-- Reference: Top 3 Most Popular Starting Station among riders
SELECT start_station_name,
	COUNT(start_station_name) AS most_popular_start,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
GROUP BY start_station_name
ORDER BY most_popular_start DESC
LIMIT 3
;

-- Top 10 Member Trip Starting Stations
-- Note: Instead of "WHERE member_casual = 'member'" the statement below was used because it contained a non-printable character which gave it a length of 7
SELECT start_station_name,
	COUNT(*) AS most_popular_start,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_start_trip_duration_member
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'member%'
GROUP BY start_station_name
ORDER BY most_popular_start DESC
LIMIT 10
;

-- Top 10 Member Trip Ending Stations
SELECT end_station_name,
	COUNT(*) AS most_popular_end,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_end_trip_duration_member
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'member%'
GROUP BY end_station_name
ORDER BY most_popular_end DESC
LIMIT 10
;

-- Top 10 Casual Trip Starting Stations
SELECT start_station_name,
	COUNT(*) AS most_popular_start,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration_casual
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'casual%'
GROUP BY start_station_name
ORDER BY most_popular_start DESC
LIMIT 10
;


-- Top 10 Casual Trip Ending Stations
SELECT end_station_name,
	COUNT(*) AS most_popular_end,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration_casual
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'casual%'
GROUP BY end_station_name
ORDER BY most_popular_end DESC
LIMIT 10
;


-- The Most Popular Starting Station Hourly for Member Riders
SELECT member_casual, COUNT(*) AS total, start_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
FROM cyclistic.cyclisticclean
WHERE start_station_name = 'Clinton St & Washington Blvd' AND member_casual LIKE 'member%'
GROUP BY member_casual, start_station_name, hour_of_day
ORDER BY hour_of_day
;

-- The Most Popular Ending Station Hourly for Member Riders
SELECT member_casual, COUNT(*) AS total, end_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
FROM cyclistic.cyclisticclean
WHERE end_station_name = 'Clinton St & Washington Blvd' AND member_casual LIKE 'member%'
GROUP BY member_casual, end_station_name, hour_of_day
ORDER BY hour_of_day
;

-- Combine the Results of the Two Earlier Queries and Sum the Total Trips
-- Most Popular Member Station Trips Per Hour
SELECT 
    start_station_name AS member_popular_station,
    hour_of_day,
    SUM(total) AS total_trips
FROM (
    -- The Most Popular Starting Station Hourly for Member Riders
    SELECT COUNT(*) AS total, start_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
    FROM cyclistic.cyclisticclean
    WHERE start_station_name = 'Clinton St & Washington Blvd' AND member_casual LIKE 'member%'
    GROUP BY start_station_name, hour_of_day
    
    UNION ALL
    
    -- The Most Popular Ending Station Hourly for Member Riders
    SELECT COUNT(*) AS total, end_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
    FROM cyclistic.cyclisticclean
    WHERE end_station_name = 'Clinton St & Washington Blvd' AND member_casual LIKE 'member%'
    GROUP BY end_station_name, hour_of_day
) AS combined_member
GROUP BY member_popular_station, hour_of_day
ORDER BY hour_of_day
;

-- Similarly, Most Popular Casual Station Trips Per Hour
SELECT start_station_name AS casual_popular_station,
	hour_of_day,
    SUM(total) AS total_trips
FROM (
	-- The Most Popular Starting Station Hourly for Casual Riders
	SELECT COUNT(*) AS total, start_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
	FROM cyclistic.cyclisticclean
	WHERE start_station_name = 'Streeter Dr & Grand Ave' AND member_casual LIKE 'casual%'
	GROUP BY start_station_name, hour_of_day

	UNION ALL

	-- The Most Popular Ending Station Hourly for Casual Riders
	SELECT COUNT(*) AS total, end_station_name, DATE_FORMAT(started_at, '%H') AS hour_of_day
	FROM cyclistic.cyclisticclean
	WHERE end_station_name = 'Streeter Dr & Grand Ave' AND member_casual LIKE 'casual%'
	GROUP BY end_station_name, hour_of_day
) AS combined_casual
GROUP BY casual_popular_station, hour_of_day
ORDER BY hour_of_day
;

-- Most Popular Casual Routes
SELECT start_station_name, end_station_name,
	COUNT(*) AS most_popular, ROUND(AVG(start_lat), 4) AS start_lat,
      ROUND(AVG(start_lng), 4) AS start_lng, ROUND(AVG(end_lat), 4) AS end_lat,
      ROUND(AVG(end_lng), 4) AS end_lng, 
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'casual%'
GROUP BY start_station_name, end_station_name
ORDER BY most_popular desc
LIMIT 10
;

-- Most Popular Member Routes
SELECT start_station_name, end_station_name,
	COUNT(*) AS most_popular, ROUND(AVG(start_lat), 4) AS start_lat,
      ROUND(AVG(start_lng), 4) AS start_lng, ROUND(AVG(end_lat), 4) AS end_lat,
      ROUND(AVG(end_lng), 4) AS end_lng,
      AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_trip_duration
FROM cyclistic.cyclisticclean
WHERE member_casual LIKE 'member%'
GROUP BY start_station_name, end_station_name
ORDER BY most_popular desc
LIMIT 10
;