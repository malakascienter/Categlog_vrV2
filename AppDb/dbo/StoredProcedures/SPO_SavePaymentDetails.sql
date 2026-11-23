-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-04
-- Description: Save payment details
-- =============================================

CREATE PROCEDURE [dbo].[SPO_SavePaymentDetails] 
(
     @json NVARCHAR(MAX)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
        BEGIN TRANSACTION;

        --------------------------------------------------
        -- TEMP TABLE
        --------------------------------------------------

        DECLARE @TempData TABLE (
            RowNo           INT IDENTITY(1,1),
            OrderId         INT,
            PayCode         NVARCHAR(100),
            PaymentAmount   DECIMAL(18,2),
            OutletCode      NVARCHAR(100),
            PaymentType     NVARCHAR(2)
        );

        INSERT INTO @TempData (OrderId, PayCode, PaymentAmount, OutletCode, PaymentType)
        SELECT
            CAST(JSON_VALUE(@json, '$.OrderId')       AS INT),
            p.PayCode,
            CAST(p.PaymentAmount AS DECIMAL(18, 2)),
            JSON_VALUE(@json, '$.OutletCode'),
            JSON_VALUE(@json, '$.PaymentType')
        FROM OPENJSON(@json, '$.Payments')
        WITH (
            PayCode         NVARCHAR(100)   '$.PayCode',
            PaymentAmount   DECIMAL(18, 2)  '$.PaymentAmount'
        ) AS p;

        IF NOT EXISTS (SELECT 1 FROM @TempData)
        BEGIN
            RAISERROR('No payment records found in JSON.',16,1)
            RETURN
        END
		

        --------------------------------------------------
        -- VARIABLES
        --------------------------------------------------

        DECLARE @NewPaymentAmount DECIMAL(18,2)
        DECLARE @PaidAmount DECIMAL(18,2)
        DECLARE @BalanceAmount DECIMAL(18,2)
        DECLARE @PaymentType NVARCHAR(2)
        DECLARE @OrderId INT
        DECLARE @TotalAmount DECIMAL(18,2)
        DECLARE @TransactionType NVARCHAR(5) = 'RA'
        DECLARE @PropertyID INT = CAST(JSON_VALUE(@json, '$.PropertyID') AS INT)
        DECLARE @Recipet VARCHAR(50)
        DECLARE @DocNo VARCHAR(MAX)
        DECLARE @OutletCode NVARCHAR(100) 

        SELECT TOP 1 
            @OrderId = OrderId,
            @PaymentType = PaymentType,
            @OutletCode = OutletCode
        FROM @TempData


        SELECT @NewPaymentAmount = ISNULL(SUM(PaymentAmount),0)
        FROM @TempData
        WHERE OrderId = @OrderId


        SET @PaidAmount = dbo.fn_SPO_GetPaidAmount(@OrderId)
        SET @BalanceAmount = dbo.fn_SPO_GetBalanceAmount(@OrderId)

        SELECT @TotalAmount = NetAmount 
        FROM SPO_OrderHeader 
        WHERE OrderId = @OrderId

        -- Generate Recipet
        SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @OutletCode, @TransactionType)
        IF @DocNo IS NULL
        BEGIN
            EXEC SPO_InsertDocumentNumber @PropertyID, @OutletCode, @TransactionType
            SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @OutletCode, @TransactionType)
        END
        SET @Recipet = CONCAT(TRIM(@TransactionType), @DocNo)
        EXEC [dbo].[SPO_UpdateDocumentNumber] @PropertyID, @OutletCode, @TransactionType


        --------------------------------------------------
        -- PAYMENT TYPE A VALIDATION
        --------------------------------------------------

        IF @PaymentType = 'A'
        BEGIN
            IF @NewPaymentAmount = 0
            BEGIN
                RAISERROR('Payment amount cannot be 0. Please enter a valid amount.',16,1);
                RETURN;
            END

            IF (@NewPaymentAmount + @PaidAmount) > @TotalAmount
            BEGIN
                RAISERROR('Total payment amount exceeds the Order Total Amount.',16,1);
                RETURN;
            END
        END


        --------------------------------------------------
        -- PAYMENT TYPE S VALIDATION
        --------------------------------------------------

        IF @PaymentType = 'S'
        BEGIN

            IF @BalanceAmount > @NewPaymentAmount
            BEGIN
                RAISERROR('Payment amount not enough to Dispatch.',16,1);
                RETURN;
            END

            IF @BalanceAmount < @NewPaymentAmount
            BEGIN
                RAISERROR('Total payment amount exceeds the Order Total Amount.',16,1);
                RETURN;
            END


            --------------------------------------------------
            -- WHEN BALANCE MATCHES
            --------------------------------------------------

            IF @BalanceAmount = @NewPaymentAmount
            BEGIN

                IF @NewPaymentAmount > 0
                BEGIN

                    --------------------------------------------------
                    -- ***** CHANGE : RUNNING PAYMENT LOOP *****
                    --------------------------------------------------

                    DECLARE @PayCode NVARCHAR(100)
                    DECLARE @PaymentAmount DECIMAL(18,2)
                    DECLARE @PrevPaid DECIMAL(18,2)
                    DECLARE @NewBalance DECIMAL(18,2)
                    

                    SET @PrevPaid = @PaidAmount

                    DECLARE payment_cursor CURSOR FOR
                    SELECT PayCode, PaymentAmount
                    FROM @TempData
                    ORDER BY RowNo

                    OPEN payment_cursor

                    FETCH NEXT FROM payment_cursor INTO @PayCode, @PaymentAmount

                    WHILE @@FETCH_STATUS = 0
                    BEGIN

                        SET @NewBalance = @TotalAmount - (@PrevPaid + @PaymentAmount)

                        -- Generate Recipet
                        SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @OutletCode, @TransactionType)
                        IF @DocNo IS NULL
                        BEGIN
                            EXEC SPO_InsertDocumentNumber @PropertyID, @OutletCode, @TransactionType
                            SELECT @DocNo = [dbo].[FN_SPO_GetNextDocumentNumber](@PropertyID, @OutletCode, @TransactionType)
                        END
                        SET @Recipet = CONCAT(TRIM(@TransactionType), @DocNo)
                        EXEC [dbo].[SPO_UpdateDocumentNumber] @PropertyID, @OutletCode, @TransactionType

                        INSERT INTO SPO_OrderWisePayment
                        (
                            OrderId,
                            PayCode,
                            PaymentAmount,
                            PaymentDate,
                            OutletCode,
                            PaymentType,
                            PreviousAmount,
                            BalanceAmount,
                            Recipet,
                            PropertyId
                        )
                        VALUES
                        (
                            @OrderId,
                            @PayCode,
                            @PaymentAmount,
                            GETDATE(),
                            @OutletCode,
                            @PaymentType,
                            @PrevPaid,
                            @NewBalance,
                            @Recipet,
                            @PropertyID
                        )

                        SET @PrevPaid = @PrevPaid + @PaymentAmount

                        FETCH NEXT FROM payment_cursor INTO @PayCode, @PaymentAmount

                    END

                    CLOSE payment_cursor
                    DEALLOCATE payment_cursor


                    --------------------------------------------------
                    -- DISPATCH ORDER
                    --------------------------------------------------

                    UPDATE SPO_OrderHeader
                    SET Status = 'D'
                    WHERE OrderId = @OrderId

                END


                --------------------------------------------------
                -- ZERO PAYMENT CASE
                --------------------------------------------------

                IF @NewPaymentAmount = 0
                BEGIN
                    UPDATE SPO_OrderHeader
                    SET Status = 'D'
                    WHERE OrderId = @OrderId
                END

            END

            SELECT @Recipet AS InvoiceNumber; 
            COMMIT TRANSACTION;
            RETURN;

        END


        --------------------------------------------------
        -- ***** CHANGE : NORMAL PAYMENT LOOP *****
        --------------------------------------------------

        DECLARE @PayCode2 NVARCHAR(100)
        DECLARE @PaymentAmount2 DECIMAL(18,2)
        DECLARE @PrevPaid2 DECIMAL(18,2)
        DECLARE @NewBalance2 DECIMAL(18,2)


        SET @PrevPaid2 = @PaidAmount

        DECLARE payment_cursor2 CURSOR FOR
        SELECT PayCode, PaymentAmount
        FROM @TempData
        ORDER BY RowNo

        OPEN payment_cursor2

        FETCH NEXT FROM payment_cursor2 INTO @PayCode2, @PaymentAmount2

        WHILE @@FETCH_STATUS = 0
        BEGIN

            SET @NewBalance2 = @TotalAmount - (@PrevPaid2 + @PaymentAmount2)


            INSERT INTO SPO_OrderWisePayment
            (
                OrderId,
                PayCode,
                PaymentAmount,
                PaymentDate,
                OutletCode,
                PaymentType,
                PreviousAmount,
                BalanceAmount,
                Recipet,
                PropertyId
            )
            VALUES
            (
                @OrderId,
                @PayCode2,
                @PaymentAmount2,
                GETDATE(),
                @OutletCode,
                @PaymentType,
                @PrevPaid2,
                @NewBalance2,
                @Recipet,
                @PropertyID
            )

            SET @PrevPaid2 = @PrevPaid2 + @PaymentAmount2

            FETCH NEXT FROM payment_cursor2 INTO @PayCode2, @PaymentAmount2

        END

        CLOSE payment_cursor2
        DEALLOCATE payment_cursor2

        SELECT @Recipet AS InvoiceNumber; 
        COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

	END CATCH

END

GO

