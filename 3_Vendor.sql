
-- Add a car to the database
EXEC add_vehicle(30.00, 5000, 'true', 5, 'MIN123NE0W456OOP', 'New York', 'Bob', 'silverado')

-- Update the rate of a car
EXEC update_car_availability('BOS123NE0W456OOP', 'false');
