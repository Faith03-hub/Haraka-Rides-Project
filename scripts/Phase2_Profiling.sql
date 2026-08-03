    -- ============================================
-- Haraka Rides: Phase 2 Data Profiling (Fleet)
-- Name: Faith N.
-- ============================================

-- 1. Categorical Data Variants: Inspect casing and whitespace issues
SELECT event_type, COUNT(*) FROM fleet_staging GROUP BY event_type;
SELECT vehicle_status, COUNT(*) FROM fleet_staging GROUP BY vehicle_status;
SELECT DISTINCT vehicle_make, vehicle_model FROM fleet_staging;

-- 2. Format Inconsistencies: Check date layouts and money field formatting
SELECT DISTINCT event_date FROM fleet_staging LIMIT 15;
SELECT DISTINCT fuel_cost FROM fleet_staging WHERE fuel_cost IS NOT NULL AND fuel_cost <> '' LIMIT 10;
SELECT DISTINCT maintenance_cost FROM fleet_staging WHERE maintenance_cost IS NOT NULL AND maintenance_cost <> '' LIMIT 10;

-- 3. Logical Nulls vs Genuinely Missing Values: Check conditional rules
-- Fuel columns should be empty for maintenance, and vice versa. Let's prove it:
SELECT 
    event_type,
    COUNT(*) AS total_events,
    COUNT(*) FILTER (WHERE liters IS NULL OR TRIM(liters) = '') AS blank_liters,
    COUNT(*) FILTER (WHERE fuel_cost IS NULL OR TRIM(fuel_cost) = '') AS blank_fuel_cost,
    COUNT(*) FILTER (WHERE service_type IS NULL OR TRIM(service_type) = '') AS blank_service_type,
    COUNT(*) FILTER (WHERE maintenance_cost IS NULL OR TRIM(maintenance_cost) = '') AS blank_maint_cost
FROM fleet_staging
GROUP BY event_type;

-- 4. Vehicle Plate Evaluation
SELECT 
    COUNT(DISTINCT vehicle_plate) AS raw_unique_plates,
    COUNT(DISTINCT UPPER(TRIM(vehicle_plate))) AS standardized_unique_plates
FROM fleet_staging;
