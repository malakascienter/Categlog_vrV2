CREATE   PROCEDURE [dbo].[SPO_SP_RejectCommonTransaction] 
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
            @HeaderID INT;

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
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID');

        ---------------------------------------------
        -- 3. Parse headerData object
        ---------------------------------------------
        DECLARE @headerData NVARCHAR(MAX) = JSON_VALUE(@JsonDetail, '$.headerData');

        IF(@TransactionTypeID = 1) -- Customer Rejection
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.ID');
            
            UPDATE TA
            SET TA.IsApproved =0,
                TA.TransactionStatus = 'X',
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID

             UPDATE SPO_Customer
                SET 
                DocumentStatus = 'X'
                WHERE ID = @HeaderID
        END
        ELSE IF(@TransactionTypeID = 2) -- Discount Approval
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId');
            
            UPDATE TA
            SET TA.IsApproved =0,
                TA.TransactionStatus = 'X',
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID

             --UPDATE [dbo].[SPO_OrderHeader]
             --   SET IsDiscountApprove =0,
             --   DiscountStatus = 'X',
             --   IsDiscount =0
             --   WHERE OrderId = @HeaderID
             UPDATE [dbo].[SPO_OrderDetails]
                SET DiscountStatus    = 'X',
                    IsDiscountApprove = 0
                WHERE OrderId = @HeaderID
        END
        ELSE IF(@TransactionTypeID = 4) -- Order Cancelation Approval
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId');
            
            UPDATE TA
            SET TA.IsApproved =0,
                TA.TransactionStatus = 'X',
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID

             UPDATE [dbo].[SPO_OrderHeader]
                SET IsOrderCancel =0,
                OrderCancelStatus = 'X',
                DocumentChargesPercentage = 0,
                RefundAmount = 0
                WHERE OrderId = @HeaderID
        END
        ELSE IF(@TransactionTypeID = 5) -- Order Approval
        BEGIN
            SELECT  @HeaderID = JSON_VALUE(@headerData, '$.OrderId');
            
            UPDATE TA
            SET TA.IsApproved =0,
                TA.TransactionStatus = 'X',
                TA.LastModifiedUserID = @UserID,
                TA.LastModifiedDate = GETDATE()
            FROM
            [dbo].[SPO_TransactionApprovalLog] TA
            WHERE TA.TransactionTypeID = @TransactionID
            AND TA.TransactionHeaderID = @HeaderID

             UPDATE [dbo].[SPO_OrderHeader]
                SET IsApprove =0,
                Status = 'X'
                WHERE OrderId = @HeaderID
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

