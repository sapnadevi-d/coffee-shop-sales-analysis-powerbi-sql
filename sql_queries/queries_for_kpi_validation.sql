/*==============================================================
  
    This SQL script calculates key business KPIs for a Coffee Shop
    Sales Dashboard created in Power BI to validate the numbers of the key metrics and the visuals, including:

    • Total Sales
    • Month-over-Month (MoM) Sales Growth
    • Total Orders
    • Order Growth Analysis
    • Total Quantity Sold
    • Quantity Growth Analysis

    The script uses:
    • Aggregate Functions
    • CTEs (Common Table Expressions)
    • Window Functions (LAG)
    • MoM Percentage Calculations

    NOTE:
    All KPI filters have been standardized to APRIL (Month = 4)
    for consistency across the analysis.
==============================================================*/


/*==============================================================
    1. VIEW COMPLETE DATASET
==============================================================*/

SELECT *
FROM coffee_shop_sales;



/*==============================================================
    2. TOTAL SALES KPI (APRIL)

    BUSINESS PURPOSE:
    Calculates the total revenue generated in April.

    FORMULA:
    Sales = Unit Price × Transaction Quantity

    OUTPUT:
    Returns sales in thousands (K format) for dashboard KPI cards.
==============================================================*/

SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 0),'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4;   -- April

/*==============================================================
    3. MONTH-OVER-MONTH SALES ANALYSIS

    BUSINESS PURPOSE:
    Compares monthly sales performance between March and April.

    METRICS:
    • Current Month Sales
    • Previous Month Sales
    • Absolute Sales Difference
    • MoM Growth Percentage

    TECHNIQUES USED:
    • CTE
    • Window Function (LAG)
==============================================================*/

WITH Monthly_Sales AS
(SELECT
        MONTH(transaction_date) AS Month_Number,
        ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (3, 4)
    GROUP BY MONTH(transaction_date)
)

SELECT
    Month_Number,
    Total_Sales,
    -- Difference from Previous Month--
    ROUND(Total_Sales - LAG(Total_Sales, 1) OVER (ORDER BY Month_Number),2) AS Month_Sales_Difference, 
-- MoM Percentage Growth--
    ROUND((Total_Sales -LAG(Total_Sales, 1) OVER (ORDER BY Month_Number))/CAST(
            LAG(Total_Sales, 1) OVER (ORDER BY Month_Number)AS FLOAT) * 100,2) AS MoM_Sales_Growth_Percentage

FROM Monthly_Sales
ORDER BY Month_Number;



/*==============================================================
    4. TOTAL ORDERS KPI (APRIL)

    BUSINESS PURPOSE:
    Calculates the total number of transactions/orders
    completed during April.
==============================================================*/

SELECT
    COUNT(transaction_id) AS Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4;   -- April

/*==============================================================
    5. MONTH-OVER-MONTH ORDER ANALYSIS

    BUSINESS PURPOSE:
    Evaluates order volume growth between March and April

    METRICS:
    • Total Orders
    • Difference from Previous Month
    • MoM Order Growth %
==============================================================*/

WITH Monthly_Orders AS
(SELECT
        MONTH(transaction_date) AS Month_Number,
        COUNT(transaction_id) AS Total_Orders
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (3, 4)
    GROUP BY MONTH(transaction_date)
)

SELECT
    Month_Number,
    Total_Orders,

    -- Order Difference from Previous Month
    Total_Orders - LAG(Total_Orders, 1) OVER (ORDER BY Month_Number)
    AS Difference_From_Previous_Month,
-- MoM Order Growth Percentage--
    ROUND((Total_Orders -LAG(Total_Orders, 1) OVER (ORDER BY Month_Number))/
        CAST(LAG(Total_Orders, 1) OVER (ORDER BY Month_Number)AS FLOAT) * 100,2) AS MoM_Order_Growth_Percentage
FROM Monthly_Orders;



/*==============================================================
    6. TOTAL QUANTITY SOLD KPI (APRIL)

    BUSINESS PURPOSE:
    Calculates the total quantity of products sold in April.
==============================================================*/

SELECT
    SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 4;   -- April



/*==============================================================
    7. MONTH-OVER-MONTH QUANTITY SOLD ANALYSIS

    BUSINESS PURPOSE:
    Analyzes growth in product sales volume between
   March and April.

    METRICS:
    • Total Quantity Sold
    • Quantity Difference
    • MoM Quantity Growth %
==============================================================*/

WITH Monthly_Quantity_Sold AS
(SELECT
        MONTH(transaction_date) AS Month_Number,
        SUM(transaction_qty) AS Total_Quantity_Sold
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) IN (3, 4)
    GROUP BY MONTH(transaction_date)
)

SELECT
    Month_Number,
    Total_Quantity_Sold,

    -- Quantity Difference from Previous Month
    Total_Quantity_Sold - LAG(Total_Quantity_Sold, 1) OVER (ORDER BY Month_Number) AS Difference_From_Previous_Month,

    -- MoM Quantity Growth Percentage
    ROUND((Total_Quantity_Sold - LAG(Total_Quantity_Sold, 1)OVER (ORDER BY Month_Number))/
        CAST(LAG(Total_Quantity_Sold, 1)OVER (ORDER BY Month_Number)AS FLOAT) * 100,2) AS MoM_Quantity_Growth_Percentage

FROM Monthly_Quantity_Sold;