/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON9/28/2017 11:14:20 AM
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
CREATE PROCEDURE[dbo].[SP_Save_Employee]
 --DECLARE PARAMETERS

	@Id int,
	@CompanyID int,
	@LocationID INT,
	@DepartmentID INT,
	@Code nvarchar(max),
	@Title NVARCHAR(max),
	@Name nvarchar(max),
	@Designation nvarchar(max),
	@Gender NVARCHAR(MAX),
	@Remark NVARCHAR(max),
	@Address1 NVARCHAR(max),
	@Address2 NVARCHAR(max),
	@Address3 NVARCHAR(max),
	@Email NVARCHAR(max),
	@Telephone NVARCHAR(max),
	@Mobile NVARCHAR(max),
	@Image VARBINARY(MAX),	
	@IsActive bit,
	@MinimumDiscount DECIMAL,
	@CrLimit DECIMAL,
	@PchLimit DECIMAL,
	@AccCredit DECIMAL,
	@AccPch DECIMAL,
	@IsDelete BIT,
	@CostCenterID INT,
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
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM Employees WHERE  [Id] = @Id)
		BEGIN
		--EXEC InsertMasterFileChangeLog 'Employees',@CreatedUserID,'U',@Name
		EXEC Inventry_AuditTail_WriteToLog 'Employees', @Id, 'INV', 'EMU', 'U', @LastModUserID,@CompanyID, '', ''
		 --UPDATE THE RECORD
		 UPDATE dbo.Employees SET
		[LocationID] = @LocationID,
		[Name] = UPPER(@Name),
		[DepartmentID] = @DepartmentID,
		[Code] = @Code,
		[Title] = UPPER(@Title),
		[Designation] = UPPER(@Designation),
		[Gender] = UPPER(@Gender),
		[Remark] = UPPER(@Remark),
		[Address1] = @Address1,
		[Address2] = @Address2,
		[Address3] = @Address3,
		[Email] = @Email,
		[Telephone] = @Telephone,
		[Mobile] = @Mobile,
		[Image] = @Image,
		[MinimumDiscount] = @MinimumDiscount,
		[CrLimit] = @CrLimit,
		[PchLimit] = @PchLimit,
		[AccCredit] = @AccCredit,
		[AccPch] = @AccPch,
		[IsDelete] = @IsDelete,
		[CostCenterID] = @CostCenterID,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2

					----newly added 06.02.2024 
			IF(@LastModUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------

	END


	ELSE
	BEGIN
	--INSERT THE RECORD
	EXEC InsertMasterFileChangeLog 'Employees',@CreatedUserID,'I',@Name
	INSERT INTO dbo.Employees
	        ( CompanyID ,
	          LocationID ,
	          DepartmentID ,
	          Code ,
	          Title ,
	          Name ,
	          Designation ,
	          Gender ,
	          Remark ,
	          Address1 ,
	          Address2 ,
	          Address3 ,
	          Email ,
	          Telephone ,
	          Mobile ,
	          Image ,
	          IsActive ,
	          MinimumDiscount ,
	          CrLimit ,
	          PchLimit ,
	          AccCredit ,
	          AccPch ,
	          IsDelete ,
	          CostCenterID ,
	          IPAddress ,
	          CreatedUserID ,
	          LastModUserID ,
	          CreatedDate ,
	          LastModDate
	        )
	VALUES  (
		@CompanyID,
		@LocationID,
		@DepartmentID,
		@Code,
		UPPER(@Title),
		UPPER(@Name),
		UPPER(@Designation),
		UPPER(@Gender),
		UPPER(@Remark),
		@Address1,
		@Address2,
		@Address3,
		@Email,
		@Telephone,
		@Mobile,
		@Image,	
		@IsActive,
		@MinimumDiscount,
		@CrLimit,
		@PchLimit,
		@AccCredit,
		@AccPch,
		@IsDelete,
		@CostCenterID,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;

		EXEC Inventry_AuditTail_WriteToLog 'Employees', @NewId, 'INV', 'EMI', 'I', @CreatedUserID,@CompanyID, '', ''
	END


---------------newly added 30.01.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
	EXEC Inventry_AuditTail_WriteToLog 'Employees', @Id, 'INV', 'EMD', 'D', @CreatedUserID,@CompanyID, '', ''
		DELETE [Employees] WHERE [Id] = @Id
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
	--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	SET @Message = 'Error Occured: ' + ERROR_MESSAGE() SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

