/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON10/23/2017 10:03:29 AM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/
CREATE PROCEDURE[dbo].[SP_Save_UserGroups]
 --DECLARE PARAMETERS

	@Id int,
	@UserGroupName nvarchar(50),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@PropertyID int,
	@message NVARCHAR(max) OUTPUT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

		IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			--RAISERROR('User ID Invalid, Please Log In Again',16,1) --commented by Nivesh 2024-02-14
			RAISERROR('User ID Invalid, Please Provide Correct User ID',16,1) --added by Nivesh 2024-02-14
			ROLLBACK TRANSACTION
		END
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM UserGroups WHERE  [Id] = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE UserGroups SET
		[UserGroupName] = @UserGroupName,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		[PropertyID] =@PropertyID
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO UserGroups(
		[UserGroupName],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[PropertyID]
		)
		VALUES
		(
		@UserGroupName,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@PropertyID
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [UserGroups] WHERE [Id] = @Id
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
	ROLLBACK TRANSACTION
	DECLARE @MessageSQL NVARCHAR(100)
	SET @MessageSQL = N'Error Occured: ' + ERROR_MESSAGE() 

	RAISERROR(@MessageSQL,16,1)
END CATCH
END--SP ENDS

GO

