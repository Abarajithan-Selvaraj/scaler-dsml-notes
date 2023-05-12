-- D12 - Q1: Find the movie titles, taglines, and directors for the top 5 popular movies.
-- Return the columns 'original_title', 'tagline', and 'director'.

SELECT
   original_title,
   tagline,
   director
FROM
   movies
ORDER BY
   popularity desc
LIMIT
   5;

-- D12 - Q2: Write a query to find all the details of the movie that has the third-highest revenue.
-- Note: Return all the columns.
-- No two movies have the same revenue. (i.e, all the values in the revenue column are unique).

SELECT
    *
FROM
    movies
ORDER BY
    revenue desc
LIMIT
    1
OFFSET
    2;

