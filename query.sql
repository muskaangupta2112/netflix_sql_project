--netflix project
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150) ,
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(150),
description VARCHAR(250)
);


SELECT * FROM netflix;

--Total number of records? 8807
SELECT COUNT(*) as total_content FROM netflix;


--Distinct values in type? Movie, TV show
SELECT DISTINCT type FROM netflix;


--1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) as total_content FROM netflix group by type;


--2. Find the most common rating for movies and TV shows
SELECT type, rating
from(
SELECT rating, 
type, 
COUNT(*),
RANK() OVER(PARTITION BY type order by count(*) desc) as ranking
from netflix
group by rating, type) as t1
where ranking=1;


--3. List all movies released in a specific year (e.g., 2020)
SELECT * from netflix
where release_year = 2020 and type= 'Movie';

--4. Find the top 5 countries with the most content on Netflix
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as country_new ,
COUNT(*) from netflix
GROUP BY country_new
order by count(*) DESC
LIMIT 5;



--5. Identify the longest movie
SELECT title, duration from netflix
where type='Movie'
order by cast(split_part(duration,'',1)as integer) desc;

--6. Find content added in the last 5 years
SELECT *, TO_DATE(date_added, 'Month DD, YYYY') FROM netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *   
FROM netflix
where director ILIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons
SELECT * from
(SELECT *,  split_part(duration,' ',1) as season_no   
FROM netflix
where type='TV Show') as subq where season_no>'5';

--9. Count the number of content items in each genre
SELECT count(*), TRIM(UNNEST(STRING_TO_ARRAY(listed_in,',')))  
FROM netflix
group by TRIM(UNNEST(STRING_TO_ARRAY(listed_in,',')));

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
COUNT(*)
FROM netflix
where country ilike 'India'
group by year
order by 2 desc
limit 5;



--11. List all movies that are documentaries
select * from netflix
where listed_in ilike '%documentaries%'
and type= 'Movie';

--12. Find all content without a director
select * from netflix
where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where casts ilike '%Salman Khan%' and release_year > extract(YEAR from current_date) - 10;


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select casts_new, count(*)
from (select *, trim(unnest(string_to_array(casts,','))) as casts_new 
from netflix
where country ilike '%India%')
group by casts_new
order by 2 desc
limit 10;
;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


with new_table as(
select *,
case 
when description ilike '%kill%' or description ilike '%violence%'
then 'Bad'
else 'Good'
END as category
from netflix
)

select category, count(*) from new_table group by 1;