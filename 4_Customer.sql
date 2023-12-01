-- View: all available cars in said location (note: reduce location data)
SELECT * FROM view_all_available_cars;

-- - [ ] Procedure: Initiate a booking / Update a booking
-- - [ ] Procedure: Cancel a booking (should happen only if reservation isn't active yet)
EXEC cancel_reservation(1);
-- - [ ] Procedure: Add a payment method / Update a payment method
-- - [ ] Procedure: View payment methods
-- - [ ] Procedure: delete payment methods
-- - [ ] Procedure: initiate payment transactions
EXEC initiate_payment_transaction(4, '7432738484381812', 'WONDER10');
EXEC approve_transaction(4);
-- - [ ] Procedure: Update profile
-- - [ ] View: rental history
EXEC get_user_reservations_history(1);
EXEC get_user_reservations_history(3);

