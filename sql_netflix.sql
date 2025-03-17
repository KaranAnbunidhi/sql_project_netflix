-- Project Netflix
drop table if exists netflix;
create table netflix 
(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(208),
	casts varchar(1000),
	country varchar(150),
	date_added varchar(50),
	release_year int,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
);

select * from netflix;


-- Business Problems and Solutions
-- Count the Number of Movies vs TV Shows
 
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY type;


--  Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE type='Movie' AND release_year = 2020;

-- Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- Identify the Longest Movie
SELECT * 
	FROM netflix
	WHERE type = 'Movie' AND
	duration =(SELECT MAX(duration) FROM netflix);

-- Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ilike '%Rajiv Chilaka%'

--List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--Count the Number of Content Items in Each Genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

--Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*) AS year,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric*100,2) as avg_content_per_year
	FROM netflix
	WHERE country='India'
	GROUP BY 1
	ORDER BY avg_content_per_year desc
	LIMIT 5;
	
--List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries';

-- Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;