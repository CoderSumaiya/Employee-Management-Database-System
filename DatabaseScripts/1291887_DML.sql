USE EmployeeDB
GO

-- 2. Insert Records into tables using Script
INSERT INTO Departments(DepartmentNo,DepartmentName)
VALUES (1,'IT'), (2,'HR'), (3,'Finance'), (4,'Sales')

INSERT INTO Designation(DesignationID,DesignationTitle)
VALUES (101,'Developer'), (102,'Executive'), (103,'GM'), (104,'SO'), (105,'Sr. Engineer'), (106,'Sr. Executive')

INSERT INTO Employee(EmployeeID,EmployeeName,Salary,DesignationID,DepartmentNo)
VALUES
(201,'Sawda Akter',20000,104,4),
(202,'Sadik Islam',21000,102,2),
(203,'Jannatul Ferdaus',15000,105,1),
(204,'Zerin Akter',18000,106,2),
(205,'Marufa Munjuri',25000,101,1),
(206,'Joha Khan',15000,103,3)

INSERT INTO Projects(ProjectID,ProjectName,Budget,EmployeeID)
VALUES 
(301,'Office Staff Management System',100000.0000,202),
(302,'Pensions System',80000.0000,206),
(303,'Cyber Security Portal',90000.0000,203),
(304,'Employee Management System',80000.0000,204),
(305,'Network Automation System',80000.0000,205),
(306,'Customer Relationship Management',150000.0000,201)

INSERT INTO ProjectAssigment(ProjectID,EmployeeID,WorkHour)
VALUES
(301,202,40), (302,206,60), (303,203,80), (304,204,50), (305,205,70), (306,201,90)

-- 3. Delete query

DELETE FROM Employee
WHERE EmployeeID = 208;
-- 4. Write an update query for any one table of your project

UPDATE Employee
SET Salary = 22000
WHERE EmployeeID = 202;
-- 5. How to use a SELECT INTO statement
IF OBJECT_ID('EmployeeDept3') IS NOT NULL
    DROP TABLE EmployeeDept3;

SELECT *
INTO EmployeeDept3
FROM Employee
WHERE DepartmentNo = 3;

-- 8. Write a script to delete a column
CREATE TABLE TestTable (TestID INT PRIMARY KEY, Name VARCHAR(20))
ALTER TABLE TestTable DROP COLUMN Name
DROP TABLE TestTable

-- 9. Join query using Group By and Having Clause
SELECT d.DepartmentName, p.ProjectName, COUNT(pa.ProjectID) AS TotalProject, SUM(p.Budget) AS TotalBudget
FROM Departments AS d 
JOIN Employee AS e ON d.DepartmentNo = e.DepartmentNo  
JOIN ProjectAssigment AS pa ON e.EmployeeID = pa.EmployeeID  
JOIN Projects AS p ON pa.ProjectID = p.ProjectID
GROUP BY d.DepartmentName, p.ProjectName
HAVING SUM(p.Budget) > 70000;

-- 10. Sub-query to show all information of Project Pensions System

SELECT *
FROM Projects
WHERE ProjectID =
(
    SELECT ProjectID
    FROM Projects
    WHERE ProjectName = 'Pensions System'
);

-- 11 (Justify). Calling View
SELECT * FROM vw_EmployeesInfoTechnology

-- 12 (Justify). Calling Stored Procedure Output Parameter
DECLARE @Name VARCHAR(40)
EXEC spEmployeeCRUD_Output 'O', 0, '', 0, 0, 0, 301, @Name OUTPUT
SELECT @Name AS ProjectName

-- 13 (Justify). Check Index
EXEC sp_helpindex Employee

-- 14 (Justify). Calling Scalar Function
SELECT dbo.fn_DepartmentTotalBudget(1) AS TotalDepartmentBudget

