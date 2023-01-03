
-- The purpose of this project is to use the data to understand trends, patterns and revenue from other machines to determine where the next location of our new vending machine will be placed  
-- user behavior, user consumption habits, and overall preferences by consumers at different locations also place a factor

SELECT *
FROM vending_machine_sales;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- select data that we are going to be using throughout analysis

SELECT 
  Location,
  Machine,
  Product,
  Category,
  [Prcd Date],
  Type,
  LineTotal,
  RQty,
  [Device ID],
  TransactionNumber
FROM vending_machine_sales
ORDER BY TransactionNumber;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Total sale per transaction
-- We are finding the LineTotal because the TransactionNumber is repeated in multiple rows
-- This query is showing each TransactionNumbers total sales having the highest tranaction of $8

SELECT
	TransactionNumber,
	SUM(LineTotal) as TotalSalesPerTransaction
FROM vending_machine_sales
GROUP BY TransactionNumber
ORDER BY 1;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Cash vs Credit to determine which type of payment the average consumer uses for purchases
-- As you can see, more consumers used Cash over Credit as a prefer source of payment

SELECT  
	convert(int,round(66.671800,0)) as CashWholePercent,
	convert(int,round(33.328100,0)) as CreditWholePercent,
	SUM(CASE WHEN Type = 'Cash' THEN 1.0 ELSE 0.0 END)/count(Type) * 100	as DecimalPercentageCashTransaction,
	SUM(CASE WHEN Type = 'Credit' THEN 1.0 ELSE 0.0 END)/count(Type) * 100	as DecimalPercentageCreditTransaction
FROM vending_machine_sales;




---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- First, we must find the total sales from each location and which location generated the most profit
-- TotalSales per machine:
--Brunswick Sq Mall: $2,537.50
--Earle Asphalt: $1,193.50
--EB Public Library: $3,950.25
--GuttenPlans: $4,884.25


SELECT Location,
	SUM(LineTotal)
FROM vending_machine_sales 
GROUP BY Location
ORDER BY 1 desc;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Here we are searching for which month had the highest sales per machine, Finding this information out will allow us to find the peak seasons for MaxProfit vs less Products
-- Again, I used OVER PARTITION BY function to create a rolling number for total sales per month by machine to show each months balance statement to determine highest month and if there was a peak season
-- Highest TotalSales per month by machine: 
--Earle Asphalt x1371: $203.25      AUGUST, 2022
--BSQ Mall x1366 - ATT: $224        JULY, 2022
--BSQ Mall x1364 - Zales: $252      JULY, 2022
--EB Public Library x1380: $855.75  JUNE, 2022
--GuttenPlans x1367: $900           JULY, 2022


SELECT Machine, CONVERT(date, [Prcd Date]) as Date, LineTotal, SUM(LineTotal)
	OVER (PARTITION BY Machine, YEAR([Prcd Date]), MONTH([Prcd Date])
		ORDER BY Machine, [Prcd Date]) as RollingTotalSalesPerMonth
FROM vending_machine_sales 
ORDER BY 1;



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Which category sold the most products out of all vending machines
-- We are searching for only the top 5 snacks per machine


--THIS QUERY SHOWS THE TOP 5 PRODUCTS SOLD FOR MACHINE "BSQ Mall x1364 - Zales"
-- THIS MACHINE SOLD MORE BEVERAGES THAN ANY OTHER CATEGORY, THIS LOCATION IS INSIDE OF A MALL WHERE PEOPLE ARE MORE LIKELY TO PURCHASE DRINKS MORE THAN ANYTHING ELSE
SELECT TOP (5) Product,
  Category,
  COUNT(RQty) as TotalQuantitySold,
  [Device ID],
  Machine
FROM vending_machine_sales
--WHERE Category is not null
   --and Product is not null
WHERE [Device ID] = 'VJ300205292'
GROUP BY [Device ID], Category, Product, Machine
ORDER BY 3 DESC;



--THIS QUERY SHOWS THE TOP 5 PRODUCTS SOLD FOR MACHINE "BSQ Mall x1366 - ATT"
-- THIS LOCATION HAD THE LEAST AMOUNT OF TOTAL PRODUCTS SOLD AMOUNG THE OTHER MACHINES; THE PRODUCTS SOLD ARE A MIXTURE OF FOOD AND BEVERAGES
-- THE LOCATION OF THIS MACHINE IS ALSO INSIDE OF A MALL WHERE PEOPLE WOULD TYPICALLY PURCHASE A SNACK AND OR A BEVERAGE
SELECT TOP (5) Product,
  Category,
  COUNT(RQty) as TotalQuantitySold,
  [Device ID],
  Machine
FROM vending_machine_sales
--WHERE Category is not null
   --and Product is not null
WHERE [Device ID] = 'VJ300320611'
GROUP BY [Device ID], Category, Product, Machine
ORDER BY 3 DESC;



