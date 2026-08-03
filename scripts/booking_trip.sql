CREATE TABLE booking.trips (
    trip_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES booking.customers(customer_id),
    driver_id INT NOT NULL REFERENCES booking.drivers(driver_id),
    vehicle_id INT NOT NULL REFERENCES fleet.vehicles(vehicle_id),
    trip_date DATE NOT NULL,
    pickup_location VARCHAR(100),
    dropoff_location VARCHAR(100),
    distance_km NUMERIC(10,2),
    fare_amount NUMERIC(10,2),
    payment_method VARCHAR(50),
    status VARCHAR(30),
    rating INT
);

-- ========================================================================
-- Haraka Rides - Phase 4: Clean & Load Trips (Completely Alias-Free)
-- ========================================================================

INSERT INTO booking.trips ( 
    customer_id, driver_id, vehicle_id, trip_date, 
    pickup_location, dropoff_location, distance_km, 
    fare_amount, payment_method, status, rating 
) 
SELECT 
    booking.customers.customer_id, 
    booking.drivers.driver_id, 
    fleet.vehicles.vehicle_id, 
    -- 1. Parse inconsistent date formats using explicit table names 
    CASE 
        WHEN trips_staging.trip_date LIKE '%/%/%' AND length(split_part(trips_staging.trip_date, '/', 3)) = 2 THEN to_date(trips_staging.trip_date, 'DD/MM/YY') 
        WHEN trips_staging.trip_date LIKE '%/%/%' THEN to_date(trips_staging.trip_date, 'DD/MM/YYYY') 
        WHEN trips_staging.trip_date LIKE '__-__-____' THEN to_date(trips_staging.trip_date, 'MM-DD-YYYY') 
        ELSE to_date(trips_staging.trip_date, 'YYYY-MM-DD') 
    END AS trip_date, 
    trips_staging.pickup_area, 
    trips_staging.dropoff_area, 
    -- 2. FIX: Check for empty distance strings before casting
    CASE 
        WHEN TRIM(trips_staging.distance_km) = '' THEN NULL
        WHEN UPPER(TRIM(trips_staging.distance_km)) = 'NULL' THEN NULL
        ELSE ABS(CAST(TRIM(trips_staging.distance_km) AS NUMERIC(10,2)))
    END AS distance_km, 
    -- 3. FIX: Check for empty fare_amount strings before regex and casting
    CASE 
        WHEN TRIM(trips_staging.fare_amount) = '' THEN NULL
        WHEN UPPER(TRIM(trips_staging.fare_amount)) = 'NULL' THEN NULL
        ELSE CAST(REGEXP_REPLACE(trips_staging.fare_amount, '[^0-9.]', '', 'g') AS NUMERIC(10,2))
    END AS fare_amount, 
    INITCAP(TRIM(trips_staging.payment_method)) AS payment_method, 
    INITCAP(TRIM(trips_staging.status)) AS status, 
    -- 4. Catch literal text 'NULL', empty spaces, and out-of-bounds ratings
    CASE 
        WHEN TRIM(trips_staging.customer_rating) = '' THEN NULL
        WHEN UPPER(TRIM(trips_staging.customer_rating)) = 'NULL' THEN NULL
        WHEN CAST(TRIM(trips_staging.customer_rating) AS INT) BETWEEN 1 AND 5 THEN CAST(TRIM(trips_staging.customer_rating) AS INT) 
        ELSE NULL 
    END AS rating 
FROM staging.trips_staging 
JOIN booking.customers ON INITCAP(TRIM(trips_staging.customer_name)) = booking.customers.customer_name 
JOIN booking.drivers ON INITCAP(TRIM(trips_staging.driver_name)) = booking.drivers.driver_name 
JOIN fleet.vehicles ON UPPER(TRIM(trips_staging.vehicle_plate)) = fleet.vehicles.plate_number;



-- Verify row count
SELECT COUNT(*) FROM booking.trips;
SELECT * FROM booking.trips;
