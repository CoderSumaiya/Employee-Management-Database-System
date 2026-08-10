USE master
GO
IF DB_ID('EmployeeDB') IS NOT NULL
DROP DATABASE EmployeeDB
GO
CREATE DATABASE EmployeeDB
ON(
NAME = EmployeeDB_Data_1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLSERVER\MSSQL\DATA\EmployeeDB_Data_1.mdf',
SIZE = 25MB,
MAXSIZE = 100MB,
FILEGROWTH = 5%
)
LOG ON(
NAME = EmployeeDB_Log_1,
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLSERVER\MSSQL\DATA\EmployeeDB_Log_1.ldf', 
SIZE = 2MB,
MAXSIZE = 25MB,
FILEGROWTH = 1%
)

USE EmployeeDB
GO

-- 1. Create Tables (Database Schema)
CREATE TABLE Departments(
DepartmentNo int Primary Key NOT NULL,
DepartmentName Varchar(20) NOT NULL
)

CREATE TABLE Designation(
DesignationID int Primary Key NOT NULL,
DesignationTitle varchar(30) NOT NULL
)

CREATE TABLE Employee(
EmployeeID int Primary Key NOT NULL,
EmployeeName Varchar(30) NOT NULL,
Salary DECIMAL (10,4),
DesignationID int NOT NULL REFERENCES Designation(DesignationID),
DepartmentNo int NOT NULL REFERENCES Departments(DepartmentNo) 
)

CREATE TABLE Projects(
ProjectID int Primary Key NOT NULL,
ProjectName Varchar(40) NOT NULL,
Budget DECIMAL(10,4),
EmployeeID int NOT NULL REFERENCES Employee(EmployeeID) 
)

CREATE TABLE ProjectAssigment(
ProjectID int NOT NULL REFERENCES Projects(ProjectID), 
EmployeeID int NOT NULL REFERENCES Employee(EmployeeID),
WorkHour DECIMAL (5,2),
PRIMARY KEY (ProjectID, EmployeeID)
)

-- 6. Write a script to Create a table (TestTable)
CREATE TABLE TestTable
(
    TestID INT PRIMARY KEY NOT NULL,
    Name VARCHAR(20),
    CreatedDate DATETIME DEFAULT GETDATE()
)
GO

-- 7. Write a script to delete a table
IF OBJECT_ID('TestTable') IS NOT NULL
 DROP TABLE TestTable
GO

-- 11. Create a view to show all IT department employees
CREATE VIEW vw_EmployeesInfoTechnology
AS
SELECT 
e.EmployeeID, e.EmployeeName, d.DepartmentName, e.DesignationID
FROM Employee AS e 
JOIN Departments d ON e.DepartmentNo = d.DepartmentNo
WHERE d.DepartmentName = 'IT'
GO

-- 12. Create Stored Procedure (CRUD with Output Parameter)
IF OBJECT_ID('spEmployeeCRUD_Output') IS NOT NULL
DROP PROCEDURE spEmployeeCRUD_Output
GO

CREATE PROC spEmployeeCRUD_Output
(
    @OperationType CHAR(1),
    @EmployeeID INT,
    @EmployeeName VARCHAR(30),
    @Salary DECIMAL(10,4),
    @DesignationID INT,
    @DepartmentNo INT,
    @ProjectID INT,
    @ProjectName VARCHAR(40) OUTPUT
)
AS
BEGIN
    IF @OperationType='S'
        SELECT * FROM Employee
    ELSE IF @OperationType='I'
        INSERT INTO Employee(EmployeeID, EmployeeName, Salary, DesignationID, DepartmentNo)
        VALUES (@EmployeeID, @EmployeeName, @Salary, @DesignationID, @DepartmentNo)
    ELSE IF @OperationType='U'
        UPDATE Employee SET EmployeeName=@EmployeeName, Salary=@Salary, DesignationID=@DesignationID, DepartmentNo=@DepartmentNo WHERE EmployeeID=@EmployeeID
    ELSE IF @OperationType='D'
        DELETE FROM Employee WHERE EmployeeID=@EmployeeID
    ELSE IF @OperationType='O'
        SELECT @ProjectName = ProjectName FROM Projects WHERE ProjectID=@ProjectID
