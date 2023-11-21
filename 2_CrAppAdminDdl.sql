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
EXEC add_reservation('completed',300.00,'2023-01-01','2023-01-10','SF004','New York','Boston', 2,'NYE345MID0456OOP','Abigail','safety first');
EXEC add_reservation('active',350.00,'2023-12-01','2023-12-12','CF001','New York','Boston', 6,'NYE678MID4056OOP','Abigail','care first');
EXEC add_reservation('cancelled',110.00,'2024-11-01','2023-11-10','SF034','New York','Boston', 2,'ARK678NEW7908OOP','Abigail','safety first');
