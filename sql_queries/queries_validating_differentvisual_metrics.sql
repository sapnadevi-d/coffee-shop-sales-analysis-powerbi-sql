/* =========================================================
   1. BASE MEASURE LOGIC (Reusable Pattern)
   ---------------------------------------------------------
   This avoids repeating (unit_price * transaction_qty)
   ========================================================= */

-- You can treat this as a conceptual base:
-- Sales = unit_price * transaction_qty


/* =========================================================
   2. TOOLTIP METRICS (Power BI Heatmap Tooltip)
   ---------------------------------------------------------
   Returns KPI values for a specific date
   ========================================================= */

SELECT
    SUM(unit_price * transaction_qty) AS Total_Sales,
    SUM(transaction_qty)              AS Total_Qty_Sold,
    COUNT(transaction_id)             AS Total_Orders
FROM coffee_shop_sales
WHERE transaction_date = '2025-04-18';



/* =========================================================
   3. WEEKDAY vs WEEKEND ANALYSIS (Monthly)
   ---------------------------------------------------------
   
   ========================================================= */

SELECT
    CASE WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4   -- April
GROUP BY 
CASE WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
   ELSE 'Weekdays'
    END;



/* =========================================================
   4. SALES BY STORE LOCATION
   ---------------------------------------------------------
   Monthly store performance ranking
   ========================================================= */

SELECT
    store_location,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4  -- April
GROUP BY store_location
ORDER BY Total_Sales DESC;



/* =========================================================
   5. DAILY SALES (BASE TIME SERIES)
   ---------------------------------------------------------
   Core trend analysis for dashboard visuals
   ========================================================= */

SELECT
    transaction_date,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
GROUP BY transaction_date
ORDER BY transaction_date;



/* =========================================================
   6. AVERAGE DAILY SALES (MONTHLY KPI)
   ---------------------------------------------------------
   Derived from daily aggregation
   ========================================================= */

SELECT
    ROUND(AVG(Daily_Sales), 2) AS Average_Daily_Sales
FROM (
    SELECT
        transaction_date,
        SUM(unit_price * transaction_qty) AS Daily_Sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 4
    GROUP BY transaction_date
) AS DailyTable;



/* =========================================================
   7. SALES STATUS vs MONTHLY AVERAGE (DAILY LEVEL)
   ---------------------------------------------------------
   Compares each day vs overall average
   ========================================================= */

WITH DailySales AS (
    SELECT
        CAST(transaction_date AS DATE) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 4
    GROUP BY CAST(transaction_date AS DATE)
)

SELECT
    day_of_month,
    total_sales,
    avg_sales,
    CASE
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sales_status
FROM DailySales
ORDER BY day_of_month;



/* =========================================================
   8. SALES BY PRODUCT CATEGORY
   ---------------------------------------------------------
   Helps identify revenue-driving categories
   ========================================================= */

SELECT
    product_category,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
GROUP BY product_category
ORDER BY Total_Sales DESC;



/* =========================================================
   9. TOP 10 PRODUCTS (COFFEE CATEGORY)
   ---------------------------------------------------------
   Product-level performance drill-down
   ========================================================= */

SELECT TOP 10
    product_type,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
  AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY Total_Sales DESC;



/* =========================================================
   10. HEATMAP TOOLTIP (HOUR + DAY CONTEXT)
   ---------------------------------------------------------
   Used for Power BI matrix tooltip interaction
   ========================================================= */

SELECT
    SUM(unit_price * transaction_qty) AS Total_Sales,
    SUM(transaction_qty)              AS Total_Qty_Sold,
    COUNT(*)                          AS Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
  AND DATEPART(WEEKDAY, transaction_date) = 2  -- Monday
  AND DATEPART(HOUR, transaction_time) = 8;



/* =========================================================
   11. HOURLY SALES TREND
   ---------------------------------------------------------
   Helps identify peak business hours
   ========================================================= */

SELECT
    DATEPART(HOUR, transaction_time) AS hour_of_day,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY hour_of_day;



/* =========================================================
   12. CLEAN WEEKDAY LABELING (BEST PRACTICE VERSION)
   ---------------------------------------------------------
   Avoids manual CASE mapping inconsistencies
   ========================================================= */

SELECT
    DATENAME(WEEKDAY, transaction_date) AS Day_of_week,
    DATEPART(WEEKDAY, transaction_date) AS Day_Number,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4
GROUP BY 
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(WEEKDAY, transaction_date)
ORDER BY Day_Number;