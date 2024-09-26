-- Alter the data types of the columns
ALTER TABLE orders_table
  ALTER COLUMN date_uuid TYPE UUID USING date_uuid::UUID,
  ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID,
  ALTER COLUMN card_number TYPE VARCHAR(19),
  ALTER COLUMN store_code TYPE VARCHAR(12),
  ALTER COLUMN product_code TYPE VARCHAR(11),
  ALTER COLUMN product_quantity TYPE SMALLINT


UPDATE dim_users
SET country_code = 'GB'
WHERE country = 'United Kingdom'
-- Alter the data types of the columns
ALTER TABLE dim_users
ALTER COLUMN first_name TYPE VARCHAR(255),
ALTER COLUMN last_name TYPE VARCHAR(255),
ALTER COLUMN date_of_birth TYPE DATE,
ALTER COLUMN country_code TYPE VARCHAR(2), 
ALTER COLUMN user_uuid TYPE UUID USING user_uuid::UUID,
ALTER COLUMN join_date TYPE DATE;

-- Alter the data types of the columns
ALTER TABLE dim_store_details
  ALTER COLUMN longitude TYPE FLOAT USING longitude::FLOAT,
  ALTER COLUMN locality TYPE VARCHAR(255),
  ALTER COLUMN store_code TYPE VARCHAR(12), 
  ALTER COLUMN staff_numbers TYPE SMALLINT,
  ALTER COLUMN opening_date TYPE DATE USING CASE WHEN opening_date = 'NaN' THEN NULL ELSE opening_date::DATE END,
  ALTER COLUMN store_type TYPE VARCHAR(255),
  ALTER COLUMN store_type DROP NOT NULL,
  ALTER COLUMN latitude TYPE FLOAT USING latitude::FLOAT,
  ALTER COLUMN country_code TYPE VARCHAR(10), 
  ALTER COLUMN continent TYPE VARCHAR(255);

-- Update location values where store_type is 'Web Portal'
UPDATE dim_store_details
SET locality = NULL
WHERE store_type = 'Web Portal' AND locality = 'N/A';

DELETE FROM dim_store_details
WHERE country_code NOT IN ('GB', 'DE', 'US')

ALTER TABLE dim_products
ADD COLUMN weight_class VARCHAR(20);

UPDATE dim_products
SET weight_class =
    CASE
        WHEN weight < 2 THEN 'Light'
        WHEN weight >= 2 AND weight < 40 THEN 'Mid_Sized'
        WHEN weight >= 40 AND weight < 140 THEN 'Heavy'
        ELSE 'Truck_Required'
    END;

ALTER TABLE dim_products
RENAME COLUMN removed TO still_available;

DELETE FROM dim_products
WHERE uuid IS NULL OR uuid = 'NaN';

DELETE FROM dim_products
WHERE uuid !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- Alter the data types of the columns
ALTER TABLE dim_products
ALTER COLUMN product_price TYPE FLOAT USING (product_price::FLOAT),
ALTER COLUMN weight TYPE FLOAT USING (weight::FLOAT),
ALTER COLUMN "EAN" TYPE VARCHAR(17),
ALTER COLUMN product_code TYPE VARCHAR(11),
ALTER COLUMN date_added TYPE DATE USING CASE WHEN date_added = 'NaN' THEN NULL ELSE date_added::DATE END,
ALTER COLUMN uuid TYPE UUID USING uuid::UUID,
ALTER COLUMN still_available TYPE BOOLEAN USING (CASE WHEN still_available = 'Still_available' THEN TRUE ELSE FALSE END),
ALTER COLUMN weight_class TYPE VARCHAR(20);

DELETE FROM dim_date_times
WHERE time_period NOT IN ('Evening', 'Morning', 'Midday', 'Late_Hours');

-- Alter the data types of the columns
ALTER TABLE dim_date_times
ALTER COLUMN month TYPE VARCHAR(2),
ALTER COLUMN year TYPE VARCHAR(4),
ALTER COLUMN day TYPE VARCHAR(2),
ALTER COLUMN time_period TYPE VARCHAR(10),
ALTER COLUMN date_uuid TYPE UUID USING date_uuid::UUID;

-- Alter the data types of the columns
ALTER TABLE dim_card_details
ALTER COLUMN card_number TYPE VARCHAR(19),
ALTER COLUMN expiry_date TYPE VARCHAR(10),
ALTER COLUMN date_payment_confirmed TYPE DATE USING date_payment_confirmed::DATE;

-- Set primary keys and corresponding foreign keys
ALTER TABLE dim_date_times
ADD PRIMARY KEY (date_uuid);

ALTER TABLE dim_users
ADD PRIMARY KEY (user_uuid);

ALTER TABLE dim_card_details
ADD PRIMARY KEY (card_number);

ALTER TABLE dim_store_details
ADD PRIMARY KEY (store_code);

ALTER TABLE dim_products
ADD PRIMARY KEY (product_code);

ALTER TABLE orders_table
ADD CONSTRAINT fk_date_uuid
FOREIGN KEY (date_uuid) REFERENCES dim_date_times,
ADD CONSTRAINT fk_user_uuid
FOREIGN KEY (user_uuid) REFERENCES dim_users, 
ADD CONSTRAINT fk_card_number
FOREIGN KEY (card_number) REFERENCES dim_card_details, 
ADD CONSTRAINT fk_store_code
FOREIGN KEY (store_code) REFERENCES dim_store_details, 
ADD CONSTRAINT fk_product_code
FOREIGN KEY (product_code) REFERENCES dim_products;  