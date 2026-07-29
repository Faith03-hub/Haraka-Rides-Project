
-- Create the structured drivers table
CREATE TABLE booking.drivers (
    driver_id SERIAL PRIMARY KEY, -- Automatically generates unique IDs (1, 2, 3...)
    driver_name VARCHAR(100) NOT NULL,
    driver_phone VARCHAR(30)
);

-- Extract and load unique drivers cleanly
INSERT INTO booking.drivers (driver_name, driver_phone)
SELECT 
    INITCAP(TRIM(driver_name)) AS driver_name, -- Fixes spacing and messy caps
    MAX(NULLIF(TRIM(driver_phone), '')) AS driver_phone -- Captures a phone number if it exists
FROM staging.trips_staging
WHERE driver_name IS NOT NULL AND TRIM(driver_name) <> ''
GROUP BY INITCAP(TRIM(driver_name));

-- Verify your clean drivers list
SELECT * FROM booking.drivers;
