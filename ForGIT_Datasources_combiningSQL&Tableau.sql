-- Task 1 - Text
-- Create a visualization that provides a breakdown between the male and female employees working in the 
-- company each year, starting from 1990. 

SELECT
YEAR(de.from_date) as Calendar_Year,
e.gender as Gender,
count(e.emp_no) as Number_Employees
From t_employees e
Join 
t_dept_emp de ON e.emp_no = de.emp_no AND YEAR(de.from_date) >= '1990'
Group by Calendar_Year, Gender
ORDER BY Calendar_Year ASC;


-- Task 2 - Text
-- Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

-- Solution Course

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

-- Task 3 - Text
-- Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you 
-- to see that per each department.

USE employees_mod;

SELECT
YEAR(s.from_date) as Calendar_Year,
d.dept_name as Department,
e.gender as Gender,
Round(Avg(s.salary),2) as Avg_Salary
From t_employees e
Join 
t_dept_emp de ON e.emp_no = de.emp_no
Join
t_departments d ON de.dept_no = d.dept_no 
Join
t_salaries s ON s.emp_no = de.emp_no 
Group by Calendar_Year, Gender, Department
Having Calendar_Year <= '2002'
ORDER BY Calendar_Year, Department ASC;



-- Task 4: 
-- Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. 
-- Let this range be defined by two values the user can insert when calling the procedure.

-- Finally, visualize the obtained result-set in Tableau as a double bar chart. 

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    e.gender, d.dept_name, AVG(s.salary) as avg_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);