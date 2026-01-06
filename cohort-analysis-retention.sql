

-- Step 1: Summarize the table including: Customer - Transaction date
SELECT DISTINCT  
	CustomerID
	, OrderDate
FROM dbo.EcomSales es 

-- Step 2: Find the date of the first transaction of the customers
SELECT DISTINCT   
	CustomerID
	, OrderDate
	, MIN(OrderDate) OVER(
		PARTITION BY CustomerID
	) AS "First_OrderDate"
FROM dbo.EcomSales es 

-- Step 3: Determine the calculation unit for the “Return Period” value

-- Step 4: Perform the “Return Period” calculation
-- based on the agreed calculation unit (e.g. Month)
WITH customer_cte AS
(SELECT DISTINCT   
	CustomerID
	, OrderDate
	, MIN(OrderDate) OVER(
		PARTITION BY CustomerID
	) AS "First_OrderDate"
FROM dbo.EcomSales es
)
---
SELECT 
	*
	--, FORMAT (First_OrderDate, 'yyyy-MM') AS "First_OrderMonth"
	, DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
ORDER BY OrderDate DESC


-- Step 5: Calculate cohort
WITH customer_cte AS
(SELECT DISTINCT   
	CustomerID
	, OrderDate
	, MIN(OrderDate) OVER(
		PARTITION BY CustomerID
	) AS "First_OrderDate"
FROM dbo.EcomSales es)
---
, pre_cohort_cte AS
(SELECT 
	*
	, FORMAT(First_OrderDate , 'yyyy-MM') AS "First_OrderMonth"
	, DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
WHERE First_OrderDate BETWEEN '2020-01-01' AND '2020-12-31' -- Giới hạn thời gian xét Cohort
)
---
SELECT 
	First_OrderMonth
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "0"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 1 THEN CustomerID END) AS "1"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 2 THEN CustomerID END) AS "2"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 3 THEN CustomerID END) AS "3"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 4 THEN CustomerID END) AS "4"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 5 THEN CustomerID END) AS "5"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 6 THEN CustomerID END) AS "6"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 7 THEN CustomerID END) AS "7"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 8 THEN CustomerID END) AS "8"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 9 THEN CustomerID END) AS "9"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 10 THEN CustomerID END) AS "10"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 11 THEN CustomerID END) AS "11"
	, COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 12 THEN CustomerID END) AS "12"	
FROM pre_cohort_cte
WHERE Retention_MonthDiff <= 12 -- Giới hạn số xét số lượng Tháng quay lại
GROUP BY First_OrderMonth

-- Step 6: Calculate retention rate
WITH customer_cte AS
(SELECT DISTINCT   
	CustomerID
	, OrderDate
	, MIN(OrderDate) OVER(
		PARTITION BY CustomerID
	) AS "First_OrderDate"
FROM dbo.EcomSales es)
---
, pre_cohort_cte AS
(SELECT 
	*
	, FORMAT(First_OrderDate , 'yyyy-MM') AS "First_OrderMonth"
	, DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
WHERE First_OrderDate BETWEEN '2020-01-01' AND '2020-12-31' -- Giới hạn thời gian xét Cohort
)
---
SELECT 
	First_OrderMonth
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END)AS "0"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 1 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "1"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 2 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "2"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 3 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "3"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 4 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "4"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 5 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "5"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 6 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "6"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 7 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "7"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 8 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "8"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 9 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "9"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 10 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "10"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 11 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "11"
	, 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 12 THEN CustomerID END)
		/ COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "12"	
FROM pre_cohort_cte
WHERE Retention_MonthDiff <= 12 -- Giới hạn số xét số lượng Tháng quay lại
GROUP BY First_OrderMonth