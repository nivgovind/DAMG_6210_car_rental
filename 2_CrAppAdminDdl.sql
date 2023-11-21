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