-- 16. Transaction with Error Handling Procedure
IF OBJECT_ID('spEmployeeDB1SelectInsertUpdateDeleteOutputReturnWithTrans') IS NOT NULL
DROP PROCEDURE spEmployeeDB1SelectInsertUpdateDeleteOutputReturnWithTrans
GO

CREATE PROC spEmployeeDB1SelectInsertUpdateDeleteOutputReturnWithTrans
@OperationType CHAR(1), @EmployeeID INT, @EmployeeName VARCHAR(30), @DepartmentNo INT, @Salary DECIMAL(10,4), @DesignationID INT, @ProjectID INT, @Name VARCHAR(40) OUTPUT, @EmployeeCount INT OUTPUT
AS
BEGIN
    IF @OperationType='S' SELECT * FROM Employee
    ELSE IF @OperationType='O' SELECT @Name = ProjectName FROM Projects WHERE ProjectID=@ProjectID
    ELSE IF @OperationType='R' BEGIN SELECT @EmployeeCount = COUNT(*) FROM Employee RETURN @EmployeeCount END
    ELSE IF @OperationType IN ('I','U','D')
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
            IF @OperationType='I' INSERT INTO Employee(EmployeeID, EmployeeName, Salary, DesignationID, DepartmentNo) VALUES (@EmployeeID, @EmployeeName, @Salary, @DesignationID, @DepartmentNo)
            ELSE IF @OperationType='U' UPDATE Employee SET EmployeeName=@EmployeeName, Salary=@Salary, DesignationID=@DesignationID, DepartmentNo=@DepartmentNo WHERE EmployeeID=@EmployeeID
            ELSE IF @OperationType='D' DELETE FROM Employee WHERE EmployeeID=@EmployeeID
            COMMIT TRANSACTION
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
            SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() AS ErrorLine
        END CATCH
    END
END
GO

-- 18. Process of Handling Error (Stored Procedure)
IF OBJECT_ID('spEmployeeSelectInsertUpdateDeleteOutputReturn') IS NOT NULL
DROP PROCEDURE spEmployeeSelectInsertUpdateDeleteOutputReturn
GO

CREATE PROC spEmployeeSelectInsertUpdateDeleteOutputReturn
@OperationType CHAR(1), @EmployeeID INT, @EmployeeName VARCHAR(30), @DepartmentNo INT, @Salary DECIMAL(10,4), @DesignationID INT, @ProjectID INT, @Name VARCHAR(40) OUTPUT, @EmployeeCount INT OUTPUT
AS
BEGIN
    IF @OperationType='S' SELECT * FROM Employee
    ELSE IF @OperationType='I' BEGIN BEGIN TRY INSERT INTO Employee VALUES (@EmployeeID, @EmployeeName, @Salary, @DesignationID, @DepartmentNo) END TRY BEGIN CATCH SELECT ERROR_MESSAGE() AS Message END CATCH END
    ELSE IF @OperationType='U' BEGIN BEGIN TRY UPDATE Employee SET EmployeeName=@EmployeeName WHERE EmployeeID=@EmployeeID END TRY BEGIN CATCH SELECT ERROR_MESSAGE() AS Message END CATCH END
    ELSE IF @OperationType='D' BEGIN BEGIN TRY DELETE FROM Employee WHERE EmployeeID=@EmployeeID END TRY BEGIN CATCH SELECT ERROR_MESSAGE() AS Message END CATCH END
    ELSE IF @OperationType='O' SELECT @Name = ProjectName FROM Projects WHERE ProjectID=@ProjectID
END
GO

-- 19. CTE (Common Table Expression)
WITH SummeryTable AS (
    SELECT p.ProjectID, p.ProjectName, SUM(Budget) AS SumAmount 
    FROM Employee AS e JOIN Projects AS p ON e.EmployeeID=p.EmployeeID
    GROUP BY p.ProjectID, p.ProjectName
),
TopTable AS ( 
    SELECT ProjectID, MAX(SumAmount) AS MaxSumAmount FROM SummeryTable
    GROUP BY ProjectID
)
SELECT s.ProjectID, s.ProjectName, s.SumAmount, t.MaxSumAmount 
FROM SummeryTable AS s JOIN Toptable AS t ON s.ProjectID = t.ProjectID

