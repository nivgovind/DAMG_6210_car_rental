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
- [ ] Procedure: create insurance type - done
`add_insurance_type (pi_name VARCHAR2, pi_coverage NUMBER)`

- [ ] Procedure: update existing insurance type - done
`update_insurance_type (pi_insurance_type_name VARCHAR2, pi_new_coverage NUMBER)`

- [ ] View: insurance analytics (count of reservations for each and total revenue from each)
`select * from view_insurance_res_rev;`


- [ ] View: Insurance analytics (top performing insurance type by vehicle type)
`select * from view_insurance_top_performer;`

### App analyst
- [ ] View: no of rentals and revenue by vendor
- [ ] View: revenue by demographic (10 years age range)
- [ ] View: No of rentals and revenue by vehicle type
- [ ] View: revenue by user’s location (10 years age range)
- [ ] View: no of rentals by discount_type
- [ ] View: total booking last week

### Customer
- [ ] View: all available cars in said location (note: reduce location data)
- [ ] Procedure: Initiate a booking / Update a booking
- [ ] Procedure: Cancel a booking (should happen only if reservation isn't active yet)
- [ ] Procedure: Add a payment method / Update a payment method
- [ ] Procedure: View payment methods
- [ ] Procedure: delete payment methods
- [ ] Procedure: initiate payment transactions
- [ ] Procedure: Update profile
- [ ] View: rental history

### Vendor (saurabh)
- [ ] Add/update a new car
- [ ] View rental history (niv)
- [ ] View all cars
- [ ] View customers who has rented his cars 
