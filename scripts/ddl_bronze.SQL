/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Purpose:
    Creates the raw (bronze layer) tables for the CRM and ERP source systems.
    If a table already exists, it is dropped and recreated.

Notes:
    - Bronze tables hold data exactly as it arrives from the source systems,
      so column types are kept loose (e.g. dates stored as INT where the
      source sends YYYYMMDD values).
    - Run this script whenever the bronze layer structure needs to change.

WARNING:
    Re-running this script DROPS the existing bronze tables and all data in
    them. Reload the data afterwards.
===============================================================================
*/

-- Create the bronze schema if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

/* ---------------------------------------------------------------------------
   CRM tables
--------------------------------------------------------------------------- */

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_first_name     NVARCHAR(50),
    cst_last_name      NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE
);
GO

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id         INT,
    prd_key        NVARCHAR(50),
    prd_nm         NVARCHAR(50),
    prd_cost       INT,
    prd_line       NVARCHAR(50),
    prd_start_date DATETIME,
    prd_end_date   DATETIME
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_id INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

/* ---------------------------------------------------------------------------
   ERP tables
--------------------------------------------------------------------------- */

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid   NVARCHAR(50),
    entry NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid   NVARCHAR(50),
    bdate DATE,
    gen   NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          NVARCHAR(50),
    cat         NVARCHAR(50),
    subcat      NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
