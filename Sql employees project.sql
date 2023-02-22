USE employees;

-- Counting the number of employees who are senior employees and on permanent contracts
SELECT 
    COUNT(title) AS 'Number of upper management employees on permanent contracts',
    title,
    to_date
FROM
    titles
WHERE
    to_date = '9999-01-01'
        AND (title LIKE '%Senior%'
        OR title LIKE 'Manager'
        OR title LIKE '%Leader')
GROUP BY title
;
    
-- Counting the number of distinct position in the company    
SELECT 
    COUNT(DISTINCT (title)) AS 'Number of positions in the organization',
    title,
    to_date
FROM
    titles
GROUP BY title;



-- The average salaries of each department
SELECT 
    FORMAT(AVG(s.salary), '###,###') AS 'Average salary per department for the year 2000',
    d.dept_name
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
WHERE
    s.from_date BETWEEN '2000-01-01' AND '2000-12-31'
GROUP BY d.dept_name
ORDER BY FORMAT(AVG(s.salary), '###,###') DESC;


-- higest paid manager on average who are on a permanent contract
SELECT 
    de.emp_no,
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    FORMAT((AVG(s.salary)), '###,###') AS 'Average salary',
    t.title,
    d.dept_name
FROM
    departments d
        JOIN
    dept_manager de ON d.dept_no = de.dept_no
        JOIN
    employees e ON e.emp_no = de.emp_no
        JOIN
    salaries s ON s.emp_no = e.emp_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE
    de.to_date = '9999-01-01'
        AND t.title = 'Manager'
GROUP BY t.title , d.dept_name
ORDER BY AVG(s.salary) DESC;


SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    de.emp_no, e.emp_no, de.to_date, de.from_date,
    CASE
        WHEN
            FORMAT(DATEDIFF(de.to_date, de.from_date) / 365,
                '#,###.##') < 5
        THEN
            'Short term contracts'
        WHEN
            FORMAT(DATEDIFF(de.to_date, de.from_date) / 365,
                '#,###.##') < 10
        THEN
            'Long term contracts'
             WHEN
            FORMAT(DATEDIFF(de.to_date, de.from_date) / 365,
                '#,###.##') < 20
        THEN
            'p term contracts'
    END AS 'Class of contract'
FROM
    employees e
        Left JOIN
    dept_emp de ON e.emp_no = de.emp_no;
    

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    COUNT(de.emp_no), de.to_date, de.from_date
    FROM
    employees e
        Left JOIN
    dept_emp de ON e.emp_no = de.emp_no
    Group by CONCAT(e.first_name, ' ', e.last_name)
    having COUNT(de.emp_no) >1;
    
-- Counting the number of male and female employees that started their contact in the year 2000    
SELECT 
    COUNT(e.emp_no) AS 'Count of employees',
    e.gender,
    d.dept_name
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
WHERE
    de.from_date BETWEEN '2000-01-01' AND '2000-12-31'
GROUP BY 2 , 3
order by 1 DESC;

-- Average salary of males and females per department since company started
SELECT 
    e.gender,
    d.dept_name,
    FORMAT(AVG(s.salary), '#,###,###') AS 'Average salary'
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
GROUP BY 1 , 2
ORDER BY 3 DESC;

-- Average salary of males and females in the company
SELECT 
    e.gender,
    FORMAT(AVG(s.salary), '#,###,###') AS 'Average salary'
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
GROUP BY 1
ORDER BY 2 DESC;

-- Checking who is the highest paid permanent employee, their job title and department
SELECT 
    e.emp_no,
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    e.gender,
    t.title,
    d.dept_name,
    MAX(s.salary) AS 'Highest Salary'
FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
        JOIN
    titles t ON e.emp_no = t.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
WHERE
    de.to_date = '9999-01-01';


select * from dept_emp;

-- List of employees who have renewed their contracts with the company
SELECT 
    de.emp_no,
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    COUNT(de.emp_no) AS 'Number of contracts with the company'
FROM
    employees e
		JOIN
    dept_emp de ON e.emp_no = de.emp_no
GROUP BY 1
HAVING COUNT(de.emp_no) >= 2
Order by 3 desc;

-- Checking to see whether a manager is retired or active using CASE statement
SELECT 
    dm.emp_no,
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    d.dept_name,
    CASE
        WHEN dm.to_date > '2000-01-01' THEN 'Active'
        ELSE 'Retired'
    END AS 'Status'
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
        JOIN
    departments d ON dm.dept_no = d.dept_no;
 
select 
de.emp_no,
CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
t.title,
case when de.from_date <> de.to_date then t.title
else t.title end as 'a',
count(de.emp_no)
from employees e 
join titles t on e.emp_no = t.emp_no
join dept_emp de on e.emp_no = de.emp_no
group by 1;

-- Checking on department managers who had salary increase
SELECT 
    dm.emp_no,
    CONCAT(e.first_name, ' ', e.last_name) AS 'Full Name',
    MAX(s.salary) - MIN(s.salary) AS 'Salary Difference',
    CASE
        WHEN MAX(s.salary) - MIN(s.salary) > 20000 THEN 'Significant salary increase'
        ELSE 'Minor salary increase'
    END AS 'Salary raise'
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no
        JOIN
    salaries s ON s.emp_no = dm.emp_no
GROUP BY 1
ORDER BY 3;  

SELECT

emp_no,

salary,

ROW_NUMBER() OVER w AS row_num

FROM

salaries

WHERE emp_no = 10560

WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);


-- Calculating average salary per job
SELECT 
    t.title,
    FORMAT(AVG(s.salary), '###,###') AS 'Average salary of job'
FROM
    employees e
        JOIN
    titles t ON e.emp_no = t.emp_no
        JOIN
    salaries s ON e.
    emp_no = s.emp_no
GROUP BY 1
ORDER BY 2 DESC;

select count(to_date) from titles
where to_date = '9999-01-01' ;

-- Number of male and female employees that have worked for the company
SELECT 
    gender, 
    COUNT(gender) AS 'Gender count'
FROM
    employees
GROUP BY gender;


-- Looking for specific employees hired in a particular period
SELECT 
    emp_no,
    CONCAT(first_name, ' ', last_name) AS 'Full Name',
    hire_date
FROM
    employees
WHERE
    last_name IN ('Bamford' , 'Facello', 'Casley')
        AND hire_date BETWEEN '1995-01-01' AND '1999-12-31'
ORDER BY 3;


-- the two most and two least hired jobs in the company
SELECT 
    *
FROM
    ((SELECT 
        COUNT(DISTINCT (emp_no)) AS 'The two most and two least hired jobs',
            title
    FROM
        titles
    GROUP BY 2
    ORDER BY 1 DESC
    LIMIT 2) UNION (SELECT 
        COUNT(DISTINCT (emp_no)), title
    FROM
        titles
    GROUP BY 2
    ORDER BY 1 ASC
    LIMIT 2)) AS hiring_result;

-- List of managers that where hired on or after 1990 - Subquery
SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND title = 'Manager'
                AND hire_date >= '1987-12-31')
ORDER BY gender;

SELECT 
    *
FROM
    dept_manager
WHERE
    emp_no IN (SELECT 
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');