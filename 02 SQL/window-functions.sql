-- D21 - Q1: Write a Query to find the first day of the first job of every employee and return it as 'first_day_job'.
-- Return the columns 'first_name', 'first_day_job'.

SELECT
    e.first_name,
    tt.start_date AS first_day_job
FROM employees AS e
JOIN 
(SELECT
    employee_id,
    start_date,
    ROW_NUMBER() OVER(PARTITION BY employee_id) as row_num
FROM job_history) AS tt
ON e.employee_id = tt.employee_id
WHERE tt.row_num = 1
ORDER BY e.first_name;


-- D21 - Q2: Write a query to calculate row number and save as 'emp_row_no', rank and save as 'emp_rank', and the dense rank of employees as 'emp_dense_rank' based on the salary column in descending order within each department using the employee's table.
-- Return the columns 'full_name' (first_name and last_name separated by space), 'department_id', 'salary', 'emp_row_no', 'emp_rank', and 'emp_dense_rank'.

SELECT
    CONCAT(first_name, " ", last_name) AS full_name,
    department_id,
    salary,
    ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_row_no,
    RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_rank,
    DENSE_RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS emp_dense_rank
FROM employees;

-- D21 - Q3: Show the details of the employees who have the 5th highest salary in each job category.
-- Return the columns 'employee_id', 'first_name', 'job_id'.

SELECT
    employee_id,
    first_name,
    job_id
FROM
(SELECT
    employee_id,
    first_name,
    salary,
    job_id,
    DENSE_RANK() OVER(PARTITION BY job_id ORDER BY salary DESC) AS emp_dense_rank
FROM employees) AS tt
WHERE emp_dense_rank = 5;

-- D21 - Q4: A company wants to divide the employees into teams such that all the members of each team have the same salary. The teams should follow these criteria:
-- Each team should consist of at least two employees.
-- All the employees on a team should have the same salary.
-- All the employees with the same salary should be assigned to the same team.
-- If an employee's salary is unique, we do not assign this employee to any team.
-- A team's ID is assigned based on the rank of the team's salary relative to the other teams' salaries, where the team with the lowest salary has team_id = 1.
-- Note that the salaries for employees not on a team are not included in this ranking.
-- Write a query to get the team_id of each employee that is in a team.
-- Return the result table ordered by team_id in ascending order. In case of a tie, order it by employee_id in ascending order.

SELECT
    employee_id,
    name,
    salary,
    DENSE_RANK() OVER(ORDER BY salary ASC) AS team_id
FROM
(SELECT
    employee_id,
    name,
    salary,
    DENSE_RANK() OVER(PARTITION BY salary ORDER BY salary DESC) AS emp_dense_rank,
    COUNT(*) OVER(PARTITION BY salary ORDER BY salary DESC) AS team_membs
FROM employees) AS tt
WHERE team_membs > 1
ORDER BY salary, employee_id;

-- D21 - Q5: Write a query to find the starting maximum salary of the first job that every employee held and return it as 'first_job_sal'.
-- Return the columns 'first_name', 'last_name', 'first_job_sal' sorted by first_name.
-- Note: Refer to the job_history table to get the job details of the employees.
-- Refer to the employees table for first_name and last_name.
-- Refer to the jobs table for the maximum salary.

SELECT
    e.first_name,
    e.last_name,
    jobs.max_salary AS first_job_sal
FROM employees AS e
JOIN 
(SELECT
    employee_id,
    start_date,
    job_id,
    ROW_NUMBER() OVER(PARTITION BY employee_id) as row_num
FROM job_history) AS tt
ON e.employee_id = tt.employee_id
JOIN jobs
ON tt.job_id = jobs.job_id
WHERE tt.row_num = 1
ORDER BY e.first_name;

-- D21 - Q6: Write a Query to find the first day of the most recent job of every employee and return it as the 'recent_job'.
-- Return the columns 'first_name', and 'recent_job'.
-- Note: Refer to the job_history table to get the job details of the employees.
-- Refer to the employees table for the first_name.
-- Return the output ordered by first_name in ascending order

