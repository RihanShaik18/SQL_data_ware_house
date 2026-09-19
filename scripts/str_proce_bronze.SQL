/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Purpose:
    Loads raw data from the source CSV files (CRM and ERP) into the bronze
    tables. For each table it:
        1. Truncates the table
        2. Bulk inserts the data from the CSV file
        3. Prints how long the load took

Parameters:
    @dataset_path - Folder that contains the 'source_crm' and 'source_erp'
                    subfolders, e.g. C:\projects\sql-data-warehouse-project\datasets
                    NOTE: BULK INSERT reads files from the machine SQL Server
                    runs on, so the path must be reachable from that machine.

Usage:
    EXEC bronze.load_bronze @dataset_path = 'C:\path\to\datasets';

Prerequisite:
    Run ddl_bronze.sql first so the bronze schema and tables exist.

WARNING:
    Every run TRUNCATES the bronze tables before loading.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
    @dataset_path NVARCHAR(500)
AS
BEGIN
    DECLARE @start_time       DATETIME,
            @end_time         DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time   DATETIME,
            @sql              NVARCHAR(MAX);

    BEGIN TRY
        IF @dataset_path IS NULL OR LTRIM(RTRIM(@dataset_path)) = ''
            THROW 50001, '@dataset_path is required.', 1;

        -- Make sure the path ends with a backslash and is safe to embed in a string literal
        IF RIGHT(@dataset_path, 1) <> '\'
            SET @dataset_path = @dataset_path + '\';
        SET @dataset_path = REPLACE(@dataset_path, '''', '''''');

        SET @batch_start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer';
        PRINT '==========================================';

        ------------------------------------------------------------------------
        -- CRM tables
        ------------------------------------------------------------------------
        PRINT '------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------';

        -- crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        SET @sql = N'BULK INSERT bronze.crm_cust_info
                     FROM ''' + @dataset_path + N'source_crm\cust_info.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        -- crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        SET @sql = N'BULK INSERT bronze.crm_prd_info
                     FROM ''' + @dataset_path + N'source_crm\prd_info.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        -- crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        SET @sql = N'BULK INSERT bronze.crm_sales_details
                     FROM ''' + @dataset_path + N'source_crm\sales_details.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        ------------------------------------------------------------------------
        -- ERP tables
        ------------------------------------------------------------------------
        PRINT '------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------';

        -- erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        SET @sql = N'BULK INSERT bronze.erp_loc_a101
                     FROM ''' + @dataset_path + N'source_erp\loc_a101.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        -- erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        SET @sql = N'BULK INSERT bronze.erp_cust_az12
                     FROM ''' + @dataset_path + N'source_erp\cust_az12.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        -- erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        SET @sql = N'BULK INSERT bronze.erp_px_cat_g1v2
                     FROM ''' + @dataset_path + N'source_erp\px_cat_g1v2.csv''
                     WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sp_executesql @sql;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '>> ----------------';

        ------------------------------------------------------------------------
        -- Summary
        ------------------------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Line   : ' + CAST(ERROR_LINE()   AS NVARCHAR(20));
        PRINT 'Error State  : ' + CAST(ERROR_STATE()  AS NVARCHAR(20));
        PRINT '==========================================';
    END CATCH
END;
GO
