
CREATE PROCEDURE [dbo].[SP_Save_TransactionWiseApprovalTypes] 
	@TrahnsactionId INT,
	@PropertyId INT,
	@locationId INT,
	@ApprovalTypeId INT,
	@SeqId INT
	
AS

DECLARE @newid INT 


BEGIN
IF EXISTS (SELECT * FROM TransactionWiseApprovalTypes
            WHERE TransactionID = @TrahnsactionId AND PropertyID = @PropertyId 
			AND LocationID =@locationId 
			AND ApprovalTypeID =@ApprovalTypeId
			AND SeqID = @SeqId)
BEGIN
	  RAISERROR ('already exists.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
			   RETURN 
END
	INSERT dbo.TransactionWiseApprovalTypes
	        ( TransactionApprovalID ,
	          TransactionID ,
	          PropertyID ,
	          LocationID ,
	          ApprovalTypeID ,
	          SeqID ,
	          IPAddress ,
	          CreatedUserID ,
	          LastModUserID ,
	          CreatedDate ,
	          LastModDate
	        )
	VALUES  (  0,
				@TrahnsactionId,
				@PropertyId,
				@locationId,
				@ApprovalTypeId,
				@SeqId,
				'',
				1,
				1,
				GETDATE(),
				GETDATE()
	        )
	SET @newid = SCOPE_IDENTITY()

	UPDATE TransactionWiseApprovalTypes SET TransactionApprovalID = @newid WHERE Id = @newid
    

END

GO

