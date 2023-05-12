-- D22 - Q1: Display the year from the hire_date as 'Year' and count the number of employees who joined in that year and save it as 'Employees_count'.
-- Order the output by the Employees_count in descending order. Use the employee's table.
-- Return the columns 'Year', and 'Employees_count'.
-- Consider only the current jobs.

SELECT *
FROM
(SELECT
    YEAR(hire_date) AS Year,
    COUNT(employee_id) AS Employees_count
FROM employees
GROUP BY YEAR(hire_date)) AS tt
ORDER BY tt.Employees_count DESC;


-- D22 - Q2: Extract the day, month, and year from the hire_date of the employees and save the columns as 'Day', 'Month', and 'Year'. Display the extracted columns and the details of those employees who were hired in the year 2000 and in January month and also salary is greater than 5000.
-- Return the columns 'employee_id', 'first_name', 'last_name', 'salary', 'hire_date', 'Day', 'Month', 'Year'.

SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    hire_date,
    DAY(hire_date) AS Day,
    MONTH(hire_date) AS Month,
    YEAR(hire_date) AS Year
FROM employees
WHERE YEAR(hire_date) = 2000
    AND MONTH(hire_date) = 1
    AND salary > 5000;

-- D23 - Q1: Display the employee's details and calculate the total no.of years the employees have been working in the company till 8th June 2022 and save it as 'Total_years'. Return the details of those employees who have been working for atleast 28 years.
-- Return the columns 'employee_id', 'first_name', 'last_name', 'Total_years'.
-- Note: To get the "Total_years" calculate the date difference and divide the difference by 365.

SELECT
   employee_id,
   first_name,
   last_name,
   -- hire_date
   DATEDIFF("2022-06-08", hire_date) / 365 AS Total_years
FROM employees
WHERE (DATEDIFF("2022-06-08", hire_date) / 365) >= 28
ORDER BY employee_id;

-- D23 - Q2: Display the manager details and calculate the total number of years the managers have been working in the company till 8th June 2022 and save it as 'Experience'.
-- Return the details of those managers whose experience is more than 25 years.
-- Return the columns 'first_name', 'last_name', 'employee_id', 'salary', 'department_name', 'Experience'.
-- Note: To calculate the 'Experience' of the managers find the date difference and divide the difference by 365.
-- The manager_id in the employees table is the employee_id of the manager.
-- Return the employee_id of the manager along with other columns and order the output by employee_id.

WITH

FETCH_MANAGERS AS (
    SELECT m.*
    FROM employees AS e
    LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
),

FETCH_DEPT AS (
    SELECT DISTINCT e.first_name, e.last_name, e.employee_id, e.salary, d.department_name, e.hire_date
    FROM FETCH_MANAGERS AS e 
    LEFT JOIN departments AS d
    ON d.department_id = e.department_id
),

CALC_EXP AS (
    SELECT first_name, last_name, employee_id, salary, department_name, DATEDIFF("2022-06-08", hire_date) / 365 AS Experience
    FROM FETCH_DEPT
    WHERE (DATEDIFF("2022-06-08", hire_date) / 365) > 25
    ORDER BY employee_id
)

SELECT * FROM CALC_EXP;

-- D23 - Q3: Write a query to calculate the total number of comments received for each user in the 30 or less days before 2020-02-10 and save the column as 'comments_count'.
-- Don't return the users who haven't received any comment in the defined time period.
-- Return the columns user_id and comments_count.
-- Order the output by user_id in ascending order.

SELECT
    user_id,
    SUM(number_of_comments) AS comments_count
FROM fb_comments
WHERE DATEDIFF("2020-02-10", created_at) BETWEEN 0 AND 30
GROUP BY user_id
ORDER BY user_id;

-- D23 - Q4: Display the details of those employees who were hired between the given date '1998-01-01' and three months after from the given date.
-- Return the columns 'employee_id', 'first_name', 'last_name', 'salary', 'department_name', 'hire_date', 'city'.
-- Use the tables employees, departments, and locations.
-- Return the result table ordered by employee_id.

WITH

FILTER_EMPLOYEES AS (
    SELECT *
    FROM employees
    WHERE hire_date BETWEEN "1998-01-01" AND DATE_ADD("1998-01-01", INTERVAL 3 MONTH)
),

