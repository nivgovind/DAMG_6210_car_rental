CREATE OR REPLACE PROCEDURE add_vendor_vehicle (
    p_make VARCHAR2,
    p_model VARCHAR2,
    p_transmission_type VARCHAR2,
    p_category VARCHAR2,
    p_fuel_type VARCHAR2
) AS
BEGIN
    -- Check for non-null values for required parameters
    IF p_make IS NOT NULL AND p_model IS NOT NULL AND p_category IS NOT NULL AND p_fuel_type IS NOT NULL THEN
        INSERT INTO vehicle_types (make, model, transmission_type, category, fuel_type)
        VALUES (p_make, p_model, p_transmission_type, p_category, p_fuel_type);
        COMMIT;
    ELSE
        -- Raise an exception if any of the required parameters is null
        RAISE_APPLICATION_ERROR(-20001, 'Required parameters cannot be null');
    END IF;
END add_vendor_vehicle;
/

CREATE OR REPLACE PROCEDURE update_vehicle (
    p_vehicle_types_id NUMBER,
    p_make VARCHAR2,
    p_model VARCHAR2,
    p_transmission_type VARCHAR2,
    p_category VARCHAR2,
    p_fuel_type VARCHAR2
) AS
BEGIN
    -- Check if the specified vehicle ID exists
    IF NOT EXISTS (SELECT 1 FROM vehicle_types WHERE id = p_vehicle_types_id) THEN
        -- Raise an exception if the vehicle ID does not exist
        RAISE_APPLICATION_ERROR(-20002, 'Specified vehicle ID does not exist');
    END IF;

    -- Check for non-null values for required parameters
    IF p_make IS NOT NULL AND p_model IS NOT NULL AND p_category IS NOT NULL AND p_fuel_type IS NOT NULL THEN
        UPDATE vehicle_types
        SET make = p_make,
            model = p_model,
            transmission_type = p_transmission_type,
            category = p_category,
            fuel_type = p_fuel_type
        WHERE id = p_vehicle_types_id;
        COMMIT;
    ELSE
        -- Raise an exception if any of the required parameters is null
        RAISE_APPLICATION_ERROR(-20001, 'Required parameters cannot be null');
    END IF;
END update_vehicle;
/

