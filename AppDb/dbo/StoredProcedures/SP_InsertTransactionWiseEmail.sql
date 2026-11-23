-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-16
-- Description:	Insert Transaction Wise Email 
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertTransactionWiseEmail] 
	@XMLDetails AS XML
AS
	 DECLARE @iDocID INT 
 BEGIN
 BEGIN TRY
         BEGIN TRANSACTION
		  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		  CREATE TABLE #TEMPH (
		   PropertyID INT,
		   LocationID INT,
		   TransactionTypeID INT,
		   UserID  INT,
		   IsActive BIT
		  )
		 
				INSERT INTO #TEMPH 
				SELECT *
				FROM    OPENXML (@iDocID,'TransactionWiseEmail',2)	
				WITH ( 
				PropertyID INT,
				LocationID INT,
				TransactionTypeID INT,
				UserID  INT,
				IsActive BIT
				)
		DECLARE @PropertyID INT= NULL, @LocationID INT = NULL, @TransactionTypeID INT = NULL, @UserID INT = NULL

		IF EXISTS (SELECT 1 FROM #TEMPH)
		BEGIN
			SELECT TOP 1 @PropertyID = PropertyID,@LocationID= LocationID ,@TransactionTypeID= TransactionTypeID,@UserID= UserID FROM #TEMPH
		END
		ELSE
		BEGIN
			RAISERROR('Not exists',16,1)
			ROLLBACK TRANSACTION
		END

		IF(@PropertyID IS NULL OR @PropertyID =0)
		BEGIN
			RAISERROR('Property Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@LocationID IS NULL )
		BEGIN
			RAISERROR('Location Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@TransactionTypeID IS NULL )
		BEGIN
			RAISERROR('Transaction Type Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@UserID IS NULL )
		BEGIN
			RAISERROR('User Invalid',16,1)
			ROLLBACK TRANSACTION
		END

		DECLARE @TransactionType CHAR(4)
		SELECT TOP 1 @TransactionType= Code FROM TransactionTypes WHERE Id= @TransactionTypeID
		
		IF EXISTS(SELECT 1 FROM TransactionWiseEmails WHERE PropertyID = @PropertyID AND LocationID = @LocationID AND TransactionType = @TransactionType AND UserID = @UserID )
		BEGIN
			RAISERROR('Record exists',16,1)
			ROLLBACK TRANSACTION
		END
				INSERT INTO dbo.TransactionWiseEmails
				(
				    [PropertyID]
					,[LocationID]
					,[TransactionType]
					,[UserID]
					,[IsActive]
				)
				SELECT 
				[PropertyID]
				  ,[LocationID]
				  ,(SELECT TOP 1 Code FROM TransactionTypes WHERE Id= TransactionTypeID )TransactionType
				  ,[UserID]
				  ,1 FROM #TEMPH
								
				IF NOT EXISTS(SELECT 1 FROM TransactionTypes WHERE Id = @TransactionTypeID AND IsMailNotification =1)
				BEGIN
					UPDATE TransactionTypes
					SET IsMailNotification = 1
					WHERE Id = @TransactionTypeID
				END


		  COMMIT TRANSACTION
 END TRY
 BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN --RollBack in case of Error
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
 END CATCH 



END

GO

