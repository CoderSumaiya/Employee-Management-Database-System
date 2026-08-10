# Employee Management System - Advanced T-SQL Project

A comprehensive relational database project built using Microsoft SQL Server (T-SQL), demonstrating advanced database administration, programming concepts, and complex querying.

## 🚀 Project Overview
This project implements a fully normalized (3NF) Employee Management Database system named **EmployeeDB**. 
It manages departments, designations, employees, projects,
and work assignments while utilizing enterprise-level database features like Stored Procedures, Triggers, Cursors, CTEs, and Error Handling.

---

## 🛠️ Key Features & Technical Implementation

* **Database Architecture (3NF):** Custom database file configurations (Data and Log files with specific size, max size,
   and growth settings) and tables with proper Primary and Foreign Key constraints.
* **Advanced T-SQL Programming:**
  * **Stored Procedures & Functions:** CRUD operations with Output parameters, Scalar-valued functions, and Table-valued functions.
  * **Triggers & Indexes:** Automated logging/messages via `AFTER` triggers and performance optimization using Non-Clustered Indexes.
  * **Transactions & Error Handling:** Implementation of `BEGIN TRY...CATCH`, explicit transactions, rollbacks, and nested/savepoint transactions.
  * **Advanced Analytics:** Window functions (`NTILE`, `ROW_NUMBER`, `RANK`, `DENSE_RANK`), Analytic functions
  (`FIRST_VALUE`, `LEAD`, `LAG`, `PERCENT_RANK`), Grouping Sets, and Common Table Expressions (CTEs).
  * **Automation:** Cursors for iterative data updates and `MERGE` statements for synchronizing archive tables.
* **Data Management:** Complex Joins, Subqueries, Correlated Subqueries, `EXISTS`, `ANY/ALL`, and date/time formatting with `CAST`/`CONVERT`.

---

## 🗄️ Database Schema & Tables
1. **`Departments`**: Stores department details (IT, HR, Finance, Sales).
2. **`Designation`**: Stores job titles and designation IDs.
3. **`Employee`**: Main employee records linked to departments and designations.
4. **`Projects`**: Project details and assigned budgets.
5. **`ProjectAssigment`**: Junction table tracking employee work hours per project.

---

## 💻 How to Run the Script
1. Open **SQL Server Management Studio (SSMS)**.
2. Open the provided SQL script file.
3. Execute the script from top to bottom. It will automatically handle database creation, table schema setup, constraints, sample data insertion, and all advanced queries/procedures.

---

## 👤 Author
**Sumaiya Akter**  
.NET Developer | Full-Stack & Database Enthusiast