-- 20. Simple Case & Search Case
SELECT EmployeeID, DepartmentNo,
CASE DepartmentNo
    WHEN 1 THEN 'IT'
    WHEN 2 THEN 'HR'
    WHEN 3 THEN 'Finance'
    WHEN 4 THEN 'Sales'
END AS Term
FROM Employee
ORDER BY DepartmentNo

SELECT ProjectID, ProjectName, Budget,
CASE 
    WHEN Budget > 120000 THEN 'High Budget'
    WHEN Budget BETWEEN 90000 AND 100000 THEN 'Medium Budget'
    WHEN Budget < 80000 THEN 'Low Budget'
    ELSE 'NONE'
END AS BudgetCategory
FROM Projects

-- 21. Create a Cursor to update data
DECLARE @ProjectID int, @ProjectName varchar(40), @Budget DECIMAL(10,4), @UpdatedCount int;
SET @UpdatedCount = 0;
DECLARE Projects_cursor CURSOR FOR
SELECT ProjectID, ProjectName, Budget FROM Projects WHERE Budget > 0;
OPEN Projects_cursor;
FETCH NEXT FROM Projects_cursor INTO @ProjectID, @ProjectName, @Budget;
WHILE @@FETCH_STATUS = 0
BEGIN  
    UPDATE Projects SET Budget = @Budget * 1.10 WHERE ProjectID = @ProjectID;
    SET @UpdatedCount = @UpdatedCount + 1;
    FETCH NEXT FROM Projects_cursor INTO @ProjectID, @ProjectName, @Budget;
END
CLOSE Projects_cursor;
DEALLOCATE Projects_cursor;

-- 22. Write NTILE() function
SELECT DepartmentName,
NTILE(2) OVER(ORDER BY DepartmentNo) AS Ntile2,
NTILE(3) OVER(ORDER BY DepartmentNo) AS Ntile3,
NTILE(4) OVER(ORDER BY DepartmentNo) AS Ntile4
FROM Departments

-- 23. Create a new table and set MERGE
IF OBJECT_ID('ProjectArchive') IS NOT NULL DROP TABLE ProjectArchive
CREATE TABLE ProjectArchive (ProjectID INT PRIMARY KEY, ProjectName VARCHAR(40) NOT NULL, Budget DECIMAL(10,4), EmployeeID INT)

MERGE ProjectArchive AS PA
USING Projects AS P ON PA.ProjectID = P.ProjectID
WHEN MATCHED THEN
    UPDATE SET PA.ProjectName = P.ProjectName, PA.Budget = P.Budget, PA.EmployeeID = P.EmployeeID
WHEN NOT MATCHED THEN
    INSERT (ProjectID, ProjectName, Budget, EmployeeID) VALUES (P.ProjectID, P.ProjectName, P.Budget, P.EmployeeID);

-- 24. Example of IIF and CHOOSE
SELECT 
    ProjectID,
    SUM(Budget) AS Amount,
    IIF(SUM(Budget) > 60000, 'High', 'Low') AS BudgetStatus
FROM Projects
GROUP BY ProjectID
ORDER BY SUM(Budget) DESC;


-- CHOOSE Example
SELECT 
    EmployeeID,
    EmployeeName,
    DesignationID,
    CHOOSE(
        CASE DesignationID
            WHEN 101 THEN 1
            WHEN 102 THEN 2
            WHEN 103 THEN 3
            WHEN 104 THEN 4
            WHEN 105 THEN 5
            WHEN 106 THEN 6
        END,
        'Developer',
        'Executive',
        'GM',
        'SO',
        'Sr. Engineer',
        'Sr. Executive'
    ) AS DesignationTitle
FROM Employee;

