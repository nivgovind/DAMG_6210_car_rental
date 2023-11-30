-- View: all available cars in said location (note: reduce location data)
select * from vehicles where id not in ( select id from reservations where status = 'active' );

-- - [ ] Procedure: Initiate a booking / Update a booking
-- - [ ] Procedure: Cancel a booking (should happen only if reservation isn't active yet)
-- - [ ] Procedure: Add a payment method / Update a payment method
-- - [ ] Procedure: View payment methods
-- - [ ] Procedure: delete payment methods
-- - [ ] Procedure: initiate payment transactions
-- - [ ] Procedure: Update profile
-- - [ ] View: rental history