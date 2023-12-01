SET SERVEROUTPUT ON;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE payment_transactions';
    EXECUTE IMMEDIATE 'DROP TABLE reservations';
    EXECUTE IMMEDIATE 'DROP TABLE vehicles';
    EXECUTE IMMEDIATE 'DROP TABLE payment_methods';
    EXECUTE IMMEDIATE 'DROP TABLE insurance_types';
    EXECUTE IMMEDIATE 'DROP TABLE discount_types';
    EXECUTE IMMEDIATE 'DROP TABLE vehicle_types';  
    EXECUTE IMMEDIATE 'DROP TABLE users';
    EXECUTE IMMEDIATE 'DROP TABLE locations';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Drop sequences if already exists
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE locations_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE discount_types_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE insurance_types_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE payment_methods_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE payment_transactions_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE reservations_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE users_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE vehicle_types_seq';
    EXECUTE IMMEDIATE 'DROP SEQUENCE vehicles_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/
-- Create sequences
CREATE SEQUENCE locations_seq START WITH 1;
CREATE SEQUENCE users_seq START WITH 1;
CREATE SEQUENCE vehicle_types_seq START WITH 1;
CREATE SEQUENCE discount_types_seq START WITH 1;
CREATE SEQUENCE insurance_types_seq START WITH 1;
CREATE SEQUENCE payment_methods_seq START WITH 1;
CREATE SEQUENCE payment_transactions_seq START WITH 1;
CREATE SEQUENCE reservations_seq START WITH 1;
CREATE SEQUENCE vehicles_seq START WITH 1;

-- Create tables
CREATE TABLE locations (
    id       NUMBER DEFAULT locations_seq.nextval NOT NULL,
    name     VARCHAR2(100) NOT NULL,
    CONSTRAINT locations_pk PRIMARY KEY (id)
);

CREATE TABLE vehicle_types (
    id                NUMBER DEFAULT vehicle_types_seq.nextval NOT NULL,
    make              VARCHAR2(20) NOT NULL,
    model             VARCHAR2(100) NOT NULL,
    transmission_type VARCHAR2(100),
    category          VARCHAR2(100) NOT NULL,
    fuel_type         VARCHAR2(20) NOT NULL,
    CONSTRAINT vehicle_types_pk PRIMARY KEY (id)
);

CREATE TABLE discount_types (
    id              NUMBER DEFAULT discount_types_seq.nextval NOT NULL,
    code            VARCHAR2(10) NOT NULL,
    discount_amount NUMBER(7,2) NOT NULL,
    min_eligible_charge NUMBER(7,2) NOT NULL,
    CONSTRAINT discount_types_pk PRIMARY KEY (id)
);

CREATE TABLE insurance_types (
    id       NUMBER DEFAULT insurance_types_seq.nextval NOT NULL,
    coverage NUMBER(7,2) NOT NULL,
    name     VARCHAR2(100) NOT NULL,
    CONSTRAINT insurance_types_pk PRIMARY KEY (id)
);

CREATE TABLE users (
    id                 NUMBER DEFAULT users_seq.nextval NOT NULL,
    role               VARCHAR2(10) NOT NULL,
    fname              VARCHAR2(100) NOT NULL,
    lname              VARCHAR2(100),
    current_location_id NUMBER,
    driver_license   VARCHAR2(20),
    age              NUMBER,
    company_name     VARCHAR2(100),
    tax_id           VARCHAR2(20),
    CONSTRAINT users_pk PRIMARY KEY (id),
    CONSTRAINT users_locations_fk FOREIGN KEY (current_location_id)
        REFERENCES locations(id)
);

