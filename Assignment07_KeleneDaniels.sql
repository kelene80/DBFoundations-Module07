--*************************************************************************--
-- Title: Assignment07
-- Author: KKDaniels
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-08-21,KKDaniels,Created File
-- 2022-08-23,KKDaniels,Modified File
-- 2022-08-24,KKDaniels,Completed File 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KKDaniels')
	 Begin 
	  Alter Database [Assignment07DB_KKDaniels] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KKDaniels;
	 End
	Create Database Assignment07DB_KKDaniels;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KKDaniels;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

---- Show the Current data in the Products,
--Select * From vProducts;
--go

---- Change format of price to U.S. Dollars

--Select ProductName,
--	Format(UnitPrice,'C', 'en-US') AS'UnitPrice'
-- From vProducts;

---- Final Code- Order By
go
Select ProductName,
	Format(UnitPrice,'C', 'en-US') AS'UnitPrice'
From vProducts
Order By ProductName;

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

---- Show the Current data in the Products,
--Go
--Select * From vCategories;
--go
--Select * From vProducts;

---- Join tables to display category/product names and unit price
--go

--Select C.CategoryName, P.ProductName,P.UnitPrice
--From vCategories as C
--	Join vProducts as P
--	 On C.CategoryID = P.CategoryID;

--go
------ Use function to format price as US dollars

--Select C.CategoryName, P.ProductName,
--	Format(UnitPrice,'C', 'en-US') AS'UnitPrice'
--From vCategories as C
--	Join vProducts as P
--	 On C.CategoryID = P.CategoryID;

go
---- Final Code- Order By

Select C.CategoryName, P.ProductName,
	Format(UnitPrice,'C', 'en-US') AS'UnitPrice'
From vCategories as C
	Join vProducts as P
	 On C.CategoryID = P.CategoryID
Order By C.CategoryName,P.ProductName;

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

---- Show the Current data in the Products,Inventories
--Go
--Select * From vProducts;
--go
--Select * From vInventories;

---- Join tables to display product names, inventory date, inventory count
--go
--Select P.ProductName, I.InventoryDate,I.Count
--From vProducts as P
--	Join vInventories as I
--	 On P.ProductID = I.ProductID;

go
----- Use function to format date like 'January,2017

--Select P.ProductName,I.Count,
--	FORMAT(i.InventoryDate,'MMMM,yyyy') AS InventoryDate
--From vProducts as P
--	Join vInventories as I
--	 On P.ProductID = I.ProductID;

Go
---- Final Code- Order By

Select P.ProductName,
	FORMAT(i.InventoryDate,'MMMM,yyyy') AS InventoryDate,
		I.Count
From vProducts as P
	Join vInventories as I
	 On P.ProductID = I.ProductID
Order By P.ProductName, Month([InventoryDate]), 3;


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
go

---- Show the Current data in the Products,Inventories
--Go
--Select * From vProducts;
--go
--Select * From vInventories;
Go

---- Join tables and format date

--Select P.ProductName,
--	FORMAT(i.InventoryDate,'MMMM,yyyy') AS InventoryDate,
--		I.Count
--From vProducts as P
--	Join vInventories as I
--	 On P.ProductID = I.ProductID;

Go

-- Add Sort By Using Cast
--Select P.ProductName,
--	FORMAT(i.InventoryDate,'MMMM,yyyy') AS InventoryDate,
--		I.Count
--From vProducts as P
--	Join vInventories as I
--	 On P.ProductID = I.ProductID
--Order By P.ProductName, Cast ([InventoryDate] AS date), 3;

Go
---- Create The View- final

Create -- Alter
View vProductInventories 
AS
	Select Top 100000
	    P.ProductName,
		Format(InventoryDate,'MMMM, yyyy') AS InventoryDate,
		Count As InventoryCount
From vProducts AS P
	Join vInventories as I
		On P.ProductId = I.ProductID
Order By P.ProductName, Month([InventoryDate]), 3;

 Check that it works: Select * From vProductInventories;

--- verified and it works great.

go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
go

---- Show the Current data in the Products,Inventories
--go
--Select * From vCategories;
--go
--Select * From vInventories
--go
--Select * From vProducts;