SELECT
    e.first_name,
    tt.start_date AS recent_job
FROM employees AS e
JOIN
(SELECT
    employee_id,
    start_date,
    ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY start_date DESC) as row_num
FROM job_history) AS tt
ON e.employee_id = tt.employee_id
WHERE tt.row_num = 1
ORDER BY e.first_name;

-- D21 - Q7: Write a query to find the salaries of the employees after applying taxes. Round the salary to the nearest integer.
-- The tax rate is calculated for each company based on the following criteria:
-- 0% If the max salary of any employee in the company is less than $1000.
-- 24% If the max salary of any employee in the company is in the range [1000, 10000] inclusive.
-- 49% If the max salary of any employee in the company is greater than $10000.
-- The salary after taxes = salary - salary x (taxes percentage / 100).
-- Order the output by company_id, and employee_id in ascending order.

SELECT
    company_id,
    employee_id,
    employee_name,
    -- salmax,
    CASE
        WHEN salmax > 10000
            THEN ROUND(salary - (salary * (49 / 100)), 0)
        WHEN salmax > 999
            THEN ROUND(salary - (salary * (24 / 100)), 0)
        ELSE ROUND(salary, 0)
    END AS salary
FROM 
(SELECT
    *,
    MAX(salary) OVER (PARTITION BY company_id ORDER BY salary DESC) AS salmax
FROM salaries) AS tt
ORDER BY company_id, employee_id;

-- D21 - Q8: The winning streak of a player is calculated as the number of consecutive wins uninterrupted by draws or losses. Write a query to count the longest winning streak for each player and save the new column as 'longest_streak'.
-- Return the player_id and longest_streak.
-- Order the output by player_id in ascending order.

SELECT
    player_id,
    MAX(streak) AS longest_streak
FROM
(SELECT 
    player_id,
    IF(
        LOWER(result) LIKE "win",
        ROW_NUMBER() OVER(PARTITION BY player_id, result, masterseq - seq ORDER BY match_day ASC),
        0
    ) AS streak
FROM
(SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY match_day ASC) AS masterseq,
    ROW_NUMBER() OVER(PARTITION BY player_id, result ORDER BY match_day ASC) AS seq
FROM matches) AS tt) AS tt1
GROUP BY player_id
ORDER BY player_id;

-- D22 - Q3: Each row in the table contains the visit_date and visit_id to the mall with the number of people during the visit. No two rows will have the same visit_date
-- Write a query to display the records with three or more rows with consecutive id's, and the number of people is greater than or equal to 100 for each.
-- Return the id, visit_date, and people.
-- Order the output by visit_date in ascending order

WITH
Q1_FILTERED_COLLECTION AS (
    SELECT * FROM mall WHERE people >= 100
),
Q2_RAISE_FLAGS AS (
    SELECT *, ROW_NUMBER() OVER(ORDER BY Q1.id) AS RN, id - ROW_NUMBER() OVER(ORDER BY Q1.id) AS DIFF
    FROM Q1_FILTERED_COLLECTION AS Q1
),
Q3_COUNT_CONSECUTIVES AS (
    SELECT *, COUNT(*) OVER(PARTITION BY Q2.DIFF) AS NUM_CONSEC
    FROM Q2_RAISE_FLAGS AS Q2
),
Q4_FILTER_NONCONSECUTIVES AS (
    SELECT id, visit_date, people
    FROM Q3_COUNT_CONSECUTIVES AS Q3
    WHERE Q3.NUM_CONSEC >= 3
)
SELECT * FROM Q4_FILTER_NONCONSECUTIVES;

-- D22 - Q4: Find the quartile of each record based on the salary of the employee save as 'Quartile'.
-- Return the columns 'employee_id', 'first_name', 'department_id', 'job_id', 'salary', 'Quartile'.

SELECT
    employee_id,
    first_name,
    department_id,
    job_id,
    salary,
    NTILE(4) OVER(ORDER BY salary) AS Quartile
FROM employees;

