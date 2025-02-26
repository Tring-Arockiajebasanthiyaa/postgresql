-- Creating Tables with Constraints

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(255) UNIQUE NOT NULL
);
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    dept_id INT REFERENCES departments(dept_id) ON DELETE CASCADE
);
CREATE TABLE projects(
  project_id SERIAL PRIMARY KEY,
  project_name VARCHAR(255) NOT NULL,
  dept_id INT REFERENCES departments(dept_id) ON DELETE CASCADE
);

--Drop and Delete

--Delete from employees;
-- Drop table employees;
-- Drop table projects;
-- drop table departments;


--Insert Sample Data 


Insert into departments (dept_name) values('Human Resources'),
('Finance'),
('Developer'),
('Marketing'),
('Sales'),('QA');


INSERT INTO employees (emp_name, email, salary, dept_id) VALUES
('Alice Johnson', 'alice@example.com', 60000.00, 1),
('Bob Smith', 'bob@example.com', 55000.00, 2),
('Charlie Brown', 'charlie@example.com', 75000.00, 3),
('David White', 'david@example.com', 50000.00, 4),
('Emma Watson', 'emma@example.com', 65000.00, 5),
('Frank Miller', 'frank@example.com', 70000.00, 3),
('Grace Hall', 'grace@example.com', 62000.00, 2),
('Henry Ford', 'henry@example.com', 58000.00, 1),
('Isla Fisher', 'isla@example.com', 72000.00, 3),
('Jack Black', 'jack@example.com', 68000.00, 5);

INSERT INTO employees (emp_name, email, salary, dept_id) VALUES
('Kevin Hart', 'kevin@example.com', 59000.00, 1),
('Lily Evans', 'lily@example.com', 63000.00, 2),
('Michael Scott', 'michael@example.com', 72000.00, 3),
('Nancy Drew', 'nancy@example.com', 51000.00, 4),
('Oliver Queen', 'oliver@example.com', 75000.00, 5),
('Pam Beesly', 'pam@example.com', 58000.00, 3);


INSERT INTO projects (project_name, dept_id) 
VALUES 
    ('HR Management System', 1),  
    ('Budget Tracker', 2),        
    ('AI Chatbot', 3),            
    ('Ad Campaign Analysis', 4),  
    ('E-Commerce Optimization', 5);

INSERT INTO projects (project_name, dept_id) 
VALUES 
    ('Voice Assistant', 3); 

INSERT INTO projects (project_name, dept_id) 
VALUES 
    ('Student Management System', 3); 

INSERT INTO projects (project_name, dept_id) 
VALUES 
    ('Recruitment Portal', 1); 

INSERT INTO projects (project_name, dept_id) 
VALUES 
    ('Payroll Management System', 1),
    ('Tax Filing Automation', 2),
    ('Cybersecurity Risk Assessment', 3),
    ('Market Trend Analyzer', 4),
    ('Customer Feedback Analyzer', 5);
	
	
--Section A: Joins 


--5. INNER JOIN: List all employees along with their department names. 

SELECT e.emp_name , d.dept_name from employees e INNER JOIN departments d on e.dept_id = d.dept_id;

--6.LEFT JOIN:Show all departments and employees, including departments with no employees. 

SELECT d.dept_name , e.emp_name from departments d LEFT JOIN employees e on e.dept_id = d.dept_id;

--7. RIGHT JOIN: Show all employees and their respective departments, including employees without a department. 

SELECT e.emp_name , d.dept_name  from  departments d  RIGHT JOIN employees e on e.dept_id = d.dept_id;

--8. FULL OUTER JOIN: List all departments and employees, even if there’s no match between them. 

SELECT d.dept_name , e.emp_name from departments d FULL OUTER JOIN employees e on e.dept_id = d.dept_id;

-- 9. JOIN with multiple tables: List all employees along with their department name and the projects assigned to that department. 

