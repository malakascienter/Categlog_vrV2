-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-08
-- Modified by		: Nivesh
-- Modified date	: 2025-12-19
-- Description:	Insert Transaction Approval log
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_InsertTransactionApprovalLog] 
	@JsonDetail NVARCHAR(MAX)
AS
BEGIN

	BEGIN TRY 
	BEGIN TRAN
		DECLARE @spParam NVARCHAR(MAX) = JSON_QUERY(@JsonDetail, '$.spParam');;
		DECLARE @TransactionID INT = JSON_VALUE(@JsonDetail, '$.TransactionTypeID');
		DECLARE @TransactionHeadereID INT = JSON_VALUE(@JsonDetail, '$.TransactionHeadereID');
		DECLARE @UserID INT,@PropertyID INT, @LocationID VARCHAR(5)

		IF(@TransactionID =1 ) -- Customer Approval
		BEGIN
			SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID');

			INSERT INTO [dbo].[SPO_TransactionApprovalLog]
			   ([TransactionTypeID]
			   ,[TransactionHeaderID]
			   ,[UserProfileID]
			   ,[IsApproved]
			   ,[TransactionStatus]
			   ,[CreatedUserID]
			   ,[LastModifiedUserID]
			   ,[CreatedDate]
			   ,[LastModifiedDate]
			   ,[LocationID]
		   )
			SELECT 
				@TransactionID,
				@TransactionHeadereID,
				UserProfileId,
				0,
				'P',
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				0
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID

			--not existing approval--
			IF NOT EXISTS(SELECT 
				1
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			)
			BEGIN
				UPDATE [dbo].[SPO_Customer]
				SET 
                DocumentStatus = 'C'
                WHERE ID = @TransactionHeadereID
			END
			-------------------------
		END
		IF(@TransactionID =3 ) -- Discount Approval
		BEGIN
			SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID'),
			@LocationID = JSON_VALUE(@spParam, '$.LocationID');

			INSERT INTO [dbo].[SPO_TransactionApprovalLog]
			   ([TransactionTypeID]
			   ,[TransactionHeaderID]
			   ,[UserProfileID]
			   ,[IsApproved]
			   ,[TransactionStatus]
			   ,[CreatedUserID]
			   ,[LastModifiedUserID]
			   ,[CreatedDate]
			   ,[LastModifiedDate]
			   ,[LocationID]
		   )
			SELECT 
				@TransactionID,
				@TransactionHeadereID,
				UserProfileId,
				0,
				'P',
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				@LocationID
			FROM [dbo].[SPO_UserWiseApproveLevels]

			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID

			--not existing approval--
			IF NOT EXISTS(SELECT 
				1
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID
			)
			BEGIN
				UPDATE [dbo].[SPO_OrderDetails]
                SET IsDiscountApprove =1,
                DiscountStatus = 'C'
                WHERE OrderId = @TransactionHeadereID
				AND IsDiscount = 1;
			END
			-------------------------
		END
		IF(@TransactionID =4 ) -- Order Cancelation
		BEGIN
			SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID'),
			@LocationID = JSON_VALUE(@spParam, '$.LocationID');

			INSERT INTO [dbo].[SPO_TransactionApprovalLog]
			   ([TransactionTypeID]
			   ,[TransactionHeaderID]
			   ,[UserProfileID]
			   ,[IsApproved]
			   ,[TransactionStatus]
			   ,[CreatedUserID]
			   ,[LastModifiedUserID]
			   ,[CreatedDate]
			   ,[LastModifiedDate]
			   ,[LocationID]
		   )
			SELECT 
				@TransactionID,
				@TransactionHeadereID,
				UserProfileId,
				0,
				'P',
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				@LocationID
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID

			----not existing approval--
			--IF NOT EXISTS(SELECT 
			--	1
			--FROM [dbo].[SPO_UserWiseApproveLevels]
			--WHERE PropertyId = @PropertyID
			--AND TransactionTypeID = @TransactionID
			--AND LocationId = @LocationID
			--)
			--BEGIN
			--	UPDATE [dbo].[SPO_OrderHeader]
   --             SET i =1,
   --             DiscountStatus = 'C'
   --             WHERE OrderId = @TransactionHeadereID
			--END
			---------------------------
		END
		IF(@TransactionID =5 ) -- Order Cancelation Approval
		BEGIN
			SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID'),
			@LocationID = JSON_VALUE(@spParam, '$.LocationID');

			INSERT INTO [dbo].[SPO_TransactionApprovalLog]
			   ([TransactionTypeID]
			   ,[TransactionHeaderID]
			   ,[UserProfileID]
			   ,[IsApproved]
			   ,[TransactionStatus]
			   ,[CreatedUserID]
			   ,[LastModifiedUserID]
			   ,[CreatedDate]
			   ,[LastModifiedDate]
			   ,[LocationID]
		   )
			SELECT 
				@TransactionID,
				@TransactionHeadereID,
				UserProfileId,
				0,
				'P',
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				@LocationID
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID

			----not existing approval--
			--IF NOT EXISTS(SELECT 
			--	1
			--FROM [dbo].[SPO_UserWiseApproveLevels]
			--WHERE PropertyId = @PropertyID
			--AND TransactionTypeID = @TransactionID
			--AND LocationId = @LocationID
			--)
			--BEGIN
			--	UPDATE [dbo].[SPO_OrderHeader]
   --             SET i =1,
   --             DiscountStatus = 'C'
   --             WHERE OrderId = @TransactionHeadereID
			--END
			---------------------------
		END
		IF(@TransactionID =2 ) -- Order Approval
		BEGIN
			SELECT
            @UserID     = JSON_VALUE(@spParam, '$.UserID'),
            @PropertyID = JSON_VALUE(@spParam, '$.PropertyID'),
			@LocationID = JSON_VALUE(@spParam, '$.LocationID');

			INSERT INTO [dbo].[SPO_TransactionApprovalLog]
			   ([TransactionTypeID]
			   ,[TransactionHeaderID]
			   ,[UserProfileID]
			   ,[IsApproved]
			   ,[TransactionStatus]
			   ,[CreatedUserID]
			   ,[LastModifiedUserID]
			   ,[CreatedDate]
			   ,[LastModifiedDate]
			   ,[LocationID]
		   )
			SELECT 
				@TransactionID,
				@TransactionHeadereID,
				UserProfileId,
				0,
				'P',
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				@LocationID
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID

			----not existing approval--
			IF NOT EXISTS(SELECT 
				1
			FROM [dbo].[SPO_UserWiseApproveLevels]
			WHERE PropertyId = @PropertyID
			AND TransactionTypeID = @TransactionID
			AND LocationId = @LocationID
			)
			BEGIN
				UPDATE [dbo].[SPO_OrderHeader]
                SET IsApprove =1,
                Status = 'C'
                WHERE OrderId = @TransactionHeadereID

				IF EXISTS (
                SELECT 1 FROM [dbo].[SPO_OrderHeader]
                WHERE OrderId = @TransactionHeadereID
                  AND Status  = 'C'
                )
               BEGIN
                EXEC [dbo].[SPO_MakeRequestForThisOrder]
                    @OrderId       = @TransactionHeadereID,
                    @UserProfileID = @UserID;
               END
			END
			---------------------------
		END
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

