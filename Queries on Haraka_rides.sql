---SIDE QUESTIONS
--F1. Rank vehicles by total fuel cost.
SELECT 
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    SUM(fleet.fuel_logs.fuel_cost) AS total_fuel_spend
FROM fleet.vehicles
JOIN fleet.fuel_logs ON fleet.vehicles.vehicle_id = fleet.fuel_logs.vehicle_id
GROUP BY fleet.vehicles.plate_number, fleet.vehicles.make, fleet.vehicles.model
ORDER BY total_fuel_spend DESC;

/*F2. Which vehicles have had more than 3 maintenance events,
 and what's their total maintenance spend?*/
SELECT 
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    COUNT(fleet.maintenance_logs.log_id) AS total_maintenance_events,
    SUM(fleet.maintenance_logs.maintenance_cost) AS total_maintenance_spend
FROM fleet.vehicles
JOIN fleet.maintenance_logs ON fleet.vehicles.vehicle_id = fleet.maintenance_logs.vehicle_id
GROUP BY fleet.vehicles.plate_number, fleet.vehicles.make, fleet.vehicles.model
HAVING COUNT(fleet.maintenance_logs.log_id) > 3
ORDER BY total_maintenance_spend DESC;

/*
 * F3. Is there a vehicle that has never had a single fuel log?
 */SELECT 
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model
FROM fleet.vehicles
LEFT JOIN fleet.fuel_logs ON fleet.vehicles.vehicle_id = fleet.fuel_logs.vehicle_id
WHERE fleet.fuel_logs.log_id IS NULL;

/*X1. For completed trips, show the vehicle's 
 * plate, make, and model alongside the trip details.
 */
SELECT 
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    booking.trips.trip_id,
    booking.trips.trip_date,
    booking.trips.fare_amount
FROM booking.trips
JOIN fleet.vehicles ON booking.trips.vehicle_id = fleet.vehicles.vehicle_id
WHERE booking.trips.status = 'Completed';

/*
 * X2. Total revenue generated per vehicle (Completed trips only)
 */
SELECT 
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    COALESCE(SUM(booking.trips.fare_amount), 0.00) AS total_revenue_generated
FROM fleet.vehicles
LEFT JOIN booking.trips ON fleet.vehicles.vehicle_id = booking.trips.vehicle_id 
    AND booking.trips.status = 'Completed'
GROUP BY fleet.vehicles.plate_number, fleet.vehicles.make, fleet.vehicles.model
ORDER BY total_revenue_generated DESC;

/*
 * X3. Are there any vehicles marked 'Under Repair' in the fleet system
 *  that still show up carrying trips in the booking system?
 */
SELECT DISTINCT
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    fleet.vehicles.status AS fleet_status,
    booking.trips.status AS trip_status
FROM fleet.vehicles
JOIN booking.trips ON fleet.vehicles.vehicle_id = booking.trips.vehicle_id
WHERE fleet.vehicles.status = 'Under Repair';

-------------------------------------------------------------------------
------------Subquery Challenges------------------------------------------
--------------------------------------------------------------------------
--S1. Which customers ride further than average?

SELECT DISTINCT
    booking.customers.customer_name,
    booking.trips.trip_id,
    booking.trips.distance_km
FROM booking.trips
JOIN booking.customers ON booking.trips.customer_id = booking.customers.customer_id
WHERE booking.trips.distance_km > (
    SELECT AVG(booking.trips.distance_km) 
    FROM booking.trips
)
ORDER BY booking.trips.distance_km DESC;

/*S2. Which vehicles spend more on fuel than the average 
vehicle's total fuel spend?*/

SELECT 
    fleet.vehicles.plate_number,
    SUM(fleet.fuel_logs.fuel_cost) AS vehicle_total_fuel
FROM fleet.fuel_logs
JOIN fleet.vehicles ON fleet.fuel_logs.vehicle_id = fleet.vehicles.vehicle_id
GROUP BY fleet.vehicles.plate_number
HAVING SUM(fleet.fuel_logs.fuel_cost) > (
    -- Subquery: Calculate the average of all vehicle fuel totals
    SELECT AVG(total_spend_per_car.total_fuel)
    FROM (
        SELECT SUM(fleet.fuel_logs.fuel_cost) AS total_fuel
        FROM fleet.fuel_logs
        GROUP BY fleet.fuel_logs.vehicle_id
    ) AS total_spend_per_car
)
ORDER BY vehicle_total_fuel DESC;

/*S3. For each completed trip, is its fare higher than the average 
 * fare for that same payment method?*/
SELECT 
    booking.trips.trip_id,
    booking.trips.payment_method,
    booking.trips.fare_amount,
    (
        SELECT ROUND(AVG(inner_trips.fare_amount), 2)
        FROM booking.trips AS inner_trips
        WHERE inner_trips.payment_method = booking.trips.payment_method
          AND inner_trips.status = 'Completed'
    ) AS average_fare_for_method
FROM booking.trips
WHERE booking.trips.status = 'Completed'
  AND booking.trips.fare_amount > (
        SELECT AVG(inner_trips.fare_amount)
        FROM booking.trips AS inner_trips
        WHERE inner_trips.payment_method = booking.trips.payment_method
          AND inner_trips.status = 'Completed'
  )
ORDER BY booking.trips.payment_method, booking.trips.fare_amount DESC;
