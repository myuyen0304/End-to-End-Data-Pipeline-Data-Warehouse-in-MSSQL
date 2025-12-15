/**************************************************************
==============================================================
Create Database and Schemas Script
==============================================================
Script Purpose:
This script checks for the existence of the database 'DataWarehouse'.
If it exists, the database is dropped and then recreated.
Finally, it creates three schemas: 'bronze', 'silver', and 'gold'
within the new 'DataWarehouse' database.

WARNING:
Running this script will permanently delete all data in the
'DataWarehouse' database if it already exists. Proceed with caution.
**************************************************************/


USE master;
GO

-- Check for existence and Drop Database (MS SQL Server Syntax)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
	
END

-- Create the new Database
CREATE DATABASE DataWarehouse;

-- Switch context to the newly created Database
USE DataWarehouse;

-- Create the Schemas

-- 1. Schema 'bronze' (Typically for raw, uncleaned data)
CREATE SCHEMA bronze;
GO

-- 2. Schema 'silver' (Typically for cleaned, standardized, and validated data)
CREATE SCHEMA silver;
GO

-- 3. Schema 'gold' (Typically for aggregated, report-ready data)
CREATE SCHEMA gold;
GO