FETCH_DETAILS AS (
    SELECT e.employee_id, e.first_name, e.last_name, e.salary, d.department_name, e.hire_date, l.city
    FROM FILTER_EMPLOYEES AS e
    LEFT JOIN departments AS d 
    ON e.department_id = d.department_id
    LEFT JOIN locations AS l 
    ON d.location_id = l.location_id
    ORDER BY e.employee_id
)

SELECT * FROM FETCH_DETAILS;

-- D23 - Q5: Display the details of those employees who were hired between the given date '1998-01-01' and six months before from the given date and also whose salary is highest in each department.
-- Return the columns 'employee_id', 'first_name', 'last_name', 'salary', 'hire_date', 'department_id'.

WITH

FILTER_EMPLOYEES AS (
    SELECT *
    FROM employees
    WHERE hire_date BETWEEN DATE_SUB("1998-01-01", INTERVAL 6 MONTH) AND "1998-01-01"
),

RANK_EMPLOYEES AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS sal_rank
    FROM FILTER_EMPLOYEES
)

SELECT employee_id, first_name, last_name, salary, hire_date, department_id
FROM RANK_EMPLOYEES
WHERE sal_rank = 1;

-- D23 - Q6: Display the details of the employees who had worked less than a year.
-- Return the columns 'employee_id', 'full_name'(first name and last name separated by space), and 'job_title'.
-- Note: To calculate the number of years employees worked take the difference between the end_date and the start_date and divide the result by 365.
-- For simplicity not considering the leap year.
-- Referring only to the past jobs of the employees.
-- Order the output by employee_id, and job_title.

WITH

FETCH_JOB_DETAILS AS (
    SELECT e.employee_id, CONCAT(e.first_name, " ", e.last_name) AS full_name, j.job_title, jh.start_date, jh.end_date
    FROM employees AS e
    LEFT JOIN job_history AS jh 
    ON e.employee_id = jh.employee_id
    LEFT JOIN jobs AS j 
    ON jh.job_id =  j.job_id
),

FILTER_EMPLOYEES AS (
    SELECT employee_id, full_name, job_title
    FROM FETCH_JOB_DETAILS
    WHERE DATEDIFF(end_date, start_date) / 365 < 1
)

SELECT * FROM FILTER_EMPLOYEES;

-- D23 - Q7: Calculate the net salary for the employees and save the column as 'Net_salary' and display the details of those employees whose net salary is greater than 15000.
-- Note: To calculate the 'Net_salary' = salary + salary *(comission_pct).
-- If the column 'comission_pct' consists of null values replace them with zeros using the ifnull() function.
-- For example: ifnull(comission_pct,0).
-- Return the columns 'employee_id', 'first_name', 'last_name', 'salary', and 'Net_Salary'.

WITH

CALC_NET_SALARY AS (
    SELECT employee_id, first_name, last_name, salary, salary + salary * IFNULL(commission_pct, 0) AS Net_Salary
    FROM employees
)

SELECT * FROM CALC_NET_SALARY
WHERE Net_Salary > 15000;

-- D23 - Q8: Write a query to reorder the entries of the genders table so that "female," "other," and "male" appear in that order in alternating rows.
-- The table should be rearranged such that the IDs of each gender are sorted in ascending order.
-- Return the column's user_id and gender

WITH

PUT_ROWNUMS AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY gender ORDER BY gender, user_id) AS rn,
    CASE
        WHEN LOWER(gender) LIKE "female"
        THEN 1
        WHEN LOWER(gender) LIKE "other"
        THEN 2
        ELSE 3
    END AS tag
    FROM genders
),

SORT_NOW AS (
    SELECT user_id, gender
    FROM PUT_ROWNUMS
    ORDER BY rn, tag 
)

SELECT * FROM SORT_NOW;

-- D23 - Q9: Write a query to rearrange the Products table so each row has (product_id, store, price). If a product is unavailable in a store, do not include a row with that product_id and store combination in the result table.
-- Order the output by product_id, and store in ascending order.

--  # MAKE COLS TO ROWS #  --

WITH

COLLECT_STORE1 AS (
    SELECT product_id, "store1" AS store,  store1 AS price
    FROM Products
),

COLLECT_STORE2 AS (
    SELECT product_id, "store2" AS store, store2 AS price
    FROM Products
),

COLLECT_STORE3 AS (
    SELECT product_id, "store3" AS store, store3 AS price
    FROM Products
),

