CREATE PROCEDURE [dbo].[SP_Save_UserWiseApproveLevels]
	@companyId INT,
	@LocationID INT,
	@transactionTypeId INT,
	@ApprovalTypeId INT,
	@UserID INT
AS
BEGIN

	IF EXISTS (SELECT * FROM dbo.UserWiseApproveLevels WHERE TransactionTypeID=@transactionTypeId AND ApproveLevelID=@ApprovalTypeId AND UserProfileId=@UserID AND propertyid=@companyId AND LocationId=@LocationID)
	BEGIN
	 RAISERROR ('Already Exists.', -- Message text.
               16, -- Severity.
               1 -- State.
               );

	RETURN 
	END
	INSERT dbo.UserWiseApproveLevels
	        ( PropertyId ,
	          LocationId ,
	          TransactionTypeID ,
	          ApproveLevelID ,
	          UserProfileId ,
	          CreatedDate ,
	          CreatedUser ,
	          ModifiedUser ,
	          ModifiedDate ,
	          IPAddress ,
	          CreatedUserID ,
	          LastModUserID ,
	          LastModDate
	        )
	VALUES  ( @companyId,@LocationID,@transactionTypeId,@ApprovalTypeId,@UserID,GETDATE(), 1, 1, GETDATE(), '', 1,1,GETDATE()
	        )
     
END

GO

