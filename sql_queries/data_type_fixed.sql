exec sp_help 'dbo.coffee_shop_sales'-- to find the meta deta of the table to check the data type detection--

-- update the date colunn to hh-mm-ss--
UPDATE dbo.coffee_shop_sales
SET transaction_time = CONVERT(TIME(0), transaction_time)
  -- change the data type fo the transaction_time column--
ALTER TABLE dbo.coffee_shop_sales
ALTER COLUMN transaction_time TIME(0)

--Change the data type of transaction_qty to INT from tiny int--
ALTER TABLE dbo.coffee_shop_sales
ALTER COLUMN transaction_qty INT

-- changed the data type of unit_price to decimal from float--
ALTER TABLE dbo.coffee_shop_sales
ALTER COLUMN unit_price Decimal (10,2)


-- changed the data type of product_id to decimal from float--
ALTER TABLE dbo.coffee_shop_sales
ALTER COLUMN product_id INT
