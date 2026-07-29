DROP TABLE IF EXISTS fleet.maintenance_logs CASCADE;
DROP TABLE IF EXISTS fleet.fuel_logs CASCADE;

-- 1. Create optimized fuel logs table
CREATE TABLE fleet.fuel_logs (
    log_id INT PRIMARY KEY, -- Maps straight to your staging log_id
    vehicle_id INT NOT NULL REFERENCES fleet.vehicles(vehicle_id),
    event_date DATE NOT NULL,
    station_name VARCHAR(100),
    liters NUMERIC(10,2),
    fuel_cost NUMERIC(10,2)
);
-- ========================================================================
-- Populate fleet.fuel_logs (Deduplicated with GROUP BY log_id)
-- ========================================================================
INSERT INTO fleet.fuel_logs (log_id, vehicle_id, event_date, station_name, liters, fuel_cost)
SELECT 
    CAST(TRIM(fleet_staging.log_id) AS INT) AS log_id,
    MAX(fleet.vehicles.vehicle_id) AS vehicle_id,
    -- 1. Parse inconsistent date formats using MAX to aggregate for the group
    MAX(CASE 
        WHEN fleet_staging.event_date LIKE '%/%/%' AND length(split_part(fleet_staging.event_date, '/', 3)) = 2 THEN to_date(fleet_staging.event_date, 'DD/MM/YY')
        WHEN fleet_staging.event_date LIKE '%/%/%' THEN to_date(fleet_staging.event_date, 'DD/MM/YYYY')
        WHEN fleet_staging.event_date LIKE '__-__-____' THEN to_date(fleet_staging.event_date, 'MM-DD-YYYY')
        ELSE to_date(fleet_staging.event_date, 'YYYY-MM-DD')
    END) AS event_date,
    MAX(INITCAP(TRIM(fleet_staging.station_name))) AS station_name,
    MAX(CAST(TRIM(fleet_staging.liters) AS NUMERIC(10,2))) AS liters,
    -- 2. Catch literal text 'NULL', empty spaces, and clean formatting from financial strings
    MAX(CASE 
        WHEN TRIM(fleet_staging.fuel_cost) = '' THEN NULL
        WHEN UPPER(TRIM(fleet_staging.fuel_cost)) = 'NULL' THEN NULL
        ELSE CAST(REGEXP_REPLACE(fleet_staging.fuel_cost, '[^0-9.]', '', 'g') AS NUMERIC(10,2))
    END) AS fuel_cost
FROM staging.fleet_staging
JOIN fleet.vehicles ON UPPER(TRIM(fleet_staging.vehicle_plate)) = fleet.vehicles.plate_number
WHERE UPPER(TRIM(fleet_staging.event_type)) = 'FUEL'
GROUP BY CAST(TRIM(fleet_staging.log_id) AS INT);

-- Verify the final deduplicated fuel row count
SELECT COUNT(*) FROM fleet.fuel_logs;



-- 2. Create optimized maintenance logs table
CREATE TABLE fleet.maintenance_logs (
    log_id INT PRIMARY KEY, -- Maps straight to your staging log_id
    vehicle_id INT NOT NULL REFERENCES fleet.vehicles(vehicle_id),
    event_date DATE NOT NULL,
    service_type VARCHAR(100),
    maintenance_cost NUMERIC(10,2)
);


-- ========================================================================
-- Populate fleet.maintenance_logs
-- ========================================================================
INSERT INTO fleet.maintenance_logs (log_id, vehicle_id, event_date, service_type, maintenance_cost)
SELECT 
    CAST(TRIM(fleet_staging.log_id) AS INT) AS log_id,
    fleet.vehicles.vehicle_id,
    CASE 
        WHEN fleet_staging.event_date LIKE '%/%/%' AND length(split_part(fleet_staging.event_date, '/', 3)) = 2 THEN to_date(fleet_staging.event_date, 'DD/MM/YY')
        WHEN fleet_staging.event_date LIKE '%/%/%' THEN to_date(fleet_staging.event_date, 'DD/MM/YYYY')
        WHEN fleet_staging.event_date LIKE '__-__-____' THEN to_date(fleet_staging.event_date, 'MM-DD-YYYY')
        ELSE to_date(fleet_staging.event_date, 'YYYY-MM-DD')
    END AS event_date,
    INITCAP(TRIM(fleet_staging.service_type)) AS service_type,
    CASE 
        WHEN TRIM(fleet_staging.maintenance_cost) = '' THEN NULL
        WHEN UPPER(TRIM(fleet_staging.maintenance_cost)) = 'NULL' THEN NULL
        ELSE CAST(REGEXP_REPLACE(fleet_staging.maintenance_cost, '[^0-9.]', '', 'g') AS NUMERIC(10,2))
    END AS maintenance_cost
FROM staging.fleet_staging
JOIN fleet.vehicles ON UPPER(TRIM(fleet_staging.vehicle_plate)) = fleet.vehicles.plate_number
WHERE UPPER(TRIM(fleet_staging.event_type)) = 'MAINTENANCE';

select * from maintenance_logs;
select * from fleet.fuel_logs;
