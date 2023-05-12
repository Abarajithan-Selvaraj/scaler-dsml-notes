-- D18 - Q1: Write a query to find all the details of those employees who earn the third-highest salary.
-- Return all the columns from the employee's table.

SELECT *
FROM employees
GROUP BY salary
ORDER BY salary DESC
LIMIT 1
OFFSET 2;

-- D18 - Q2: Find the details of the employees who earn less than the average salary in their respective departments.
-- Return the columns 'employee_id', 'first_name', 'last_name', 'department_id', 'salary'.

SELECT
    employees.employee_id,
    employees.first_name,
    employees.last_name,
    employees.department_id,
    employees.salary
FROM employees
JOIN (SELECT department_id, AVG(salary) AS salavg FROM employees GROUP BY department_id) AS res
ON res.department_id = employees.department_id
WHERE res.salavg > employees.salary
ORDER BY employees.employee_id;

-- D18 - Q3: Display the employee's full name ( first name and last name separated by space) as 'full_name' of all those employees whose salary is greater than 40% of their department’s total salary.
-- Return the column 'full_name'.

SELECT
    CONCAT(employees.first_name, " ", employees.last_name) AS full_name
FROM employees
JOIN (SELECT department_id, SUM(salary) AS totsal FROM employees GROUP BY department_id) AS res
ON res.department_id = employees.department_id
WHERE ROUND(0.4 * res.totsal, 2) < employees.salary;

-- D18 - Q4: Display the 'full_name' (first and last name separated by space) of a manager who manages 4 or more employees.
-- Return the column 'full_name'.
-- The column manager_id in the employees table represents the employee_id of the manager.

SELECT
    CONCAT(mgrs.first_name, " ", mgrs.last_name) AS full_name
    -- COUNT(*)
FROM employees
LEFT JOIN employees AS mgrs
ON mgrs.employee_id = employees.manager_id
GROUP BY employees.manager_id
HAVING COUNT(*) >= 4;

-- D18 - Q5: Display the count of employees as 'No_of_Employees' and, the total salary paid to employees as 'Total_Salary' present in each department.
-- Return the columns 'department_name', 'No_of_Employees', and 'Total_Salary'.
-- Return the output ordered by department_name in ascending order.

SELECT
    departments.department_name,
    COUNT(*) AS No_of_Employees,
    SUM(employees.salary) AS Total_Salary
FROM employees
LEFT JOIN departments
ON departments.department_id = employees.department_id
WHERE NOT departments.department_name IS NULL
GROUP BY employees.department_id
ORDER BY departments.department_name;

-- D18 - Q6: Write a query to tag the department as per the count of employees working in that department.
-- If the number of employees is 1 then the "Junior Department"
-- If the number of employees is ≤ 4 then "Intermediate Department".
-- If the number of employees is > 4 then it is "Senior Department" and save the column as "Department_level."
-- Save the department_id as 'Department' and count of employees as 'No_of_employees'.
-- Order the output by the 'No_of_employees' and 'Department' in ascending order.
-- Return the columns 'Department', 'No_of_employees', and 'Department_level'.

SELECT
    department_id AS Department,
    COUNT(*) AS No_of_employees,
    CASE
        WHEN COUNT(*) = 1
        THEN "Junior Department"
        WHEN COUNT(*) <= 4
        THEN "Intermediate Department"
        ELSE "Senior Department"
    END AS Department_level
FROM employees
GROUP BY department_id
ORDER BY No_of_employees, Department;

-- D18 - Q7: Display all the details of those departments where the salary of any employee in that department is at least 9000.
-- Return all the columns from the departments ordered by department_id column in ascending manner.

SELECT
    departments.*
FROM employees
RIGHT JOIN departments
ON departments.department_id = employees.department_id
GROUP BY employees.department_id
HAVING (SELECT COUNT(*) FROM (SELECT * FROM employees AS a WHERE a.salary >= 9000) AS t WHERE employees.department_id = t.department_id) = (SELECT COUNT(*) FROM (SELECT * FROM employees) AS t  WHERE employees.department_id = t.department_id)
-- WHERE NOT departments.department_id IS NULL
ORDER BY departments.department_id;

-- D18 - Q8: Find the average salary of the employees for each department and order the departments by department_id in ascending order. Save the average salary as 'Average_salary'.
-- Return the columns 'department_id', 'department_name', 'Average_salary'.

SELECT
    employees.department_id,
    departments.department_name,
    AVG(employees.salary) AS Average_salary
FROM employees
LEFT JOIN departments
ON departments.department_id = employees.department_id
WHERE NOT employees.department_id IS NULL
GROUP BY employees.department_id
ORDER BY departments.department_id;

-- D18 - Q9: Given a table of candidates and their skills, you're asked to find the candidates best suited for an open Data Science job. We want to find candidates who are proficient in 'Python', 'Tableau', and 'MySQL'.
-- Write a query to list the candidates who possess all three required skills for the job. Sort the output by candidate_id in ascending order.
-- Note: There are no duplicates in the candidates table.

SELECT candidate_id
FROM candidates
GROUP BY candidate_id
HAVING COUNT((SELECT a.skill FROM candidates AS a WHERE a.candidate_id = candidates.candidate_id AND LOWER(a.skill) LIKE "python")) > 0
    AND COUNT((SELECT a.skill FROM candidates AS a WHERE a.candidate_id = candidates.candidate_id AND LOWER(a.skill) LIKE "tableau")) > 0
    AND COUNT((SELECT a.skill FROM candidates AS a WHERE a.candidate_id = candidates.candidate_id AND LOWER(a.skill) LIKE "mysql")) > 0;


-- D18 - Q10: Write a query to find the customer_id and customer_name of customers who bought products "Bread", and "Milk" but did not buy the product "Eggs" since we want to recommend them to purchase this product.
-- Return the output ordered by customer_id in ascending order

SELECT
    customers.customer_id,
    customers.customer_name
FROM orders
JOIN customers
ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id
HAVING COUNT((SELECT a.product_name FROM orders AS a WHERE a.customer_id = orders.customer_id AND a.product_name = "Bread")) > 0
    AND COUNT((SELECT a.product_name FROM orders AS a WHERE a.customer_id = orders.customer_id AND a.product_name = "Milk")) > 0
    AND COUNT((SELECT a.product_name FROM orders AS a WHERE a.customer_id = orders.customer_id AND a.product_name = "Eggs")) = 0;