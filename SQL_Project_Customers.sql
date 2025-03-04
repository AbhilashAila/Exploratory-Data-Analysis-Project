/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

--USE master;
--GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
--IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
--BEGIN
--    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--    DROP DATABASE DataWarehouseAnalytics;
--END;
--GO

---- Create the 'DataWarehouseAnalytics' database
--CREATE DATABASE DataWarehouseAnalytics;
--GO

--USE DataWarehouseAnalytics;
--GO

-- Create Schemas

--CREATE SCHEMA gold;
--GO

--CREATE TABLE gold.dim_customers(
--	customer_key int,
--	customer_id int,
--	customer_number nvarchar(50),
--	first_name nvarchar(50),
--	last_name nvarchar(50),
--	country nvarchar(50),
--	marital_status nvarchar(50),
--	gender nvarchar(50),
--	birthdate date,
--	create_date date
--);
--GO

--CREATE TABLE gold.dim_products(
--	product_key int ,
--	product_id int ,
--	product_number nvarchar(50) ,
--	product_name nvarchar(50) ,
--	category_id nvarchar(50) ,
--	category nvarchar(50) ,
--	subcategory nvarchar(50) ,
--	maintenance nvarchar(50) ,
--	cost int,
--	product_line nvarchar(50),
--	start_date date 
--);
--GO

--CREATE TABLE gold.fact_sales(
--	order_number nvarchar(50),
--	product_key int,
--	customer_key int,
--	order_date date,
--	shipping_date date,
--	due_date date,
--	sales_amount int,
--	quantity tinyint,
--	price int 
--);
--GO

--TRUNCATE TABLE gold.dim_customers;
--GO

--BULK INSERT gold.dim_customers
--FROM 'C:\Users\user\Downloads\SQL\gold.dim_customers.csv'
--WITH (
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	TABLOCK
--);
--GO

--TRUNCATE TABLE gold.dim_products;
--GO

--BULK INSERT gold.dim_products
--FROM 'C:\Users\user\Downloads\SQL\gold.dim_products.csv'
--WITH (
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	TABLOCK
--);
--GO

--TRUNCATE TABLE gold.fact_sales;
--GO

--BULK INSERT gold.fact_sales
--FROM 'C:\Users\user\Downloads\SQL\gold.fact_sales.csv'
--WITH (
--	FIRSTROW = 2,
--	FIELDTERMINATOR = ',',
--	TABLOCK
--);
--GO
--select * from gold.dim_customers
--select * from gold.dim_products
--select * from gold.fact_sales
--select 
--year(order_date) as Order_Year,
--Month(order_date) as Order_Month,
--SUM(sales_amount) as Total_Sales,
--COUNT(distinct customer_key) as Total_Customers,
--SUM(quantity) as Total_Qty
--from gold.fact_sales
--where order_date is Not Null
--group by year(order_date), Month(order_date)
--order by year(order_date),Month(order_date)

--select 
--Datetrunc(MONTH,order_date) as Order_Year,
--SUM(sales_amount) as Total_Sales,
--COUNT(distinct customer_key) as Total_Customers,
--SUM(quantity) as Total_Qty
--from gold.fact_sales
--where order_date is Not Null
--group by Datetrunc(MONTH,order_date)
--order by Datetrunc(MONTH,order_date)


--- Calculate the total sales per month
--- and the running total of sales over time
--select 
--Order_Year,
--Total_Sales,
--SUM(Total_Sales) over( order by Order_Year) as Running_Total_Sales,
--AVG(Total_Sales) over(order by Order_Year) as Running_Avg_Sales
--from (
--select 
--Datetrunc(YEAR,order_date) as Order_Year,
--sum(sales_amount) as Total_Sales,
--avg(sales_amount) as Avg_Sales
--from gold.fact_sales
--where order_date is Not Null
--group by Datetrunc(YEAR,order_date)
--) a


-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales 

