/*Total Revenue: The sum of all fares from booking.trips (completed only) [Capstone].
 * Total Fuel Cost: The sum of all costs from fleet.fuel_logs [Capstone].
 * Total Maintenance Cost: The sum of all costs from fleet.maintenance_logs [Capstone]*/

SELECT 
    fleet.vehicles.vehicle_id,
    fleet.vehicles.plate_number,
    fleet.vehicles.make,
    fleet.vehicles.model,
    COALESCE((
        SELECT SUM(booking.trips.fare_amount) 
        FROM booking.trips 
        WHERE booking.trips.vehicle_id = fleet.vehicles.vehicle_id 
          AND booking.trips.status = 'Completed'
    ), 0.00) AS total_revenue,
    COALESCE((
        SELECT SUM(fleet.fuel_logs.fuel_cost) 
        FROM fleet.fuel_logs 
        WHERE fleet.fuel_logs.vehicle_id = fleet.vehicles.vehicle_id
    ), 0.00) AS total_fuel_cost,
    COALESCE((
        SELECT SUM(fleet.maintenance_logs.maintenance_cost) 
        FROM fleet.maintenance_logs 
        WHERE fleet.maintenance_logs.vehicle_id = fleet.vehicles.vehicle_id
    ), 0.00) AS total_maintenance_cost,
    (
        COALESCE((
            SELECT SUM(booking.trips.fare_amount) 
            FROM booking.trips 
            WHERE booking.trips.vehicle_id = fleet.vehicles.vehicle_id 
              AND booking.trips.status = 'Completed'
        ), 0.00) - 
        COALESCE((
            SELECT SUM(fleet.fuel_logs.fuel_cost) 
            FROM fleet.fuel_logs 
            WHERE fleet.fuel_logs.vehicle_id = fleet.vehicles.vehicle_id
        ), 0.00) - 
        COALESCE((
            SELECT SUM(fleet.maintenance_logs.maintenance_cost) 
            FROM fleet.maintenance_logs 
            WHERE fleet.maintenance_logs.vehicle_id = fleet.vehicles.vehicle_id
        ), 0.00)
    ) AS net_profit
FROM fleet.vehicles
ORDER BY net_profit DESC;