-- THIS QUERY SHOWS THE TOP 5 PRODUCTS SOLD FOR MACHINE "Earle Asphalt x1371"
-- THIS MACHINE SHOWS THE MOST QUANTITY OF PRODUCTS SOLD WERE FOOD RELATED ITEMS, IT'S SAFE TO ASSUME THIS LOCATION IS MOST LIKELY LOCATED SOMEWHERE CHILDREN GATHER; GENERATING LESS REVENUE
SELECT TOP (5) Product,
  Category,
  COUNT(RQty) as TotalQuantitySold,
  [Device ID],
  Machine
FROM vending_machine_sales
--WHERE Category is not null
   --and Product is not null
WHERE [Device ID] = 'VJ300320686'
GROUP BY [Device ID], Category, Product, Machine
ORDER BY 3 DESC;



--THIS QUERY SHOWS THE TOP 5 PRODUCTS SOLD FOR MACHINE "GuttenPlans x1367"
-- THIS QUERY SHOWS MORE BEVERAGES WITH CAFFINE WERE SOLD MORE THAN ANYTHING ELSE (NOT INCLUDING THE KITKAT BAR) SHOWING THE HIGHEST QUANTITY SALES AMOUNG ANY OTHER MACHINE
SELECT TOP (5) Product,
  Category,
  COUNT(RQty) as TotalQuantitySold,
  [Device ID],
  Machine
FROM vending_machine_sales
--WHERE Category is not null
   --and Product is not null
WHERE [Device ID] = 'VJ300320609'
GROUP BY [Device ID], Category, Product, Machine
ORDER BY 3 DESC;



--THIS QUERY SHOWS THE TOP 5 PRODUCTS SOLD FOR MACHINE "EB Public Library x1380"
-- THIS QUERY SHOWS THAT THE LIBRARY LOCATION SOLD MORE BEVERAGES THAN ANYTHING ELSE
SELECT TOP (5) Product,
  Category,
  COUNT(RQty) as TotalQuantitySold,
  [Device ID],
  Machine
FROM vending_machine_sales
--WHERE Category is not null
   --and Product is not null
WHERE [Device ID] = 'VJ300320692'
GROUP BY [Device ID], Category, Product, Machine
ORDER BY 3 DESC;


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Total profit and total quantity sold by highest rated category 
-- We are trying to determine which snacks and beverages we should put into the new machine to generate max profit



-- THIS QUERY SHOWS THE HIGHEST SOLD CARBONATED DRINKS BY TOTALQUANTITYSOLD VS $$TOTALSALES$$
-- ALL 5 CARBONATED PRODUCTS WILL BE PLACED IN THE NEW MACHINE SINCE THEY GENERATED A LARGE PORTION OF EACH MACHINES REVENUE
SELECT TOP (5) Product,
  COUNT(RQty) as TotalQuantitySold,
  SUM(LineTotal) as TotalSales,
  Category
FROM vending_machine_sales
--WHERE Category is not null
  -- and Product is not null
WHERE Category = 'Carbonated'
GROUP BY Category, Product
ORDER BY 2 DESC;



-- THIS QUERY SHOWS THE HIGHEST SOLD NON CARBONATED BEVERAGES BY TOTALQUANTITYSOLD VS $$TOTALSALES$$
-- WE WILL BE TAKING THE TOP 5 NON CARBONATED BEVERAGES SINCE EACH PRODUCT IS MORE THAN DOUBLED SALES VS QUANTITY
SELECT TOP (5) Product,
  COUNT(RQty) as TotalQuantitySold,
  SUM(LineTotal) as TotalSales,
  Category
FROM vending_machine_sales
--WHERE Category is not null
  -- and Product is not null
WHERE Category = 'Non Carbonated'
GROUP BY Category, Product
ORDER BY 2 DESC;



-- THIS QUERY SHOWS THE HIGHEST SOLD WATER BEVERAGES BY TOTALQUANTITYSOLD VS $$TOTALSALES$$
-- THE WATER PRODUCTS WILL ALWAYS GENERATED REVENUE DUE TO BEING THE HEALTHIER ALTERNATIVE COMPARED TO CAFFINED BEVERAGES; WE WILL BE TAKING THE TOP 4 BEVERAGES
SELECT TOP (4) Product,
  COUNT(RQty) as TotalQuantitySold,
  SUM(LineTotal) as TotalSales,
  Category
FROM vending_machine_sales
--WHERE Category is not null
  -- and Product is not null
WHERE Category = 'Water'
GROUP BY Category, Product
ORDER BY 2 DESC;



-- THIS QUERY SHOWS THE HIGHEST SOLD FOOD SNACKS BY TOTALQUANTITYSOLD VS $$TOTALSALES$$
-- WE WILL BE TAKING THE TOP 15 FOOD SNACKS FROM ALL MACHINES BECAUSE WE WANT TO GIVE OUR CUSTOMERS A VARIETY OF SNACKS TO CHOOSE FROM WHILE GENERATING MAX PROFIT
SELECT TOP (15) Product,
  COUNT(RQty) as TotalQuantitySold,
  SUM(LineTotal) as TotalSales,
  Category
FROM vending_machine_sales
--WHERE Category is not null
  -- and Product is not null
WHERE Category = 'Food'
GROUP BY Category, Product
ORDER BY 2 DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------