UNITE_EM AS (
    SELECT * FROM COLLECT_STORE1
    UNION ALL
    SELECT * FROM COLLECT_STORE2
    UNION ALL
    SELECT * FROM COLLECT_STORE3
)

SELECT * FROM UNITE_EM
WHERE NOT price IS NULL
ORDER BY product_id, store;

-- D23 - Q10: Given the data about the purchases made by different users, write a query to find the total number of users and the total amount spent for each date who have purchased using the mobile-only, the desktop-only, and both mobile and desktop together.
-- Order the output by spend_date, platform in ascending order.

WITH

FIND_BOTH AS (
    SELECT *
    FROM (
        SELECT user_id, spend_date, "both" AS platform,
            ROW_NUMBER() OVER(PARTITION BY user_id, spend_date) AS rn,
            COUNT(*) OVER(PARTITION BY user_id, spend_date) AS cnt,
            SUM(amount) OVER(PARTITION BY user_id, spend_date) AS total_amount
        FROM Spending
    ) AS temp
    WHERE cnt = 2
    AND rn = 1
),

FIND_ONLY AS (
    SELECT *
    FROM (
        SELECT user_id, spend_date, platform,
            ROW_NUMBER() OVER(PARTITION BY user_id, spend_date) AS rn,
            COUNT(*) OVER(PARTITION BY user_id, spend_date) AS cnt,
            SUM(amount) OVER(PARTITION BY user_id, spend_date) AS total_amount
        FROM Spending
    ) AS temp
    WHERE cnt = 1
),

UNITE_THEM AS (
    -- SELECT * FROM CONDITION_BOTH
    SELECT * FROM FIND_BOTH
    UNION ALL
    SELECT * FROM FIND_ONLY
),

SUMMARY AS (
    SELECT DISTINCT
        spend_date,
        platform,
        SUM(total_amount) OVER(PARTITION BY spend_date, platform) AS total_amount, 
        SUM(rn) OVER(PARTITION BY spend_date, platform) AS total_users
    FROM UNITE_THEM AS a
),

CROSS_LIST AS (
    SELECT DISTINCT a.spend_date, b.platform FROM SUMMARY AS a
    CROSS JOIN (SELECT DISTINCT platform FROM SUMMARY) AS b
    ORDER BY spend_date, platform
),

CONDITION_SUMMARY AS (
    SELECT
        b.spend_date,
        b.platform,
        IF(a.total_amount IS NULL, 0, a.total_amount) AS total_amount,
        IF(a.total_users IS NULL, 0, a.total_users) AS total_users
    FROM SUMMARY AS a
    RIGHT JOIN CROSS_LIST AS b
    ON a.spend_date = b.spend_date
    AND a.platform = b.platform
    ORDER BY spend_date, platform
)

SELECT * FROM CONDITION_SUMMARY;

-- D23 - Q11: Write a query to calculate the total sales amount of each item for each year, with the corresponding product_id, product_name, and report_year.
-- Order the output by product_id and report_year in ascending order.

WITH

RECURSIVE years AS (
  SELECT product_id, period_start, period_end, EXTRACT(YEAR FROM period_start) AS year, average_daily_sales
  FROM sales
  UNION ALL
  SELECT years.product_id, years.period_start, years.period_end, years.year + 1 as year, years.average_daily_sales
  FROM years
  JOIN sales
  ON years.product_id = sales.product_id
  WHERE years.year < EXTRACT(YEAR FROM sales.period_end)
),

DEFINE_YEARS AS (
    SELECT *,
        DATE_FORMAT(MAKEDATE(year, 1), '%Y-%m-%d') AS first_day,
        DATE_FORMAT(DATE_ADD(MAKEDATE(year, 1), INTERVAL 1 YEAR) - INTERVAL 1 DAY, '%Y-%m-%d') AS last_day
    FROM years
),

FIND_DATE_RANGES AS (
    SELECT *,
        IF(DATEDIFF(period_start, first_day) > 0, period_start, first_day) AS start_date,
        IF(DATEDIFF(period_end, last_day) > 0, last_day, period_end) AS end_date
    FROM DEFINE_YEARS
),

CALC_AMT AS (
    SELECT 
        a.product_id,
        b.product_name,
        a.year AS report_year,
        ROUND((DATEDIFF(a.end_date, a.start_date) + 1) * a.average_daily_sales, 0) AS total_amount
    FROM FIND_DATE_RANGES AS a
    LEFT JOIN products AS b
    ON a.product_id = b.product_id
)

