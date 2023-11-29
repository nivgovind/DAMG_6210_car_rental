-- customer should be able to get a list of available cars for rent and be able to filter this list according to the type of car, vendor and location
-- get_available_vehicles (
--     pi_location_name VARCHAR2 DEFAULT NULL,
--     pi_vehicle_type VARCHAR2 DEFAULT NULL,
--     pi_vendor_name VARCHAR2 DEFAULT NULL,
--     pi_pick_up_date VARCHAR2 DEFAULT NULL,
--     pi_dropoff_date VARCHAR2 DEFAULT NULL
-- )

-- Get of list of all available vehicles
-- 'pending', 'active', 'completed', 'cancelled'
-- get all the vehicles are 'pending', 'active', 'cancelled' and after the current date
-- select * from vehicles where id not in (select vehicles_id from reservations where status in ('pending', 'active'));


-- -- customer should be able to get a list of available cars for rent and be able to filter this list according to the type of car, vendor and location
-- create view for customers to get available vehicles
-- create or replace view view_available_vehicles as 
--     select * 
--     from vehicles 
--         where id not in (
--             select vehicles_id 
--             from reservations 
--                 where status in ('pending', 'active'));






-- CREATE OR REPLACE PROCEDURE get_available_vehicles (
--     pi_location_name VARCHAR2 DEFAULT NULL,
--     pi_vehicle_type VARCHAR2 DEFAULT NULL,
--     pi_vendor_name VARCHAR2 DEFAULT NULL,
--     pi_pick_up_date VARCHAR2 DEFAULT NULL,
--     pi_dropoff_date VARCHAR2 DEFAULT NULL
-- ) AS
--     v_location_id locations.id%TYPE;
--     v_vehicle_type_id vehicle_types.id%TYPE;
--     v_vendor_id users.id%TYPE;
--     v_vehicle_id vehicles.id%TYPE;
--     v_pickup_date DATE;
--     v_dropoff_date DATE;
--     v_query VARCHAR2;
--     e_invalid_location EXCEPTION;
--     e_invalid_vehicle_type EXCEPTION;
--     e_invalid_vendor EXCEPTION;

-- BEGIN
--     v_query := 'create or replace view view_available_vehicles as select * from vehicles where id not in (select vehicles_id from reservations where status in (''pending'', ''active''))';
    

--     BEGIN
--         if pi_pick_up_date IS NOT NULL then
--             v_pickup_date := TO_DATE(pi_pick_up_date, 'YYYY-MM-DD');

--             v_query := v_query || ' AND ' || v_pickup_date || ' NOT BETWEEN pickup_date AND dropoff_date';
--         end if;

--         if pi_dropoff_date IS NOT NULL then
--             v_dropoff_date := TO_DATE(pi_dropoff_date, 'YYYY-MM-DD');

--             v_query := v_query || ' AND ' || v_dropoff_date || ' NOT BETWEEN pickup_date AND dropoff_date';
--         end if;

--     EXCEPTION
--         WHEN OTHERS THEN
--             DBMS_OUTPUT.PUT_LINE('ERROR: Invalid date format');
--             COMMIT;
--     END;

--     if pi_location_name is not NULL then
--         SELECT id INTO v_location_id FROM locations WHERE name = pi_location_name;

--         IF v_location_id IS NULL THEN
--             RAISE e_invalid_location;
--         END IF;

--         v_query := v_query || ' AND current_location_id = ' || v_location_id;
--     end if;
    
--     if pi_vehicle_type is not NULL then
--         SELECT id INTO v_vehicle_type_id FROM vehicle_types WHERE model = pi_vehicle_type;

--         IF v_vehicle_type_id IS NULL THEN
--             RAISE e_invalid_vehicle_type;
--         END IF;

--         v_query := v_query || ' AND vehicle_type_id = ' || v_vehicle_type_id;
--     end if;

--     if pi_vendor_name is not NULL then
--         SELECT id INTO v_vendor_id FROM users WHERE fname = pi_vendor_name;

--         IF v_vendor_id IS NULL THEN
--             RAISE e_invalid_vendor;
--         END IF;

--         v_query := v_query || ' AND users_id = ' || v_vendor_id;
--     end if;

--     v_query := v_query || ';'; 

--     EXECUTE IMMEDIATE v_query;

--     EXECUTE IMMEDIATE "SELECT * FROM view_available_vehicles";

--     COMMIT;
-- EXCEPTION
--     WHEN e_invalid_location THEN
--         DBMS_OUTPUT.PUT_LINE('ERROR: Invalid location');
--     WHEN e_invalid_vehicle_type THEN
--         DBMS_OUTPUT.PUT_LINE('ERROR: Invalid vehicle type');
--     WHEN e_invalid_vendor THEN
--         DBMS_OUTPUT.PUT_LINE('ERROR: Invalid vendor');
--     WHEN OTHERS THEN
--         RAISE;
--         COMMIT;
-- END get_available_vehicles;
-- /


-- EXEC get_available_vehicles();
