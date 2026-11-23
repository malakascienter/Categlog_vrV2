-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-19
-- Modified by		: Nivesh
-- Modified date	: 2025-12-19
-- Description:	Completion Common Transaction
-- =============================================
CREATE     PROCEDURE [dbo].[SPO_SP_CancelationCommonTransaction] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	BEGIN TRY 
        ---------------------------------------------
        -- 1. Parse JSON input
        ---------------------------------------------
        DECLARE 
            @UserID INT,
            @PropertyID INT,
            @TransactionTypeID INT,
            @TransactionID INT,
            @Action CHAR(1),
            @HeaderID INT,
            @LocationID  VARCHAR(5),
            @Remarks NVARCHAR(MAX),
            @DocumentChargesPercentage DECIMAL(18,2),
            @RefundAmount DECIMAL(18,2)

        -- Extract top-level fields
        SELECT
            @TransactionTypeID = JSON_VALUE(@JsonDetail, '$.TransactionTypeID'),
            @Action            = JSON_VALUE(@JsonDetail, '$.action');
        
        SELECT @TransactionID = TransactionID 
        FROM
        SPO_CommonTransactionColumnConfiguration
        WHERE Id = @TransactionTypeID
        ---------------------------------------------
        -- 2. Parse spParam object
        ---------------------------------------------
        DECLARE @spParam NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.spParam');

        SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID'),
            @Remarks    = JSON_VALUE(@spParam, '$.Remarks'),
            @LocationID = JSON_VALUE(@spParam, '$.LocationID'),
            @DocumentChargesPercentage = JSON_VALUE(@spParam, '$.DocumentChargesPercentage'),
            @RefundAmount = JSON_VALUE(@spParam, '$.RefundAmount');

        ---------------------------------------------
        -- 3. Parse headerData object
        ---------------------------------------------
        DECLARE @headerData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.headerData');

        SELECT 
            @HeaderID = JSON_VALUE(@headerData, '$.OrderId');

        ---------------------------------------------
        -- 4. DetailData (optional)
        ---------------------------------------------
         DECLARE @detailData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.detailData');
        SET @detailData = REPLACE(REPLACE(@detailData, '\\"', '"'), '\\\\', '\');
        SET @detailData = JSON_QUERY(@detailData);
         
        IF (@TransactionTypeID = 3)
        BEGIN
            DECLARE @OrderCancelApprovalJson NVARCHAR(MAX);
            IF @LocationID IS NULL OR @LocationID = ''
            BEGIN
                SELECT @LocationID = DeliveryOutlet 
                FROM [dbo].[SPO_OrderHeader]
                WHERE OrderId = @HeaderID;
            END

            SET @OrderCancelApprovalJson =
            (
                SELECT
                    JSON_QUERY((
                        SELECT
                            @UserID     AS UserID,
                            @PropertyID AS PropertyID,
                            @LocationID AS LocationID,   
                            @Remarks    AS Remarks
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                    )) AS spParam,
                    5                AS TransactionTypeID,   
                    @HeaderID        AS TransactionHeadereID
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            EXEC dbo.SPO_SP_InsertTransactionApprovalLog @OrderCancelApprovalJson;

            -- Mark order as cancel requested
            UPDATE [dbo].[SPO_OrderHeader]
            SET IsOrderCancel     = 0,
                OrderCancelStatus = 'P',
                DocumentChargesPercentage = @DocumentChargesPercentage,
                RefundAmount = @RefundAmount
            WHERE OrderId = @HeaderID;
        END

         IF(@TransactionTypeID = 4) -- Order Cancelation
            BEGIN
                DECLARE @HeaderIsDiscount BIT
                SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId')
            
                --Insert Old Data--
                UPDATE TA
                SET TA.OldData = (
                    SELECT (
                    SELECT * FROM
                    [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS HeaderData,
                     (
                    SELECT * FROM
                    [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS DetailData
                    FOR JSON PATH
                )
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND TA.UserProfileID= @UserID
                -------------------
            
                UPDATE TA
                SET TA.IsApproved =1,
                    TA.LastModifiedUserID = @UserID,
                    TA.LastModifiedDate = GETDATE()
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND TA.UserProfileID= @UserID

                UPDATE [dbo].[SPO_OrderHeader]
                SET IsOrderCancel =0,
                OrderCancelStatus = 'P'
                WHERE OrderId = @HeaderID

                IF NOT EXISTS(SELECT 1 FROM  [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID AND TA.IsApproved =0)
                BEGIN
                    UPDATE TA
                    SET TA.TransactionStatus = 'C'
                    FROM
                    [dbo].[SPO_TransactionApprovalLog] TA
                    WHERE TA.TransactionTypeID = @TransactionID
                    AND TA.TransactionHeaderID = @HeaderID

                    UPDATE [dbo].[SPO_OrderHeader]
                    SET IsOrderCancel =1,
                    OrderCancelStatus = 'P'
                    WHERE OrderId = @HeaderID
                END

                --Insert New Data--
                UPDATE TA
                SET TA.NewData = (
                    SELECT (
                    SELECT * FROM
                    [dbo].[SPO_OrderHeader] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS HeaderData,
                     (
                    SELECT * FROM
                    [dbo].[SPO_OrderDetails] WHERE OrderId = @HeaderID
                    FOR JSON PATH
                    ) AS DetailData
                    FOR JSON PATH
                )
                FROM
                [dbo].[SPO_TransactionApprovalLog] TA
                WHERE TA.TransactionTypeID = @TransactionID
                AND TA.TransactionHeaderID = @HeaderID
                AND TA.UserProfileID= @UserID
                -------------------
            END

	BEGIN TRAN
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