--with Yearly_Prod_Sales as (
--select 
--year(s.order_date) as order_year, p.product_name, sum(s.sales_amount) as Total_Amt
--from gold.fact_sales s
--left join gold.dim_products p
--on s.product_key=p.product_key
--where s.order_date is Not Null
--group by year(s.order_date),p.product_name
--)
--select 
--order_year,product_name,Total_Amt, Avg(Total_Amt) over(partition by product_name ) Avg_Sales,
--Total_Amt-Avg(Total_Amt) over(partition by product_name ) as Diff_Avg,
--case when Total_Amt-Avg(Total_Amt) over(partition by product_name ) > 0 then 'Above Avg'
--          when Total_Amt-Avg(Total_Amt) over(partition by product_name ) < 0 then 'Below Avg'
--		  else 'Avg '  end as Avg_Change,
--LAG(Total_Amt) over(partition by product_name order by order_year) as PY_Sales,
--Total_Amt-LAG(Total_Amt) over(partition by product_name order by order_year) as Diff_PY_Sales,
--case when Total_Amt-LAG(Total_Amt) over(partition by product_name order by order_year)> 0 then 'Increase'
--          when Total_Amt-LAG(Total_Amt) over(partition by product_name order by order_year)< 0 then 'Decrease'
--		  else 'No Change'  end as Avg_Changef
--from Yearly_Prod_Sales



-- Which Category Contributes the most to overall sales

--select  
--category,
--Total_Amt, 
--SUM(Total_Amt) over() as Overall_Total,
--concat(format(Total_Amt*1.0/ SUM(Total_Amt) over() *100,'N2'),'%') as Percentage_Of_Total 
--from(
--select 
--p.category,
--sum(sales_amount) as Total_Amt
--from gold.fact_sales s
--left join gold.dim_products p
--on s.product_key=p.product_key
--group by p.category ) a
--order by Percentage_Of_Total desc


--Segment products into cost ranges and count how many products fall into each segment.
--With Product_Segment as (
--select 
--product_key,
--product_name,
--cost,
--case When cost <100 Then 'Below 100'
--          When cost between 100 and 500 then '100 - 500'
--		  When cost between 500 and 1000 then '500 - 1000'
--		  else 'Above 1000'
--		  end as Cost_Range
--from gold.dim_products ) 
--select 
--Cost_Range,
--COUNT(product_key) as Total_Products
--from Product_Segment
--group by Cost_Range
--order by Total_Products desc



--/ *Group customers into three segments based on their spending behavior:
--- VIP: Customers with at least 12 months of history and spending more than €5,000.
--Regular: Customers with at least 12 months of history but spending €5,000 or less
--New: Customers with a lifespan less than 12 months.
--And find the total number of customers by each group

--with Cust_Spending as (
--select 
--c.customer_key,
--sum(sales_amount) as Total_Spending,
--DATEDIFF(MONTH,min(order_date),max(order_date)) as Life_Span_Months
--from gold.fact_sales s
--left join gold.dim_customers c
--on s.customer_key=c.customer_key
--where order_date is Not Null
--group by c.customer_key)
--select 
--Cust_Group,COUNT(customer_key) as Total_Customers
--from(
--select 
--customer_key,
--case when Total_Spending > 5000  and Life_Span_Months >=12 then 'VIP'
--          when Total_Spending <= 5000 and Life_Span_Months >=12 then 'Regular'
--		  else 'New'
-- 		  end  Cust_Group
--from Cust_Spending) a
--group by Cust_Group
--order by Total_Customers desc


--Customer Report
--Purpose: This report consolidates key customer metrics and behaviors
--Highlights :
--Gathers essential fields such as names, ages, and transaction details.
--Segments customers into categories (VIP, Regular, New) and age groups.
--Aggregates customer-level metrics:
--- total orders
--- total sales
--- total quantity purchased
--- total products
--- lifespan (in months)
--Calculates valuable KPIs:
--- recency (months since last order)
--- average order value
--- average monthly spend

