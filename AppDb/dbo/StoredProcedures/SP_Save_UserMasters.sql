
--[dbo].[SP_Save_UserMasters]5,0,0,0,0,0,444,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0
CREATE PROCEDURE[dbo].[SP_Save_UserMasters]
 --DECLARE PARAMETERS

	@UserMasterID int,
	@CompanyID int,
	@LocationID int,
	@UserName nvarchar(max),
	@UserDescription nvarchar(max),
	@Password nvarchar(max),
	@currentPassword nvarchar(max),
	@UserGroupID int,
	@IsActive bit,
	@IsUserCantChangePassword bit,
	@IsUserMustChangePassword bit,
	@IsDelete bit,
	@EmployeeId int,
	@FirstName nvarchar(max),
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY

	BEGIN TRANSACTION

	--SELECT @UserMasterID UserMasterID, @currentPassword Pssword INTO AAdata
	--SELECT * FROM AAdata
	--DROP TABLE AAdata

IF @Action =3
		BEGIN
			IF EXISTS(SELECT* FROM UserMasters WHERE  Id = @UserMasterID AND [Password]=@currentPassword)
				BEGIN
				UPDATE UserMasters
				SET [Password]=@Password
				WHERE  Id = @UserMasterID 
			END
			ELSE
				BEGIN

					RAISERROR('Old password is incorrect!', 16,1);
				END
	END
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM UserMasters WHERE  [UserName] = @UserName)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE UserMasters SET
		[CompanyID] = @CompanyID,
		[LocationID] = @LocationID,
		[UserName] = @UserName,
		[UserDescription] = @UserDescription,
		[Password] = @Password,
		[UserGroupID] = @UserGroupID,
		[IsActive] = @IsActive,
		[IsUserCantChangePassword] = @IsUserCantChangePassword,
		[IsUserMustChangePassword] = @IsUserMustChangePassword,
		[IsDelete] = @IsDelete,
		[EmployeeId] = @EmployeeId,
		[FirstName]=@FirstName,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [Id] = @UserMasterID
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO UserMasters(
		[CompanyID],
		[LocationID],
		[UserName],
		[UserDescription],
		[Password],
		[UserGroupID],
		[IsActive],
		[IsUserCantChangePassword],
		[IsUserMustChangePassword],
		[IsDelete],
		[EmployeeId],
		[FirstName],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@CompanyID,
		@LocationID,
		@UserName,
		@UserDescription,
		@Password,
		@UserGroupID,
		@IsActive,
		@IsUserCantChangePassword,
		@IsUserMustChangePassword,
		@IsDelete,
		@EmployeeId,
		@FirstName,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [UserMasters] WHERE [Id] = @UserMasterID
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	SET @status = -1;
SET @message =  ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	RAISERROR (@message,  16,1 );  
END CATCH
END--SP ENDS

GO

