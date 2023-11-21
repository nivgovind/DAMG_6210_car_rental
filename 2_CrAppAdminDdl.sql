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
-- SUV
exec add_vehicle_type('jeep', 'cherokee', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('honda', 'cr-v', 'cvt', 'suv', 'petrol');
exec add_vehicle_type('toyota', 'highlander', 'automatic', 'suv', 'hybrid');
exec add_vehicle_type('subaru', 'outback', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('ford', 'explorer', 'automatic', 'suv', 'petrol');
-- Truck
exec add_vehicle_type('chevrolet', 'silverado', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('ford', 'f-250', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('ram', '1500', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('toyota', 'tundra', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('nissan', 'titan', 'automatic', 'truck', 'petrol');
-- Hatchback
exec add_vehicle_type('volkswagen', 'golf', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('ford', 'fiesta', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('honda', 'fit', 'cvt', 'hatchback', 'petrol');
exec add_vehicle_type('toyota', 'yaris', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('mazda', 'mazda3', 'automatic', 'hatchback', 'gasoline');
-- Convertible
exec add_vehicle_type('ford', 'mustang', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('chevrolet', 'camaro', 'manual', 'convertible', 'petrol');
exec add_vehicle_type('bmw', '4 series', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mazda', 'mx-5 miata', 'manual', 'convertible', 'gasoline');
exec add_vehicle_type('audi', 'a3 cabriolet', 'automatic', 'convertible', 'petrol');

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