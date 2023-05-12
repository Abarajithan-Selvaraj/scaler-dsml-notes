-- D15 - Q1: Find all the employees whose first name ends with the letter 'n'.
-- Return the columns 'employee_id', 'full_name' (first name and last name separated by space), and 'phone_number'.

SELECT
   employee_id,
   CONCAT(first_name, " ", last_name) as full_name,
   phone_number
FROM
   employees
WHERE
   LOWER(first_name) LIKE "%n";

-- D15 - Q2: Display all the details of the employees who did not work at any job in the past.
-- Return all the columns from the employee's table.
-- NOTE: To get the details of the employee's previous jobs refer to the job_history table.
-- Use the tables employees and job_history.
-- an employee is present in job_history table if has worked before.

SELECT
    *
FROM
    employees
WHERE
    employee_id NOT IN (SELECT employee_id FROM job_history);

-- D15 - Q3: Find the details of employees who are not working in any department.
-- Return the columns 'employee_id','first_name', 'last_name','job_id', and 'manager_id'.
-- NOTE: The missing value in the department_id column in the employees table refers to not working in any department.

SELECT
    employee_id,
    first_name,
    last_name,
    job_id,
    manager_id
FROM 
    employees
WHERE
    department_id IS NULL;


-- D15 - Q4: Find the employee's details who work in the same job as the employee with employee_id as 107.
-- Return the columns (first name, last name separated by space) as 'full_name', 'salary', 'department_id', 'job_id'.

SELECT
    CONCAT(first_name, " ", last_name) AS full_name,
    salary,
    department_id,
    job_id
FROM
    employees
WHERE
    job_id = (SELECT job_id FROM employees WHERE employee_id = 107);

-- D15 - Q5: Calculate the weighted average rating from the columns vote_count and vote_average and save the column as 'Weighted_avg_rating'.
-- Display the top 10 movies and their rating up to two decimals based on the new column created.
-- Return the columns original_title, Weighted_avg_rating
-- Return the output ordered by Weighted_avg_rating in descending order and original_title in ascending order.
-- Note: Use the given formula to calculate a weighted average rating (v/(v+m) * R) + (m/(m+v) * C )
-- Where,
-- v is the number of votes for the movie vote_count;
-- m is the minimum votes required, take m as 104.0;
-- R is the average rating of the movie vote_average;
-- C is the mean vote across the whole report take c as 5.97.
-- Return the columns 'original_title' , 'Weighted_avg_rating'

SELECT
    original_title,
    ROUND((vote_count / (vote_count + 104.0) * vote_average) + (104.0 / (vote_count + 104.0) * 5.97), 2) AS Weighted_avg_rating
FROM
    movies
ORDER BY
    Weighted_avg_rating DESC
LIMIT 10;

-- D15 - Q6: Write a query to calculate the salary of all employees after an increment of 20%. Save the newly calculated salary column as 'New_salary'.
-- Note: Return the columns emp_id, name, salary, and 'New_salary'.
-- Order the output by the emp_id in ascending order.

-- Steps to calculate the salary increment:
-- Multiply the current salary by the percentage of the increment.
-- Divide the result by 100.
-- Then add the result to the current salary.
-- Round off the 'New_salary'.

SELECT
    emp_id,
    name,
    salary,
    ROUND(salary * 1.20, 0) AS New_salary
FROM
    employees
ORDER BY
    emp_id;

-- D15 - Q7: Show the titles of the movies that are released (i.e, release_year) after 2014 and have an average vote rating (i.e,vote_average) greater than 7.
-- Return the column 'original_title'

SELECT
    original_title
FROM
    movies
WHERE
    release_year > 2014
    AND vote_average > 7;

-- D15 - Q8: List down all the movies along with their details that have keywords like 'sport' or 'sequel' or 'suspense'.
-- Note: Return the columns 'original_title', 'director', 'genres', 'cast', 'budget', 'revenue', 'runtime', and 'vote_average'.

SELECT
    original_title,
    director,
    genres,
    cast,
    budget,
    revenue,
    runtime,
    vote_average
FROM
    movies
WHERE
    LOWER(keywords) LIKE '%sport%'
    OR LOWER(keywords) LIKE '%sequel%'
    OR LOWER(keywords) LIKE '%suspense%';

-- D15 - Q9: Display the details of the movies which belong to the 'Horror' genre in descending order of popularity.
-- Return the columns 'original_title', 'popularity'.

SELECT
    original_title,
    popularity
FROM
    movies
WHERE
    LOWER(genres) LIKE 'horror'
ORDER BY
    popularity DESC;


-- D15 - Q10: Find the details of the movies that are released between the years 2012-2015 i.e, (Including 2012 and 2015).
-- Return the columns 'original_title', 'genres', 'vote_average', and 'revenue'.

SELECT
    original_title,
    genres,
    vote_average,
    revenue
FROM
    movies
WHERE
    release_year BETWEEN 2012 AND 2015;


-- D15 - Q11: Write a SQL query to report the movies with an odd-numbered ID and a description that is not "boring".
-- Note: Return the result table ordered by rating in descending order.

SELECT
    *
FROM
    cinema
WHERE
    MOD(id, 2) = 1
    AND NOT LOWER(description) = 'boring'
ORDER BY
    rating DESC;


