-- Start all files with exception handling
-- Users and roles
-- Not use the default admin

SET SERVEROUTPUT ON;

begin
    execute immediate 'drop user customer cascade';
    execute immediate 'drop user vendor cascade';
    execute immediate 'drop user insurance_agent cascade';
    execute immediate 'drop user system_analyst cascade';
exception
    when others then
        if sqlcode!=-1918 then
            raise;
        end if;    
end;
/

-- Customer
create user customer identified by "BlightPass#111";
grant create session to customer;
grant select on locations to customer;
grant select on vehicle_types to customer;
grant select on discount_types to customer;
grant select on insurance_types to customer;
grant select on users to customer;
grant select, insert, update, delete on payment_methods to customer;
grant select, insert, update, delete on reservations to customer;
grant insert on payment_transactions to customer;

-- Vendor
create user vendor identified by "BlightPass#111";
grant create session to vendor;
grant select on locations to vendor;
grant select on vehicle_types to vendor;
grant select on discount_types to vendor;
grant select on insurance_types to vendor;
grant select on users to vendor;
grant select, insert, update, delete on vehicles to customer;
grant select on reservations to vendor;


-- Insurance Agent
create user insurance_agent identified by "BlightPass#111";
grant create session to insurance_agent;
grant select on locations to insurance_agent;
grant select on vehicle_types to insurance_agent;
grant select, insert, update, delete on insurance_types to insurance_agent;


-- Analyst
create user system_analyst identified by "BlightPass#111";
grant create session to system_analyst;
grant select on locations to system_analyst;
grant select on vehicle_types to system_analyst;
grant select, insert, update on discount_types to system_analyst;
grant select on insurance_types to system_analyst;
grant select on users to system_analyst;
grant select on vehicles to system_analyst;
grant select on reservations to system_analyst;
