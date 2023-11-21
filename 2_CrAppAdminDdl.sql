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
