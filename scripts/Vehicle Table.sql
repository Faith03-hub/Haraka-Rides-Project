-- ========================================================
-- Haraka Rides - Phase 4: Production Vehicles Table (Automated Extraction)
-- Schema: fleet (or your clean schema name)
-- ========================================================

-- 1. Create clean production table with strict data types
CREATE TABLE IF NOT EXISTS fleet.vehicles2(
    vehicle_id SERIAL PRIMARY KEY, -- Automatically generates your 1 to 12 IDs
    plate_number VARCHAR(20) NOT NULL UNIQUE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    vehicle_status VARCHAR(30) NOT NULL
);

-- 2. Extract, clean, and insert dynamically from fleet_staging
INSERT INTO fleet.vehicles2(plate_number, make, model, year, vehicle_status)
SELECT DISTINCT 
    UPPER(TRIM(vehicle_plate)) AS plate_number, -- Fixes the whitespace and casing mess
    INITCAP(TRIM(vehicle_make)) AS make,        -- Normalizes vehicle makes (e.g. Toyota)
    INITCAP(TRIM(vehicle_model)) AS model,      -- Normalizes vehicle models (e.g. Vitz)
    CAST(TRIM(vehicle_year) AS INT) AS year,    -- Casts text years to integers safely
    INITCAP(TRIM(vehicle_status)) AS vehicle_status
FROM staging.fleet_staging
WHERE vehicle_plate IS NOT NULL AND TRIM(vehicle_plate) <> '';

-- 3. Run a quick check to verify it perfectly matches your 12 vehicles
SELECT * FROM fleet.vehicles2;
