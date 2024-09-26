-- How many stores does the business have in each country?
SELECT country_code, count(store_code) AS total_no_stores
FROM  dim_store_details
GROUP BY country_code

-- Which locations have the most stores?
SELECT locality, count(store_code) AS total_no_stores
FROM  dim_store_details
GROUP BY locality
ORDER BY total_no_stores DESC
LIMIT 7


-- Which months produced the most sales?
SELECT sum(product_price*product_quantity) AS total_sales, month
FROM  orders_table
JOIN dim_products ON orders_table.product_code = dim_products.product_code
JOIN dim_date_times ON orders_table.date_uuid = dim_date_times.date_uuid
GROUP BY month
ORDER BY total_sales DESC
LIMIT 6

-- How many sales are made online?
SELECT 
COUNT(*) AS number_of_sales, 
SUM(orders_table.product_quantity) AS product_quantity_count, 
CASE WHEN dim_store_details.store_type = 'Web Portal' THEN 'Web'
ELSE 'Offline'
END AS location
FROM  orders_table
JOIN dim_store_details ON orders_table.store_code = dim_store_details.store_code
GROUP BY location

-- What percentage of sales come through each type of store?
SELECT 
    dim_store_details.store_type,
    SUM(orders_table.product_quantity * dim_products.product_price) AS total_sales,
    (SUM(orders_table.product_quantity * dim_products.product_price) / 
     (SELECT SUM(orders_table.product_quantity * dim_products.product_price) 
      FROM orders_table 
      JOIN dim_store_details ON orders_table.store_code = dim_store_details.store_code 
      JOIN dim_products ON orders_table.product_code = dim_products.product_code) * 100) AS percentage_total
FROM 
    orders_table
JOIN 
    dim_store_details ON orders_table.store_code = dim_store_details.store_code
JOIN 
    dim_products ON orders_table.product_code = dim_products.product_code
GROUP BY 
    dim_store_details.store_type;

-- Which month in each year produced the highest cost in sales?
SELECT 
    SUM(orders_table.product_quantity * dim_products.product_price) AS total_sales,
    dim_date_times.year,
    dim_date_times.month
FROM 
    orders_table
JOIN 
    dim_date_times ON orders_table.date_uuid = dim_date_times.date_uuid 
JOIN 
    dim_store_details ON orders_table.store_code = dim_store_details.store_code
JOIN 
    dim_products ON orders_table.product_code = dim_products.product_code
GROUP BY 
    dim_date_times.year, dim_date_times.month
ORDER BY 
    total_sales DESC
LIMIT 10;

-- What is the staff headcount?
SELECT 
    SUM(dim_store_details.staff_numbers) AS total_staff_numbers,
    dim_store_details.country_code
FROM 
    dim_store_details
GROUP BY 
    dim_store_details.country_code;

-- Which German store type is selling the most?
SELECT 
    SUM(orders_table.product_quantity * dim_products.product_price) AS total_sales,
    dim_store_details.store_type,
    dim_store_details.country_code
FROM 
    orders_table
JOIN 
    dim_store_details ON orders_table.store_code = dim_store_details.store_code
JOIN 
    dim_products ON orders_table.product_code = dim_products.product_code
WHERE 
    dim_store_details.country_code = 'DE'
GROUP BY 
    dim_store_details.store_type, dim_store_details.country_code
ORDER BY 
    total_sales DESC;

-- Determine the average time taken betweeen each sale grouped by year
WITH sale_times AS (
    SELECT 
        year,
        EXTRACT(EPOCH FROM LEAD((CONCAT(year, '-', LPAD(month::TEXT, 2, '0'), '-', LPAD(day::TEXT, 2, '0'), ' ', timestamp))::timestamp) OVER (PARTITION BY year ORDER BY (CONCAT(year, '-', LPAD(month::TEXT, 2, '0'), '-', LPAD(day::TEXT, 2, '0'), ' ', timestamp))::timestamp) - (CONCAT(year, '-', LPAD(month::TEXT, 2, '0'), '-', LPAD(day::TEXT, 2, '0'), ' ', timestamp))::timestamp) AS time_diff_seconds
    FROM 
        orders_table
    JOIN 
        dim_date_times ON orders_table.date_uuid = dim_date_times.date_uuid
)
SELECT 
    year,
    CONCAT('"hours": ', FLOOR(AVG(time_diff_seconds) / 3600), 
           ', "minutes": ', FLOOR(MOD(AVG(time_diff_seconds) / 60, 60)), 
           ', "seconds": ', FLOOR(MOD(AVG(time_diff_seconds), 60)), 
           ', "milliseconds": ', FLOOR(MOD(AVG(time_diff_seconds) * 1000, 1000))) AS actual_time_taken
FROM 
    sale_times
GROUP BY 
    year
ORDER BY 
    year;