Go

---- Join tables,format date, group by, order by

--Select C.CategoryName,
--	FORMAT(I.InventoryDate,'MMMM,yyyy') AS InventoryDate,
--	Sum(I.Count) As InventoryCountByCategort
--From vCategories as C
--	Join vProducts as P
--	 On P.CategoryID = C.CategoryID
--	Join vInventories as I
--	 On I.ProductID = P.ProductID
--Group By C.CategoryName,I.InventoryDate
--Order By C.CategoryName, Month(InventoryDate);

go

---- Create View final

Create -- or Alter
View vCategoryInventories
AS
 Select Top 1000000
	c.CategoryName,
	FORMAT(i.InventoryDate,'MMMM,yyyy') AS InventoryDate,
	sum(i.Count) As InventoryCountByCategory
From vCategories AS C
	Join vProducts as P
	 On P.CategoryID = C.CategoryID
	Join vInventories as I
	 On I.ProductID = P.ProductID
Group By C.CategoryName,InventoryDate
Order By C.CategoryName, Month(InventoryDate);

 --Check that it works: Select * From vCategoryInventories;

 --- works great yeah!!!!
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
go

---- look at date from vProductInventories

--Select * From vProductInventories;

Go

---- Review data from vProductInventories to add lag

--Select
--	ProductName, 
--	InventoryDate,
--	InventoryCount,
--	[PreviousMountCount] = Lag(Sum(InventoryCount)) Over (Order By Month(InventoryDate))
--From vProductInventories 

Go

---- Include Group By and Order By

--Select
--	ProductName, 
--	InventoryDate,
--	InventoryCount,
--	[PreviousMountCount] = Lag(Sum(InventoryCount)) Over (Order By Month(InventoryDate))
--From vProductInventories
--Group By ProductName, InventoryDate,InventoryCount
--Order By ProductName,Month(InventoryDate);

go

---- address null
--Select
--	ProductName, 
--	InventoryDate,
--	InventoryCount,
--	PreviousMonthCount = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate)))
--	From vProductInventories
--	Group By ProductName, InventoryDate, InventoryCount
--	Order By ProductName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date)


---- Create View final script

Create
View vProductInventoriesWithPreviousMonthCounts
AS
 Select Top 100000
	ProductName, 
	InventoryDate,
	InventoryCount,
	PreviousMonthCount = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over(Order By ProductName, Month(InventoryDate)))
From vProductInventories
Group By ProductName, InventoryDate, InventoryCount
Order By ProductName, Cast(DateName(mm, InventoryDate) + ', ' + Datename(yy, InventoryDate) as date) 


-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

--- it worked

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

--- see steps from question 6 on how vproductInventoriesWithPreviousMonthCounts

Go

---- determine inventory count based on 1,0,-1 criteria

--Select
--	InventoryCount,
--	PreviousMonthCount,
--KPI = Case
--	When InventoryCount > PreviousMonthCount Then 1
--	When InventoryCount = PreviousMonthCount Then 0
--	When InventoryCount < PreviousMonthCount Then -1
--	End
--From vProductInventoriesWithPreviousMonthCounts;

Go

---- include other column data- product names, inventory date

--Select
--	ProductName,
--	InventoryDate,
--	InventoryCount,
--	PreviousMonthCount,
--KPI = Case
--	When InventoryCount > PreviousMonthCount Then 1
--	When InventoryCount = PreviousMonthCount Then 0
--	When InventoryCount < PreviousMonthCount Then -1
--	End
--From vProductInventoriesWithPreviousMonthCounts;

Go
---- Create View final script
Create or Alter
View vProductInventoriesWithPreviousMonthCountsWithKPIs
AS

Select
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
	End
From vProductInventoriesWithPreviousMonthCounts;

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

--- verified and script worked


-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
go

---- Use code from question 7 that determined KPI script

--- Final Script 

Create or Alter 
Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
As
    Return (Select
			ProductName,
			InventoryDate,
			InventoryCount,
			PreviousMonthCount,
			CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
Where CountVsPreviousCountKPI = @KPI)
					

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

---- verified code work

/***************************************************************************************/