CREATE TABLE payment_methods (
    id              NUMBER DEFAULT payment_methods_seq.nextval NOT NULL,
    active_status   NUMBER NOT NULL CHECK (active_status IN (1,0)),
    card_number     VARCHAR2(16) NOT NULL,
    expiration_date DATE NOT NULL,
    security_code   VARCHAR2(3) NOT NULL,
    billing_address VARCHAR2(100),
    users_id        NUMBER NOT NULL,
    CONSTRAINT payment_methods_pk PRIMARY KEY (id),
    CONSTRAINT payment_methods_users_fk FOREIGN KEY (users_id)
        REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE vehicles (
    id                  NUMBER DEFAULT vehicles_seq.nextval NOT NULL,
    hourly_rate         NUMBER(7,2) NOT NULL,
    miles_driven        NUMBER,
    availability_status NUMBER NOT NULL CHECK (availability_status IN (1,0)),
    passenger_capacity  NUMBER,
    registration_id     VARCHAR2(20) NOT NULL,
    current_location_id NUMBER,
    users_id            NUMBER,
    vehicle_type_id     NUMBER,
    CONSTRAINT vehicles_pk PRIMARY KEY (id),
    CONSTRAINT vehicles_users_fk FOREIGN KEY ( users_id )
        REFERENCES users ( id ) ON DELETE CASCADE,
    CONSTRAINT vehicles_vehicle_type_fk FOREIGN KEY ( vehicle_type_id )
        REFERENCES vehicle_types ( id ),
    CONSTRAINT vehicles_locations_fk FOREIGN KEY (current_location_id)
        REFERENCES locations(id)
);


CREATE TABLE reservations (
    id                 NUMBER DEFAULT reservations_seq.nextval NOT NULL,
    status             VARCHAR2(10) NOT NULL,
    charge             NUMBER(7,2),
    pickup_date        DATE NOT NULL,
    dropoff_date       DATE NOT NULL,
    insurance_id       VARCHAR2(20) NOT NULL,
    pickup_location_id NUMBER,
    dropoff_location_id NUMBER,
    passenger_count    NUMBER,
    vehicles_id        NUMBER NOT NULL,
    users_id           NUMBER,
    insurance_types_id NUMBER,
    CONSTRAINT reservations_pk PRIMARY KEY (id),
    CONSTRAINT reservations_insurance_types_fk FOREIGN KEY ( insurance_types_id )
        REFERENCES insurance_types ( id ),
    CONSTRAINT reservations_users_fk FOREIGN KEY ( users_id )
        REFERENCES users ( id ),
    CONSTRAINT reservations_vehicles_fk FOREIGN KEY ( vehicles_id )
        REFERENCES vehicles ( id ),
    CONSTRAINT pickup_location_fk FOREIGN KEY (pickup_location_id)
        REFERENCES locations(id),
    CONSTRAINT dropoff_location_fk FOREIGN KEY (dropoff_location_id)
        REFERENCES locations(id),
    CONSTRAINT status_check CHECK (status IN ('pending', 'active', 'completed', 'cancelled'))
);

CREATE TABLE payment_transactions (
    id                 NUMBER DEFAULT payment_transactions_seq.nextval NOT NULL,
    status             NUMBER NOT NULL,
    amount             NUMBER(7,2) NOT NULL,
    approval_code      VARCHAR2(20),
    reservations_id    NUMBER,
    payment_methods_id NUMBER,
    discount_types_id  NUMBER,
    CONSTRAINT payment_transactions_pk PRIMARY KEY (id),
    CONSTRAINT payment_transactions_discount_types_fk FOREIGN KEY ( discount_types_id )
        REFERENCES discount_types ( id ),
    CONSTRAINT payment_transactions_payment_methods_fk FOREIGN KEY ( payment_methods_id )
        REFERENCES payment_methods ( id ),
    CONSTRAINT payment_transactions_reservations_fk FOREIGN KEY ( reservations_id )
        REFERENCES reservations ( id ),
    CONSTRAINT payment_transactions_status_check CHECK (status IN (1, 0))
);

-- Procedure for adding location
CREATE OR REPLACE PROCEDURE add_location (
    pi_name VARCHAR2
) AS
    v_name_count NUMBER;
    e_unique_name EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_name_count FROM locations WHERE name = pi_name;

    IF v_name_count = 0 THEN
        INSERT INTO locations VALUES (locations_seq.nextval, pi_name);
        DBMS_OUTPUT.PUT_LINE(pi_name || ' added');
    ELSE
        RAISE e_unique_name;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_name THEN
        DBMS_OUTPUT.PUT_LINE(pi_name || 'already exists');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_location;
/

-- Procedure for adding vehicle types
CREATE OR REPLACE PROCEDURE add_vehicle_type (
    pi_make VARCHAR2,
    pi_model VARCHAR2,
    pi_transmission_type VARCHAR2,
    pi_category VARCHAR2,
    pi_fuel_type VARCHAR2
) AS
    v_model_count NUMBER;
    e_unique_name EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_model_count FROM vehicle_types WHERE make = pi_make AND model = pi_model;

    IF v_model_count = 0 THEN
        INSERT INTO vehicle_types VALUES (vehicle_types_seq.nextval, pi_make, pi_model, pi_transmission_type, pi_category, pi_fuel_type);
        DBMS_OUTPUT.PUT_LINE(pi_make || '-' || pi_model || ' added');
    ELSE
        RAISE e_unique_name;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_name THEN
        DBMS_OUTPUT.PUT_LINE(pi_make || '-' || pi_model || ' already exists');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_vehicle_type;
/


-- Procedure for adding discount types
CREATE OR REPLACE PROCEDURE add_discount_type (
    pi_code VARCHAR2,
    pi_min_amount NUMBER,
    pi_amount NUMBER
) AS
    v_code_count NUMBER;
    e_unique_code EXCEPTION;
    e_invalid_amount EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_code_count FROM discount_types WHERE code = pi_code;
    IF pi_amount < 0 THEN
        RAISE e_invalid_amount;
    END IF;

    IF v_code_count = 0 THEN
        INSERT INTO discount_types VALUES (discount_types_seq.nextval, pi_code, pi_min_amount, pi_amount);
        DBMS_OUTPUT.PUT_LINE(pi_code || ' added');
    ELSE
        RAISE e_unique_code;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_code THEN
        DBMS_OUTPUT.PUT_LINE(pi_code || 'already exists');
    WHEN e_invalid_amount THEN
        DBMS_OUTPUT.PUT_LINE(pi_amount || 'is not a valid discount amount');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_discount_type;
/

-- Procedure for adding insurance types
CREATE OR REPLACE PROCEDURE add_insurance_type (
    pi_name VARCHAR2,
    pi_coverage NUMBER
) AS
    v_name_count NUMBER;
    e_unique_code EXCEPTION;
    e_invalid_amount EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_name_count FROM insurance_types WHERE name = pi_name;
    IF pi_coverage <= 0 THEN
        RAISE e_invalid_amount;
    END IF;

    IF v_name_count = 0 THEN
        INSERT INTO insurance_types VALUES (insurance_types_seq.nextval, pi_coverage, pi_name);
        DBMS_OUTPUT.PUT_LINE(pi_name || ' added');
    ELSE
        RAISE e_unique_code;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_code THEN
        DBMS_OUTPUT.PUT_LINE(pi_name || 'already exists');
    WHEN e_invalid_amount THEN
        DBMS_OUTPUT.PUT_LINE(pi_coverage || 'is not a valid coverage amount');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_insurance_type;
/


-- Procedure for adding users
CREATE OR REPLACE PROCEDURE add_user (
    pi_role VARCHAR2,
    pi_fname VARCHAR2,
    pi_lname VARCHAR2,
    pi_location VARCHAR2,
    pi_DL VARCHAR2,
    pi_age NUMBER,
    pi_cname VARCHAR2,
    pi_taxid VARCHAR2
) AS
    v_user_count NUMBER;
    v_location_id locations.id%TYPE;
    e_unique_code EXCEPTION;
    e_incomplete_customer_info EXCEPTION;
    e_incomplete_vendor_info EXCEPTION;
    e_invalid_location_info EXCEPTION;
    e_invalid_role EXCEPTION;
    e_invalid_age EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_user_count FROM users WHERE fname = pi_fname AND lname = pi_lname;
    
    IF pi_role != 'customer' AND pi_role != 'vendor' THEN
        RAISE e_invalid_role;
    END IF;

    SELECT id
        INTO v_location_id
        FROM locations
        WHERE name = pi_location;

    IF v_location_id IS NULL THEN
        raise e_invalid_location_info;
    END IF;

    IF pi_role = 'customer' THEN
        IF pi_age < 23 THEN
            RAISE e_invalid_age;
        END IF;

        IF LENGTH(pi_DL) < 16 THEN
            RAISE e_incomplete_customer_info;
        END IF;
    ELSIF pi_role = 'vendor' AND LENGTH(pi_taxid) < 16 AND LENGTH(pi_cname) < 5 THEN
        RAISE e_incomplete_vendor_info;
    END IF;

    IF v_user_count = 0 THEN
        INSERT INTO users (
            role,
            fname,
            lname,
            current_location_id,
            driver_license,
            age,
            company_name,
            tax_id
        ) VALUES (
            pi_role,
            pi_fname,
            pi_lname,
            v_location_id,
            pi_DL,
            pi_age,
            pi_cname,
            pi_taxid
        );

        DBMS_OUTPUT.PUT_LINE(pi_fname || ' added');
    ELSE
        RAISE e_unique_code;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_code THEN
        DBMS_OUTPUT.PUT_LINE(pi_fname || 'already exists');
    WHEN e_incomplete_customer_info THEN
        DBMS_OUTPUT.PUT_LINE(pi_fname || 'does not have valid customer info');
    WHEN e_incomplete_vendor_info THEN
        DBMS_OUTPUT.PUT_LINE(pi_fname || 'does not have valid vendor info');
    WHEN e_invalid_location_info THEN
        DBMS_OUTPUT.PUT_LINE(pi_location || 'is not valid location info');
    WHEN e_invalid_role THEN
        DBMS_OUTPUT.PUT_LINE(pi_role || 'is not valid role info');
    WHEN e_invalid_age THEN
        DBMS_OUTPUT.PUT_LINE(pi_age || 'is not valid age info');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_user;
/

-- Procedure for adding vehicles
CREATE OR REPLACE PROCEDURE add_vehicle (
    pi_hourly_rate NUMBER,
    pi_miles_driven NUMBER,
    pi_availability_status VARCHAR2,
    pi_passenger_capacity NUMBER,
    pi_registration_id VARCHAR,
    pi_location_name VARCHAR,
    pi_user_name VARCHAR,
    pi_make VARCHAR

) AS
    v_reg_count NUMBER;
    v_status NUMBER;
    v_location_id vehicle_types.id%TYPE;
    v_vendor_id users.id%TYPE;
    v_vehicle_type_id vehicles.id%TYPE;
    e_unique_reg_id EXCEPTION;
    e_invalid_reg_id EXCEPTION;
    e_invalid_ref EXCEPTION;
    e_invalid_pger_count EXCEPTION;
    e_invalid_data EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_reg_count FROM vehicles WHERE registration_id = pi_registration_id;

    IF pi_availability_status = 'true' THEN
        v_status := 1;
    ELSIF pi_availability_status = 'false' THEN
        v_status := 0;
    ELSE
        RAISE e_invalid_data;
    END IF;
    
    IF v_reg_count != 0 THEN
        RAISE e_unique_reg_id;
    END IF;
    
    IF pi_passenger_capacity > 10 THEN
        RAISE e_invalid_pger_count;
    END IF;

    IF LENGTH(pi_registration_id) != 16 THEN
        raise e_invalid_reg_id;
    END IF;

    SELECT id
        INTO v_location_id
        FROM locations
        WHERE name = pi_location_name;

    SELECT id
        INTO v_vendor_id
        FROM users
        WHERE fname = pi_user_name;
    
    SELECT id
        INTO v_vehicle_type_id
        FROM vehicle_types
        WHERE model = pi_make;

    IF v_vendor_id IS NULL OR v_vehicle_type_id IS NULL OR v_location_id IS NULL THEN
        raise e_invalid_ref;
    END IF;

    INSERT INTO vehicles
        VALUES(
            vehicles_seq.nextval,
            pi_hourly_rate,
            pi_miles_driven,
            v_status,
            pi_passenger_capacity,
            pi_registration_id,
            v_location_id,
            v_vendor_id,
            v_vehicle_type_id
        );
    
    DBMS_OUTPUT.PUT_LINE(pi_registration_id || ' vehicle added');
    COMMIT;

EXCEPTION
    WHEN e_unique_reg_id THEN
        DBMS_OUTPUT.PUT_LINE(pi_registration_id || 'already exists');
    WHEN e_invalid_reg_id THEN
        DBMS_OUTPUT.PUT_LINE(pi_registration_id || 'is invalid');
    WHEN e_invalid_ref THEN
        DBMS_OUTPUT.PUT_LINE('References does not exist');
    WHEN e_invalid_pger_count THEN
        DBMS_OUTPUT.PUT_LINE(pi_passenger_capacity || 'is invalid');
    WHEN e_invalid_data THEN
        DBMS_OUTPUT.PUT_LINE('Data is invalid');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_vehicle;
/

-- Procedure for adding payment methods
CREATE OR REPLACE PROCEDURE add_payment_method (
    pi_card_number VARCHAR2,
    pi_active_status VARCHAR2,
    pi_expiration_date VARCHAR2,
    pi_security_code VARCHAR2,
    pi_billing_address VARCHAR2,
    pi_user_name VARCHAR
) AS
    v_card_count NUMBER;
    v_status NUMBER;
    v_expiration_date DATE;
    e_unique_name EXCEPTION;
    v_user_id users.id%TYPE;
    e_invalid_ref EXCEPTION;
    e_invalid_data EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO v_card_count FROM payment_methods WHERE card_number = pi_card_number;
    v_expiration_date := TO_DATE(pi_expiration_date, 'YYYY-MM-DD');
    
    IF pi_active_status = 'true' THEN
        v_status := 1;
    ELSIF pi_active_status = 'false' THEN
        v_status := 0;
    ELSE
        RAISE e_invalid_data;
    END IF;
    
    SELECT id
        INTO v_user_id
        FROM users
        WHERE fname = pi_user_name;

    IF v_user_id IS NULL THEN
        RAISE e_invalid_ref;
    END IF;

    IF LENGTH(pi_card_number) != 16 OR LENGTH(pi_security_code) != 3 OR v_expiration_date < SYSDATE THEN
        RAISE e_invalid_data;
    END IF;

    IF v_card_count = 0 THEN
        INSERT INTO payment_methods (id, active_status, card_number, expiration_date, security_code, billing_address, users_id)
        VALUES (payment_methods_seq.nextval, v_status, pi_card_number, v_expiration_date, pi_security_code, pi_billing_address, v_user_id);

        DBMS_OUTPUT.PUT_LINE(pi_card_number || ' added');
    ELSE
        RAISE e_unique_name;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_unique_name THEN
        DBMS_OUTPUT.PUT_LINE(pi_card_number || ' already exists');
    WHEN e_invalid_ref THEN
        DBMS_OUTPUT.PUT_LINE('References do not exist');
    WHEN e_invalid_data THEN
        DBMS_OUTPUT.PUT_LINE('Invalid data');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;

END add_payment_method;
/

-- Procedure for adding reservations
CREATE OR REPLACE PROCEDURE add_reservation (
    pi_status VARCHAR2,
    pi_charge NUMBER,
    pi_pickup_date VARCHAR2,
    pi_dropoff_date VARCHAR2,
    pi_insurance_id VARCHAR2,
    pi_pickup_location_name VARCHAR2,
    pi_dropoff_location_name VARCHAR2,
    pi_passenger_count NUMBER,
    pi_vehicle_registration_id VARCHAR2,
    pi_user_name VARCHAR2,
    pi_insurance_type_name VARCHAR2
) AS
    v_pickup_location_id locations.id%TYPE;
    v_dropoff_location_id locations.id%TYPE;
    v_insurance_type_id insurance_types.id%TYPE;
    v_user_id users.id%TYPE;
    v_vehicle_id vehicles.id%TYPE;
    e_invalid_location EXCEPTION;
    e_invalid_insurance EXCEPTION;
    e_invalid_user EXCEPTION;
    e_invalid_vehicle EXCEPTION;
BEGIN
    SELECT id INTO v_pickup_location_id FROM locations WHERE name = pi_pickup_location_name;
    SELECT id INTO v_dropoff_location_id FROM locations WHERE name = pi_dropoff_location_name;
    SELECT id INTO v_insurance_type_id FROM insurance_types WHERE lower(name) LIKE lower(pi_insurance_type_name);
    SELECT id INTO v_user_id FROM users WHERE fname = pi_user_name;
    SELECT id INTO v_vehicle_id FROM vehicles WHERE registration_id = pi_vehicle_registration_id;

    IF v_pickup_location_id IS NULL OR v_dropoff_location_id IS NULL THEN
        RAISE e_invalid_location;
    END IF;

    IF v_insurance_type_id IS NULL THEN
        RAISE e_invalid_insurance;
    END IF;

    IF v_user_id IS NULL THEN
        RAISE e_invalid_user;
    END IF;

    IF v_vehicle_id IS NULL THEN
        RAISE e_invalid_vehicle;
    END IF;

    INSERT INTO reservations (
        id,
        status,
        charge,
        pickup_date,
        dropoff_date,
        insurance_id,
        pickup_location_id,
        dropoff_location_id,
        passenger_count,
        vehicles_id,
        users_id,
        insurance_types_id
    ) VALUES (
        reservations_seq.nextval,
        pi_status,
        pi_charge,
        TO_DATE(pi_pickup_date, 'YYYY-MM-DD'),
        TO_DATE(pi_dropoff_date, 'YYYY-MM-DD'),
        pi_insurance_id,
        v_pickup_location_id,
        v_dropoff_location_id,
        pi_passenger_count,
        v_vehicle_id,
        v_user_id,
        v_insurance_type_id
    );

    DBMS_OUTPUT.PUT_LINE('Reservation added');
    COMMIT;

EXCEPTION
    WHEN e_invalid_location THEN
        DBMS_OUTPUT.PUT_LINE('Invalid pickup or dropoff location');
    WHEN e_invalid_insurance THEN
        DBMS_OUTPUT.PUT_LINE('Invalid insurance type');
    WHEN e_invalid_user THEN
        DBMS_OUTPUT.PUT_LINE('Invalid user');
    WHEN e_invalid_vehicle THEN
        DBMS_OUTPUT.PUT_LINE('Invalid vehicle');
    WHEN OTHERS THEN
        RAISE;
        COMMIT;

END add_reservation;
/

-- Procedure for adding payment transactions
CREATE OR REPLACE PROCEDURE add_payment_transaction (
    pi_status VARCHAR2,
    pi_amount NUMBER,
    pi_approval_code VARCHAR2,
    pi_reservation_id NUMBER,
    pi_card_number VARCHAR2,
    pi_discount_code VARCHAR2
) AS
    v_reservation_id reservations.id%TYPE;
    v_status NUMBER;
    v_payment_method_id payment_methods.id%TYPE;
    v_discount_type_id discount_types.id%TYPE;
    e_invalid_reservation EXCEPTION;
    e_invalid_payment_method EXCEPTION;
    e_invalid_discount_type EXCEPTION;
    e_invalid_data EXCEPTION;
BEGIN
    SELECT id INTO v_reservation_id FROM reservations WHERE id = pi_reservation_id;

    IF v_reservation_id IS NULL THEN
        RAISE e_invalid_reservation;
    END IF;

    IF pi_status = 'pending' THEN
        v_status := 0;
    ELSIF pi_status = 'completed' THEN
        v_status := 1;
    ELSE
        RAISE e_invalid_data;
    END IF;

    SELECT id INTO v_payment_method_id FROM payment_methods WHERE card_number = pi_card_number;

    IF v_payment_method_id IS NULL THEN
        RAISE e_invalid_payment_method;
    END IF;

    
    SELECT id INTO v_discount_type_id FROM discount_types WHERE code = pi_discount_code;
    
    IF pi_discount_code IS NULL OR pi_discount_code = '' THEN
        SELECT id INTO v_discount_type_id FROM discount_types WHERE code = 'NO_DISC';
    ELSE
        SELECT id INTO v_discount_type_id FROM discount_types WHERE code = pi_discount_code;
    END IF;

    INSERT INTO payment_transactions (
        id,
        status,
        amount,
        approval_code,
        reservations_id,
        payment_methods_id,
        discount_types_id
    ) VALUES (
        payment_transactions_seq.nextval,
        v_status,
        pi_amount,
        pi_approval_code,
        v_reservation_id,
        v_payment_method_id,
        v_discount_type_id
    );

    DBMS_OUTPUT.PUT_LINE('Payment transaction added');
    COMMIT;

EXCEPTION
    WHEN e_invalid_reservation THEN
        DBMS_OUTPUT.PUT_LINE('Invalid reservation');
    WHEN e_invalid_payment_method THEN
        DBMS_OUTPUT.PUT_LINE('Invalid payment method');
    WHEN e_invalid_discount_type THEN
        DBMS_OUTPUT.PUT_LINE('Invalid discount type');
    WHEN e_invalid_data THEN
        DBMS_OUTPUT.PUT_LINE('Invalid status');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;

END add_payment_transaction;
/

-- Update procedures

-- Update insurance type (available to insurnace analust)
CREATE OR REPLACE PROCEDURE update_insurance_type (
    pi_insurance_type_name VARCHAR2,
    pi_new_coverage NUMBER
) AS
    v_insurance_type_id insurance_types.id%TYPE;
    e_not_found EXCEPTION;
BEGIN
    -- Find the insurance type ID based on the name
    SELECT id INTO v_insurance_type_id
    FROM insurance_types
    WHERE lower(name) LIKE lower(pi_insurance_type_name);

    -- Check if the insurance type exists
    IF v_insurance_type_id IS NOT NULL THEN
        -- Update the coverage amount
        UPDATE insurance_types
        SET coverage = pi_new_coverage
        WHERE id = v_insurance_type_id;

        DBMS_OUTPUT.PUT_LINE('Insurance type ' || pi_insurance_type_name || ' updated with new coverage: ' || pi_new_coverage);
    ELSE
        RAISE e_not_found;
    END IF;

    COMMIT;

EXCEPTION
    WHEN e_not_found THEN
        DBMS_OUTPUT.PUT_LINE(pi_insurance_type_name || 'does not exist');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;

END update_insurance_type;
/



-- Views

-- View: insurance analytics (count of reservations for each and total revenue from each)
CREATE OR REPLACE VIEW view_insurance_res_rev AS
SELECT
    it.id AS insurance_type_id,
    it.name AS insurance_type_name,
    COUNT(r.id) AS reservation_count,
    NVL(SUM(pt.amount), 0) AS total_revenue
FROM
    reservations r 
LEFT JOIN
    insurance_types it ON r.insurance_types_id = it.id
LEFT JOIN
    (SELECT * FROM payment_transactions WHERE status = 1) pt ON r.id = pt.reservations_id
GROUP BY
    it.id, it.name;


-- view: Insurance analytics (top performing insurance type by vehicle type) (note:rank over)
CREATE OR REPLACE VIEW view_insurance_top_performer AS
SELECT
    v.make,
    v.model,
    it.name AS insurance_type_name,
    COUNT(r.id) AS reservation_count
FROM reservations r
JOIN insurance_types it ON r.insurance_types_id = it.id
JOIN (
        SELECT tv.id as id, tvtp.make, tvtp.model 
        FROM vehicles tv 
        JOIN vehicle_types tvtp 
            ON tv.vehicle_type_id = tvtp.id
    ) v ON r.vehicles_id = v.id
GROUP BY
    v.make,
    v.model,
    it.name
ORDER BY
    COUNT(r.id) DESC;


-- View: Analytics rental frequency and revenue by vehicle type
CREATE OR REPLACE VIEW rentals_and_revenue_by_vehicle_type AS
SELECT
    vt.id AS vehicle_type_id,
    vt.make AS make,
    vt.model AS model,
    COUNT(r.id) AS number_of_rentals,
    NVL(SUM(pt.amount), 0) AS total_revenue
FROM
    vehicle_types vt
LEFT JOIN
    vehicles v ON vt.id = v.vehicle_type_id
LEFT JOIN
    reservations r ON v.id = r.vehicles_id
LEFT JOIN
    payment_transactions pt ON r.id = pt.reservations_id
GROUP BY
    vt.id, vt.make, vt.model
ORDER BY
    NVL(SUM(pt.amount), 0) DESC, COUNT(r.id) DESC;


-- View: no of rentals and revenue by vendor
CREATE OR REPLACE VIEW rentals_revenue_by_vendor AS
SELECT 
    u.fname || ' ' || u.lname AS vendor_name,
    count(r.id) as no_of_rentals,
    NVL(SUM(r.charge), 0) AS total_revenue
FROM reservations r
join vehicles v on r.vehicles_id = v.id
join users u on v.users_id = u.id   
group by u.fname, u.lname
order by count(r.id) desc, NVL(SUM(r.charge), 0) desc;


-- View: revenue by demographic (10 years age range)
CREATE OR REPLACE VIEW revenue_by_demographic AS
SELECT
    FLOOR((u.age - 1) / 10) * 10 AS age_range_start,
    FLOOR((u.age - 1) / 10) * 10 + 9 AS age_range_end,
    COUNT(r.id) AS reservation_count,
    SUM(pt.amount) AS total_revenue
FROM
    reservations r
JOIN
    users u ON r.users_id = u.id
JOIN
    (select * from payment_transactions where STATUS = 1) pt ON r.id = pt.reservations_id
GROUP BY
    FLOOR((u.age - 1) / 10) * 10, FLOOR((u.age - 1) / 10) * 10 + 9
ORDER BY
    COUNT(r.id) DESC, SUM(pt.amount) DESC;

-- View: revenue by user’s location
CREATE OR REPLACE VIEW revenue_by_location_view AS
SELECT
    l.name,
    NVL(SUM(vt.amount), 0) AS revenue
FROM
    (
        SELECT
            pt.reservations_id AS id,
            r.pickup_location_id AS location_id,
            pt.amount AS amount
        FROM
            payment_transactions pt
        JOIN
            reservations r ON pt.reservations_id = r.id
        WHERE
            pt.status = 1
            AND r.status = 'completed'
    ) vt
JOIN
    locations l ON vt.location_id = l.id
GROUP BY
    l.name
ORDER BY
    NVL(SUM(vt.amount), 0) DESC;

-- View: no of rentals by discount_type
CREATE OR REPLACE VIEW view_rentals_by_discount_type as
select dt.code, count(r.id) as reservation_frequency
from reservations r
join payment_transactions pt on r.id = pt.reservations_id
join discount_types dt on pt.discount_types_id = dt.id
group by dt.code
order by count(r.id) desc;

-- View: total booking last week
CREATE OR REPLACE VIEW view_total_booking_last_week as
select * 
from reservations
where pickup_date >= sysdate - 7
order by pickup_date desc;

-- View: all available cars
CREATE OR REPLACE VIEW view_all_available_cars as
select * 
from vehicles 
where id not in (
    select vehicles_id from reservations where status = 'active'
);

-- view all rental history
create or replace view view_all_rental_history as
SELECT
    r.id as id,
    u.id as user_id,
    u.fname || ' ' || u.lname AS customer_name,
    vt.make || '-' || vt.model AS car_name,
    r.pickup_date,
    r.dropoff_date,
    r.charge
FROM
    reservations r
JOIN
    users u ON r.users_id = u.id
JOIN
    vehicles ON r.vehicles_id = vehicles.id
JOIN
    vehicle_types vt ON vehicles.vehicle_type_id = vt.id
WHERE
    r.status = 'completed'
ORDER BY
    u.fname || ' ' || u.lname, r.pickup_date DESC;

-- Procedure: Initiate a booking / Update a booking

-- Procedure: Cancel a booking (should happen only if reservation isn't active yet)
CREATE OR REPLACE PROCEDURE cancel_reservation (
    pi_reservation_id IN NUMBER
) AS
    v_reservation_status VARCHAR2(10);

    -- Exceptions
    e_booking_not_found EXCEPTION;
    e_invalid_reservation_state EXCEPTION;

BEGIN
    -- Check if the reservation ID exists
    SELECT status
    INTO v_reservation_status
    FROM reservations
    WHERE id = pi_reservation_id;

    -- Exception: Booking ID not found
    IF v_reservation_status IS NULL THEN
        RAISE e_booking_not_found;
    END IF;

    -- Exception: Booking ID found but not in pending state
    IF v_reservation_status != 'pending' THEN
        RAISE e_invalid_reservation_state;
    END IF;

    -- Update the reservation status to canceled
    UPDATE reservations
    SET status = 'cancelled'
    WHERE id = pi_reservation_id;

    DBMS_OUTPUT.PUT_LINE('Reservation ' || pi_reservation_id || ' has been cancelled.');
    COMMIT;

EXCEPTION
    WHEN e_booking_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Reservation ID not found.');
    WHEN e_invalid_reservation_state THEN
        DBMS_OUTPUT.PUT_LINE('Error: Reservation is not in pending state.');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;
END cancel_reservation;
/

-- Procedure: Add a payment method / Update a payment method
-- Procedure: View payment methods
-- Procedure: delete payment methods
-- Procedure: initiate payment transactions
CREATE OR REPLACE PROCEDURE initiate_payment_transaction (
    pi_reservation_id IN NUMBER,
    pi_card_number    IN VARCHAR2,
    pi_discount_code  IN VARCHAR2 DEFAULT NULL
) AS
    v_reservation_status reservations.status%TYPE;
    v_amount             reservations.charge%TYPE;
    v_discount_amount    discount_types.discount_amount%TYPE;
    v_payment_status     payment_transactions.status%TYPE;
    v_payment_method_id  payment_methods.id%TYPE;
    v_discount_type_id   discount_types.id%TYPE;
    v_users_id           reservations.users_id%TYPE;
    v_pm_users_id        payment_methods.users_id%TYPE;
    e_reservation_not_found     EXCEPTION;
    e_payment_method_not_found  EXCEPTION;
    e_invalid_discount_code     EXCEPTION;
    e_invalid_reservation_state EXCEPTION;
    e_invalid_discount_amount   EXCEPTION;
    e_invalid_data              EXCEPTION;

BEGIN
    -- Check if the reservation ID exists
    SELECT status, charge, users_id
    INTO v_reservation_status, v_amount, v_users_id
    FROM reservations
    WHERE id = pi_reservation_id;

    -- Exception: Reservation ID not found
    IF v_reservation_status IS NULL THEN
        RAISE e_reservation_not_found;
    END IF;

    -- Check if the reservation status is 'active'
    IF v_reservation_status != 'active' THEN
        RAISE e_invalid_reservation_state;
    END IF;

    -- Check if the payment method exists
    SELECT id, active_status, users_id
    INTO v_payment_method_id, v_payment_status, v_pm_users_id
    FROM payment_methods
    WHERE card_number = pi_card_number;

    -- Exception: Payment method not found
    IF v_payment_method_id IS NULL THEN
        RAISE e_payment_method_not_found;
    END IF;

    -- Exception: Payment method is not active
    IF v_payment_status != 1 OR v_pm_users_id != v_users_id THEN
        RAISE e_invalid_data;
    END IF;

    -- Check if a discount code is provided
    IF pi_discount_code IS NOT NULL THEN
        -- Check if the discount code exists
        SELECT id, discount_amount
        INTO v_discount_type_id, v_discount_amount
        FROM discount_types
        WHERE code = pi_discount_code;

        -- Exception: Invalid discount code
        IF v_discount_type_id IS NULL THEN
            RAISE e_invalid_discount_code;
        END IF;

        -- Exception: Discount amount is negative
        IF v_discount_amount < 0 THEN
            RAISE e_invalid_discount_amount;
        END IF;
    END IF;

    -- Insert payment transaction record
    INSERT INTO payment_transactions (
        id,
        status,
        amount,
        approval_code,
        reservations_id,
        payment_methods_id,
        discount_types_id
    ) VALUES (
        payment_transactions_seq.nextval,
        0, -- Pending status
        v_amount - NVL(v_discount_amount, 0), -- Apply discount if available
        NULL,
        pi_reservation_id,
        v_payment_method_id,
        v_discount_type_id
    );

    DBMS_OUTPUT.PUT_LINE('Payment transaction initiated for Reservation ID: ' || pi_reservation_id || 'payment_id:' || payment_transactions_seq.currval);
    COMMIT;

EXCEPTION
    WHEN e_reservation_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Reservation ID not found.');
    WHEN e_payment_method_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Error: Payment method not found.');
    WHEN e_invalid_discount_code THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid discount code.');
    WHEN e_invalid_reservation_state THEN
        DBMS_OUTPUT.PUT_LINE('Error: Reservation is not in active state.');
    WHEN e_invalid_discount_amount THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid discount amount.');
    WHEN e_invalid_data THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid data.');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;
END initiate_payment_transaction;
/

-- Procedure: approve payment transactions
CREATE OR REPLACE PROCEDURE approve_transaction (
    pi_reservation_id IN NUMBER
) AS
    v_approval_code VARCHAR2(16);
BEGIN
    -- Generate a random 16-character approval code
    v_approval_code := DBMS_RANDOM.STRING('A', 16);

    -- Update payment transaction record with the approval code and set status to approved
    UPDATE payment_transactions
    SET status = 1, -- Set status to approved
        approval_code = v_approval_code
    WHERE reservations_id = pi_reservation_id and approval_code IS NULL;

    DBMS_OUTPUT.PUT_LINE('Transaction Approved. Approval Code: ' || v_approval_code);
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Transaction ID not found.');
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;
END approve_transaction;
/

-- Function: Retrieve rental records for a user
CREATE OR REPLACE FUNCTION get_user_completed_reservations(user_id IN NUMBER)
RETURN SYS_REFCURSOR
AS
    c_reservations SYS_REFCURSOR;
BEGIN
    OPEN c_reservations FOR
        SELECT
            r.id as id,
            u.id as user_id,
            u.fname || ' ' || u.lname AS customer_name,
            vt.make || '-' || vt.model AS car_name,
            r.pickup_date,
            r.dropoff_date,
            r.charge
        FROM
            reservations r
        JOIN
            users u ON r.users_id = u.id
        JOIN
            vehicles ON r.vehicles_id = vehicles.id
        JOIN
            vehicle_types vt ON vehicles.vehicle_type_id = vt.id
        WHERE
            r.status = 'completed' and u.id = user_id
        ORDER BY
            u.fname || ' ' || u.lname, r.pickup_date DESC;
    RETURN c_reservations;
END;
/

-- Procedure: Display rental history
CREATE OR REPLACE PROCEDURE get_user_reservations_history(user_id IN NUMBER) AS
    l_reservations SYS_REFCURSOR;
    r_reservation cust_rental_history%ROWTYPE;
BEGIN
    l_reservations := get_user_completed_reservations(user_id);
    LOOP
        BEGIN
            FETCH l_reservations INTO r_reservation;
            EXIT WHEN l_reservations%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(r_reservation.id || ', ' || r_reservation.customer_name || ', ' || r_reservation.car_name || ', ' || r_reservation.pickup_date || ', ' || r_reservation.dropoff_date || ', ' || r_reservation.charge);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('No reservations found.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
        END;
    END LOOP;
    CLOSE l_reservations;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Add data
-- Add locations
exec add_location('New York');
exec add_location('Los Angeles');
exec add_location('Chicago');
exec add_location('Houston');
exec add_location('Miami');
exec add_location('San Francisco');
exec add_location('Seattle');
exec add_location('Denver');
exec add_location('Atlanta');
exec add_location('Dallas');
exec add_location('Phoenix');
exec add_location('Boston');
exec add_location('Las Vegas');
exec add_location('Orlando');
exec add_location('Portland');
exec add_location('Austin');
exec add_location('Nashville');
exec add_location('San Diego');
exec add_location('Minneapolis');

-- Add vehicle types
-- Sedan
exec add_vehicle_type('honda', 'accord', 'automatic', 'sedan', 'petrol');
exec add_vehicle_type('toyota', 'corolla', 'manual', 'sedan', 'gasoline');
exec add_vehicle_type('ford', 'fusion', 'automatic', 'sedan', 'hybrid');
exec add_vehicle_type('chevrolet', 'malibu', 'automatic', 'sedan', 'gasoline');
exec add_vehicle_type('nissan', 'sentra', 'cvt', 'sedan', 'petrol');
exec add_vehicle_type('mercedes', 'cla', 'automatic', 'sedan', 'petrol');
-- SUV
exec add_vehicle_type('jeep', 'cherokee', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('honda', 'cr-v', 'cvt', 'suv', 'petrol');
exec add_vehicle_type('toyota', 'highlander', 'automatic', 'suv', 'hybrid');
exec add_vehicle_type('subaru', 'outback', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('ford', 'explorer', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('mercedes', 'wrangler', 'automatic', 'suv', 'petrol');
-- Truck
exec add_vehicle_type('chevrolet', 'silverado', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('ford', 'f-250', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('ram', '1500', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('toyota', 'tundra', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('nissan', 'titan', 'automatic', 'truck', 'petrol');
exec add_vehicle_type('hummer', 'h1', 'automatic', 'truck', 'petrol');
-- Hatchback
exec add_vehicle_type('volkswagen', 'golf', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('ford', 'fiesta', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('honda', 'fit', 'cvt', 'hatchback', 'petrol');
exec add_vehicle_type('toyota', 'yaris', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('mazda', 'mazda3', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('chevrolet', 'bolt', 'automatic', 'hatchback', 'gasoline');
-- Convertible
exec add_vehicle_type('ford', 'mustang', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('chevrolet', 'camaro', 'manual', 'convertible', 'petrol');
exec add_vehicle_type('bmw', '4 series', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mazda', 'mx-5 miata', 'manual', 'convertible', 'gasoline');
exec add_vehicle_type('audi', 'a3 cabriolet', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mercedes', 'slk 350', 'automatic', 'convertible', 'petrol');


-- Add discount types
EXEC add_discount_type('FIRST', 5.00, 10.00);
EXEC add_discount_type('NO_DISC', 0.00, 0.00);
EXEC add_discount_type('NEW2024', 10.00, 30.00);
EXEC add_discount_type('WONDER10', 20.00, 100.00);
EXEC add_discount_type('PEACEOUT', 30.00, 120.00);

-- Add insurance types
EXEC add_insurance_type('star all', 2000);
EXEC add_insurance_type('safety first', 5000);
EXEC add_insurance_type('travel shield', 3000);
EXEC add_insurance_type('care first', 1000);
EXEC add_insurance_type('cruise protection', 6000);

-- Add users
EXEC add_user('customer', 'Abigail', 'Gring', 'New York', 'DL12345678901234', 25, NULL, NULL);
EXEC add_user('vendor', 'Bob', 'Cat', 'Los Angeles', NULL, NULL, 'BobCat rentals', 'TaxID1234567890123');
EXEC add_user('customer', 'Cat', 'Stevens', 'Boston', 'DL98765432109876', 30, NULL, NULL);
EXEC add_user('vendor', 'Dina', 'Jones', 'Minneapolis', NULL, NULL, 'New Old rentals', 'TaxID8765432109876');

-- Add vehicles
EXEC add_vehicle(25.00, 5000, 'true', 5, 'BOS123NE0W456OOP', 'New York', 'Bob', 'silverado')
EXEC add_vehicle(40.00, 5000, 'true', 5, 'NYE345MID0456OOP', 'New York', 'Dina', 'mustang')
EXEC add_vehicle(50.00, 5000, 'true', 5, 'NYE678MID4056OOP', 'New York', 'Dina', 'camaro')
EXEC add_vehicle(30.00, 5000, 'true', 5, 'ARK678NEW7908OOP', 'New York', 'Bob', 'fiesta')


-- Add payment methods
EXEC add_payment_method('1234876539081234','true', '2024-01-31','186','1 kev St, New York, USA','Abigail');
EXEC add_payment_method('1234567890123456','true', '2027-12-31','123','1 kev St, New York, USA','Abigail');
EXEC add_payment_method('7432738484381812','true', '2026-03-31','354','34 Main St, Boston, USA','Cat');
EXEC add_payment_method('6363712392387232','true', '2027-10-31','154','123 Main St, Boston, USA','Cat');

-- Add reservations
EXEC add_reservation('pending',100.00,'2023-12-01','2023-12-10','SA001','New York','Boston', 2,'ARK678NEW7908OOP','Abigail','star all');
EXEC add_reservation('active',200.00,'2023-12-02','2023-12-11','TS012','New York','Boston', 4,'NYE345MID0456OOP','Abigail','travel shield');
EXEC add_reservation('completed',300.00,'2023-01-01','2023-01-10','SF004','New York','Boston', 2,'NYE345MID0456OOP','Cat','safety first');
EXEC add_reservation('active',350.00,'2023-12-01','2023-12-12','CF001','New York','Boston', 6,'NYE678MID4056OOP','Cat','care first');
EXEC add_reservation('cancelled',110.00,'2024-11-01','2023-11-10','SF034','New York','Boston', 2,'ARK678NEW7908OOP','Abigail','safety first');
EXEC add_reservation('active',200.00,'2023-05-11','2023-05-14','TS012','New York','Boston', 4,'NYE345MID0456OOP','Abigail','travel shield');
EXEC add_reservation('completed',300.00,'2023-03-20','2023-04-10','SF004','New York','Boston', 2,'NYE345MID0456OOP','Cat','safety first');
EXEC add_reservation('active',350.00,'2023-12-01','2023-12-12','CF001','New York','Boston', 6,'NYE678MID4056OOP','Cat','care first');

-- Add Payment transactions
EXEC add_payment_transaction('completed', 100.00, 'VAR300com', 1, '1234876539081234', 'WONDER10');
EXEC add_payment_transaction('completed', 200.00, 'WERE200', 2, '1234876539081234', 'NEW2024');
EXEC add_payment_transaction('completed', 300.00, 'COMP20', 3, '1234876539081234', 'FIRST');
EXEC add_payment_transaction('completed', 350.00, 'COP20we', 4, '1234876539081234', 'NO_DISC');


-- Update expired reservations to cancelled
CREATE OR REPLACE TRIGGER trg_update_expired_reservations
BEFORE INSERT OR UPDATE ON reservations
FOR EACH ROW
BEGIN
    IF :NEW.dropoff_date < SYSDATE AND :NEW.status != 'completed' THEN
        :NEW.status := 'cancelled';
        DBMS_OUTPUT.PUT_LINE('Reservation ' || :NEW.id || ' updated status: cancelled by trigger.');
    END IF;
END;
/

