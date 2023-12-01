# Business rules
- Vendors must provide company name and tax ID to be able to list vehicles.
- When a new vehicle is added by the vendor, they should be listed available by default. They will also need a vehicle type from the system to be listed.
- Payments can be made through previously saved payment methods (CC and debit card).
- Saved payment methods will be checked if they are within expiry date.
- Billing address will be assumed to be the address provided in user information unless changed.
- Customers should have a valid DL and should be over 21 years to be able to rent a car.
- Customer should have at least one payment method saved before making a reservation
- Reservation becomes confirmed only if the transaction is approved/successful and the vehicle's availability is verified.
- Customers can update their reservation, subject to vehicle availability and transaction status.
- Customers will have the option of choosing from insurance types in the system before making the reservation. If not, a default insurance type will be assigned.
Vehicles will be marked unavailable once the reservation is active.
- An active reservation can be defined when the current date is between the pickup date and the drop-off date.

# Covered use cases
### App
- [x] (trigger)Update expired reservations to cancelled
```
trg_update_expired_reservations
```
- [x] retrieve rental records for a user
```
EXEC get_user_completed_reservations(user_id IN NUMBER);
```


### Insurance analyst
- [x] Procedure: create insurance type
```
add_insurance_type (pi_name VARCHAR2, pi_coverage NUMBER)
```

- [x] Procedure: update existing insurance type
```
update_insurance_type (pi_insurance_type_name VARCHAR2, pi_new_coverage NUMBER);
```

- [x] View: insurance analytics (count of reservations for each and total revenue from each)
```
select * from view_insurance_res_rev;
```

- [x] View: Insurance analytics (top performing insurance type by vehicle type)
```
select * from view_insurance_top_performer;
```

### App analyst
- [x] View: No of rentals and revenue by vehicle type
```
select * from rentals_and_revenue_by_vehicle_type;
```
- [x] View: no of rentals and revenue by vendor
```
select * from rentals_revenue_by_vendor;
```
- [x] View: revenue by demographic (10 years age range)
```
select * from revenue_by_demographic;
```
- [x] View: revenue by user’s location
```
select * from revenue_by_location_view;
```
- [x] View: no of rentals by discount_type
```
select * from view_rentals_by_discount_type;
```
- [x] View: total booking last week
```
select * from view_total_booking_last_week;
```
### Customer
- [x] View: all available cars
```
select * from view_all_available_cars;
```
- [x] Package: Customer new reservation flow
    - [x] Procedure: Initiate a complete booking (reservation with successful payment)
    - [x] Procedure: initiate payment transactions
    - [x] Procedure: approve payment transactions
```
DECLARE
    v_pickup_location_name VARCHAR2(100) := 'Los Angeles';
    v_dropoff_location_name VARCHAR2(100) := 'New York';
    v_insurance_type_name VARCHAR2(100) := 'travel shield';
    v_user_name VARCHAR2(100) := 'Abigail';
    v_vehicle_registration_id VARCHAR2(100) := 'ARK678NEW7908OOP';
    v_pickup_date VARCHAR2(100) := '2024-05-11';
    v_dropoff_date VARCHAR2(100) := '2024-04-10';
    v_passenger_count NUMBER := 5;
    v_card_number VARCHAR2(100) := '1234567890123456';
    v_discount_code VARCHAR2(100) := 'WONDER10';
BEGIN
    booking_package.initiate_booking(
        pi_pickup_date => v_pickup_date,
        pi_dropoff_date => v_dropoff_date,
        pi_pickup_location_name => v_pickup_location_name,
        pi_dropoff_location_name => v_dropoff_location_name,
        pi_passenger_count => v_passenger_count,
        pi_vehicle_registration_id => v_vehicle_registration_id,
        pi_user_name => v_user_name,
        pi_insurance_type_name => v_insurance_type_name
    );
-- Procedure: initiate payment transactions
    booking_package.initiate_payment_transaction(
        pi_user_name => v_user_name,
        pi_vehicle_registration_id => v_vehicle_registration_id,
        pi_pick_up_date => v_pickup_date,
        pi_card_number => v_card_number,
        pi_discount_code => v_discount_code
    );

    booking_package.approve_transaction(
        pi_user_name => v_user_name,
        pi_vehicle_registration_id => v_vehicle_registration_id,
        pi_pick_up_date => v_pickup_date
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
        ROLLBACK;
END;
```
- [x] Procedure: Cancel a booking (should happen only if reservation isn't active yet)
```
EXEC cancel_reservation(RESERVATION_ID as number);
```
- [ ] Procedure: Add a payment method / Update a payment method

- [ ] Procedure: View payment methods
```
EXEC get_payment_methods('Abigail');
```
- [x] View: rental history
```
-- history by a user
EXEC get_user_reservations_history(user_id as number);
```

### Vendor (saurabh)
- [ ] Add/update a new car
- [ ] View rental history (niv)
- [ ] View all cars
- [ ] View customers who has rented his cars 
