/* 
Problem 1: Identifying Factors Affecting User Retention
Background: The e-commerce company is experiencing a decline in user retention rates, and they want to understand the factors influencing user retention.
Objective: Identify patterns and variables associated with users who return to the website for multiple sessions 

User Engagement Analysis:
Calculate the average number of repeat sessions per user.
Analyze the device_type and utm_source to understand if specific devices or marketing sources contribute to higher repeat sessions.
Explore the specific marketing campaigns that brought users back.
Analyze the specific content or ads that influenced revisit behavior.
Understand if users coming from specific referral sources tend to revisit more often.
Evaluate whether re-visit patterns vary based on the day of the week or time of day.
Consider whether certain seasons or periods lead to increased revisits.*/

-- Analyzing repeat visitors
-- 
CREATE TEMPORARY TABLE repeat_sessions 
SELECT new_sessions.user_id,
		new_sessions.website_session_id AS new_session_id,
        website_sessions.website_session_id AS repeat_session_id
FROM
(SELECT User_id, website_session_id
FROM website_sessions
WHERE is_repeat_session = 0) AS new_sessions
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND website_sessions.is_repeat_session = 1
    AND website_sessions.website_session_id >  new_sessions.website_session_id;
    
SELECT * 
FROM repeat_sessions;


SELECT ROUND(AVG(repeat_sessions),2) AS Average_repeat_sessions
FROM
(SELECT user_id,
COUNT(DISTINCT new_session_id) new_sessions,
COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM repeat_sessions
GROUP BY 1) AS users;

-- Analyze the device_type and utm_source to understand if specific devices or marketing sources contribute to higher repeat sessions.

CREATE TEMPORARY TABLE repeat_sessions 
SELECT new_sessions.user_id,
		new_sessions.website_session_id AS new_session_id,
        website_sessions.website_session_id AS repeat_session_id
FROM
(SELECT User_id, website_session_id
FROM website_sessions
WHERE is_repeat_session = 0) AS new_sessions
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND website_sessions.is_repeat_session = 1
    AND website_sessions.website_session_id >  new_sessions.website_session_id;
    
SELECT * FROM repeat_sessions;
    
SELECT COALESCE(device_type, 'None') AS 'Device Type', COALESCE(utm_source,'None') AS 'Refferal Source', COUNT(repeat_session_id) AS 'Number of repeats'
FROM repeat_sessions
INNER JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 
device_type,
    utm_source
ORDER BY 3 DESC;

-- Explore the specific marketing campaigns that brought users back.

CREATE TEMPORARY TABLE repeat_sessions 
SELECT new_sessions.user_id,
		new_sessions.website_session_id AS new_session_id,
        website_sessions.website_session_id AS repeat_session_id
FROM
(SELECT User_id, website_session_id
FROM website_sessions
WHERE is_repeat_session = 0) AS new_sessions
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND website_sessions.is_repeat_session = 1
    AND website_sessions.website_session_id >  new_sessions.website_session_id;
    
SELECT * FROM repeat_sessions;
        
SELECT COALESCE(utm_campaign,'None') AS 'Marketing Campaign', COUNT(repeat_session_id) AS 'Number of repeat sessions'
FROM repeat_sessions
RIGHT JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 1
ORDER BY 2 DESC;

-- Analyze the specific content or ads that influenced revisit behavior.


CREATE TEMPORARY TABLE repeat_sessions 
SELECT new_sessions.user_id,
		new_sessions.website_session_id AS new_session_id,
        website_sessions.website_session_id AS repeat_session_id
FROM
(SELECT User_id, website_session_id
FROM website_sessions
WHERE is_repeat_session = 0) AS new_sessions
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND website_sessions.is_repeat_session = 1
    AND website_sessions.website_session_id >  new_sessions.website_session_id;
    
SELECT COALESCE(utm_content,'None') AS ADs, COUNT(repeat_session_id) AS 'Number of repeat sessions'
FROM repeat_sessions
RIGHT JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 1
ORDER BY 2 DESC;

-- Understand if users coming from specific referral sources tend to revisit more often

SELECT COALESCE(http_referer, 'None') 'Refferal Source', COUNT(repeat_session_id) AS 'Number of repeat sessions'
FROM repeat_sessions
RIGHT JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 1
ORDER BY 2 DESC;


-- Evaluate whether re-visit patterns vary based on the day of the week or time of day

SELECT DAYNAME(created_at) AS Day, COUNT(repeat_session_id) AS 'Number of repeat sessions'
FROM repeat_sessions
RIGHT JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 1
ORDER BY 2 DESC;

-- Consider whether certain seasons or periods lead to increased revisits.

SELECT MONTHNAME(created_at) AS Month, COUNT(repeat_session_id) AS 'Number of repeat sessions'
FROM repeat_sessions
RIGHT JOIN website_sessions
ON repeat_sessions.repeat_session_id = website_sessions.website_session_id
GROUP BY 1
ORDER BY 2 DESC;
