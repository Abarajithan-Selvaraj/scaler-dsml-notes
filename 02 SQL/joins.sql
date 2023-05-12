-- D16 - Q1: Write a query that reports the product_name, year, and price for each sale_id in the sales table.
-- Return the result table ordered by year in ascending order.

SELECT
   product.product_name,
   sales.year,
   sales.price
FROM sales
LEFT JOIN product
ON sales.product_id = product.product_id
ORDER BY sales.year;

-- D16 - Q2: Write a query that reports the buyers who have bought the product S8 but not an iPhone.
-- Note: Return the result table ordered by buyer_id in ascending order.
-- S8 and iPhone are products present in the Product table.

SELECT
    DISTINCT
    Sales.buyer_id
    -- Sales.product_id,
    -- Product.product_name
FROM Sales
LEFT JOIN Product
ON Sales.product_id = Product.product_id
WHERE LOWER(Product.product_name) LIKE "s8"
AND NOT Sales.buyer_id IN (SELECT s.buyer_id FROM Sales AS s LEFT JOIN Product AS p ON s.product_id = p.product_id WHERE LOWER(p.product_name) LIKE "iphone")
ORDER BY Sales.buyer_id;

-- D16 - Q3: Find the details of all those employees who work in the 'Human Resources' department.
-- Return the columns 'employee_id', 'department_id', 'first_name', 'last_name', 'job_id', 'department_name'.

SELECT
    e.employee_id,
    e.department_id,
    e.first_name,
    e.last_name,
    e.job_id,
    d.department_name
FROM employees AS e
LEFT JOIN departments AS d
ON e.department_id = d.department_id
WHERE
    lower(d.department_name) LIKE 'human resources';

-- D16 - Q4: Display the details of all those departments that don't have any working employees.
-- Return the columns 'department_id', 'department_name'.

SELECT
    d.department_id,
    d.department_name
FROM departments as d
LEFT JOIN employees AS e
ON e.department_id = d.department_id
WHERE e.department_id IS NULL;

-- D16 - Q5: Write a query to report the name and bonus amount of each employee with a bonus less than 1000.
-- Return the output ordered by bonus in ascending order.

SELECT
    u.name,
    v.bonus
FROM employee AS u
LEFT JOIN bonus AS v
ON u.empId = v.empId
WHERE
    v.bonus < 1000
    OR v.bonus IS NULL
ORDER BY v.bonus;

-- D16 - Q6: Write a query to report the distinct titles of the kid-friendly movies streamed in June 2020.
-- Return the result table ordered by title in ascending order.

SELECT
    cnt.title
FROM Content AS cnt
RIGHT JOIN TVProgram AS tvp
ON cnt.content_id = tvp.content_id
ORDER BY cnt.title;

-- D16 - Q7: Write a query to report the names of all the salespersons who did not have any orders related to the company named "RED".
-- Note: Return the result table ordered by name.

SELECT
    DISTINCT
    -- o.sales_id,
    s.name
    -- o.com_id,
    -- c.name
FROM salesperson AS s
LEFT JOIN orders AS o
ON s.sales_id = o.sales_id
LEFT JOIN company AS c
ON o.com_id = c.com_id
WHERE NOT LOWER(c.name) LIKE "%red%"
OR c.name IS NULL
ORDER BY s.name;

-- D16 - Q8: Write a query to find the employee_id of the employees whose salary is strictly less than $15000 and whose manager left the company.
-- When a manager leaves the company, their information is deleted from the employees table, but the reports still have their manager_id set to the manager that left.
-- Note: Return the result ordered by employee_id in ascending order.

SELECT
    employee_id
    -- salary,
    -- manager_id
FROM employees
WHERE NOT manager_id IN (SELECT employee_id FROM employees)
ORDER BY employee_id;


-- D16 - Q9: Display the details of the employees who had job titles like 'sales' in the past and the min_salary is greater than or equal to 6000.
-- Return the columns 'employee_id', 'department_name', 'job_id', 'job_title', and 'min_salary'.
-- Return the employee's current information for the columns 'employee_id', and 'department_name'.
-- Return the employee's past information for the columns 'job_id', 'job_title', and 'min_salary'.
-- Return the output ordered by employee_id and min_salary in ascending order.

-- NOTE: To get the min_salary refer to the jobs table.
-- Refer to the job_history table to get the details of past jobs.
-- An employee might have worked in multiple jobs in the past whose record will be available in job_history.
-- If any employee hasn't worked in any jobs in the past, his record wouldn't be present in the job_history table.

SELECT
    employees.employee_id,
    departments.department_name,
    job_history.job_id,
    jobs.job_title,
    jobs.min_salary
FROM employees
LEFT JOIN departments
ON employees.department_id = departments.department_id
LEFT JOIN job_history
ON employees.employee_id = job_history.employee_id
LEFT JOIN jobs
ON job_history.job_id = jobs.job_id
WHERE LOWER(jobs.job_title) LIKE "%sales%"
   OR LOWER(jobs.job_title) LIKE "%account%"
   AND jobs.min_salary >= 6000;

