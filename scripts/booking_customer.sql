-- Create the bookings schema if you haven't yet
CREATE SCHEMA IF NOT EXISTS bookings;

-- Create the structured customers table
CREATE TABLE booking.customers(
    customer_id SERIAL PRIMARY KEY, -- Automatically generates unique IDs
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(30)
);
-- Extract and load unique customers cleanly
INSERT INTO booking.customers (customer_name, customer_phone)
SELECT 
    INITCAP(TRIM(customer_name)) AS customer_name, -- Fixes spacing and capitalization (e.g. "FAITH NJERI")
    MAX(NULLIF(TRIM(customer_phone), '')) AS customer_phone -- Grabs their valid phone number if it exists
FROM staging.trips_staging
WHERE customer_name IS NOT NULL AND TRIM(customer_name) <> ''
GROUP BY INITCAP(TRIM(customer_name));

-- Verify your clean customer list
SELECT * FROM booking.customers;