-- 25. Example of ISNULL
SELECT Budget, ISNULL(Budget,0) + 50000 AS AdjustedBudget FROM Projects

-- 26. Ranking functions (ROW_NUMBER, RANK, DENSE_RANK)
SELECT ROW_NUMBER() OVER (Partition BY ProjectName ORDER BY ProjectID) AS RowNumber, ProjectName, ProjectID FROM Projects
SELECT RANK() OVER (ORDER BY ProjectName) AS Rank FROM Projects
SELECT DENSE_RANK() OVER (ORDER BY ProjectName) AS DenseRank FROM Projects

-- 27. Analytic Functions
-- FIRST_VALUE, LAST_VALUE, LEAD, LAG, PERCENT_RANK

SELECT
    ProjectID,
    ProjectName,
    Budget,

    FIRST_VALUE(Budget)
        OVER (ORDER BY ProjectID) AS FirstBudget,

    LAST_VALUE(Budget)
        OVER (
            ORDER BY ProjectID
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING
        ) AS LastBudget,

    LEAD(Budget)
        OVER (ORDER BY ProjectID) AS NextBudget,

    LAG(Budget)
        OVER (ORDER BY ProjectID) AS PreviousBudget,

    PERCENT_RANK()
        OVER (ORDER BY Budget) AS PercentRank

FROM Projects;
-- 28. Example Grouping Sets
SELECT EmployeeID, DesignationID, SUM(Salary) AS SumAmount FROM Employee
GROUP BY GROUPING SETS ((EmployeeID, DesignationID), (DesignationID), ())

-- 29. Example of ANY, ALL, SOME
-- ALL
SELECT *
FROM Projects
WHERE Budget > ALL
(
    SELECT Budget
    FROM Projects
    WHERE EmployeeID = 202
);


-- ANY
SELECT *
FROM Employee
WHERE DepartmentNo > ANY
(
    SELECT DepartmentNo
    FROM Employee
    WHERE EmployeeID = 202
);


-- SOME
SELECT *
FROM Employee
WHERE DepartmentNo > SOME
(
    SELECT DepartmentNo
    FROM Employee
    WHERE EmployeeID = 203
);

-- 31. Example of a nested/savepoint transaction
SELECT DepartmentNo, DepartmentName INTO #DepartmentsCopy FROM Departments WHERE DepartmentNo < 4
BEGIN TRANSACTION
DELETE FROM #DepartmentsCopy WHERE DepartmentNo = 1
SAVE TRAN Department1
DELETE FROM #DepartmentsCopy WHERE DepartmentNo = 2
SAVE TRAN Department2
DELETE FROM #DepartmentsCopy WHERE DepartmentNo = 3
SELECT * FROM #DepartmentsCopy
ROLLBACK TRAN Department2
SELECT * FROM #DepartmentsCopy
COMMIT TRANSACTION

-- 32. Example of Correlated Subquery
SELECT ProjectID, EmployeeID,
(SELECT MAX(Budget) FROM Projects WHERE Projects.ProjectID = ProjectAssigment.ProjectID) AS LatestPBudget
FROM ProjectAssigment

-- 33. Example of OVER clause
SELECT EmployeeName, EmployeeID,
SUM(Salary) OVER (Partition BY EmployeeID) AS salaryTotal
FROM Employee

-- 34. Example of EXISTS operator
SELECT ProjectID, EmployeeID
FROM ProjectAssigment AS PA
WHERE EXISTS (SELECT * FROM Projects AS P WHERE P.ProjectID = PA.ProjectID)




-- 37 (Justify). Calling Sequence Value
SELECT NEXT VALUE FOR ProjectsSequence AS ProjectID;

-- 38. Changing date and time format with CAST and CONVERT
SELECT CAST('25-June-2019 10:00AM' AS DATE)
SELECT FORMAT(CONVERT(datetime,'25-June-2019 10:00 AM'),'hh:mm:ss')