-- D16 - Q10: Display the details of the employees who belong to the 'Europe' region. Sort the output in descending order of salary and ascending order of the employee_id.
-- Note: Return the columns 'employee_id', 'full_name' (first_name and last_name separated by space), 'salary', 'phone_number', 'department_id', 'department_name', 'street_address', 'city', 'country_name', 'region_id', 'region_name'.

SELECT
    employees.employee_id,
    CONCAT(employees.first_name, " ", employees.last_name) AS full_name,
    employees.salary,
    employees.phone_number,
    employees.department_id,
    departments.department_name,
    locations.street_address,
    locations.city,
    countries.country_name,
    countries.region_id,
    regions.region_name
FROM employees
LEFT JOIN departments
ON employees.department_id = departments.department_id
LEFT JOIN locations
ON departments.location_id = locations.location_id
LEFT JOIN countries
ON locations.country_id = countries.country_id
LEFT JOIN regions
ON countries.region_id = regions.region_id
WHERE LOWER(regions.region_name) LIKE "europe"
ORDER BY
    employees.salary DESC,
    employees.employee_id;


-- D17 - Q1: Write a query to report all the sessions that did not get shown any ads.
-- Return the output order by session_id in ascending order.

SELECT
    DISTINCT
    Playback.session_id
FROM Ads
LEFT JOIN Playback
ON Ads.customer_id = Playback.customer_id
WHERE NOT Ads.timestamp BETWEEN Playback.start_time AND Playback.end_time
ORDER BY Playback.session_id;

-- D17 - Q2: Display the details of the employees who joined the company before their managers joined the company.
-- Return the columns 'employee_id', 'first_name', and 'last_name'.
-- Return the result ordered by employee_id in ascending order.

SELECT
    emps.employee_id,
    emps.first_name,
    emps.last_name
FROM employees AS emps
JOIN employees AS mgrs
ON emps.manager_id = mgrs.employee_id
WHERE emps.hire_date < mgrs.hire_date
ORDER BY emps.employee_id;

-- D17 - Q3: Write a query to find the shortest distance between any two points from the points table. Round the distance to two decimal points
-- Note: The distance between two points p1(x1, y1) and p2(x2, y2) is calculated using euclidean distance formula √((x2 - x1)2 + (y2 - y1)2).
-- Save the new column as 'shortest'.

SELECT
    ROUND(SQRT(POWER(P2.x - P1.x, 2) + POWER(P2.y - P1.y, 2)), 2) AS shortest
FROM points AS P1
JOIN points AS P2
ON P1.x <> P2.x
ORDER BY shortest
LIMIT 1;

-- D17 - Q4: Display the details of those employees who have a manager working in the department that is US based. Also, display the output in ascending order of their 'employee_id'.
-- Return the columns 'employee_id, 'first_name', 'last_name'.
-- manager_id column represents the employee_id of the manager.

SELECT
    employees.employee_id,
    employees.first_name,
    employees.last_name
FROM employees
JOIN employees AS mgrs
ON employees.manager_id = mgrs.employee_id
LEFT JOIN departments
ON mgrs.department_id = departments.department_id
LEFT JOIN locations
ON departments.location_id = locations.location_id
LEFT JOIN countries
ON locations.country_id = countries.country_id
WHERE UPPER(countries.country_name) LIKE "%U%S%"
ORDER BY employees.employee_id;

-- D17 - Q5: Write a query to report all the consecutive available seats in the cinema.
-- Return the result table ordered by seat_id in ascending order
-- Note: In the table cinema, 1 means seats are available and 0 means that seats are not available.

SELECT
    DISTINCT
    cinema.seat_id
FROM cinema
JOIN cinema AS seats
ON ABS(cinema.seat_id - seats.seat_id) = 1
    AND seats.free = 1
    AND cinema.free = 1
ORDER BY cinema.seat_id;

-- D17 - Q6: Write a query to find the account_id of the accounts that should be banned from Leetflex.
-- An account should be banned if it was logged in at some moment from two different IP addresses.
-- Return the output ordered by account_id in ascending order.

SELECT
    loginfo.account_id
FROM loginfo
JOIN loginfo AS LIN2
ON loginfo.account_id = LIN2.account_id
    AND loginfo.ip_address != LIN2.ip_address
    AND LIN2.login BETWEEN loginfo.login AND loginfo.logout
ORDER BY loginfo.account_id;

-- D17 - Q7: Write a query to find all the people who viewed more than one article on the same date.
-- Save the viewer_id as the id.
-- Return the result sorted by id in ascending order.

SELECT
    DISTINCT
    views.viewer_id AS id
FROM views
JOIN views AS v2
ON views.viewer_id = v2.viewer_id
    AND views.article_id != v2.article_id
    AND views.view_date = v2.view_date
ORDER BY id;

