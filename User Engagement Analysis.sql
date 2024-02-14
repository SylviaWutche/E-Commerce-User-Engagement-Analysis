-- User Retention and Conversion Optimization;

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
Consider whether certain seasons or periods lead to increased revisits.
*/



SELECT DISTINCT
    is_repeat_session
FROM
    website_sessions;

-- Finding out how many unique users repeated a session

SELECT 
    is_repeat_session,
    COUNT(DISTINCT user_id) AS Number_of_users
FROM
    website_sessions
GROUP BY 1;

-- the average number of repeat session per user
SELECT 
    AVG(Repeat_sessions) AS avg_repeat_sessions_per_user
FROM
    (SELECT 
        user_id,
            COUNT(DISTINCT is_repeat_session) AS Repeat_sessions
    FROM
        website_sessions
    GROUP BY user_id) AS User_Repeat_Sessions;

-- Analyze the device_type and utm_source to understand if specific devices or marketing sources contribute to higher repeat sessions.

SELECT 
    *
FROM
    (SELECT 
        is_repeat_session,
            COUNT(DISTINCT user_id) AS Number_of_users
    FROM
        website_sessions
    GROUP BY 1) Repeat_sessions
WHERE
    is_repeat_session > 0;

-- Joining the number of users who came back for another session to the website sessions table to find out what utm_source and device type rank high

SELECT 
    device_type, utm_source, COUNT(user_id) AS Number_of_users
FROM
    (SELECT 
        *
    FROM
        (SELECT 
        is_repeat_session,
            COUNT(DISTINCT user_id) AS Number_of_users
    FROM
        website_sessions
    GROUP BY 1) Repeat_sessions
    WHERE
        is_repeat_session > 0) Repeat_users
        JOIN
    website_sessions wb ON Repeat_users.is_repeat_session = wb.is_repeat_session
GROUP BY device_type , utm_source
ORDER BY Number_of_users DESC;


--  Explore the specific marketing campaigns that brought users back.

SELECT
    COALESCE(utm_campaign,'No Campaign') AS type_of_campaign,
    COUNT(DISTINCT user_id) AS num_of_users,
    AVG(repeat_sessions) AS avg_repeat_sessions,
    SUM(total_pageviews) AS total_pageviews,
    SUM(items_purchased) AS total_items_purchased,
    SUM(conversion) / COUNT(DISTINCT user_id) AS conversion_rate
FROM (
    SELECT
        utm_campaign,
        ws.user_id,
        COUNT(*) AS repeat_sessions,
        SUM(items_purchased) AS items_purchased,
        COUNT(DISTINCT CASE WHEN items_purchased > 0 THEN ws.website_session_id END) AS conversion,
        SUM(CASE WHEN is_repeat_session = 1 THEN 1 ELSE 0 END) AS total_repeat_sessions,
        SUM(CASE WHEN is_repeat_session = 1 THEN items_purchased ELSE 0 END) AS total_repeat_purchases,
        COUNT(DISTINCT website_pageview_id) AS total_pageviews
    FROM
        website_sessions ws
    LEFT JOIN
        orders o ON ws.website_session_id = o.website_session_id
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        website_pageviews wp ON ws.website_session_id = wp.website_session_id
    WHERE
        is_repeat_session = 1
    GROUP BY
        utm_campaign, user_id
) AS subquery
GROUP BY
    utm_campaign
ORDER BY
    num_users DESC;

-- Analyze the specific content or ad variations that influenced revisit behavior.

SELECT 
    *
FROM
    (SELECT 
        user_id, website_session_id, is_repeat_session
    FROM
        website_sessions) Repeat_sessions
HAVING is_repeat_session > 0;

-- STEP 2: Analyze the specific content or ad variations that influenced revisit behavior.

SELECT 
    COALESCE(utm_content, 'No AD') AS 'Type of Ad',
    COUNT(DISTINCT user_id) AS Number_of_users
FROM
    (SELECT 
        *
    FROM
        (SELECT 
        is_repeat_session,
            COUNT(DISTINCT user_id) AS Number_of_users
    FROM
        website_sessions
    GROUP BY 1) Repeat_sessions
    WHERE
        is_repeat_session > 0) Repeat_users
        JOIN
    website_sessions wb ON Repeat_users.is_repeat_session = wb.is_repeat_session
GROUP BY utm_content
ORDER BY Number_of_users DESC;


-- Understand if users coming from specific referral sources tend to revisit more often

SELECT 
    *
FROM
    (SELECT 
        user_id, website_session_id, is_repeat_session
    FROM
        website_sessions) Repeat_sessions
HAVING is_repeat_session > 0;

-- STEP 2: Understand if users coming from specific referral sources tend to revisit more often

SELECT 
    COALESCE(http_referer, 'None') AS Referer,
    COUNT(DISTINCT user_id) AS Number_of_users
FROM
    (SELECT 
        *
    FROM
        (SELECT 
        is_repeat_session,
            COUNT(DISTINCT user_id) AS Number_of_users
    FROM
        website_sessions
    GROUP BY 1) Repeat_sessions
    WHERE
        is_repeat_session > 0) Repeat_users
        JOIN
    website_sessions wb ON Repeat_users.is_repeat_session = wb.is_repeat_session
GROUP BY http_referer
ORDER BY Number_of_users DESC;


-- Evaluate whether re-visit patterns vary based on the day of the week or time of day.- 

SELECT 
    DAYNAME(created_at) AS day_of_week,
    COUNT(DISTINCT user_id) AS num_users
FROM
    website_sessions
WHERE
    is_repeat_session > 0
GROUP BY 1
ORDER BY 2 DESC;
    
-- Analyzing Revisit Patterns by Hour of Day

SELECT 
    HOUR(created_at) AS hour_of_day,
    COUNT(DISTINCT user_id) AS num_users
FROM
    website_sessions
WHERE
    is_repeat_session > 0
GROUP BY hour_of_day
ORDER BY 2 DESC;
 
-- Analyzing Seasonal Revisit Patterns

SELECT 
    MONTHNAME(created_at) AS month,
    COUNT(DISTINCT user_id) AS num_users
FROM
    website_sessions
WHERE
    is_repeat_session > 0
GROUP BY 1
ORDER BY 2 DESC;