END
GO

-- 13. Create a Non Clustered Index
CREATE NONCLUSTERED INDEX IX_Employee_DepartmentNo 
ON Employee (DepartmentNo);
GO

-- 14. Create a Scalar Function for Department Total Budget
IF OBJECT_ID('fn_DepartmentTotalBudget') IS NOT NULL
DROP FUNCTION fn_DepartmentTotalBudget
GO

CREATE FUNCTION fn_DepartmentTotalBudget (@DepartmentNo INT)
RETURNS DECIMAL(10,4)
AS
BEGIN
    DECLARE @TotalBudget DECIMAL(10,4)
    SELECT @TotalBudget = SUM(p.Budget)
    FROM Projects p
    INNER JOIN Employee e ON p.EmployeeID = e.EmployeeID
    WHERE e.DepartmentNo = @DepartmentNo
    RETURN @TotalBudget
END
GO

-- 15. Create Trigger on Insert, Update, Delete
IF OBJECT_ID('tr_Employee_IUD') IS NOT NULL
DROP TRIGGER tr_Employee_IUD
GO

CREATE TRIGGER tr_Employee_IUD
ON Employee
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    PRINT 'Employee table data changed successfully'
END
GO


-- 17. Create a Table-Valued Function
-- to get Department wise detail information

IF OBJECT_ID('fn_GetDepartmentDetails') IS NOT NULL
    DROP FUNCTION fn_GetDepartmentDetails;
GO

CREATE FUNCTION fn_GetDepartmentDetails
(
    @DepartmentNo INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        EmployeeID,
        EmployeeName,
        Salary,
        DesignationID,
        DepartmentNo
    FROM Employee
    WHERE DepartmentNo = @DepartmentNo
);
GO

-- Justify
SELECT *
FROM fn_GetDepartmentDetails(1);

-- 30. Example of ALTER, CREATE, DROP table
CREATE TABLE TestEmployee (TestID INT PRIMARY KEY, TestName VARCHAR(30))
ALTER TABLE TestEmployee ADD Salary DECIMAL(10,2)
DROP TABLE TestEmployee
GO
-- 35 Create a View to show all employee, department, project, and designation details
IF OBJECT_ID('dbo.vw_EmployeeCompleteDetails', 'V') IS NOT NULL
    DROP VIEW dbo.vw_EmployeeCompleteDetails;
GO

CREATE VIEW dbo.vw_EmployeeCompleteDetails
AS
SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentNo,
    d.DepartmentName,
    des.DesignationID,
    des.DesignationTitle,
    p.ProjectID,
    p.ProjectName,
    p.Budget
FROM Employee AS e
LEFT JOIN Departments AS d
    ON e.DepartmentNo = d.DepartmentNo
LEFT JOIN Designation AS des
    ON e.DesignationID = des.DesignationID
LEFT JOIN Projects AS p
    ON e.EmployeeID = p.EmployeeID;
GO

-- Calling the View
SELECT *
FROM dbo.vw_EmployeeCompleteDetails;

-- 36. Create a View to show all employee,
-- department and project details
IF OBJECT_ID('dbo.vw_EmployeeDepartmentProject', 'V') IS NOT NULL
    DROP VIEW dbo.vw_EmployeeDepartmentProject;
GO
CREATE VIEW dbo.vw_EmployeeDepartmentProject
AS
SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentNo,
    d.DepartmentName,
    p.ProjectID,
    p.ProjectName,
    p.Budget
FROM Employee AS e
LEFT JOIN Departments AS d
    ON e.DepartmentNo = d.DepartmentNo
LEFT JOIN Projects AS p
    ON e.EmployeeID = p.EmployeeID;
GO
-- 36. Calling View 
SELECT *
FROM dbo.vw_EmployeeDepartmentProject;
-- 37. Example of Sequence
CREATE SEQUENCE projectsSequence AS int START WITH 1001 INCREMENT BY 1 MINVALUE 1001 MAXVALUE 99999 CYCLE CACHE 10
GO