SELECT e.emp_name , d.dept_name ,p.project_name from employees e INNER JOIN departments d on e.dept_id = d.dept_id INNER Join projects p on e.dept_id = p.dept_id;


-- Section B: Aggregate Functions 


-- 10. Count the total number of employees in each department. 

SELECT d.dept_name , COUNT(e.dept_id) as Countings from departments d LEFT JOIN employees e on e.dept_id = d.dept_id group by d.dept_name ;

--11. Find the total salary paid in each department.

SELECT d.dept_name , COALESCE(SUM(e.salary)) as total_salary from departments d LEFT JOIN employees e on d.dept_id = e.dept_id group by d.dept_name;

--12. Calculate the average salary for each department. 

SELECT d.dept_name , COALESCE(AVG(e.salary)) as Average_salary from departments d LEFT JOIN employees e on d.dept_id = e.dept_id group by d.dept_name;

--13. Find the minimum and maximum salary in the company. 

SELECT MIN(salary) as Minimum_Salary , MAX(salary) as Maximum_Salary from employees;

--14. List the total number of projects each department is handling.

SELECT d.dept_name ,COUNT(p.dept_id) as Projects_Count from departments d LEFT JOIN projects p on d.dept_id = p.dept_id group by d.dept_name;


-- Section C: GROUP BY and HAVING 


-- 15. Show the average salary per department, but only for departments where the average salary is greater than 50,000. 

SELECT d.dept_name ,AVG(e.salary) as Average_Salary from departments d LEFT JOIN employees e on d.dept_id = e.dept_id group by d.dept_name having AVG(e.salary )> 50000;

--16. Find departments with more than 3 employees. 

SELECT d.dept_name from departments d JOIN employees e on e.dept_id = d.dept_id group by d.dept_name having count(e.emp_id) >= 3;

-- 17. List projects assigned to departments that have at least 2 projects. 

SELECT d.dept_name, p.project_name FROM projects p JOIN departments d ON d.dept_id = p.dept_id WHERE p.dept_id IN (SELECT dept_id FROM projects GROUP BY dept_id HAVING COUNT(project_name) >= 2);

-- Custom Functions 


-- 18. Create a function to calculate bonuses 
-- ● Write a PostgreSQL function that takes an employee’s salary as input and 
-- returns the bonus amount (10% of salary). 
-- ● Test the function by selecting all employees and displaying their bonus. 

CREATE FUNCTION employee_bonus(salary numeric)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    bonus numeric;
	
BEGIN
   bonus := salary * 0.10;
   RETURN bonus;
END
$$;

DROP FUNCTION employee_salary(NUMERIC);

SELECT emp_name, salary, employee_bonus(salary) AS bonus FROM employees;

-- 19. Create a function to count employees in a department 
-- ● Write a function that takes a dept_id as input and returns the number of 
-- employees in that department. 
-- ● Test the function by calling it for different department IDs. 


CREATE FUNCTION employees_count(dept_id1 int)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE 
   emp_count INT;
BEGIN 
   SELECT COUNT(e.emp_id) into emp_count from employees e where e.dept_id = dept_id1;
   RETURN emp_count;
END
$$;

--Testing
SELECT employees_count(5);

--Drop

DROP FUNCTION employees_count(int);

-- 20. Create a function to check high salaries 
-- ● Write a function that takes a salary as input and returns "High Salary" if it's 
-- above 80,000, "Medium Salary" if it's between 50,000-80,000, and "Low 
-- Salary" otherwise. 
-- ● Test the function by applying it to all employees.

CREATE FUNCTION salary_range(salary numeric)
RETURNS varchar(255)
LANGUAGE plpgsql
AS $$
DECLARE
   res varchar(255);
BEGIN
   CASE 
       WHEN salary > 80000 THEN res := 'High Salary';
	   WHEN salary <= 80000 and salary >= 50000 THEN res := 'Medium Salary';
   ELSE
       res := 'Low Salary';
   END CASE;
   RETURN res;
END
$$;

--Testing
SELECT salary_range(60000);



