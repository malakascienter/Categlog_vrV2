CREATE PROCEDURE [dbo].[SupplierExpense_M_Save]
    @Id INT,
    @SupplierId INT,
    @SupplierName NVARCHAR(255) = NULL,
    @TxnDate DATE,
    @Amount DECIMAL(18,2),
    @Remark NVARCHAR(MAX),
    @UserId INT,
    @PropertyId INT,
    @Operation VARCHAR(10),
    @InvoiceNo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- This ensures that if any error occurs, the transaction is rolled back automatically
    
    DECLARE @NewId INT;
    DECLARE @ErrorCode INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate required parameters
        IF @SupplierId IS NULL OR @TxnDate IS NULL OR @Amount IS NULL
        BEGIN
            SET @ErrorCode = 50003;
            SET @ErrorMessage = 'SupplierId, TxnDate, and Amount are required fields.';
            RAISERROR(@ErrorMessage, 16, 1);
        END
        
        -- Validate Amount is positive
        IF @Amount <= 0
        BEGIN
            SET @ErrorCode = 50004;
            SET @ErrorMessage = 'Amount must be greater than zero.';
            RAISERROR(@ErrorMessage, 16, 1);
        END
        
        IF @Operation = 'I'
        BEGIN
            INSERT INTO SupplierExpense (
                SupplierId,
                SupplierName,
                PropertyId,
                TxnDate,
                Amount,
                Remark,
                CreatedUserId,
                CreatedDateTime,
				InvoiceNo
            )
            VALUES (
                @SupplierId,
                ISNULL(@SupplierName, ''),
                @PropertyId,
                @TxnDate,
                @Amount,
                ISNULL(@Remark, ''),
                @UserId,
                GETDATE(),
				@InvoiceNo
            );
            
            SET @NewId = SCOPE_IDENTITY();
            
            COMMIT TRANSACTION;
            
            -- Return success with new ID
            SELECT 
                @NewId AS NewId,
                1 AS Success,
                '' AS ErrorMessage;
        END
        ELSE IF @Operation = 'U'
        BEGIN
            -- Check if record exists before update
            IF NOT EXISTS (SELECT 1 FROM SupplierExpense WHERE Id = @Id AND PropertyId = @PropertyId)
            BEGIN
                SET @ErrorCode = 50001;
                SET @ErrorMessage = 'Record not found for update.';
                RAISERROR(@ErrorMessage, 16, 1);
            END
            
            UPDATE SupplierExpense 
            SET 
                SupplierId = @SupplierId,
                SupplierName = ISNULL(@SupplierName, SupplierName),
                TxnDate = @TxnDate,
                Amount = @Amount,
                Remark = ISNULL(@Remark, Remark),
                EditedUserId = @UserId,
                EditedDateTime = GETDATE(),
				InvoiceNo = @InvoiceNo
            WHERE Id = @Id AND PropertyId = @PropertyId;
            
            SET @NewId = @Id;
            
            COMMIT TRANSACTION;
            
            -- Return success
            SELECT 
                @NewId AS NewId,
                1 AS Success,
                '' AS ErrorMessage;
        END
        ELSE
        BEGIN
            SET @ErrorCode = 50002;
            SET @ErrorMessage = 'Invalid operation specified. Use ''INSERT'' or ''UPDATE''.';
            RAISERROR(@ErrorMessage, 16, 1);
        END
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction if error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Get error information
        SET @ErrorCode = ISNULL(ERROR_NUMBER(), 50000);
        SET @ErrorMessage = ERROR_MESSAGE();
        
        -- Return error information
        SELECT 
            -1 AS NewId,
            0 AS Success,
            @ErrorMessage AS ErrorMessage,
            @ErrorCode AS ErrorCode;
    END CATCH
END

GO