SELECT * FROM CALC_AMT
ORDER BY product_id, report_year;

-- D23 - Q12: Write a query to find the most frequently ordered product(s) for each customer.
-- The output should contain the product_id and product_name for each customer_id who ordered at least one order.
-- Order the output by customer_id and product_id in ascending order.

WITH
COUNT_PURCHASES AS (
    SELECT customer_id, product_id, COUNT(product_id) AS cnt FROM orders
    GROUP BY customer_id, product_id
    ORDER BY customer_id, product_id
),
 
TAG_MAX AS (
    SELECT *, MAX(cnt) OVER(PARTITION BY customer_id) AS tag
    FROM COUNT_PURCHASES
),

FILTER_TBL AS (
    SELECT * FROM TAG_MAX
    WHERE tag = cnt
),

FETCH_PRD_INFO AS (
    SELECT a.customer_id, a.product_id, b.product_name
    FROM FILTER_TBL AS a
    LEFT JOIN products AS b
    ON a.product_id = b.product_id
    ORDER BY customer_id, product_id
)

SELECT * FROM FETCH_PRD_INFO;

-- D23 - Q13: Write a query to find the number of grand slam tournaments won by each player and save the column as 'grand_slams_count'. Do not include the players who did not win any tournament.
-- Order the output by player_id in ascending order.

WITH

winners_list AS (
    SELECT year, Wimbledon AS winner
    FROM championships
    UNION ALL
    SELECT year, Fr_open AS winner
    FROM championships
    UNION ALL
    SELECT year, US_open AS winner
    FROM championships
    UNION ALL
    SELECT year, Au_open AS winner
    FROM championships
),

winnings AS (
    SELECT winner, count(*) AS grand_slams_count
    FROM winners_list
    GROUP BY winner
    ORDER BY winner
)

SELECT player_id, player_name, grand_slams_count
FROM players
LEFT JOIN winnings
ON winner = player_id
WHERE NOT grand_slams_count IS NULL;

-- D23 - Q14: Create a view as 'emp_view' that has the details i.e, employee_id, first_name, last_name, salary, department_id, department_name, location_id, street_address, and city.
-- Display the details from the view of those employees who work in departments that are located in Seattle or Southlake.
-- Return the view with columns 'employee_id', 'first_name', 'last_name', 'salary', 'department_id', 'department_name', 'location_id', 'street_address', 'city'.

WITH
emp_view AS (
    SELECT
        a.employee_id, a.first_name, a.last_name, a.salary, a.department_id, c.department_name, c.location_id, d.street_address, d.city
    FROM employees AS a
    LEFT JOIN departments AS c
    ON a.department_id = c.department_id
    LEFT JOIN locations AS d
    ON c.location_id = d.location_id
),

loc_info AS (
    SELECT DISTINCT * FROM emp_view
    WHERE UPPER(city) LIKE "SEATTLE"
    OR UPPER(city) LIKE "SOUTHLAKE"

)

SELECT * FROM loc_info;

-- D23 - Q15: Create a view as 'Manager_details' that has manager details i.e, employee id, manager's name(first name and last name separated by space) as 'Manager', salary, phone_number, department_id, department_name, street_address, city, country_name.
-- Display the details of the Top 5 managers with the highest salary from the view 'Manager_details'.
-- Return the columns employee_id, Manager, salary, and department_name from the view Manager_details.
-- The result table must be ordered by salary column in descending manner.
-- No duplication of manager details is expected in the output.

WITH
Manager_details AS (
    SELECT a.employee_id, CONCAT(a.first_name, " ", a.last_name) AS MANAGER, a.salary, a.phone_number, a.department_id, c.department_name, d.street_address, d.city, e.country_name
    FROM employees AS a
    LEFT JOIN employees AS b
    ON a.manager_id = b.employee_id
    LEFT JOIN departments AS c
    ON a.department_id = c.department_id
    LEFT JOIN locations AS d
    ON c.location_id = d.location_id
    LEFT JOIN countries as e
    ON d.country_id = e.country_id
),

Top5 AS (
    SELECT DISTINCT employee_id, MANAGER AS Manager, salary, department_name FROM Manager_details
    ORDER BY salary DESC, Manager
    LIMIT 5
)

SELECT * FROM Top5;

