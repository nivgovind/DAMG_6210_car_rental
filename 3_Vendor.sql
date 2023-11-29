CREATE OR REPLACE PROCEDURE add_vendor_vehicle (
    p_make VARCHAR2,
    p_model VARCHAR2,
    p_transmission_type VARCHAR2,
    p_category VARCHAR2,
    p_fuel_type VARCHAR2,
    p_hourly_rate NUMBER,
    p_miles_driven NUMBER,
    p_passenger_capacity NUMBER,
    p_registration_id VARCHAR2,
    p_current_location_name VARCHAR2
) AS
    v_vendor_id NUMBER;
    v_vehicle_type_id NUMBER;
    v_location_id NUMBER;
BEGIN

    -- Check if the vehicle type already exists
    SELECT id INTO v_vehicle_type_id
    FROM vehicle_types
    WHERE make = p_make AND model = p_model AND ROWNUM = 1;

    IF v_vehicle_type_id IS NULL THEN
        -- Raise an exception if the vehicle type does not exist
        RAISE_APPLICATION_ERROR(-20003, 'Specified vehicle type does not exist');
    END IF;

    -- Check if the location already exists
    SELECT id INTO v_location_id
    FROM locations
    WHERE name = p_current_location_name AND ROWNUM = 1;

    IF v_location_id IS NULL THEN
        -- Raise an exception if the location does not exist
        RAISE_APPLICATION_ERROR(-20004, 'Specified location does not exist');
    END IF;

    -- Insert the new vehicle
    INSERT INTO vehicles (
        hourly_rate,
        miles_driven,
        availability_status,
        passenger_capacity,
        registration_id,
        current_location_id,
        users_id,
        vehicle_type_id
    ) VALUES (
        p_hourly_rate,
        p_miles_driven,
        1,
        p_passenger_capacity,
        p_registration_id,
        v_location_id,
        v_vendor_id,
        v_vehicle_type_id
    );

    COMMIT;
END add_vendor_vehicle;
/



    
    

CREATE OR REPLACE VIEW rented_cars_view AS
SELECT
    u.id AS customer_id,
    u.fname || ' ' || u.lname AS customer_name,
    r.id AS reservation_id,
    r.pickup_date,
    r.dropoff_date,
    v.id AS vehicle_id
    
FROM
    users u
JOIN
    reservations r ON u.id = r.users_id
JOIN
    vehicles v ON r.vehicles_id = v.id
WHERE
    u.role = 'customer'
    AND EXISTS (
        SELECT 1
        FROM vehicles v_vendor
        JOIN users u_vendor ON v_vendor.users_id = u_vendor.id
        WHERE v_vendor.id = v.id
          AND u_vendor.role = 'vendor'
          AND u_vendor.id = USER
    );
