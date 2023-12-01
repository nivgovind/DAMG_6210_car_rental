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
- [ ] (trigger)When reservation is created, it should calculate the charge and add insurance cost
- [ ] (trigger)When payment_transaction is created, we should create label for approval_code


### Insurance analyst
- [ ] Add more data under first two points
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
- [ ] Procedure: Initiate a complete booking (reservation with successful payment)
```

```
- [x] Procedure: Cancel a booking (should happen only if reservation isn't active yet)
```
EXEC cancel_reservation(RESERVATION_ID as number);
```
- [ ] Procedure: Add a payment method / Update a payment method
- [ ] Procedure: View payment methods
- [ ] Procedure: delete payment methods
- [ ] Procedure: initiate payment transactions
- [x] View: rental history
```
-- all history
select * from view_all_rental_history;

-- history by a user
EXEC get_user_reservations_history(user_id as number);
```

### Vendor (saurabh)
- [ ] Add/update a new car
- [ ] View rental history (niv)
- [ ] View all cars
- [ ] View customers who has rented his cars 


## Functions
- retrieve rental records for a user
```
get_user_completed_reservations(user_id IN NUMBER)
```