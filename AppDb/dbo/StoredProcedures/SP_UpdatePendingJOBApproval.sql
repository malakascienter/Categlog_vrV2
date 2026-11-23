--SP_UpdatePendingJOBApproval
CREATE PROCEDURE [dbo].[SP_UpdatePendingJOBApproval]
	@XMLDetails XML,
	@IsApprove BIT = 1 
AS
BEGIN
	DECLARE @iDocID INT 

DECLARE   @RequestTransactionTypeID INT
		, @ApprovedDate DATETIME
		, @UserProfileID BIGINT
		, @RequestHeaderID BIGINT
		, @ApprovalLevelID INT 
      


EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

SELECT  @RequestTransactionTypeID = RequestTransactionTypeID
      , @ApprovedDate             = ApprovedDate 
	  , @UserProfileID            = UserProfileID 
	  , @RequestHeaderID          = RequestHeaderID 
	  , @ApprovalLevelID		  = ApprovalLevelID 
FROM     OPENXML (@iDocID,'/JOBApproved',2)
WITH (RequestTransactionTypeID int,ApprovedDate datetime,UserProfileID bigint, RequestHeaderID bigint,ApprovalLevelID int)



IF(@IsApprove = 1) --Approve JOB
BEGIN


		UPDATE dbo.ApprovalLogs 
		SET   IsComplete = 1
			, ApprovalUserid = @UserProfileID
			, docStatus ='C'
		WHERE TransactionID = @RequestTransactionTypeID 
		AND TransactionHeaderID = @RequestHeaderID 
		AND ApprovalLevelID = @ApprovalLevelID

		DECLARE  @PropertyID INT
				,@LocationID INT
				,@TransactionID INT
				,@TransactionHeaderID BIGINT

		SELECT   @PropertyID = PropertyID
				,@LocationID = LocationID
				,@TransactionID=TransactionID,@TransactionHeaderID=TransactionHeaderID
		from dbo.ApprovalLogs
		where TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID
		
		DECLARE @CUNT INT 
			SET @CUNT = (SELECT COUNT(*) 
						 FROM dbo.ApprovalLogs 
						 WHERE PropertyID= @PropertyID 
						 AND LocationID=@LocationID 
						 AND TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
						 AND DocStatus <> 'C')
			PRINT @PropertyID
					PRINT @LocationID
					PRINT @TransactionHeaderID
			IF (@CUNT = 0)
			BEGIN
				IF @TransactionID = 57  
				BEGIN
					UPDATE  dbo.JobHeaders
					SET   Approved     = 1 
						, Status ='P'
					WHERE ID = @TransactionHeaderID 
				END

				ELSE
				BEGIN
					UPDATE  dbo.RequestHeaders
					SET   isApproved = 1 
						, DocumentStatus ='P'
					WHERE Id = @TransactionHeaderID 
					AND RequestType =(SELECT Code FROM TransactionTypes WHERE Id= @TransactionID )

					DECLARE @ApprovLevels INT = 0	
					SET @ApprovLevels =  (SELECT  COUNT(*) 
										  FROM dbo.ApprovalLogs 
										  WHERE PropertyID = @PropertyID 
										  AND LocationID = @LocationID  
										  AND TransactionID =@TransactionID)

					IF(@ApprovLevels = 0)
					BEGIN
			
						DECLARE @ApprovedQuantity INT
						SELECT  @ApprovedQuantity = dbo.RequestDetails.RequestedQuantity 
						FROM dbo.RequestDetails 
						WHERE  RequestHeaderID = @TransactionHeaderID

						UPDATE dbo.RequestDetails
						SET ApprovedQuantity = @ApprovedQuantity ,IssuedQuantity = 0
						WHERE  RequestHeaderID = @TransactionHeaderID

					END
		
	
	
				END

			end 
			else if (select COUNT(*) from ApprovalLogs
				where PropertyID=@PropertyID and LocationID=@LocationID 
				and TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
				and DocStatus ='X')>0
			begin

				if @TransactionID=57
				begin
					Update  dbo.JobHeaders
					set Approved=0 , Status ='X'
					WHERE ID = @TransactionHeaderID 
				END
			
				else
				begin
		
					Update  dbo.RequestHeaders
					set isApproved=0 , DocumentStatus ='X'
					where Id = @TransactionHeaderID and RequestType = (select Code from TransactionTypes where Id= @TransactionID )
		
				end

			end 
		--EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID		
END
ELSE  -- Reject JOB
BEGIN
		Update  dbo.JobHeaders
		SET Approved = 0 , Status ='X'
		WHERE Id = @RequestHeaderID 
		
		UPDATE dbo.ApprovalLogs 
		SET   IsComplete = 1
			, ApprovalUserid = @UserProfileID
			, docStatus ='X'
		WHERE TransactionID = @RequestTransactionTypeID 
		AND TransactionHeaderID = @RequestHeaderID 
		AND ApprovalLevelID = @ApprovalLevelID



END

END

GO