--with basic_details as (
--select 
--s.order_number,
--s.product_key,
--s.order_date,
--s.sales_amount,
--s.quantity,
--c.customer_key,
--c.customer_number,
--CONCAT(c.first_name , ' ' , c.last_name) as Customer_Name,
--DATEDIFF(YEAR,c.birthdate,GETDATE()) as Age
--from gold.fact_sales s
--left join gold.dim_customers c
--on s.customer_key=c.customer_key
--where s.order_date is Not null),
-- aggregated as  (
--select 
--customer_key,
--Customer_Name,
--customer_number,
--age,
--SUM(sales_amount) as Total_Amt,
--COUNT(distinct order_number) as Total_Orders,
--SUM(quantity) as Total_Quantity,
--COUNT(distinct product_key) as Total_products,
--max(order_date) as Last_Order,
--DATEDIFF(MONTH,MIN(order_date),Max(order_date)) as Life_Span
--from basic_details
--group by customer_key,
--Customer_Name,
--customer_number,
--age
--)
--select 
--customer_key,
--Customer_Name,
--customer_number,
--age, 
--case when age < 20 then 'Under 20'
--          when age between 20 and 29 then '20-29'
--		  when age between 30 and 39 then '30-39'
--		  when age between 40 and 49 then '40-49'
--		  else 'Above 50'
--		  end as Age_group,
--case when Life_Span>=12 and Total_Amt>5000 then 'VIP'
--           when Life_Span >=12 and Total_Amt <=5000 then 'Regular'
--		   else 'New'
--		   end as Cus_Group,
--Total_Amt,
--Total_Orders,
--Total_Quantity,
--Total_products,
--datediff(Month,Last_Order,getdate()) as Recency,
--case when Total_Amt = 0 then 0
--else
--Total_Amt/Total_Orders
--end as Avg_Order_Value,
--case when Life_Span = 0 then 0 
--else
--Total_Amt/Life_Span
--end as Avg_Monthly_Spend
--from aggregated


--create View gold.report_cust as 
--with basic_details as (
--select 
--s.order_number,
--s.product_key,
--s.order_date,
--s.sales_amount,
--s.quantity,
--c.customer_key,
--c.customer_number,
--CONCAT(c.first_name , ' ' , c.last_name) as Customer_Name,
--DATEDIFF(YEAR,c.birthdate,GETDATE()) as Age
--from gold.fact_sales s
--left join gold.dim_customers c
--on s.customer_key=c.customer_key
--where s.order_date is Not null),
-- aggregated as  (
--select 
--customer_key,
--Customer_Name,
--customer_number,
--age,
--SUM(sales_amount) as Total_Amt,
--COUNT(distinct order_number) as Total_Orders,
--SUM(quantity) as Total_Quantity,
--COUNT(distinct product_key) as Total_products,
--max(order_date) as Last_Order,
--DATEDIFF(MONTH,MIN(order_date),Max(order_date)) as Life_Span
--from basic_details
--group by customer_key,
--Customer_Name,
--customer_number,
--age
--)
--select 
--customer_key,
--Customer_Name,
--customer_number,
--age, 
--case when age < 20 then 'Under 20'
--          when age between 20 and 29 then '20-29'
--		  when age between 30 and 39 then '30-39'
--		  when age between 40 and 49 then '40-49'
--		  else 'Above 50'
--		  end as Age_group,
--case when Life_Span>=12 and Total_Amt>5000 then 'VIP'
--           when Life_Span >=12 and Total_Amt <=5000 then 'Regular'
--		   else 'New'
--		   end as Cus_Group,
--Total_Amt,
--Total_Orders,
--Total_Quantity,
--Total_products,
--datediff(Month,Last_Order,getdate()) as Recency,
--case when Total_Amt = 0 then 0
--else
--Total_Amt/Total_Orders
--end as Avg_Order_Value,
--case when Life_Span = 0 then 0 
--else
--Total_Amt/Life_Span
--end as Avg_Monthly_Spend
--from aggregated


select * from gold.report_cust






