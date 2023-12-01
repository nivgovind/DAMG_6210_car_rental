
-- Add data
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
exec add_vehicle_type('mercedes', 'cla', 'automatic', 'sedan', 'petrol');
exec add_vehicle_type('ford', 'city', 'automatic', 'sedan', 'petrol');
exec add_vehicle_type('honda', 'civic', 'automatic', 'sedan', 'petrol');
exec add_vehicle_type('honda', 'verna', 'automatic', 'sedan', 'gasoline');
exec add_vehicle_type('chevrolet', 'cruze', 'automatic', 'sedan', 'petrol');
exec add_vehicle_type('mercedes', 'sla', 'automatic', 'sedan', 'gasoline');
exec add_vehicle_type('nissan', 'center', 'automatic', 'sedan', 'gasoline');
exec add_vehicle_type('toyota', 'altis', 'automatic', 'sedan', 'gasoline');
exec add_vehicle_type('ford', 'mondeo', 'automatic', 'sedan', 'gasoline');
-- SUV
exec add_vehicle_type('jeep', 'cherokee', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('honda', 'cr-v', 'cvt', 'suv', 'petrol');
exec add_vehicle_type('toyota', 'highlander', 'automatic', 'suv', 'hybrid');
exec add_vehicle_type('subaru', 'outback', 'automatic', 'suv', 'gasoline');
exec add_vehicle_type('ford', 'explorer', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('mercedes', 'wrangler', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('jeep', 'compass', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('mercedes', 'gl500', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('mercedes', 'gwagon', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('audi', 'q3', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('volvo', 'xc40', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('volvo', 'xc60', 'automatic', 'suv', 'petrol');
exec add_vehicle_type('volvo', 'xc90', 'automatic', 'suv', 'hybrid');
exec add_vehicle_type('audi', 'q5', 'automatic', 'suv', 'petrol');
-- Truck
exec add_vehicle_type('chevrolet', 'silverado', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('ford', 'f-250', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('ram', '1500', 'automatic', 'truck', 'diesel');
exec add_vehicle_type('toyota', 'tundra', 'automatic', 'truck', 'gasoline');
exec add_vehicle_type('nissan', 'titan', 'automatic', 'truck', 'petrol');
exec add_vehicle_type('hummer', 'h1', 'automatic', 'truck', 'petrol');
exec add_vehicle_type('hummer', 'h2', 'automatic', 'truck', 'petrol');
exec add_vehicle_type('hummer', 'h3', 'automatic', 'truck', 'petrol');
exec add_vehicle_type('force', 'ties', 'automatic', 'truck', 'petrol');
-- Hatchback
exec add_vehicle_type('volkswagen', 'golf', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('ford', 'fiesta', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('honda', 'fit', 'cvt', 'hatchback', 'petrol');
exec add_vehicle_type('toyota', 'yaris', 'manual', 'hatchback', 'petrol');
exec add_vehicle_type('mazda', 'mazda3', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('chevrolet', 'bolt', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('volkswagen', 'polo', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('mazda', 'cx30', 'automatic', 'hatchback', 'gasoline');
exec add_vehicle_type('ford', 'bell', 'automatic', 'hatchback', 'gasoline');


-- Convertible
exec add_vehicle_type('ford', 'mustang', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('chevrolet', 'camaro', 'manual', 'convertible', 'petrol');
exec add_vehicle_type('bmw', '4 series', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mazda', 'mx-5 miata', 'manual', 'convertible', 'gasoline');
exec add_vehicle_type('audi', 'a3 cabriolet', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mercedes', 'slk 350', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('volkswagen', 'beetle', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('bmw', 'm4', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('mercedes', 'sl550', 'automatic', 'convertible', 'petrol');
exec add_vehicle_type('bmw', '328I', 'automatic', 'convertible', 'petrol');

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
EXEC add_insurance_type('cruise protection', 6000);

-- Add users
EXEC add_user('customer', 'Abigail', 'Gring', 'New York', 'DL12345678901234', 25, NULL, NULL);
EXEC add_user('vendor', 'Bob', 'Cat', 'Los Angeles', NULL, NULL, 'BobCat rentals', 'TaxID1234567890123');
EXEC add_user('customer', 'Cat', 'Stevens', 'Boston', 'DL98765432109876', 30, NULL, NULL);
EXEC add_user('vendor', 'Dina', 'Jones', 'Minneapolis', NULL, NULL, 'New Old rentals', 'TaxID8765432109876');
EXEC add_user('vendor', 'Lewis', 'Alonso', 'Minneapolis', NULL, NULL, 'Merc rentals', 'TaxID8765432109875');
EXEC add_user('customer', 'Ocon', 'Riccardo', 'Boston', 'DL98765432109877', 30, NULL, NULL);
EXEC add_user('customer', 'Nico', 'Bottas', 'Chicago', 'DL98765432109888', 35, NULL, NULL);
EXEC add_user('customer', 'James', 'Hunt', 'Seattle', 'DL98765432109866', 27, NULL, NULL);
EXEC add_user('customer', 'Adam', 'Jameson', 'Boston', 'DL98765432109855', 40, NULL, NULL);
EXEC add_user('customer', 'Jos', 'Broad', 'Boston', 'DL98765432109844', 50, NULL, NULL);
EXEC add_user('vendor', 'Rick', 'Johnson', 'Chicago', NULL, NULL, 'Haas rentals', 'TaxID8765432109874');
EXEC add_user('vendor', 'Mick', 'Bottas', 'Seattle', NULL, NULL, 'Alpine rentals', 'TaxID8765432109873');
EXEC add_user('vendor', 'Fernando', 'Hulkenberg', 'Seattle', NULL, NULL, 'Force rentals', 'TaxID8765432109873');


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
EXEC add_reservation('completed',300.00,'2023-01-01','2023-01-10','SF004','New York','Boston', 2,'NYE345MID0456OOP','Cat','safety first');
EXEC add_reservation('active',350.00,'2023-12-01','2023-12-12','CF001','New York','Boston', 6,'NYE678MID4056OOP','Cat','care first');
EXEC add_reservation('cancelled',110.00,'2024-11-01','2023-11-10','SF034','New York','Boston', 2,'ARK678NEW7908OOP','Abigail','safety first');
EXEC add_reservation('active',200.00,'2023-05-11','2023-05-14','TS012','New York','Boston', 4,'NYE345MID0456OOP','Abigail','travel shield');
EXEC add_reservation('completed',300.00,'2023-03-20','2023-04-10','SF004','New York','Boston', 2,'NYE345MID0456OOP','Cat','safety first');
EXEC add_reservation('active',350.00,'2023-12-01','2023-12-12','CF001','New York','Boston', 6,'NYE678MID4056OOP','Cat','care first');

-- Add Payment transactions
EXEC add_payment_transaction('completed', 100.00, 'VAR300com', 1, '1234876539081234', 'WONDER10');
EXEC add_payment_transaction('completed', 200.00, 'WERE200', 2, '1234876539081234', 'NEW2024');
EXEC add_payment_transaction('completed', 300.00, 'COMP20', 3, '1234876539081234', 'FIRST');
EXEC add_payment_transaction('completed', 350.00, 'COP20we', 4, '1234876539081234', 'NO_DISC');

