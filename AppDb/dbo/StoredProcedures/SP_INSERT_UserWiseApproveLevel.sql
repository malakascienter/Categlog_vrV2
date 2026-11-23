CREATE PROCEDURE [dbo].[SP_INSERT_UserWiseApproveLevel] 
	-- Add the parameters for the stored procedure here
	@PropertyId INT, 
	@LocationId INT,
	@TransactionTypeID INT, 
	@ApproveLevelID INT, 
	@UserProfileId INT,
	@User INT
AS
BEGIN

	SET NOCOUNT ON;
	INSERT INTO dbo.UserWiseApproveLevels
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
	VALUES  ( @PropertyId, -- PropertyId - int
	          @LocationId , -- LocationId - int
	          @TransactionTypeID , -- TransactionTypeID - int
	          @ApproveLevelID , -- ApproveLevelID - int
	          @UserProfileId , -- UserProfileId - int
	          GETDATE() , -- CreatedDate - datetime
	          @User , -- CreatedUser - int
	          @User , -- ModifiedUser - int
	          GETDATE() , -- ModifiedDate - datetime
	          N'' , -- IPAddress - nvarchar(max)
	          @User, -- CreatedUserID - int
	          @User , -- LastModUserID - int
	          GETDATE()  -- LastModDate - datetime
	        )
	

END

GO

