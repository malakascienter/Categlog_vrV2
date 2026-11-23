CREATE PROCEDURE[dbo].[SP_Save_SubContractors]
 --DECLARE PARAMETERS

	@ID int,
	@PropertyID int,
	@Code nvarchar(10),
	@Name nvarchar(100),
	@Address1 nvarchar(100),
	@BillingAddress nvarchar(100),
	@Email nvarchar(255),
	@Telephone1 nvarchar(15),
	@Telephone2 nvarchar(15),
	@FaxNo nvarchar(15),
	@ContactPerson nvarchar(50),
	@CountryID int,
	@Remarks nvarchar(max),
	@CreditLimit decimal(18, 2),
	@CreditPeriod real,
	@PaymentTermID int,
	@CurrencyID int,
	@NameOnCheque nvarchar(max),
	@SupplierGradingID int,
	@IsDefaultSupplier bit,
	@IsActive bit,
	@IsLabor bit,
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
		IF EXISTS(SELECT* FROM SubContractors WHERE  [ID] = @ID)
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'SubContractors', @ID, 'INV', 'SBCU', 'U', @LastModUserID,@PropertyID, '', ''
		EXEC InsertMasterFileChangeLog 'Subcontractors',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE SubContractors SET
		[PropertyID] = @PropertyID,
		[Code] = @Code,
		[Name] = UPPER(@Name),
		[Address1] =  UPPER(@Address1),
		[BillingAddress] =  UPPER(@BillingAddress),
		[Email] =  UPPER(@Email),
		[Telephone1] = @Telephone1,
		[Telephone2] = @Telephone2,
		[FaxNo] = @FaxNo,
		[ContactPerson] =  UPPER(@ContactPerson),
		[CountryID] = @CountryID,
		[Remarks] =  UPPER(@Remarks),
		[CreditLimit] = @CreditLimit,
		[CreditPeriod] = @CreditPeriod,
		[PaymentTermID] = @PaymentTermID,
		[CurrencyID] = @CurrencyID,
		[NameOnCheque] = UPPER(@NameOnCheque),
		[SupplierGradingID] = @SupplierGradingID,
		[IsDefaultSupplier] = @IsDefaultSupplier,
		[IsActive] = @IsActive,
		[IsLabor] = @IsLabor,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [ID] = @ID
		SET @statusIN = 2

					----newly added 07.02.2024 
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
	EXEC InsertMasterFileChangeLog 'Subcontractors',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO SubContractors(
		[PropertyID],
		[Code],
		[Name],
		[Address1],
		[BillingAddress],
		[Email],
		[Telephone1],
		[Telephone2],
		[FaxNo],
		[ContactPerson],
		[CountryID],
		[Remarks],
		[CreditLimit],
		[CreditPeriod],
		[PaymentTermID],
		[CurrencyID],
		[NameOnCheque],
		[SupplierGradingID],
		[IsDefaultSupplier],
		[IsActive],
		[IsLabor],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@PropertyID,
		@Code,
		 UPPER(@Name),
		 UPPER(@Address1),
		 UPPER(@BillingAddress),
		 UPPER(@Email),
		@Telephone1,
		@Telephone2,
		@FaxNo,
		 UPPER(@ContactPerson),
		@CountryID,
		 UPPER(@Remarks),
		@CreditLimit,
		@CreditPeriod,
		@PaymentTermID,
		@CurrencyID,
		UPPER(@NameOnCheque),
		@SupplierGradingID,
		@IsDefaultSupplier,
		@IsActive,
		@IsLabor,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'SubContractors', @NewId, 'INV', 'SBCI', 'I', @CreatedUserID,@PropertyID, '', ''
	END

			----newly added 07.02.2024 
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
		DELETE [Suppliers] WHERE [ID] = @ID
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
SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

