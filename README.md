# DAMG 6210 Final project

## Team details
Team Name: DB wizards
Members: 
- Nivedhithaa Govindaraj (govindaraj.n@northeastern.edu)
- Saurabh Srivastava (srivastava.sau@northeastern.edu)

## Order of execution
1. run `1_SysAdmin.sql`
2. run `2_CrAppAdminDdl.sql`
3. run `3_CrAppAdminGrantScript.sql`

## Table of contents

### 1_SysAdmin.sql
- Script for creating application admin and granting them permissions.

### 2_CrAppAdminDdl.sql
- Table creation script as application admin
- Procedure definitions for inserting data.

### 1_SysAdmin.sql
- Script for creating app users (customers, vendors, insurance_agent, analyst) and granting them relevant permissions.

## Changes from Week 2
- Introduced 2 new roles insurance agent and analyst

### Insurance agent
- will manage insurance details in the schema
- Has read permission for relevant tables
- Has permission to update, create and delete available insurance types

### Analyst
- Will aggregate data and report on the performance of the rental business
- Has relevant read permissions on tables except for sensitive data such as payment transactions.
