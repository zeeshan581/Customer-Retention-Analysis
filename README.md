# Cohort Analysis on Retention Rate (12 months)

This repository contains a cohort analysis to evaluate customer retention rates based on transaction data from the `EcomSales, Product, Region, Customer` tables. The analysis tracks customers' first purchase dates and calculates their retention over time using monthly intervals.

## Methodology

The cohort analysis was performed in the following steps using SQL queries:

### Step 1: Summarise Customer Transactions
Extract unique customer IDs and their transaction dates.
```sql
SELECT DISTINCT  
    CustomerID
    , OrderDate
FROM dbo.EcomSales es
```

### Step 2: Identify First Transaction Date
Determine the first transaction date for each customer using a window function.
```sql
SELECT DISTINCT   
    CustomerID
    , OrderDate
    , MIN(OrderDate) OVER(
        PARTITION BY CustomerID
    ) AS "First_OrderDate"
FROM dbo.EcomSales es
```

### Step 3: Define Calculation Unit
The "Return Period" is calculated using months as the unit, determined by the `DATEDIFF(MONTH, ...)` function.

### Step 4: Calculate Return Period
Computed the difference in months between the first transaction date and subsequent orders using `DATEDIFF`

![Step 4](https://github.com/annettelynn/SQL-cohort-analysis-ecomsales-retention/blob/main/step3-cohort.png)


```sql
WITH customer_cte AS
(SELECT DISTINCT   
    CustomerID
    , OrderDate
    , MIN(OrderDate) OVER(
        PARTITION BY CustomerID
    ) AS "First_OrderDate"
FROM dbo.EcomSales es
)
SELECT 
    *
    , DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
ORDER BY OrderDate DESC
```

### Step 5: Calculate Cohort
Grouped customers by their first order month `First_OrderMonth` and counted distinct customers returning at each month interval (0 to 12 months) for the year 2020.

![Step 5](https://github.com/annettelynn/SQL-cohort-analysis-ecomsales-retention/blob/main/step5-cohort1.png)


```sql
WITH customer_cte AS
(SELECT DISTINCT   
    CustomerID
    , OrderDate
    , MIN(OrderDate) OVER(
        PARTITION BY CustomerID
    ) AS "First_OrderDate"
FROM dbo.EcomSales es)
, pre_cohort_cte AS
(SELECT 
    *
    , FORMAT(First_OrderDate , 'yyyy-MM') AS "First_OrderMonth"
    , DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
WHERE First_OrderDate BETWEEN '2020-01-01' AND '2020-12-31'
)
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
WHERE Retention_MonthDiff <= 12
GROUP BY First_OrderMonth
```

### Step 6: Calculate Retention Rate
Calculated the retention rate as a percentage of customers returning each month relative to the initial cohort size (month 0)

![Step 6](https://github.com/annettelynn/SQL-cohort-analysis-ecomsales-retention/blob/main/outcome.png)
```sql
WITH customer_cte AS
(SELECT DISTINCT   
    CustomerID
    , OrderDate
    , MIN(OrderDate) OVER(
        PARTITION BY CustomerID
    ) AS "First_OrderDate"
FROM dbo.EcomSales es)
, pre_cohort_cte AS
(SELECT 
    *
    , FORMAT(First_OrderDate , 'yyyy-MM') AS "First_OrderMonth"
    , DATEDIFF(MONTH, First_OrderDate, OrderDate) AS "Retention_MonthDiff"
FROM customer_cte
WHERE First_OrderDate BETWEEN '2020-01-01' AND '2020-12-31'
)
SELECT 
    First_OrderMonth
    , 100.00 * COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END)
        / COUNT(DISTINCT CASE WHEN Retention_MonthDiff = 0 THEN CustomerID END) AS "0"
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
WHERE Retention_MonthDiff <= 12
GROUP BY First_OrderMonth
```

## Outcome
The analysis resulted in a retention rate table showing the percentage of customers returning each month after their first purchase. The visual representation of this data is available here. The cohort is limited to customers with their first transaction between January 1, 2020, and December 31, 2020. Retention is tracked up to 12 months, with rates calculated relative to the initial cohort size.

|First_OrderMonth|0|1|2|3|4|5|6|7|8|9|10|11|12|
|----------------|-|-|-|-|-|-|-|-|-|-|--|--|--|
|2020-01|100.0000000000000|0.0000000000000|0.4651162790697|1.3953488372093|0.9302325581395|1.8604651162790|0.0000000000000|3.2558139534883|2.7906976744186|0.9302325581395|4.1860465116279|0.9302325581395|0.9302325581395|
|2020-02|100.0000000000000|0.4950495049504|0.9900990099009|0.4950495049504|1.4851485148514|1.9801980198019|1.4851485148514|2.9702970297029|1.9801980198019|0.4950495049504|2.4752475247524|0.9900990099009|2.4752475247524|
|2020-03|100.0000000000000|1.8939393939393|1.1363636363636|1.5151515151515|1.8939393939393|1.1363636363636|2.2727272727272|1.1363636363636|3.4090909090909|1.5151515151515|0.7575757575757|1.5151515151515|2.6515151515151|
|2020-04|100.0000000000000|0.8163265306122|1.6326530612244|1.6326530612244|0.8163265306122|2.0408163265306|1.6326530612244|3.2653061224489|2.8571428571428|0.4081632653061|0.4081632653061|1.6326530612244|1.6326530612244|
|2020-05|100.0000000000000|1.3071895424836|0.6535947712418|1.3071895424836|1.6339869281045|1.3071895424836|2.9411764705882|1.6339869281045|1.6339869281045|0.3267973856209|1.3071895424836|2.2875816993464|0.9803921568627|
|2020-06|100.0000000000000|0.9302325581395|1.8604651162790|0.2325581395348|0.2325581395348|1.1627906976744|1.6279069767441|0.6976744186046|1.6279069767441|0.6976744186046|1.1627906976744|0.9302325581395|1.3953488372093|
|2020-07|100.0000000000000|1.6528925619834|2.8925619834710|1.2396694214876|0.8264462809917|2.8925619834710|2.4793388429752|0.0000000000000|1.6528925619834|1.2396694214876|1.6528925619834|1.2396694214876|2.8925619834710|
|2020-08|100.0000000000000|3.1707317073170|1.7073170731707|1.4634146341463|1.7073170731707|0.2439024390243|1.2195121951219|0.4878048780487|0.9756097560975|1.7073170731707|2.1951219512195|0.7317073170731|1.9512195121951|
|2020-09|100.0000000000000|2.3706896551724|2.3706896551724|1.2931034482758|0.6465517241379|0.6465517241379|1.2931034482758|2.1551724137931|1.9396551724137|1.0775862068965|1.5086206896551|1.5086206896551|1.7241379310344|
|2020-10|100.0000000000000|2.0887728459530|4.4386422976501|0.7832898172323|0.7832898172323|1.8276762402088|0.5221932114882|0.7832898172323|0.5221932114882|1.5665796344647|1.0443864229765|1.8276762402088|2.8720626631853|
|2020-11|100.0000000000000|1.2396694214876|0.8264462809917|0.6198347107438|2.4793388429752|1.2396694214876|1.8595041322314|2.2727272727272|0.8264462809917|2.2727272727272|2.2727272727272|3.3057851239669|3.0991735537190|
|2020-12|100.0000000000000|1.3487475915221|0.7707129094412|3.2755298651252|0.9633911368015|1.5414258188824|1.5414258188824|1.7341040462427|1.7341040462427|2.8901734104046|1.5414258188824|2.5048169556840|2.5048169556840|


