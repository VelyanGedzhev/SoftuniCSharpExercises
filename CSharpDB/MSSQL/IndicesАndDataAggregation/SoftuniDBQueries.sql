USE SoftUni

--13. Departments Total Salaries
SELECT DepartmentID, SUM(Salary)
	FROM Employees 
	GROUP BY DepartmentID

--14. Employees Minimum Salaries
SELECT 
		DepartmentID,
		MIN(Salary)
	FROM Employees
	WHERE DepartmentID IN (2, 5, 7) AND HireDate > '2000/01/01'
	GROUP BY DepartmentID

--15. Employees Average Salaries
SELECT *
	INTO MyNewTable
	FROM Employees
	WHERE Salary > 30000

DELETE FROM MyNewTable
WHERE ManagerID = 42

UPDATE MyNewTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT 
		DepartmentID,
		AVG(Salary)
	FROM MyNewTable
	GROUP BY DepartmentID
	
--16. Employees Maximum Salaries
SELECT DepartmentID, MAX(Salary)
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries
SELECT COUNT(*) AS [Count]
	FROM Employees
	WHERE ManagerID IS NULL

--18. *3rd Highest Salary (not included in final score)
SELECT DISTINCT
		k.DepartmentID,
		k.Salary
	FROM(SELECT 
		DepartmentID,
		Salary,
		DENSE_RANK() OVER(PARTITION BY e.DepartmentID ORDER BY e.Salary DESC) AS [Ranked]
	FROM Employees AS e) AS k
	WHERE k.Ranked = 3

--19. **Salary Challenge (not included in final score)
SELECT TOP(10) FirstName, LastName, DepartmentID
	FROM Employees AS emp
	WHERE Salary > (SELECT AVG(Salary)
						FROM Employees AS e
						WHERE emp.DepartmentID = e.DepartmentID
						GROUP BY DepartmentID)
	ORDER BY emp.DepartmentID

