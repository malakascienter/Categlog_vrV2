

-- =============================================
-- Author:      Dilshan
-- Create date: 2025-10-16
-- Description: Insert or Update Customer record via JSON input
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_spInsertOrUpdateCustomer]
    @CustomerJson VARCHAR(MAX),
	@Oparation VARCHAR(1)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        SET NOCOUNT ON;

        -- Temp table for JSON data
        CREATE TABLE #Customer
        (
            ID BIGINT,
            CustomerTypeID BIGINT,
            CustomerName VARCHAR(250),
            FullName VARCHAR(MAX),
            DateOfBirth DATE,
            MobileNumber VARCHAR(50),
            Email VARCHAR(MAX),
            IsEbillRequest BIT,
            [Address] VARCHAR(MAX),
            CreditLimit NUMERIC(22,4),
            CreditPeriod INT,
            EmployeeCode VARCHAR(50),
            IsActive BIT,
			PropertyId INT,
            UserId INT
        );

        -- Parse JSON input
        INSERT INTO #Customer
        (
            ID,
            CustomerTypeID,
            CustomerName,
            FullName,
            DateOfBirth,
            MobileNumber,
            Email,
            IsEbillRequest,
            [Address],
            CreditLimit,
            CreditPeriod,
            EmployeeCode,
            IsActive,
			PropertyId,
            UserId
        )
        SELECT 
            ID,
            CustomerTypeID,
            CustomerName,
            FullName,
            DateOfBirth,
            MobileNumber,
            Email,
            IsEbillRequest,
            [Address],
            CreditLimit,
            CreditPeriod,
            EmployeeCode,
            IsActive,
			PropertyId,
            UserId
        FROM OPENJSON(@CustomerJson)
        WITH (
            ID BIGINT '$.ID',
            CustomerTypeID BIGINT '$.CustomerTypeID',
            CustomerName VARCHAR(250) '$.CustomerName',
            FullName VARCHAR(MAX) '$.FullName',
            DateOfBirth DATE '$.DateOfBirth',
            MobileNumber VARCHAR(50) '$.MobileNumber',
            Email VARCHAR(MAX) '$.Email',
            IsEbillRequest BIT '$.IsEbillRequest',
            [Address] VARCHAR(MAX) '$.Address',
            CreditLimit NUMERIC(22,4) '$.CreditLimit',
            CreditPeriod INT '$.CreditPeriod',
            EmployeeCode VARCHAR(50) '$.EmployeeCode',
            IsActive BIT '$.IsActive',
		    PropertyId INT '$.PropertyId',
            UserId INT '$.UserId'
        );

        DECLARE @CustomerID BIGINT;
		DECLARE @CustomerTypeID VARCHAR(MAX);
        DECLARE @PropertyId  INT;
        DECLARE @UserId  INT;
        DECLARE @IsCustomerApprove BIT = 0;
        SELECT TOP 1 @CustomerID = ID,@CustomerTypeID = CustomerTypeID,@UserId = UserId,@PropertyId = PropertyId FROM #Customer;

        SELECT @IsCustomerApprove = IsCustomerApprove FROM SPO_CustomerType WHERE ID = @CustomerTypeID

		IF ( isnull(@CustomerTypeID,0) = 0)  
		BEGIN
			RAISERROR ('Please select customer type.!',16,1)   
		END


		
        -- If record exists -> Update
        IF (@Oparation = 'U')
        BEGIN
            UPDATE C
            SET 
                C.CustomerTypeID = T.CustomerTypeID,
                C.CustomerName = T.CustomerName,
                C.FullName = T.FullName,
                C.DateOfBirth = T.DateOfBirth,
                C.MobileNumber = T.MobileNumber,
                C.Email = T.Email,
                C.IsEbillRequest = T.IsEbillRequest,
                C.Address = T.Address,
                C.CreditLimit = T.CreditLimit,
                C.CreditPeriod = T.CreditPeriod,
                C.EmployeeCode = T.EmployeeCode,
                C.IsActive = T.IsActive,
                C.DocumentStatus    = CASE 
                                          WHEN  @IsCustomerApprove = 1 THEN 'P' 
                                          ELSE 'C' 
                                      END
            FROM #Customer T
            INNER JOIN SPO_Customer C ON C.ID = T.ID;
        END
        ELSE
        BEGIN
            -- Insert new record
            INSERT INTO [dbo].[SPO_Customer]
            (
                CustomerTypeID,
                CustomerName,
                FullName,
                DateOfBirth,
                MobileNumber,
                Email,
                IsEbillRequest,
                [Address],
                CreditLimit,
                CreditPeriod,
                EmployeeCode,
                IsActive,
				PropertyId,
                DocumentStatus
            )
            SELECT 
                CustomerTypeID,
                CustomerName,
                FullName,
                DateOfBirth,
                MobileNumber,
                Email,
                IsEbillRequest,
                [Address],
                CreditLimit,
                CreditPeriod,
                EmployeeCode,
                IsActive,
				PropertyId,
               CASE 
                    WHEN  @IsCustomerApprove = 1 THEN 'P' 
                    ELSE 'C' 
                END
            FROM #Customer;

            SET @CustomerID = SCOPE_IDENTITY();



            IF (@IsCustomerApprove = 1)
            BEGIN
                DECLARE @CustomerApprovalJson NVARCHAR(MAX);

                SET @CustomerApprovalJson =
                (
                    SELECT
                        JSON_QUERY((
                            SELECT
                                @UserId     AS UserID,
                                @PropertyId AS PropertyID
                            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                        )) AS spParam,
                        1 AS TransactionTypeID,
                        @CustomerID AS TransactionHeadereID
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                );

                EXEC dbo.SPO_SP_InsertTransactionApprovalLog @CustomerApprovalJson;
            END
     END

        DROP TABLE #Customer;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrMsg VARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH;
END;

GO

