CREATE PROCEDURE [dbo].[SP_Insert_TransactionWiseApprovalType] 
	
	@TransactionApprovalID int,
	@TransactionID					INT,
	@PropertyID				INT,
	@LocationID				int,
	@ApprovalTypeID			int,
	@SeqID					int,
	@CreatedUserID				INT,
	@LastModUserID				INT,
	@Operation					CHAR(1)		
	
AS
BEGIN

	SET NOCOUNT ON;

	IF @Operation = 'I'
	BEGIN
	

		INSERT INTO dbo.TransactionWiseApprovalTypes		        ( 
			TransactionApprovalID,
		          TransactionID ,
		          PropertyID ,
		          LocationID ,
		          ApprovalTypeID ,
		          SeqID ,
		          CreatedUserID ,
		          LastModUserID ,
		          CreatedDate ,
		          LastModDate
		        )
		
		VALUES
		(@TransactionApprovalID,
			@TransactionID,
			@PropertyID,
			@LocationID,
			@ApprovalTypeID,
			@SeqID,
			@CreatedUserID,
			@LastModUserID,
			GETDATE(),
			GETDATE()
		)

		SELECT @TransactionApprovalID = SCOPE_IDENTITY();

		UPDATE dbo.TransactionWiseApprovalTypes
		SET TransactionApprovalID = @TransactionApprovalID
		WHERE Id = @TransactionApprovalID

	END
			
	ELSE 
	BEGIN
	
		UPDATE dbo.TransactionWiseApprovalTypes
		SET

			SeqID=@SeqID,
			LastModDate					=	GETDATE(),
			LastModUserID				=	@LastModUserID
			WHERE Id	=	@TransactionApprovalID
	
	END
    
END

GO

